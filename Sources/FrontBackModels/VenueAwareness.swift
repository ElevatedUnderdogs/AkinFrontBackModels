//
//  VenueAwareness.swift
//  AkinFrontBackModels
//
//  Created for VENUE_PARTNERSHIP_GOAL_LOOP.md Phase 3 on 8/14/26.
//  Copyright © 2026 ElevatedUnderdogs. All rights reserved.
//

import Foundation

// MARK: - Awareness state

/// How much a venue already knows about Map Mates.
///
/// This lives in the shared models package rather than on the server because the
/// client renders the suppression reason, and a client that cannot name the state
/// would have to pattern match on prose.
///
/// The states are ordered by how much the venue knows, not by how the app feels
/// about them. `declined` is a venue that heard the introduction and said no, which
/// is more knowledge than `unaware`, not less.
public enum VenueAwarenessState: String, Codable, Sendable, Hashable, CaseIterable {

    /// Nobody has introduced Map Mates to this venue, as far as the server knows.
    case unaware

    /// At least one customer has been shown the introduction card for this venue.
    /// The venue may or may not actually have been spoken to: showing the card
    /// spends the budget either way, because the venue may have been pitched
    /// regardless of whether anybody reported it.
    case pitched

    /// The venue knows what Map Mates is. Reached by a customer reporting that the
    /// staff already knew, or by a receptive conversation that did not end in a join.
    case aware

    /// The venue is participating: somebody there has generated a referral code.
    case engaged

    /// The venue heard the introduction and did not want it.
    case declined
}

// MARK: - Transitions

/// Whether one awareness state may follow another, and why not when it may not.
///
/// Every ordered pair of states is decided here explicitly. The switch has no
/// `default:` arm, so adding a state to ``VenueAwarenessState`` is a compile error
/// in this file rather than a silent fall-through to some catch-all behaviour.
public enum VenueAwarenessTransition {

    /// Why a transition is not allowed, in words a person reading a log can act on.
    public struct Rejection: Error, Equatable, Sendable, CustomStringConvertible {

        public let from: VenueAwarenessState
        public let to: VenueAwarenessState
        public let reason: String

        public init(from: VenueAwarenessState, to: VenueAwarenessState, reason: String) {
            self.from = from
            self.to = to
            self.reason = reason
        }

        public var description: String {
            "A venue in \(from.rawValue) cannot move to \(to.rawValue). \(reason)"
        }
    }

    /// The verdict for one ordered pair.
    public enum Verdict: Equatable, Sendable {
        case allowed
        case rejected(Rejection)

        public var isAllowed: Bool {
            switch self {
            case .allowed: return true
            case .rejected: return false
            }
        }
    }

    /// Decides one ordered pair. Total over all twenty five pairs.
    ///
    /// The regressions are all rejected on the same principle: awareness is
    /// knowledge the venue now has, and knowledge does not un-happen. A venue that
    /// has seen the introduction cannot become `unaware` again just because the
    /// person who showed it left the job.
    public static func verdict(
        from: VenueAwarenessState,
        to: VenueAwarenessState
    ) -> Verdict {
        switch (from, to) {

        // From unaware.
        case (.unaware, .unaware):
            return .allowed
        case (.unaware, .pitched):
            return .allowed
        case (.unaware, .aware):
            return .allowed
        case (.unaware, .engaged):
            return .allowed
        case (.unaware, .declined):
            // Allowed on purpose, even though the ordinary path records the
            // introduction first and so arrives here from `pitched`. A refusal that
            // reaches the server without its matching shown-record is still a
            // refusal, and dropping it would put the venue back in the pool. Losing
            // a no is far more expensive than an out-of-order write.
            return .allowed

        // From pitched.
        case (.pitched, .unaware):
            return .rejected(
                Rejection(
                    from: from,
                    to: to,
                    reason: """
                    The introduction has already been shown to a customer standing in \
                    this venue. Whether or not anybody reported what happened, the \
                    venue may have been spoken to, so it is not unaware again.
                    """
                )
            )
        case (.pitched, .pitched):
            return .allowed
        case (.pitched, .aware):
            return .allowed
        case (.pitched, .engaged):
            return .allowed
        case (.pitched, .declined):
            return .allowed

        // From aware.
        case (.aware, .unaware):
            return .rejected(
                Rejection(
                    from: from,
                    to: to,
                    reason: """
                    The venue is on record as knowing what Map Mates is. Forgetting \
                    that would let the same venue be introduced from scratch on every \
                    shift.
                    """
                )
            )
        case (.aware, .pitched):
            return .allowed
        case (.aware, .aware):
            return .allowed
        case (.aware, .engaged):
            return .allowed
        case (.aware, .declined):
            return .allowed

        // From engaged.
        case (.engaged, .unaware):
            return .rejected(
                Rejection(
                    from: from,
                    to: to,
                    reason: """
                    Somebody at this venue has generated a referral code. That record \
                    exists, so the venue cannot be treated as never having heard of \
                    the app.
                    """
                )
            )
        case (.engaged, .pitched):
            return .rejected(
                Rejection(
                    from: from,
                    to: to,
                    reason: """
                    A participating venue does not need introducing. Showing the card \
                    for it would pitch a venue that is already running the thing being \
                    pitched.
                    """
                )
            )
        case (.engaged, .aware):
            return .rejected(
                Rejection(
                    from: from,
                    to: to,
                    reason: """
                    Participation is stronger than awareness. Dropping back to aware \
                    would lose the fact that a code exists, which is the fact the \
                    venue's own report is built on.
                    """
                )
            )
        case (.engaged, .engaged):
            return .allowed
        case (.engaged, .declined):
            return .allowed

        // From declined.
        case (.declined, .unaware):
            return .rejected(
                Rejection(
                    from: from,
                    to: to,
                    reason: """
                    The venue said no. Forgetting that is exactly how a venue gets \
                    asked again next week by somebody who does not know.
                    """
                )
            )
        case (.declined, .pitched):
            return .allowed
        case (.declined, .aware):
            // A venue only gets a second introduction once the ninety day freeze has
            // elapsed, so reaching this pair means somebody there has now said they
            // know it and are interested. That is a real change of position and the
            // state should follow it. What stops the venue being asked repeatedly
            // afterwards is the cooldown policy, not this table.
            return .allowed
        case (.declined, .engaged):
            return .allowed
        case (.declined, .declined):
            return .allowed
        }
    }

    /// The state a reported outcome produces, given where the venue is now.
    ///
    /// The result is always a state the transition table allows from `current`, so
    /// this function and ``verdict(from:to:)`` cannot disagree.
    public static func state(
        after outcome: VenuePitchOutcome,
        from current: VenueAwarenessState
    ) -> VenueAwarenessState {
        switch outcome {
        case .receptive:
            // Interested but not signed up. Aware, and on the short freeze.
            return current == .engaged ? .engaged : .aware

        case .alreadyKnew:
            return current == .engaged ? .engaged : .aware

        case .notReceptive:
            return .declined

        case .noChance:
            // The customer never got to say anything, so the venue learned nothing.
            // The pitch is still spent, which is why the state stays at pitched
            // rather than reverting.
            return current == .unaware ? .pitched : current

        case .skipped:
            // The customer chose not to introduce it. Same reasoning as noChance:
            // the card was shown, so the budget is spent, but the venue is no wiser.
            return current == .unaware ? .pitched : current
        }
    }
}

// MARK: - Outcome

/// What the customer reports happened when they introduced Map Mates to the venue.
///
/// `skipped` is a first class outcome rather than an absence, because a customer
/// choosing not to introduce it is information about the moment, and because the
/// card was still shown, which still spends the venue's pitch budget.
public enum VenuePitchOutcome: String, Codable, Sendable, Hashable, CaseIterable {

    /// The staff had not heard of it, and did not refuse.
    ///
    /// The case name says receptive and the label a person taps says "they had not
    /// heard of it", which are two different sentences about one answer. The freeze
    /// is timed on the second: a venue that is new to this and did not say no is a
    /// venue where the next conversation is the one that lands, so seven days.
    ///
    /// It is deliberately not "they were enthusiastic". Nobody taps that honestly.
    case receptive

    /// The staff already knew about Map Mates.
    case alreadyKnew

    /// The staff heard it and did not want it.
    case notReceptive

    /// There was no opening: a queue, a rush, nobody free to talk to.
    case noChance

    /// The customer dismissed the card without introducing anything.
    case skipped
}

// MARK: - Shift buckets

/// A named part of a venue's day, so the morning crew and the evening crew are
/// tracked as different audiences.
///
/// The point is not analytics. It is that four customers meeting at the same bar on
/// the same evening must not produce four introductions to the same bartender, while
/// the person opening the next morning has genuinely not heard it.
public enum VenueShiftBucket: String, Codable, Sendable, Hashable, CaseIterable {

    /// 00:00 to 05:59 local.
    case overnight

    /// 06:00 to 10:59 local.
    case morning

    /// 11:00 to 14:59 local.
    case midday

    /// 15:00 to 17:59 local.
    case afternoon

    /// 18:00 to 21:59 local.
    case evening

    /// 22:00 to 23:59 local.
    case lateNight

    /// The bucket an hour of the local clock falls in.
    ///
    /// Total over 0 through 23. Any other value is a programming error rather than a
    /// venue state, so it throws rather than picking a bucket.
    public static func forLocalHour(_ hour: Int) throws -> VenueShiftBucket {
        switch hour {
        case 0...5: return .overnight
        case 6...10: return .morning
        case 11...14: return .midday
        case 15...17: return .afternoon
        case 18...21: return .evening
        case 22...23: return .lateNight
        default:
            throw VenueAwarenessError.hourOutsideDay(hour: hour)
        }
    }

    /// The bucket a moment falls in, for a venue whose timezone is known.
    ///
    /// - Parameters:
    ///   - date: the moment to bucket.
    ///   - timeZoneIdentifier: the venue's IANA timezone identifier. Optional
    ///     because the venue table genuinely has no timezone column today, so a
    ///     missing one is a state that occurs, not a hypothetical.
    ///   - venueName: carried into the error so a log line names the venue.
    public static func forDate(
        _ date: Date,
        timeZoneIdentifier: String?,
        venueName: String
    ) throws -> VenueShiftBucket {
        guard let timeZoneIdentifier, timeZoneIdentifier.isEmpty == false else {
            throw VenueAwarenessError.venueHasNoTimeZone(venueName: venueName)
        }

        guard let timeZone = TimeZone(identifier: timeZoneIdentifier) else {
            throw VenueAwarenessError.venueTimeZoneNotRecognised(
                venueName: venueName,
                identifier: timeZoneIdentifier
            )
        }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return try forLocalHour(calendar.component(.hour, from: date))
    }
}

// MARK: - Cooldown policy

/// Everything the cooldown policy is allowed to look at.
///
/// A struct rather than five arguments so that adding an input is a visible change
/// at every call site, and so the table driven test can name its cases.
public struct VenuePitchContext: Equatable, Sendable {

    public let state: VenueAwarenessState

    /// The most recently reported outcome for this venue, or nil when the card has
    /// been shown and nobody has reported anything.
    public let lastOutcome: VenuePitchOutcome?

    /// How many times the card has been shown for this venue inside the counting
    /// window, which the caller defines. The server uses thirty days.
    public let pitchCountInWindow: Int

    /// The bucket the moment being tested falls in.
    public let shiftBucket: VenueShiftBucket

    /// The bucket the most recent pitch fell in, or nil when there has been none.
    public let lastPitchShiftBucket: VenueShiftBucket?

    /// When the most recent pitch happened, or nil when there has been none.
    public let lastPitchAt: Date?

    /// The moment being tested.
    public let now: Date

    public init(
        state: VenueAwarenessState,
        lastOutcome: VenuePitchOutcome?,
        pitchCountInWindow: Int,
        shiftBucket: VenueShiftBucket,
        lastPitchShiftBucket: VenueShiftBucket?,
        lastPitchAt: Date?,
        now: Date
    ) {
        self.state = state
        self.lastOutcome = lastOutcome
        self.pitchCountInWindow = pitchCountInWindow
        self.shiftBucket = shiftBucket
        self.lastPitchShiftBucket = lastPitchShiftBucket
        self.lastPitchAt = lastPitchAt
        self.now = now
    }
}

/// Whether the card may be shown for this venue right now.
public enum VenuePitchEligibility: Equatable, Sendable {

    case eligible

    /// Suppressed, with a reason a person can read. Every reason in the policy is
    /// distinct, so a log line identifies which rule fired without a rule id.
    case suppressed(reason: String)

    public var isEligible: Bool {
        switch self {
        case .eligible: return true
        case .suppressed: return false
        }
    }

    public var suppressionReason: String? {
        switch self {
        case .eligible: return nil
        case .suppressed(let reason): return reason
        }
    }
}

/// The cooldown rules, as one pure function.
///
/// Aggressive early then decaying, handing off to outcome adaptive freezes, keyed by
/// shift. Pure so the whole rule set is testable without a database and so the same
/// verdict can be computed on the client for an explanation string.
public enum VenueCooldownPolicy {

    // MARK: Freeze lengths

    /// A venue that said no is not asked again for this long.
    public static let declinedFreeze: TimeInterval = 90 * 24 * 60 * 60

    /// Interested but not signed up. Short, because the next conversation is the
    /// one that lands.
    public static let receptiveFreeze: TimeInterval = 7 * 24 * 60 * 60

    /// They already knew. No point repeating it soon, but they are not a no.
    public static let alreadyKnewFreeze: TimeInterval = 30 * 24 * 60 * 60

    /// Nobody got a chance to say anything. The venue learned nothing, so the freeze
    /// is short, but it is not zero: the same rush is probably still on.
    public static let noChanceFreeze: TimeInterval = 24 * 60 * 60

    /// The conservative default. Used when the customer skipped, and when the card
    /// was shown and nothing at all was reported.
    public static let conservativeFreeze: TimeInterval = 14 * 24 * 60 * 60

    /// How many introductions a venue nobody has reported on may receive before the
    /// adaptive rules take over. Aggressive early, in the decisions table's words.
    public static let earlyPitchAllowance: Int = 2

    // MARK: Evaluation

    public static func evaluate(_ context: VenuePitchContext) -> VenuePitchEligibility {

        // 1. A participating venue is never introduced to the thing it is running.
        if context.state == .engaged {
            return .suppressed(
                reason: """
                This venue already has Map Mates running, so there is nothing to \
                introduce.
                """
            )
        }

        // 2. A refusal is honoured for a long time, and the reason says until when.
        if context.state == .declined {
            guard let lastPitchAt = context.lastPitchAt else {
                return .suppressed(
                    reason: """
                    This venue is on record as having declined, and no date was \
                    recorded for the refusal, so the freeze cannot be timed out. It \
                    stays suppressed until an outcome is recorded that moves it.
                    """
                )
            }

            let freezeEnds = lastPitchAt.addingTimeInterval(declinedFreeze)
            if context.now < freezeEnds {
                return .suppressed(
                    reason: """
                    This venue said no on \(Self.dayString(lastPitchAt)). It is not \
                    asked again until \(Self.dayString(freezeEnds)).
                    """
                )
            }
            return .eligible
        }

        // 3. One introduction per shift, always. This is the rule that stops four
        //    customers in one evening from pitching the same bartender four times,
        //    and it fires whether or not anybody reported an outcome.
        if let lastPitchShiftBucket = context.lastPitchShiftBucket,
           lastPitchShiftBucket == context.shiftBucket,
           let lastPitchAt = context.lastPitchAt,
           Self.isSameLocalDayWindow(lastPitchAt, context.now) {
            return .suppressed(
                reason: """
                Somebody has already shown this venue the introduction during the \
                \(context.shiftBucket.rawValue) shift. The next one waits for a \
                different shift.
                """
            )
        }

        // 4. Nothing reported yet: aggressive early, then the conservative freeze.
        guard let lastOutcome = context.lastOutcome else {
            if context.pitchCountInWindow < earlyPitchAllowance {
                return .eligible
            }

            guard let lastPitchAt = context.lastPitchAt else {
                return .suppressed(
                    reason: """
                    This venue has reached the early allowance of \
                    \(earlyPitchAllowance) introductions with nothing reported back, \
                    and no date was recorded for the most recent one, so the freeze \
                    cannot be timed out.
                    """
                )
            }

            let freezeEnds = lastPitchAt.addingTimeInterval(conservativeFreeze)
            if context.now < freezeEnds {
                return .suppressed(
                    reason: """
                    This venue has been shown the introduction \
                    \(context.pitchCountInWindow) times with nothing reported back, \
                    so it waits the conservative \
                    \(Self.dayCount(conservativeFreeze)) days, until \
                    \(Self.dayString(freezeEnds)).
                    """
                )
            }
            return .eligible
        }

        // 5. Outcome adaptive.
        let freeze: TimeInterval
        let outcomeSentence: String

        switch lastOutcome {
        case .receptive:
            freeze = receptiveFreeze
            outcomeSentence = "The last person here was interested"
        case .alreadyKnew:
            freeze = alreadyKnewFreeze
            outcomeSentence = "The staff here already knew about Map Mates"
        case .notReceptive:
            freeze = declinedFreeze
            outcomeSentence = "The last person here was not interested"
        case .noChance:
            freeze = noChanceFreeze
            outcomeSentence = "The last customer never got an opening to say anything"
        case .skipped:
            freeze = conservativeFreeze
            outcomeSentence = "The last customer chose not to introduce it"
        }

        guard let lastPitchAt = context.lastPitchAt else {
            return .suppressed(
                reason: """
                \(outcomeSentence), and no date was recorded for that introduction, \
                so the \(Self.dayCount(freeze)) day freeze cannot be timed out.
                """
            )
        }

        let freezeEnds = lastPitchAt.addingTimeInterval(freeze)
        if context.now < freezeEnds {
            return .suppressed(
                reason: """
                \(outcomeSentence), on \(Self.dayString(lastPitchAt)). The next \
                introduction here is offered from \(Self.dayString(freezeEnds)).
                """
            )
        }

        return .eligible
    }

    // MARK: Helpers

    /// Whether two moments are close enough that they are the same working shift
    /// rather than the same named bucket a week apart.
    ///
    /// Eighteen hours rather than a calendar day, so an overnight shift that starts
    /// before midnight and ends after it is one shift, while the same bucket
    /// tomorrow is a new one.
    static func isSameLocalDayWindow(_ earlier: Date, _ later: Date) -> Bool {
        later.timeIntervalSince(earlier) < 18 * 60 * 60
    }

    static func dayCount(_ interval: TimeInterval) -> Int {
        Int(interval / (24 * 60 * 60))
    }

    /// A date rendered for a human reading a suppression reason. Fixed to a stable
    /// locale and to UTC so the same input produces the same string in a test on any
    /// machine, which is what makes the reasons assertable.
    static func dayString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Errors

/// Every way the venue awareness layer can refuse, each with enough context to
/// diagnose without opening the caller.
///
/// One enum rather than five types so a caller can switch exhaustively, with each
/// case carrying its own payload so no two cases produce the same message.
public enum VenueAwarenessError: Error, Equatable, Sendable, CustomStringConvertible {

    /// No venue exists for the identifier the caller sent.
    case unknownVenue(identifier: String)

    /// The venue exists but has no timezone, so its day cannot be divided into
    /// shifts. Not defaulted to UTC: a closing shift in Los Angeles bucketed as a
    /// UTC morning merges the evening crew with the next morning's.
    case venueHasNoTimeZone(venueName: String)

    /// The venue carries a timezone string the system does not recognise.
    case venueTimeZoneNotRecognised(venueName: String, identifier: String)

    /// The outcome string in the request body is not one of the five outcomes.
    case malformedOutcome(received: String, accepted: [String])

    /// The correlation identifier names a card that was shown too long ago to be the
    /// one being reported on, or one that was never recorded.
    case staleCorrelationIdentifier(identifier: String, ageInSeconds: Int?)

    /// The venue has no pitch budget left in this window.
    case pitchBudgetExhausted(venueName: String, shiftBucket: VenueShiftBucket, reason: String)

    /// An hour outside 0 through 23 reached the bucketing function.
    case hourOutsideDay(hour: Int)

    /// The greet named by the request does not exist, so no venue can be resolved.
    case unknownGreet(identifier: String)

    /// The caller is not one of the two participants in the greet they named.
    case callerNotInGreet(callerIdentifier: String, greetIdentifier: String)

    public var description: String {
        switch self {
        case .unknownVenue(let identifier):
            return """
            No venue is stored under the identifier "\(identifier)". Eligibility \
            cannot be decided for a venue the server does not have, and answering \
            eligible would introduce Map Mates to a venue no report can ever be \
            attributed to.
            """

        case .venueHasNoTimeZone(let venueName):
            return """
            The venue "\(venueName)" has no timezone, so its day cannot be divided \
            into shifts. Bucketing it in UTC instead would merge a closing crew with \
            the next morning's crew, which is the exact bombardment the shift key \
            exists to prevent.
            """

        case .venueTimeZoneNotRecognised(let venueName, let identifier):
            return """
            The venue "\(venueName)" carries the timezone identifier "\(identifier)", \
            which this system does not recognise. A guess would put the venue's \
            shifts on the wrong clock.
            """

        case .malformedOutcome(let received, let accepted):
            return """
            The outcome "\(received)" is not one this endpoint accepts. The accepted \
            outcomes are \(accepted.joined(separator: ", ")). An unrecognised outcome \
            is not recorded as a skip, because a skip is itself a reportable answer.
            """

        case .staleCorrelationIdentifier(let identifier, let ageInSeconds):
            let age = ageInSeconds.map { "\($0) seconds old" } ?? "of unknown age"
            return """
            The correlation identifier "\(identifier)" is \(age) and does not match a \
            card this server recorded showing. Recording the outcome against it would \
            attribute a report to the wrong introduction.
            """

        case .pitchBudgetExhausted(let venueName, let shiftBucket, let reason):
            return """
            The venue "\(venueName)" has no introduction budget left in the \
            \(shiftBucket.rawValue) shift. \(reason)
            """

        case .hourOutsideDay(let hour):
            return """
            The hour \(hour) is outside 0 through 23, so no shift bucket covers it. \
            This is a caller mistake rather than a venue state.
            """

        case .unknownGreet(let identifier):
            return """
            No greet is stored under the identifier "\(identifier)". The venue a meet \
            happened at is resolved through the greet, so without one there is no \
            venue to decide about.
            """

        case .callerNotInGreet(let callerIdentifier, let greetIdentifier):
            return """
            The user "\(callerIdentifier)" is not a participant in the greet \
            "\(greetIdentifier)". Only the two people who met may report what \
            happened at the venue they met at.
            """
        }
    }
}

// MARK: - Wire types

/// What the client sends to ask whether the introduction card may be shown.
public struct VenueEligibilityRequest: Codable, Equatable, Sendable {

    /// The greet whose venue is being asked about. The server resolves the venue and
    /// the two participants from this, so the client never names a venue itself.
    public let greetIdentifier: UUID

    /// Minted on the device when the card is about to be shown, and carried through
    /// every later stage of the funnel.
    public let clientCorrelationIdentifier: String

    public init(greetIdentifier: UUID, clientCorrelationIdentifier: String) {
        self.greetIdentifier = greetIdentifier
        self.clientCorrelationIdentifier = clientCorrelationIdentifier
    }
}

/// The eligibility answer, plus everything the card needs to render honestly.
public struct VenueEligibilityResponse: Codable, Equatable, Sendable {

    public let isEligible: Bool

    /// Present exactly when `isEligible` is false.
    public let suppressionReason: String?

    public let venueName: String

    /// The Google Place identifier the venue is stored under, when it has one.
    ///
    /// The client needs it to build a scannable link, and it cannot derive it: the
    /// client's `Venue` carries a name, an address, and coordinates, and no
    /// identifier at all. Optional because a venue row created before Places
    /// lookups genuinely has none, and a code built without one still resolves to
    /// the venue by name on the landing page.
    public let venueGooglePlaceIdentifier: String?

    public let awarenessState: VenueAwarenessState

    public let shiftBucket: VenueShiftBucket

    /// This venue's own referral count for the current month. Zero is a real answer
    /// and is rendered as one, never padded.
    public let usersSentToVenueThisMonth: Int

    /// Which period that count covers, in words, on the venue's own clock.
    public let periodDescription: String

    /// Staff at this venue who already have referral codes, so the customer can tell
    /// whether the person in front of them needs the introduction at all.
    public let participatingStaffNames: [String]

    /// Which arm of the motivation experiment this user is in. Stable per user.
    public let experimentArm: VenueMotivationArm

    public init(
        isEligible: Bool,
        suppressionReason: String?,
        venueName: String,
        venueGooglePlaceIdentifier: String?,
        awarenessState: VenueAwarenessState,
        shiftBucket: VenueShiftBucket,
        usersSentToVenueThisMonth: Int,
        periodDescription: String = "",
        participatingStaffNames: [String],
        experimentArm: VenueMotivationArm
    ) {
        self.isEligible = isEligible
        self.suppressionReason = suppressionReason
        self.venueName = venueName
        self.venueGooglePlaceIdentifier = venueGooglePlaceIdentifier
        self.awarenessState = awarenessState
        self.shiftBucket = shiftBucket
        self.usersSentToVenueThisMonth = usersSentToVenueThisMonth
        self.periodDescription = periodDescription
        self.participatingStaffNames = participatingStaffNames
        self.experimentArm = experimentArm
    }

    /// Same reason as ``VenueScanResponse``: the app in somebody's pocket is older
    /// than the server it is talking to, always.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isEligible = try container.decode(Bool.self, forKey: .isEligible)
        suppressionReason = try container.decodeIfPresent(String.self, forKey: .suppressionReason)
        venueName = try container.decode(String.self, forKey: .venueName)
        venueGooglePlaceIdentifier = try container.decodeIfPresent(
            String.self, forKey: .venueGooglePlaceIdentifier
        )
        awarenessState = try container.decode(VenueAwarenessState.self, forKey: .awarenessState)
        shiftBucket = try container.decode(VenueShiftBucket.self, forKey: .shiftBucket)
        usersSentToVenueThisMonth = try container.decode(
            Int.self, forKey: .usersSentToVenueThisMonth
        )
        participatingStaffNames = try container.decode(
            [String].self, forKey: .participatingStaffNames
        )
        experimentArm = try container.decode(VenueMotivationArm.self, forKey: .experimentArm)

        periodDescription = try container.decodeIfPresent(
            String.self, forKey: .periodDescription
        ) ?? ""
    }
}

/// What the client sends when the customer answers on the card, or later on the
/// rating screen.
public struct VenueOutcomeReport: Codable, Equatable, Sendable {

    public let greetIdentifier: UUID

    /// The same identifier the eligibility call carried, so a late report on the
    /// rating screen lands on the same row the card created rather than opening a
    /// second one.
    public let clientCorrelationIdentifier: String

    public let outcome: VenuePitchOutcome

    /// Where the answer came from. Two surfaces can answer, and the reconciliation
    /// in 5.3 needs to know which one arrived.
    public let source: Source

    public enum Source: String, Codable, Equatable, Sendable, CaseIterable {
        case card
        case ratingScreen
    }

    public init(
        greetIdentifier: UUID,
        clientCorrelationIdentifier: String,
        outcome: VenuePitchOutcome,
        source: Source
    ) {
        self.greetIdentifier = greetIdentifier
        self.clientCorrelationIdentifier = clientCorrelationIdentifier
        self.outcome = outcome
        self.source = source
    }
}

/// What the server says back after recording an outcome.
public struct VenueOutcomeAcknowledgement: Codable, Equatable, Sendable {

    public let awarenessState: VenueAwarenessState

    /// True when this report changed the stored state. False when it was a duplicate
    /// of one already recorded for the same correlation identifier, which is how the
    /// rating screen answer avoids double counting a card answer.
    public let didChangeState: Bool

    /// How many introductions this venue has now had inside the counting window.
    /// Returned so a test can assert it incremented exactly once.
    public let pitchCountInWindow: Int

    public init(
        awarenessState: VenueAwarenessState,
        didChangeState: Bool,
        pitchCountInWindow: Int
    ) {
        self.awarenessState = awarenessState
        self.didChangeState = didChangeState
        self.pitchCountInWindow = pitchCountInWindow
    }
}

// MARK: - Motivation experiment

/// The two arms of the intrinsic versus extrinsic experiment.
///
/// Assignment is a pure function of the user id, so it is stable across sessions and
/// across devices without storing anything, and both arms are reachable.
public enum VenueMotivationArm: String, Codable, Equatable, Sendable, CaseIterable {

    /// The ask is framed as helping future matches happen at good venues. No reward.
    case intrinsic

    /// The ask carries a concrete in-app benefit.
    case extrinsic

    /// Stable assignment from a user identifier.
    ///
    /// Uses the low bit of a sum over the uuid's bytes rather than `hashValue`,
    /// because Swift's string and uuid hashing is seeded per process and would put
    /// the same user in a different arm on every server restart.
    public static func forUser(_ userIdentifier: UUID) -> VenueMotivationArm {
        var total: UInt32 = 0
        withUnsafeBytes(of: userIdentifier.uuid) { buffer in
            for byte in buffer {
                total = total &+ UInt32(byte)
            }
        }
        return total % 2 == 0 ? .intrinsic : .extrinsic
    }
}

// MARK: - Transparency surface

/// One introduction this user made, and what it actually produced.
///
/// Every field is a fact the server holds. Nothing here is projected, averaged, or
/// filled in when unknown: an introduction whose venue never scanned reports that
/// it never scanned.
public struct VenueIntroductionRecord: Codable, Equatable, Sendable, Identifiable {

    public let id: UUID

    public let venueName: String

    /// When the card was shown to this user.
    public let shownAt: Date

    /// What the user reported, or nil when they never answered.
    public let reportedOutcome: VenuePitchOutcome?

    /// Whether somebody at the venue actually scanned the code. This is the metric
    /// the whole loop is measured on, so it is the one the user sees.
    public let wasScannedByVenue: Bool

    /// Whether the venue went on to generate a referral code of their own.
    public let venueJoined: Bool

    public init(
        id: UUID,
        venueName: String,
        shownAt: Date,
        reportedOutcome: VenuePitchOutcome?,
        wasScannedByVenue: Bool,
        venueJoined: Bool
    ) {
        self.id = id
        self.venueName = venueName
        self.shownAt = shownAt
        self.reportedOutcome = reportedOutcome
        // Recorded as given, not inferred from the join.
        //
        // This used to read `venueJoined ? true : wasScannedByVenue`, in a type
        // whose own doc says nothing here is projected or filled in when unknown,
        // feeding a history screen that tells the customer a scan is somebody at the
        // venue actually pointing a camera at their screen. In the App Clip a join
        // is only reachable after a scan, so the two rarely disagreed, but
        // `POST /venueIntroductionJoin` is unauthenticated and independent of the
        // scan endpoint, so a join with no scan behind it was reachable and reported
        // a camera event that had not happened.
        self.wasScannedByVenue = wasScannedByVenue
        self.venueJoined = venueJoined
    }
}

/// Everything the transparency surface renders.
public struct VenueIntroductionHistoryResponse: Codable, Equatable, Sendable {

    public let records: [VenueIntroductionRecord]

    /// How many of this user's introductions a venue actually scanned. Derived from
    /// `records` so the headline and the list can never disagree.
    public var scannedCount: Int {
        records.filter(\.wasScannedByVenue).count
    }

    /// How many venues went on to join.
    public var joinedCount: Int {
        records.filter(\.venueJoined).count
    }

    public init(records: [VenueIntroductionRecord]) {
        self.records = records
    }
}


// MARK: - Who scanned

/// Which experience a scan should open.
///
/// Carried in the link rather than guessed from context, because the same printed
/// path serves a customer arriving and a venue being introduced, and the two want
/// opposite screens. An unrecognised value is an error rather than a silent fall
/// through to the customer path: a venue owner shown the consumer tagline learns
/// nothing about why they were asked to scan.
public enum VenueScanRole: String, Codable, Sendable, Equatable, CaseIterable {

    /// Somebody who might come to the venue. The behaviour every printed code has
    /// had until now, and the behaviour of a link that names no role at all.
    case customer

    /// Somebody who works at or runs the venue.
    case venue

    /// The query item name this role travels under.
    public static let queryItemName = "role"

    /// Resolves the role from a raw query value.
    ///
    /// - A nil or empty value is `customer`, which keeps every code printed before
    ///   roles existed working exactly as it did.
    /// - A recognised value is that role.
    /// - Anything else throws, because silently treating "owner" or "staff" as a
    ///   customer would send a venue owner to the consumer screen with no trace of
    ///   why, and would attribute their scan to the wrong funnel.
    public static func resolve(rawValue: String?) throws -> VenueScanRole {
        guard let rawValue, rawValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            return .customer
        }

        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let role = VenueScanRole(rawValue: trimmed) else {
            throw VenueScanRoleError.unrecognised(
                received: trimmed,
                accepted: VenueScanRole.allCases.map(\.rawValue)
            )
        }
        return role
    }
}

public enum VenueScanRoleError: Error, Equatable, Sendable, CustomStringConvertible {

    case unrecognised(received: String, accepted: [String])

    public var description: String {
        switch self {
        case .unrecognised(let received, let accepted):
            // Said to whoever is holding the phone, so it says what to do rather
            // than why we chose to fail.
            //
            // This used to explain our own design reasoning to a venue, in our own
            // words, including "record their scan against the wrong funnel". Funnel
            // is not a word anybody behind a counter uses, and none of the reasoning
            // was something the reader could act on. The reasoning is still worth
            // keeping, so it lives in this type's doc comment, where the people it
            // is for will find it.
            _ = accepted
            return """
            This code did not open properly. Ask whoever showed it to you to bring \
            it up again, and it should work on the second try. The code named \
            "\(received)", which this app does not recognise.
            """
        }
    }
}

/// Which video a venue asked for.
public enum VenueAudience: String, Codable, Sendable, Equatable, CaseIterable {

    /// Counter staff: the short muted cut, read with a line behind the customer.
    case counterStaff

    /// The owner or manager: cost, effort, return, in that order.
    case ownerOrManager

    public var videoIdentifier: String {
        switch self {
        case .counterStaff: return "A_counter"
        case .ownerOrManager: return "B_owner"
        }
    }

    public var title: String {
        switch self {
        case .counterStaff: return "I work here"
        case .ownerOrManager: return "I own or manage here"
        }
    }

    /// What to call this audience inside a sentence.
    ///
    /// ``title`` is the label on a button the venue picks, written in their voice,
    /// so lowercasing it mid-sentence produced "Playing the i work here version."
    /// with a bare lowercase i. A sentence needs a noun, not a button.
    public var described: String {
        switch self {
        case .counterStaff: return "counter staff"
        case .ownerOrManager: return "owner and manager"
        }
    }
}

// MARK: - The venue side of the scan

/// What the App Clip tells the server when somebody at a venue scans.
///
/// Unauthenticated on purpose. The whole point of the venue branch is that a
/// bartender can see the venue's own number without an account, an install, or a
/// password, so the only thing identifying this scan is the correlation identifier
/// the customer's code carried.
public struct VenueScanReport: Codable, Equatable, Sendable {

    /// The identifier the customer's code carried. Joins this scan to the card that
    /// produced it.
    public let clientCorrelationIdentifier: String

    /// The role the link named, as it appeared. Sent raw rather than parsed so the
    /// server records what was actually scanned when the value is unrecognised.
    public let roleRawValue: String

    /// Which video the scanner asked for, once they pick. Nil on the first call,
    /// which is the scan itself.
    public let audience: VenueAudience?

    public init(
        clientCorrelationIdentifier: String,
        roleRawValue: String,
        audience: VenueAudience? = nil
    ) {
        self.clientCorrelationIdentifier = clientCorrelationIdentifier
        self.roleRawValue = roleRawValue
        self.audience = audience
    }
}

/// What the venue sees, and it is the venue's own numbers.
public struct VenueScanResponse: Codable, Equatable, Sendable {

    public let venueName: String

    /// This venue's own count for the current month. The first thing the venue
    /// branch renders, because a venue owner has no reason to read a tagline.
    public let usersSentToVenueThisMonth: Int

    /// How many people at this venue already have referral codes.
    public let participatingStaffCount: Int

    /// Who those people are.
    ///
    /// A count alone told a regional manager that somebody here participates and
    /// nothing about who, which is the one thing a per-person report is for.
    public let participatingStaffNames: [String]

    /// What each of them has produced.
    ///
    /// Names alone still did not answer the question a per person report exists to
    /// answer. Empty on a response from a server that predates it.
    public let participatingStaff: [VenueStaffSummary]

    /// Which period the count covers, in words, on the venue's own clock.
    ///
    /// Stated rather than assumed. A number whose window is unstated cannot be
    /// reconciled against a till, and reconciling against a till is the whole
    /// argument for showing it.
    public let periodDescription: String

    /// True when this scan could not be joined to any card. The venue still sees
    /// their real number; what is missing is which introduction produced the scan.
    public let isOrphan: Bool

    /// Why it could not be joined. Present exactly when `isOrphan` is true, and
    /// never the word unknown: an orphan with no reason is a silently dropped row
    /// wearing a different name.
    public let orphanReason: String?

    /// The Google Place identifier, so the venue branch can build a code of the
    /// venue's own without another round trip.
    public let venueGooglePlaceIdentifier: String?

    /// The venue's own report page, complete with the key that opens it.
    ///
    /// Built by the server rather than assembled on the client from the place
    /// identifier. A Google Place identifier is a public fact about a business,
    /// obtainable for any address from Maps, so a report page addressed by that
    /// alone was an open directory: anybody could walk the identifier space and read
    /// off which named staff at which businesses take part and how much each of them
    /// has produced. The link is unguessable now, and the only way to be given one
    /// is to have scanned a real code at the venue it belongs to.
    ///
    /// Nil from a server that predates the change, and from an orphan scan, which
    /// has no venue to report on.
    public let venueReportURLString: String?

    public init(
        venueName: String,
        usersSentToVenueThisMonth: Int,
        participatingStaffCount: Int,
        participatingStaffNames: [String] = [],
        participatingStaff: [VenueStaffSummary] = [],
        periodDescription: String = "",
        isOrphan: Bool,
        orphanReason: String?,
        venueGooglePlaceIdentifier: String?,
        venueReportURLString: String? = nil
    ) {
        self.venueName = venueName
        self.usersSentToVenueThisMonth = usersSentToVenueThisMonth
        self.participatingStaffCount = participatingStaffCount
        self.participatingStaffNames = participatingStaffNames
        self.participatingStaff = participatingStaff
        self.periodDescription = periodDescription
        self.isOrphan = isOrphan
        self.orphanReason = orphanReason
        self.venueGooglePlaceIdentifier = venueGooglePlaceIdentifier
        self.venueReportURLString = venueReportURLString
    }

    /// Decodes tolerantly, because an App Clip in the wild is always an older
    /// binary than the server it talks to.
    ///
    /// The synthesised decoder threw `keyNotFound` the first time a field was
    /// added, and the venue branch answered a real scan with "This code did not
    /// resolve. The data couldn't be read because it is missing", which is a
    /// sentence that blames the code in the customer's hand for a version skew.
    /// Every field added after the first release decodes with a default instead.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        venueName = try container.decode(String.self, forKey: .venueName)
        usersSentToVenueThisMonth = try container.decode(
            Int.self, forKey: .usersSentToVenueThisMonth
        )
        participatingStaffCount = try container.decode(
            Int.self, forKey: .participatingStaffCount
        )
        isOrphan = try container.decode(Bool.self, forKey: .isOrphan)
        orphanReason = try container.decodeIfPresent(String.self, forKey: .orphanReason)
        venueGooglePlaceIdentifier = try container.decodeIfPresent(
            String.self, forKey: .venueGooglePlaceIdentifier
        )

        participatingStaffNames = try container.decodeIfPresent(
            [String].self, forKey: .participatingStaffNames
        ) ?? []
        participatingStaff = try container.decodeIfPresent(
            [VenueStaffSummary].self, forKey: .participatingStaff
        ) ?? []
        periodDescription = try container.decodeIfPresent(
            String.self, forKey: .periodDescription
        ) ?? ""
        venueReportURLString = try container.decodeIfPresent(
            String.self, forKey: .venueReportURLString
        )
    }
}

/// One person at a venue, and what they have produced.
public struct VenueStaffSummary: Codable, Equatable, Sendable, Identifiable {

    public let employeeName: String

    /// How many people this person has referred to the app.
    public let referralsCount: Int

    public var id: String { employeeName }

    public init(employeeName: String, referralsCount: Int) {
        self.employeeName = employeeName
        self.referralsCount = referralsCount
    }
}

/// The venue generating a code of their own, from inside the clip.
public struct VenueJoinReport: Codable, Equatable, Sendable {

    public let clientCorrelationIdentifier: String

    /// The name the person at the venue put on their own code.
    public let referrerName: String

    public init(clientCorrelationIdentifier: String, referrerName: String) {
        self.clientCorrelationIdentifier = clientCorrelationIdentifier
        self.referrerName = referrerName
    }
}

public struct VenueJoinResponse: Codable, Equatable, Sendable {

    public let venueName: String

    /// The link the venue's own code encodes. Built server side so the venue's code
    /// and every printed code share one generator.
    public let referralURLString: String

    public init(venueName: String, referralURLString: String) {
        self.venueName = venueName
        self.referralURLString = referralURLString
    }
}

// MARK: - Who may move a venue's awareness state

/// Everything the outcome rules need to decide, gathered in one place.
///
/// This exists because of where the bugs were. The transition table above is total
/// and exhaustively tested, and in six adversarial review passes it never produced
/// a defect. The rules deciding whether to WRITE an answer and where to MOVE the
/// venue lived as a growing pile of booleans inside a database function, and they
/// produced a defect in every one of the last three passes, each time in the fix
/// for the pass before, and three times in a test written to prove the fix.
///
/// So they get the same treatment: a pure function over stated facts, decided
/// exhaustively, testable without a database, and readable as a whole rather than
/// as a sequence of guards each of which was right about the case its author had in
/// mind.
public struct VenueOutcomeContext: Equatable, Sendable {

    /// What is being reported now.
    public let reported: VenuePitchOutcome

    /// Which surface it came from.
    public let source: VenueOutcomeSource

    /// What this row already holds, if anything.
    public let existing: VenuePitchOutcome?

    /// Which surface that existing answer came from.
    public let existingSource: VenueOutcomeSource?

    /// Where the venue is now.
    public let venueState: VenueAwarenessState

    /// What this row's own verdict displaced when it moved the venue, if it did.
    public let displacedByThisRow: VenueAwarenessState?

    /// Whether this row's verdict is the latest word on the venue's state.
    public let thisRowOwnsTheState: Bool

    public init(
        reported: VenuePitchOutcome,
        source: VenueOutcomeSource,
        existing: VenuePitchOutcome?,
        existingSource: VenueOutcomeSource?,
        venueState: VenueAwarenessState,
        displacedByThisRow: VenueAwarenessState?,
        thisRowOwnsTheState: Bool
    ) {
        self.reported = reported
        self.source = source
        self.existing = existing
        self.existingSource = existingSource
        self.venueState = venueState
        self.displacedByThisRow = displacedByThisRow
        self.thisRowOwnsTheState = thisRowOwnsTheState
    }
}

/// Which surface an outcome came from.
///
/// A string on the wire and on the row, an enum here, so a comparison cannot be
/// made against a typo.
public enum VenueOutcomeSource: String, Codable, CaseIterable, Sendable {
    case card
    case ratingScreen
    /// The venue itself, through the App Clip. Outranks both customer surfaces.
    case venueBranch
}

/// What to do with one reported outcome.
public struct VenueOutcomeDecision: Equatable, Sendable {

    /// Whether the row's answer is replaced.
    public let writesTheAnswer: Bool

    /// Where the venue ends up. Equal to the current state when nothing moves.
    public let nextState: VenueAwarenessState

    /// Whether this row's verdict becomes the latest word on the venue's state.
    ///
    /// True whenever the venue moves, and ALSO when it does not move but this row
    /// was not already the one that spoke last. That second half is the one that
    /// was missing. Two people in one greet both get a card, and `notReceptive`
    /// yields `.declined` from anywhere, so the second refusal moves nothing while
    /// still being the most recent word. A row that takes the word back this way
    /// has to refresh what it displaced, or it keeps a record of a state from an
    /// older verdict and a later withdrawal restores the wrong one.
    ///
    /// The service reads this for both purposes, which is the point of it being one
    /// value: ownership and the displaced record are the same decision and drifted
    /// apart when they were two.
    public let claimsTheState: Bool

    /// Whether this report retracts this row's own earlier verdict.
    public let isWithdrawal: Bool

    /// Why, in one sentence, for a log line and for a reader.
    public let reason: String
}

public enum VenueOutcomeAuthority {

    /// Decides one report, from stated facts, with no database and no side effects.
    ///
    /// The order of these rules is the whole of the policy, so it is written as one
    /// sequence rather than as separate guards:
    ///
    /// 1. The venue's own word outranks both customer surfaces, in both directions.
    /// 2. A venue that has joined is not moved by a customer's report at all.
    /// 3. A surface may correct itself; a card may overrule a rating screen.
    /// 4. A `skipped` that replaces this row's own verdict, while that verdict is
    ///    still the latest word, is a withdrawal and restores what it displaced.
    /// 5. Otherwise the transition table decides.
    public static func decide(_ context: VenueOutcomeContext) -> VenueOutcomeDecision {
        let hasAnswer = context.existing != nil
        let venueHasSpoken = context.existingSource == .venueBranch

        // 1. The venue's own refusal is not overwritten by a customer.
        if venueHasSpoken, context.source != .venueBranch {
            return VenueOutcomeDecision(
                writesTheAnswer: false,
                nextState: context.venueState,
                claimsTheState: false,
                isWithdrawal: false,
                reason: """
                The venue answered for itself on this introduction, and a customer \
                reporting how the counter reacted is a guess about somebody else.
                """
            )
        }

        let sameSurface = context.existingSource == context.source
        let writes = hasAnswer == false || context.source == .card || sameSurface

        guard writes else {
            return VenueOutcomeDecision(
                writesTheAnswer: false,
                nextState: context.venueState,
                claimsTheState: false,
                isWithdrawal: false,
                reason: """
                This introduction already carries an answer from a surface this one \
                does not outrank, so it is left as it is.
                """
            )
        }

        // 2. A venue holding a live referral code is not declined by a customer.
        if context.venueState == .engaged {
            return VenueOutcomeDecision(
                writesTheAnswer: true,
                nextState: .engaged,
                claimsTheState: false,
                isWithdrawal: false,
                reason: """
                This venue has a code of its own, so what a customer reports is \
                recorded and does not move it. Asking to be left alone is the \
                venue's to do, from its own screen.
                """
            )
        }

        // 4. A withdrawal of this row's own standing verdict.
        let isWithdrawal = context.reported == .skipped
            && hasAnswer
            && context.thisRowOwnsTheState
            && context.displacedByThisRow != nil

        if isWithdrawal, let displaced = context.displacedByThisRow {
            let allowed = VenueAwarenessTransition
                .verdict(from: context.venueState, to: displaced)
                .isAllowed
            return VenueOutcomeDecision(
                writesTheAnswer: true,
                nextState: allowed ? displaced : context.venueState,
                claimsTheState: false,
                isWithdrawal: true,
                reason: allowed
                    ? "The answer that moved this venue has been taken back, so what it displaced goes back."
                    : "The answer has been taken back, and the venue has moved on since, so its state stays where it is."
            )
        }

        // 5. The table decides.
        let next = VenueAwarenessTransition.state(after: context.reported, from: context.venueState)
        return VenueOutcomeDecision(
            writesTheAnswer: true,
            nextState: next,
            claimsTheState: next != context.venueState || context.thisRowOwnsTheState == false,
            isWithdrawal: false,
            reason: "Recorded, and the venue's state follows from it."
        )
    }
}
