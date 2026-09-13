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
//  over. The same reasoning covers every other moment an automatic greet makes no sense, starting
//  with either member already being in one.
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
    case memberCapReached(count: Int, cap: Int, until: Date)

    /// One of the two is already inside an active greet.
    case alreadyInAGreet(isScanner: Bool)

    /// This pair already has an automatic greet nobody has answered.
    case pendingGreetUnanswered

    /// This pair has already confirmed that they met.
    case alreadyMet

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

    /// One has blocked the other, in either direction. Not a cooldown and never expires on a
    /// timer, which is why it carries no date.
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

    /// Whether the reason is one that clears on its own, and when.
    ///
    /// `nil` means it does not clear on a timer: somebody has to do something. Item S-C13 requires
    /// a skipped greet to say when the pair becomes eligible again, and a rule whose answer is
    /// "never, until a person acts" has to be able to say that rather than invent a date.
    public var clearsAt: Date? {
        switch self {
        case .pairCooldown(let until): return until
        case .memberCapReached(_, _, let until): return until
        case .busy(_, let until): return until
        case .frozenByAnotherMember(let until): return until
        case .alreadyInAGreet,
             .pendingGreetUnanswered,
             .alreadyMet,
             .automaticGreetsOff,
             .hiddenFromNearby,
             .blocked,
             .unreachable,
             .unverified,
             .moderationFlagged,
             .outsideStatedAvailability,
             .noVenueBetweenThem:
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
        }
    }

    /// One sentence a member would recognise, for item S-C14's surface.
    ///
    /// Written in the second person and about the member who is ASKING, which is why several cases
    /// carry `isScanner`: "You are in the middle of meeting somebody" and "The person we would
    /// introduce you to is already meeting somebody else" are the same rule and not the same
    /// sentence. No dash punctuation anywhere, per the project's copy rule.
    public var memberFacingReason: String {
        switch self {
        case .pairCooldown:
            return "You two were introduced recently. We wait a while before doing it again."
        case .memberCapReached(_, let cap, _):
            return "You have had \(cap) automatic introductions today, which is as many as we send."
        case .alreadyInAGreet(let isScanner):
            return isScanner
                ? "You are in the middle of meeting somebody."
                : "They are already meeting somebody else."
        case .pendingGreetUnanswered:
            return "We already introduced you and nobody has answered yet."
        case .alreadyMet:
            return "You two have already met."
        case .busy(let isScanner, _):
            return isScanner ? "You said you are busy right now." : "They said they are busy right now."
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
        case .noVenueBetweenThem:
            return "There is nowhere between you two to meet."
        }
    }
}

// MARK: - Whether an automatic greet may be created

public enum AutomaticGreetEligibility: Equatable, Sendable {

    case eligible

    case suppressed(AutomaticGreetSuppression)

    public var isEligible: Bool {
        switch self {
        case .eligible: return true
        case .suppressed: return false
        }
    }

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
        public let isReachable: Bool
        public let hasConfirmedModerationFlag: Bool
        public let busyUntil: Date?
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
        self.candidateFrozenUntil = candidateFrozenUntil
        self.hasVenueBetweenThem = hasVenueBetweenThem
        self.now = now
        self.cap = cap
        self.capWindow = capWindow
        self.defaultCooldown = defaultCooldown
    }
}

// MARK: - The rules

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

    public static let defaultMemberCapWindow: TimeInterval = 24 * 60 * 60

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
                return .suppressed(.alreadyMet)
            }
        }

        // 6. Volume, before the pair timer, because a member at their cap should be told about the
        //    cap rather than about one particular person.
        if context.scanner.automaticGreetsInWindow >= context.cap {
            let clearsAt = (context.scannerOldestGreetInWindowAt ?? context.now)
                .addingTimeInterval(context.capWindow)
            return .suppressed(.memberCapReached(
                count: context.scanner.automaticGreetsInWindow,
                cap: context.cap,
                until: clearsAt
            ))
        }

        // 7. The pair timer, last, and with the LONGER of the two members' chosen cooldowns.
        //    Item S-C11: a cooldown is a member saying leave me alone for this long, and the other
        //    member's shorter setting must not override it.
        if let last = context.lastAutomaticGreetAt {
            let chosen = [
                context.scanner.chosenCooldownSeconds,
                context.candidate.chosenCooldownSeconds,
            ].compactMap { $0 }.max()
            let length = chosen ?? cooldown(
                for: context.lastAutomaticGreetOutcome,
                default: context.defaultCooldown
            )
            let until = last.addingTimeInterval(length)
            if context.now < until {
                return .suppressed(.pairCooldown(until: until))
            }
        }

        return .eligible
    }
}
