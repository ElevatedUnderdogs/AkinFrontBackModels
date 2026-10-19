//
//  AutomaticGreetCooldown.swift
//  AkinFrontBackModels
//
//  GOAL_LOOP20 Phase S-C, for
//  docs/GOAL_LOOP20--MAPMATES-TUTORIAL-NAVIGATION-COPY-AND-MEETUP-TRUTH.md.
//
//  When an automatic greet must NOT be created, as one pure function.
//
//  Scott, 2026-09-13: automatic greets need a default cool down and a way to set it manually,
//  because two compatible members standing near each other would otherwise be greeted over and
//  over, which is a hassle. The same reasoning covers every other moment an automatic greet
//  makes no sense, starting with either member already being in one.
//
//  WHY THIS LIVES IN THE SHARED MODELS PACKAGE and not on the server. The same reason
//  `VenueCooldownPolicy` gives in `VenueAwareness.swift`: the client renders the suppression
//  reason, and a client that cannot name the state would have to pattern match on prose. Here the
//  requirement is stronger, because a member is entitled to find out WHY a compatible person
//  nearby produced no introduction (item S-C14), and "parse this sentence" is not an answer.
//
//  WHY IT IS A SEPARATE TYPE from `VenueCooldownPolicy` rather than a case added to it. The two
//  cool different things. One decides whether a venue may be shown a partnership pitch; this one
//  decides whether two members may be introduced. A shared name would invite a future reader to
//  change one and break the other, and their durations have nothing to do with each other.
//
//  WHAT IS DELIBERATELY NOT HERE. The policy is pure: it takes a context and returns a verdict. It
//  performs no queries and reads no clock. Every fact it needs is passed in, so the whole rule set
//  is testable without a database and the same verdict can be computed on the client for an
//  explanation string. The server assembles the context; `S-C4-enforcement.md` names where.
//

import Foundation

// MARK: - Why an automatic greet was not created

/// The named reason an automatic greet was suppressed.
///
/// Named rather than a sentence, which is the one place this type deliberately improves on
/// `VenueCooldownPolicy`. That type's `suppressed(reason: String)` carries prose, so a client that
/// wants to do anything but print it has to match on words. Every case here is a value the client
/// can switch on, and `memberFacingReason` is derived FROM the case rather than being the case.
public enum AutomaticGreetSuppression: Equatable, Hashable, Sendable, Codable {

    /// The pair's cooldown from their last automatic greet has not elapsed.
    /// Carries the moment it does, so a caller can say when rather than only that.
    case pairCooldown(until: Date)

    /// This member has already had as many automatic greets as the cap allows in the window,
    /// from anybody. The crowded room rule.
    ///
    /// `isScanner` because it applies to BOTH members, as of GOAL_LOOP20 Phase S-G. It was checked
    /// on the scanner only, defended by a comment saying the cap protects the member being
    /// interrupted and the scanner is the one being interrupted. An automatic greet interrupts
    /// both: it is created for the pair and `triggerGreetForMultiple` notifies the candidate as
    /// much as the scanner, which is why the candidate is checked for reachability at all. So a
    /// member who had taken their three for the day could still be introduced any number of times
    /// by other people walking past them, which is the crowded room this rule is named for.
    case memberCapReached(isScanner: Bool, count: Int, cap: Int, until: Date)

    /// One of the two is already inside an active greet.
    case alreadyInAGreet(isScanner: Bool)

    /// This pair already has an automatic greet nobody has answered.
    case pendingGreetUnanswered

    /// This pair has already confirmed that they met, and until when that holds.
    ///
    /// GOAL_LOOP20 Phase S-I, row SW-SL-016. It used to carry nothing and report `clearsAt` nil,
    /// which said "somebody has to act" about a rule that is in fact a ninety day timer: `evaluate`
    /// only reaches it while `now` is inside `metCooldown` of the last greet. A member asking why
    /// got "you two have already met" and no date, for a state that does clear on its own.
    case alreadyMet(until: Date?)

    /// One of the two raised their own busy pause and it has not lapsed.
    case busy(isScanner: Bool, until: Date?)

    /// One of the two has the Auto greets switch off.
    ///
    /// `isScanner` distinguishes the two, and the distinction is the whole point of the case:
    /// before this loop the switch was read only for the CANDIDATE, so a member who had turned
    /// Auto greets off could still trigger a scan that created a greet for themselves.
    case automaticGreetsOff(isScanner: Bool)

    /// One of the two has hidden themselves from the nearby list.
    case hiddenFromNearby(isScanner: Bool)

    /// One has blocked the other, in either direction.
    ///
    /// Not a cooldown and never expires on a timer, which is why it carries no date.
    case blocked

    /// The other member cannot receive anything right now: no live socket and no usable push
    /// token, so the introduction would go nowhere.
    case unreachable

    /// One of the two has not verified their email address.
    case unverified(isScanner: Bool)

    /// The other member's profile photo carries a confirmed moderation flag.
    case moderationFlagged

    /// A third member holds a live freeze on the candidate: somebody else already claimed the
    /// next chance to greet them.
    case frozenByAnotherMember(until: Date?)

    /// The current local time falls outside the weekly availability the member saved.
    case outsideStatedAvailability(isScanner: Bool)

    /// There is nowhere to send the two of them.
    case noVenueBetweenThem

    /// Something about the OTHER member stops it, and what that is, is theirs.
    ///
    /// GOAL_LOOP20 Phase S-I, row SEC-004. The member facing surface answers any signed in member
    /// about any member id they can name, and nine of the rules above describe the candidate rather
    /// than the asker: that they are busy until a particular minute, that a moderator confirmed a
    /// flag against them, that somebody else holds a freeze on them. The server still evaluates and
    /// logs the real rule, and the scan still obeys it. This is the answer the asker gets instead.
    case unavailableToYou

    /// Whether the reason is one that clears on its own, and when.
    ///
    /// `nil` means it does not clear on a timer: somebody has to do something. Item S-C13 requires
    /// a skipped greet to say when the pair becomes eligible again, and a rule whose answer is
    /// "never, until a person acts" has to be able to say that rather than invent a date.
    public var clearsAt: Date? {
        switch self {
        case .pairCooldown(let until): return until
        case .alreadyMet(let until): return until
        case .memberCapReached(_, _, _, let until): return until
        case .busy(_, let until): return until
        case .frozenByAnotherMember(let until): return until
        case .alreadyInAGreet,
             .pendingGreetUnanswered,
             .automaticGreetsOff,
             .hiddenFromNearby,
             .blocked,
             .unreachable,
             .unverified,
             .moderationFlagged,
             .outsideStatedAvailability,
             .noVenueBetweenThem,
             .unavailableToYou:
            return nil
        }
    }

    /// A stable identifier for logs, metrics and tests, so a failing test names the rule that
    /// broke rather than a line number.
    ///
    /// Deliberately not derived from the case name by reflection: a rename would silently change
    /// every historical log line's key.
    public var ruleName: String {
        switch self {
        case .pairCooldown: return "pair_cooldown"
        case .memberCapReached: return "member_cap_reached"
        case .alreadyInAGreet: return "already_in_a_greet"
        case .pendingGreetUnanswered: return "pending_greet_unanswered"
        case .alreadyMet: return "already_met"
        case .busy: return "busy"
        case .automaticGreetsOff: return "automatic_greets_off"
        case .hiddenFromNearby: return "hidden_from_nearby"
        case .blocked: return "blocked"
        case .unreachable: return "unreachable"
        case .unverified: return "unverified"
        case .moderationFlagged: return "moderation_flagged"
        case .frozenByAnotherMember: return "frozen_by_another_member"
        case .outsideStatedAvailability: return "outside_stated_availability"
        case .noVenueBetweenThem: return "no_venue_between_them"
        case .unavailableToYou: return "unavailable_to_you"
        }
    }

    /// A date a member can read, with no time of day on it.
    ///
    /// The time is dropped deliberately: these sentences are about when a member may be introduced
    /// again, and a minute is a precision the rule does not have. `dateStyle: .medium` gives
    /// "13 Oct 2026" in English rather than "10/13/26", which cannot be misread as a day and month
    /// the other way round.
    ///
    /// NOT in the member's own locale, and the doc comment used to claim it was. These sentences
    /// are built where `memberFacingReason` is read, and the server reads it: `AutomaticGreetStatus`
    /// carries the finished string, so the formatter runs in the SERVER's locale and time zone.
    /// The claim is dropped rather than the behaviour changed, because the type already sends
    /// `clearsAt` alongside the sentence and a client that wants the member's own formatting has
    /// the date to do it with.
    private static func readable(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    /// One sentence a member would recognise, for item S-C14's surface.
    ///
    /// Written in the second person and about the member who is ASKING, which is why several cases
    /// carry `isScanner`: "You are in the middle of meeting somebody" and "The person we would
    /// introduce you to is already meeting somebody else" are the same rule and not the same
    /// sentence. No dash punctuation anywhere, per the project's copy rule.
    public var memberFacingReason: String {
        switch self {
        case .pairCooldown(let until):
            // The DATE, not "a while". The model holds it, the scan logs it, and a member told
            // "we wait a while" cannot tell a day from a month. GOAL_LOOP20 Phase S-I, rows
            // UFC-007 and UX-SL-006.
            return "You two were introduced recently. We can introduce you again after "
                + "\(Self.readable(until))."
        case .memberCapReached(let isScanner, let count, let cap, let until):
            guard isScanner else {
                // About the OTHER member, so it says as little as the rest of that family does.
                // `AutomaticGreetGate.redactedForTheAsker` collapses it further before it leaves
                // the server; this is the sentence the log keeps.
                return "The person we would introduce you to has had as many introductions as we "
                    + "send for now."
            }
            // COUNT, not the cap, and not "today".
            //
            // It printed the cap, so a member who received five when the cap is three was told
            // they had three, and `count` was bound to `_` and read nowhere in the file. And
            // "today" is a claim about the window, which `AUTOMATIC_GREET_MEMBER_CAP_WINDOW_SECONDS`
            // makes server tunable, so the sentence became false the first time anybody set it to
            // anything but a day. The moment it clears is carried by the case, so it is said
            // instead of guessed at.
            return "You have had \(count) automatic introductions, which is as many as we send "
                + "(\(cap)). We can introduce you to somebody again after \(Self.readable(until))."
        case .alreadyInAGreet(let isScanner):
            return isScanner
                ? "You are in the middle of meeting somebody."
                : "They are already meeting somebody else."
        case .pendingGreetUnanswered:
            return "We already introduced you and nobody has answered yet."
        case .alreadyMet(let until):
            guard let until else { return "You two have already met." }
            return "You two have already met. We can introduce you again after "
                + "\(Self.readable(until))."
        case .busy(let isScanner, _):
            return isScanner
                ? "You said you are busy right now."
                : "They said they are busy right now."
        case .automaticGreetsOff(let isScanner):
            return isScanner
                ? "Auto greets is off, so we are not introducing you to anybody."
                : "They have Auto greets off."
        case .hiddenFromNearby(let isScanner):
            return isScanner ? "You are hidden right now." : "They are hidden right now."
        case .blocked:
            return "One of you blocked the other."
        case .unreachable:
            return "They cannot receive an introduction right now."
        case .unverified(let isScanner):
            return isScanner
                ? "Your email address is not verified yet."
                : "Their account is not verified yet."
        case .moderationFlagged:
            return "That profile is under review."
        case .frozenByAnotherMember:
            return "Somebody else has the next chance to greet them."
        case .outsideStatedAvailability(let isScanner):
            return isScanner
                ? "This is outside the hours you said you are open to meeting."
                : "This is outside the hours they said they are open to meeting."
        case .unavailableToYou:
            // Deliberately says nothing about them. Row SEC-004: what stops it is theirs.
            return "We cannot introduce you to them right now."
        case .noVenueBetweenThem:
            return "There is nowhere between you two to meet."
        }
    }
}

// MARK: - Whether an automatic greet may be created

/// The whole answer the policy gives: create the greet, or do not and say which rule stopped it.
///
/// Two cases rather than a Bool and an optional reason, because the two states a Bool allows that
/// this does not, eligible WITH a reason and ineligible WITHOUT one, are both nonsense and both
/// representable in the Bool version.
public enum AutomaticGreetEligibility: Equatable, Sendable {

    /// Nothing stops it. The caller creates the greet.
    case eligible

    /// One rule stopped it, and it is the FIRST one `evaluate` reached rather than the only one
    /// that applies: the order is the order a member should be told about, so being blocked is
    /// reported as blocked and not as a cooldown that happens also to be running.
    case suppressed(AutomaticGreetSuppression)

    /// True when the greet may be created. The rule, when there is one, is `suppression`.
    public var isEligible: Bool {
        switch self {
        case .eligible: return true
        case .suppressed: return false
        }
    }

    /// The rule that stopped it, or nil when nothing did.
    public var suppression: AutomaticGreetSuppression? {
        switch self {
        case .eligible: return nil
        case .suppressed(let reason): return reason
        }
    }
}

// MARK: - How the pair's last automatic greet ended

/// The outcome of the pair's most recent automatic greet, which decides how long they wait.
///
/// `unknown` is not a failure state. It is the honest answer while a greet is still open or when
/// the events do not say, and it is what `AutomaticGreetCooldownPolicy.defaultCooldown` is for.
public enum AutomaticGreetOutcome: String, Codable, Sendable, Hashable, CaseIterable {

    /// Either member said no.
    case declined

    /// It timed out with at least one member never answering.
    case expiredUnanswered

    /// Somebody opted in and then left before they met.
    case endedEarly

    /// They confirmed they met.
    case met

    /// Still open, or the events do not say.
    case unknown
}

// MARK: - The facts the policy needs

/// Everything the policy reads, gathered by the caller.
///
/// One struct rather than fifteen arguments, and every field is a fact rather than a verdict, so
/// the policy owns every decision and the caller owns every query. A caller that computed
/// "shouldSuppressForBusy" and passed a Bool would be making the ruling and the policy would be
/// rubber stamping it.
///
/// Members are named `scanner` and `candidate` rather than `user` and `otherUser`. The scan is
/// triggered by whichever member moved, so "the user" is an arbitrary one of the two, and
/// `S-C1-suppression-conditions.md` found EIGHT conditions that were checked for one side and not
/// the other precisely because the old code called one of them "the user".
public struct AutomaticGreetContext: Equatable, Sendable {

    public struct Member: Equatable, Sendable {

        public let id: UUID
        public let automaticGreetsEnabled: Bool
        public let isHiddenFromNearby: Bool
        public let isEmailVerified: Bool
        /// Whether a notification could actually reach them: at least one device or PushKit
        /// token. An introduction nobody can be told about is not an introduction.
        public let isReachable: Bool

        /// Whether a MODERATOR has confirmed a flag against their profile. A flag another member
        /// raised and nobody has looked at does not count, which is why the name says confirmed.
        public let hasConfirmedModerationFlag: Bool

        /// The moment their own busy pause lapses, or nil when they are not paused. Set for both
        /// members when a greet ends, so somebody who has just agreed to meet is not offered a
        /// second meetup on the walk over.
        public let busyUntil: Date?

        /// Whether the moment falls inside the hours they said they are open to meeting. Their
        /// stated availability, not their observed activity: the app does not infer this.
        public let isWithinStatedAvailability: Bool

        /// How many automatic greets this member has received inside the cap's window, from
        /// anybody. The crowded room rule reads this.
        public let automaticGreetsInWindow: Int

        /// The cooldown this member chose for themselves, in seconds, or nil to use the policy
        /// default. Item S-C9 builds the control that sets it and item S-C10 persists it.
        public let chosenCooldownSeconds: TimeInterval?

        public init(
            id: UUID,
            automaticGreetsEnabled: Bool,
            isHiddenFromNearby: Bool,
            isEmailVerified: Bool,
            isReachable: Bool,
            hasConfirmedModerationFlag: Bool,
            busyUntil: Date?,
            isWithinStatedAvailability: Bool,
            automaticGreetsInWindow: Int,
            chosenCooldownSeconds: TimeInterval?
        ) {
            self.id = id
            self.automaticGreetsEnabled = automaticGreetsEnabled
            self.isHiddenFromNearby = isHiddenFromNearby
            self.isEmailVerified = isEmailVerified
            self.isReachable = isReachable
            self.hasConfirmedModerationFlag = hasConfirmedModerationFlag
            self.busyUntil = busyUntil
            self.isWithinStatedAvailability = isWithinStatedAvailability
            self.automaticGreetsInWindow = automaticGreetsInWindow
            self.chosenCooldownSeconds = chosenCooldownSeconds
        }

        /// The same member with their automatic greet count filled in.
        ///
        /// A `Member` is built from a user record and a count needs a database, so the two are
        /// separate steps and this is the second one. GOAL_LOOP20 Phase S-G: it exists for both
        /// members now, where the count used to be gathered for the scanner alone.
        public func withVolume(_ count: Int) -> Member {
            Member(
                id: id,
                automaticGreetsEnabled: automaticGreetsEnabled,
                isHiddenFromNearby: isHiddenFromNearby,
                isEmailVerified: isEmailVerified,
                isReachable: isReachable,
                hasConfirmedModerationFlag: hasConfirmedModerationFlag,
                busyUntil: busyUntil,
                isWithinStatedAvailability: isWithinStatedAvailability,
                automaticGreetsInWindow: count,
                chosenCooldownSeconds: chosenCooldownSeconds
            )
        }
    }

    public let scanner: Member
    public let candidate: Member

    /// Whether each member is inside an active greet with anybody.
    public let scannerIsInAGreet: Bool
    public let candidateIsInAGreet: Bool

    /// Whether either has blocked the other, in either direction.
    public let isBlockedEitherWay: Bool

    /// When this pair's last automatic greet was created, or nil if they have never had one.
    public let lastAutomaticGreetAt: Date?

    /// How that greet ended.
    public let lastAutomaticGreetOutcome: AutomaticGreetOutcome

    /// Whether this pair has an automatic greet that is still open and unanswered.
    public let hasPendingUnansweredGreet: Bool

    /// When the OLDEST automatic greet inside the cap's window was created for the scanner, or
    /// nil when there are none. The cap clears one window after that one, not one window from now.
    public let scannerOldestGreetInWindowAt: Date?

    /// The same for the CANDIDATE, so their cap clears one window after their own oldest greet
    /// rather than one window from now. Nil when they have none, or when a caller does not gather
    /// it, in which case the cap still fires and the date it reports is `now` plus a window.
    public let candidateOldestGreetInWindowAt: Date?

    /// When a freeze another member holds on the candidate lapses, or nil when there is none.
    public let candidateFrozenUntil: Date?

    /// Whether a venue exists between the two of them.
    public let hasVenueBetweenThem: Bool

    /// The moment being tested.
    public let now: Date

    /// The cap and its window, passed in rather than read from the policy's constants, so item
    /// S-C12's server tunable values reach the decision.
    public let cap: Int
    public let capWindow: TimeInterval

    /// The default pair cooldown, passed in for the same reason.
    public let defaultCooldown: TimeInterval

    public init(
        scanner: Member,
        candidate: Member,
        scannerIsInAGreet: Bool,
        candidateIsInAGreet: Bool,
        isBlockedEitherWay: Bool,
        lastAutomaticGreetAt: Date?,
        lastAutomaticGreetOutcome: AutomaticGreetOutcome,
        hasPendingUnansweredGreet: Bool,
        scannerOldestGreetInWindowAt: Date?,
        candidateOldestGreetInWindowAt: Date? = nil,
        candidateFrozenUntil: Date?,
        hasVenueBetweenThem: Bool,
        now: Date,
        cap: Int = AutomaticGreetCooldownPolicy.defaultMemberCap,
        capWindow: TimeInterval = AutomaticGreetCooldownPolicy.defaultMemberCapWindow,
        defaultCooldown: TimeInterval = AutomaticGreetCooldownPolicy.defaultPairCooldown
    ) {
        self.scanner = scanner
        self.candidate = candidate
        self.scannerIsInAGreet = scannerIsInAGreet
        self.candidateIsInAGreet = candidateIsInAGreet
        self.isBlockedEitherWay = isBlockedEitherWay
        self.lastAutomaticGreetAt = lastAutomaticGreetAt
        self.lastAutomaticGreetOutcome = lastAutomaticGreetOutcome
        self.hasPendingUnansweredGreet = hasPendingUnansweredGreet
        self.scannerOldestGreetInWindowAt = scannerOldestGreetInWindowAt
        self.candidateOldestGreetInWindowAt = candidateOldestGreetInWindowAt
        self.candidateFrozenUntil = candidateFrozenUntil
        self.hasVenueBetweenThem = hasVenueBetweenThem
        self.now = now
        self.cap = cap
        self.capWindow = capWindow
        self.defaultCooldown = defaultCooldown
    }
}

// MARK: - The rules

/// Every rule about whether the app may introduce two members WITHOUT being asked.
///
/// A namespace of pure functions over `AutomaticGreetContext`: it reads no database, no clock and
/// no environment, which is what lets the server, a client and a test each ask the same question
/// and get the same answer. Every duration below is a first guess and every one of them is tunable
/// on the server without an app release, which `AutomaticGreetTuning` does.
public enum AutomaticGreetCooldownPolicy {

    // MARK: Durations
    //
    // Every one of these is argued in `docs/goal-loop-20-evidence/S-C2-durations.json` in the akin
    // repository, and every one is a first guess about member behaviour that nobody has measured.
    // That is why `defaultPairCooldown` and the two cap values are server tunable (item S-C12) and
    // the four outcome lengths are not: the outcome lengths encode what each outcome MEANS, and a
    // server that could set a decline to cool for less time than a timeout could make the set
    // incoherent from a dashboard.

    /// The cooldown when the last greet's outcome is `unknown`, which includes every greet that is
    /// still open. Twenty four hours, so two compatible members in the same place all day are
    /// introduced exactly once.
    public static let defaultPairCooldown: TimeInterval = 24 * 60 * 60

    /// Either member said no. The clearest nuisance in the set if repeated.
    public static let declinedCooldown: TimeInterval = 30 * 24 * 60 * 60

    /// It timed out with nobody answering. The commonest cause is a phone nobody was looking at,
    /// which is a bad moment rather than a decision.
    public static let expiredUnansweredCooldown: TimeInterval = 3 * 24 * 60 * 60

    /// Somebody opted in and then left. A softer no than a decline and still a withdrawal.
    public static let endedEarlyCooldown: TimeInterval = 7 * 24 * 60 * 60

    /// They met. The longest, because success is the case where an automatic introduction adds the
    /// least: two people who have met have every ordinary means of arranging a second meeting.
    public static let metCooldown: TimeInterval = 90 * 24 * 60 * 60

    /// How many automatic greets one member may receive in the window, from anybody.
    public static let defaultMemberCap: Int = 3

    /// The window the cap is counted over. A cap without a window is not a rule, and the two are
    /// separate constants because the server tunes them separately.
    public static let defaultMemberCapWindow: TimeInterval = 24 * 60 * 60

    /// The rules that are about ONE member, with no second member involved.
    ///
    /// GOAL_LOOP20 item S-C14. A member who is getting no automatic introductions at all is asking
    /// a question about THEMSELVES, not about a particular person, and the answer is usually one of
    /// these seven. Reusing `evaluate` for it would mean inventing a fake second member and then
    /// hoping none of the pair rules fired on the fake.
    ///
    /// The order is the same as `evaluate`'s and for the same reason: consent first, so a member
    /// who has turned Auto greets off is told that rather than told about a cap they never reached.
    public static func memberLevelSuppression(
        for member: AutomaticGreetContext.Member,
        now: Date,
        cap: Int = defaultMemberCap,
        capWindow: TimeInterval = defaultMemberCapWindow,
        oldestGreetInWindowAt: Date? = nil
    ) -> AutomaticGreetSuppression? {
        if !member.automaticGreetsEnabled { return .automaticGreetsOff(isScanner: true) }
        if member.isHiddenFromNearby { return .hiddenFromNearby(isScanner: true) }
        if !member.isEmailVerified { return .unverified(isScanner: true) }
        if let until = member.busyUntil, until > now { return .busy(isScanner: true, until: until) }
        if !member.isWithinStatedAvailability { return .outsideStatedAvailability(isScanner: true) }
        if member.automaticGreetsInWindow >= cap {
            return .memberCapReached(
                isScanner: true,
                count: member.automaticGreetsInWindow,
                cap: cap,
                until: (oldestGreetInWindowAt ?? now).addingTimeInterval(capWindow)
            )
        }
        return nil
    }

    /// The cooldown for an outcome.
    public static func cooldown(
        for outcome: AutomaticGreetOutcome,
        default defaultCooldown: TimeInterval = defaultPairCooldown
    ) -> TimeInterval {
        switch outcome {
        case .declined: return declinedCooldown
        case .expiredUnanswered: return expiredUnansweredCooldown
        case .endedEarly: return endedEarlyCooldown
        case .met: return metCooldown
        case .unknown: return defaultCooldown
        }
    }

    // MARK: The decision

    /// Whether an automatic greet may be created for this pair right now.
    ///
    /// The order of the checks is not arbitrary and is not an optimisation. It runs from the rules
    /// that are about CONSENT, through the ones about STATE, to the one about time, because a
    /// member who has turned Auto greets off should be told that rather than told about a cooldown
    /// they never asked for. A log line that names `pair_cooldown` for a member who is opted out
    /// entirely would send the next reader looking in the wrong place.
    public static func evaluate(_ context: AutomaticGreetContext) -> AutomaticGreetEligibility {

        // 1. Consent, both ways. The scanner side is new in GOAL_LOOP20: before it, the Auto
        //    greets switch was read only for the candidate, so a member who had opted out could
        //    still trigger a scan that created a greet FOR THEMSELVES, with a settings row and a
        //    push. A switch that filters other people out of your results is a filter; a switch
        //    that decides whether you may be introduced is a consent, and this one is labelled as
        //    the second.
        if !context.scanner.automaticGreetsEnabled {
            return .suppressed(.automaticGreetsOff(isScanner: true))
        }
        if !context.candidate.automaticGreetsEnabled {
            return .suppressed(.automaticGreetsOff(isScanner: false))
        }

        // 2. A block is a standing instruction and outranks everything below it.
        if context.isBlockedEitherWay {
            return .suppressed(.blocked)
        }

        if context.scanner.isHiddenFromNearby {
            return .suppressed(.hiddenFromNearby(isScanner: true))
        }
        if context.candidate.isHiddenFromNearby {
            return .suppressed(.hiddenFromNearby(isScanner: false))
        }

        // 3. Account state.
        if !context.scanner.isEmailVerified {
            return .suppressed(.unverified(isScanner: true))
        }
        if !context.candidate.isEmailVerified {
            return .suppressed(.unverified(isScanner: false))
        }
        if context.candidate.hasConfirmedModerationFlag {
            return .suppressed(.moderationFlagged)
        }

        // 4. Right now.
        if context.scannerIsInAGreet {
            return .suppressed(.alreadyInAGreet(isScanner: true))
        }
        if context.candidateIsInAGreet {
            return .suppressed(.alreadyInAGreet(isScanner: false))
        }
        if let until = context.scanner.busyUntil, until > context.now {
            return .suppressed(.busy(isScanner: true, until: until))
        }
        if let until = context.candidate.busyUntil, until > context.now {
            return .suppressed(.busy(isScanner: false, until: until))
        }
        if !context.candidate.isReachable {
            return .suppressed(.unreachable)
        }
        if let until = context.candidateFrozenUntil, until > context.now {
            return .suppressed(.frozenByAnotherMember(until: until))
        }
        if !context.scanner.isWithinStatedAvailability {
            return .suppressed(.outsideStatedAvailability(isScanner: true))
        }
        if !context.candidate.isWithinStatedAvailability {
            return .suppressed(.outsideStatedAvailability(isScanner: false))
        }

        // 5. This pair's history.
        if context.hasPendingUnansweredGreet {
            return .suppressed(.pendingGreetUnanswered)
        }
        if context.lastAutomaticGreetOutcome == .met {
            // Checked before the timer so the member facing reason is the true one. "You two have
            // already met" is what a member would recognise; "you were introduced recently" is not
            // what they would say about somebody they had a drink with.
            if let last = context.lastAutomaticGreetAt,
               context.now < last.addingTimeInterval(metCooldown) {
                return .suppressed(.alreadyMet(until: last.addingTimeInterval(metCooldown)))
            }
        }

        // 6. Volume, before the pair timer, because a member at their cap should be told about the
        //    cap rather than about one particular person.
        //
        //    BOTH members, as of Phase S-G. It was the scanner only, defended by a comment saying
        //    the cap protects the member being interrupted and the scanner is the one being
        //    interrupted. An automatic greet interrupts both of them, so a member who had taken
        //    their three could still be introduced any number of times by other people walking
        //    past, which is the crowded room this rule is named for. The scanner is checked first
        //    because a member is owed the reason they can act on.
        if context.scanner.automaticGreetsInWindow >= context.cap {
            let clearsAt = (context.scannerOldestGreetInWindowAt ?? context.now)
                .addingTimeInterval(context.capWindow)
            return .suppressed(.memberCapReached(
                isScanner: true,
                count: context.scanner.automaticGreetsInWindow,
                cap: context.cap,
                until: clearsAt
            ))
        }
        if context.candidate.automaticGreetsInWindow >= context.cap {
            let clearsAt = (context.candidateOldestGreetInWindowAt ?? context.now)
                .addingTimeInterval(context.capWindow)
            return .suppressed(.memberCapReached(
                isScanner: false,
                count: context.candidate.automaticGreetsInWindow,
                cap: context.cap,
                until: clearsAt
            ))
        }

        // 7. The pair timer, last.
        //
        //    Item S-C11: a cooldown is a member saying leave me alone for this long, and the other
        //    member's shorter setting must not override it. So the LONGER of the two chosen values
        //    wins, and a member who has chosen nothing follows the server's default.
        //
        //    What a choice replaces is the DEFAULT, and only the default. This read
        //    `chosen ?? cooldown(for:default:)`, which let a choice replace the outcome's own
        //    length too: a member who DECLINED an introduction is owed thirty days by
        //    `declinedCooldown`, and could be introduced to the person they declined one hour
        //    later because the other member had picked one hour. A decline is a refusal and the
        //    control is labelled "How long we wait before introducing you to the same person
        //    again", not "how long a refusal lasts". So the outcome's length is a FLOOR that a
        //    choice may lengthen and may not shorten.
        //
        //    `.met` never reaches this line: step 5 above returns first, with a sentence a member
        //    would recognise.
        if let last = context.lastAutomaticGreetAt {
            let chosen: TimeInterval? = [
                context.scanner.chosenCooldownSeconds,
                context.candidate.chosenCooldownSeconds,
            ].compactMap { $0 }.max()
            // `.unknown` is not a floor. It is the case that HAS no outcome specific length, so
            // `cooldown(for:default:)` answers the default for it, and the default is precisely
            // what a member's choice replaces: the control says "The default is 1 day, and Use the
            // default in the list puts you back on it", so a member who picks one hour means one
            // hour. Treating it as a floor would make every choice shorter than the default do
            // nothing, silently.
            let outcomeFloor: TimeInterval = context.lastAutomaticGreetOutcome == .unknown
                ? 0
                : cooldown(for: context.lastAutomaticGreetOutcome, default: context.defaultCooldown)
            let length = max(chosen ?? context.defaultCooldown, outcomeFloor)
            let until = last.addingTimeInterval(length)
            if context.now < until {
                return .suppressed(.pairCooldown(until: until))
            }
        }

        // 8. A place to meet, last, because it is the only input a caller may not know yet.
        //
        // The field was on the context and read by nothing, so a caller who passed `false` was
        // told the pair were eligible. The one caller today passes `true` with a comment saying it
        // cannot know: the venue is chosen inside `triggerGreetForMultiple` after a live Places
        // call, and the rule is enforced there with this same reason. Honoured here so the next
        // caller, who may know, is obeyed rather than ignored.
        if !context.hasVenueBetweenThem {
            return .suppressed(.noVenueBetweenThem)
        }

        return .eligible
    }
}

// MARK: - The member facing choice

/// The cooldown lengths a member may pick from, as named choices rather than a number.
///
/// GOAL_LOOP20 item S-C9. Named because the control has to SHOW the current value, STATE the
/// default, and let the member return to the default without guessing which option that was, and
/// all three of those are impossible with a bare number: a member who has chosen 86400 cannot tell
/// whether that is the default or a value they set.
///
/// The set covers a much shorter option and a much longer one either side of the default, which is
/// what the item asks for, and stops there. A slider would let a member pick 71 minutes, which is
/// a decision nobody wants to make about a thing they will set once.
public enum AutomaticGreetCooldownChoice: String, Codable, Sendable, Hashable, CaseIterable {

    /// Whatever the server says, which is `AutomaticGreetCooldownPolicy.defaultPairCooldown` unless
    /// it has been tuned. This is the value a member returns to, and it is a CASE rather than the
    /// absence of one so that "back to the default" is something they can tap.
    case useDefault

    case oneHour
    case sixHours
    case oneDay
    case oneWeek
    case oneMonth

    /// The length in seconds, or nil for `useDefault`, which has no length of its own.
    public var seconds: TimeInterval? {
        switch self {
        case .useDefault: return nil
        case .oneHour: return 60 * 60
        case .sixHours: return 6 * 60 * 60
        case .oneDay: return 24 * 60 * 60
        case .oneWeek: return 7 * 24 * 60 * 60
        case .oneMonth: return 30 * 24 * 60 * 60
        }
    }

    /// What the row says. No dash punctuation, per the project's copy rule.
    public var title: String {
        switch self {
        case .useDefault: return "Use the default"
        case .oneHour: return "1 hour"
        case .sixHours: return "6 hours"
        case .oneDay: return "1 day"
        case .oneWeek: return "1 week"
        case .oneMonth: return "1 month"
        }
    }

    /// The choice that matches a stored number of seconds, or `useDefault` when there is none.
    ///
    /// A stored value that matches no choice resolves to the nearest one rather than to
    /// `useDefault`, because a member who set six hours on an older build and then opens a newer
    /// one should not silently be told they are on the default.
    public static func matching(seconds: TimeInterval?) -> AutomaticGreetCooldownChoice {
        guard let seconds else { return .useDefault }
        let candidates = allCases.compactMap {
            choice -> (AutomaticGreetCooldownChoice, TimeInterval)? in
            guard let value = choice.seconds else { return nil }
            return (choice, abs(value - seconds))
        }
        return candidates.min { $0.1 < $1.1 }?.0 ?? .useDefault
    }
}

/// What the server holds for this member, and what the default currently is.
///
/// The default is sent DOWN rather than compiled into the row, because item S-C12 makes it tunable
/// without an app release, and a row that printed a compiled number while the server used another
/// would be lying to the member about the thing they are being asked to change.
public struct AutomaticGreetCooldownSettings: Codable, Hashable, Equatable, Sendable {

    /// The member's own choice, or nil when they have made none.
    public let chosenSeconds: TimeInterval?

    /// What `useDefault` currently means, in seconds.
    public let defaultSeconds: TimeInterval

    /// Why this member is getting no automatic introductions AT ALL right now, in a sentence they
    /// would recognise, or nil when nothing about them is stopping it.
    ///
    /// GOAL_LOOP20 item S-C14. It travels with the cooldown settings rather than on a call of its
    /// own, because the screen that asks for one is the screen that should show the other: a member
    /// looking at the Auto greets panel is already asking whether they are being introduced.
    ///
    /// Defaulted in the initialiser so an older server that does not send it decodes, and the row
    /// then simply says nothing extra rather than failing to load.
    public let memberLevelReason: String?

    public init(
        chosenSeconds: TimeInterval?,
        defaultSeconds: TimeInterval,
        memberLevelReason: String? = nil
    ) {
        self.chosenSeconds = chosenSeconds
        self.defaultSeconds = defaultSeconds
        self.memberLevelReason = memberLevelReason
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        chosenSeconds = try container.decodeIfPresent(TimeInterval.self, forKey: .chosenSeconds)
        defaultSeconds = try container.decode(TimeInterval.self, forKey: .defaultSeconds)
        memberLevelReason = try container.decodeIfPresent(String.self, forKey: .memberLevelReason)
    }

    public var choice: AutomaticGreetCooldownChoice {
        AutomaticGreetCooldownChoice.matching(seconds: chosenSeconds)
    }

    /// The default expressed as the choice a member would recognise, for the row's "the default is"
    /// line. Falls back to naming the raw hours when a tuned value matches no named choice.
    public var defaultTitle: String {
        let nearest = AutomaticGreetCooldownChoice.matching(seconds: defaultSeconds)
        if nearest.seconds == defaultSeconds { return nearest.title }
        let hours = Int((defaultSeconds / 3600).rounded())
        return hours == 1 ? "1 hour" : "\(hours) hours"
    }
}

// MARK: - Asking why there was no introduction

/// The gate's verdict for one pair, in a form a client can render and a test can assert on.
///
/// GOAL_LOOP20 items S-C14 and S-C15. A member who knows somebody compatible is nearby and gets no
/// introduction should be able to find out why, in the app, without support. That is only possible
/// if the reason travels as a VALUE: a client handed prose could print it and nothing else.
public struct AutomaticGreetStatus: Codable, Hashable, Equatable, Sendable {

    public let isEligible: Bool

    /// The stable rule key, for logs, metrics and tests. Nil when eligible.
    public let ruleName: String?

    /// The sentence a member would recognise. Nil when eligible.
    public let memberFacingReason: String?

    /// When the pair becomes eligible again, or nil when nothing clears on a timer.
    public let clearsAt: Date?

    public init(
        isEligible: Bool,
        ruleName: String?,
        memberFacingReason: String?,
        clearsAt: Date?
    ) {
        self.isEligible = isEligible
        self.ruleName = ruleName
        self.memberFacingReason = memberFacingReason
        self.clearsAt = clearsAt
    }

    public init(_ eligibility: AutomaticGreetEligibility) {
        switch eligibility {
        case .eligible:
            self.init(isEligible: true, ruleName: nil, memberFacingReason: nil, clearsAt: nil)
        case .suppressed(let reason):
            self.init(
                isEligible: false,
                ruleName: reason.ruleName,
                memberFacingReason: reason.memberFacingReason,
                clearsAt: reason.clearsAt
            )
        }
    }
}

/// What a debug caller wants done to the pair's history before the verdict is computed.
///
/// GOAL_LOOP20 item S-C15, and Scott's standing rule about states that are only reachable through a
/// long real world sequence. A pair cooldown is twenty four hours by default. Without this, testing
/// the release side of the commonest rule in the set means waiting a day, which is not a thing that
/// fits inside a working session, so it would not get tested and the rule would ship unverified.
///
/// Every case is refused unless the server has been told to allow debug routes, and the refusal
/// says so rather than failing quietly.
public enum AutomaticGreetDebugAction: Codable, Hashable, Equatable, Sendable {

    /// Move the pair's last automatic greet far enough into the past that every cooldown has
    /// elapsed. The greet itself is left alone, so the OUTCOME still applies and the release can be
    /// tested per outcome rather than only in general.
    case expireCooldownNow

    /// Put the pair's last automatic greet this many seconds ago, so any point on a cooldown can be
    /// landed on directly, including the second before it clears.
    case setLastGreet(secondsAgo: Double)

    /// Forget that this pair was ever introduced automatically, so the next scan sees a first
    /// introduction.
    case clearPairHistory
}
