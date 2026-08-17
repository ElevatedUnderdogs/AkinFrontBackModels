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
        after outcome: VenueAskOutcome,
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
/// The name this type used to carry.
///
/// Renamed by `VENUE_ASK_REWRITE_GOAL_LOOP.md` item 3.2, which requires that no
/// production symbol in the venue introduction feature calls the errand a pitch.
/// The decisions table of both loops says the same thing in prose: the reader asks
/// whether somebody is familiar with the program, and never walks up to pitch.
///
/// The alias is kept so the server, which stores these on a `VenuePitch` row and
/// in a `venue_pitches` table, keeps compiling without a schema change. The raw
/// values are untouched by the rename, so nothing persisted moves.
public typealias VenuePitchOutcome = VenueAskOutcome

public enum VenueAskOutcome: String, Codable, Sendable, Hashable, CaseIterable {

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
    public let lastOutcome: VenueAskOutcome?

    /// How many times the card has been shown for this venue inside the counting
    /// window, which the caller defines. The server uses thirty days.
    public let pitchCountInWindow: Int

    /// The bucket the moment being tested falls in.
    public let shiftBucket: VenueShiftBucket

    /// The bucket the most recent pitch fell in, or nil when there has been none.
    public let lastPitchShiftBucket: VenueShiftBucket?

    /// When the most recent pitch happened, or nil when there has been none.
    public let lastPitchAt: Date?

    /// When this venue was most recently told no, over every introduction it has
    /// had, or nil when nobody has refused it.
    ///
    /// Separate from `lastPitchAt`, and the separation is the point. The declined
    /// branch used to time the ninety days from the last pitch, and every lookup
    /// feeding that value excludes the greet being asked about, because a greet's
    /// own two rows must not suppress each other. So the second person in the same
    /// meet was handed an eligible verdict minutes after the first was told no,
    /// and a venue whose last OTHER introduction was three months ago was eligible
    /// on the day it refused. An adversarial pass walked both sequences.
    public let lastRefusalAt: Date?

    /// The moment being tested.
    public let now: Date

    public init(
        state: VenueAwarenessState,
        lastOutcome: VenueAskOutcome?,
        pitchCountInWindow: Int,
        shiftBucket: VenueShiftBucket,
        lastPitchShiftBucket: VenueShiftBucket?,
        lastPitchAt: Date?,
        lastRefusalAt: Date? = nil,
        now: Date
    ) {
        self.state = state
        self.lastOutcome = lastOutcome
        self.pitchCountInWindow = pitchCountInWindow
        self.shiftBucket = shiftBucket
        self.lastPitchShiftBucket = lastPitchShiftBucket
        self.lastPitchAt = lastPitchAt
        self.lastRefusalAt = lastRefusalAt
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
        //
        // Timed from the refusal, not from the last pitch.
        //
        // It used to be `lastPitchAt`, and every lookup that produces that value
        // excludes the greet being asked about, because a greet's own two rows
        // must not suppress each other. So a refusal was defeated within minutes
        // by the other person in the same meet, who was handed an eligible verdict
        // and asked to walk up to the same counter; and a venue whose last other
        // introduction happened to be ninety days ago was eligible on the day it
        // said no. An adversarial pass walked both. `lastRefusalAt` is over every
        // introduction the venue has had, this greet included, because a refusal
        // is a fact about the venue rather than about one card.
        if context.state == .declined {
            guard let refusedAt = context.lastRefusalAt ?? context.lastPitchAt else {
                return .suppressed(
                    reason: """
                    This venue is on record as having declined, and no date was \
                    recorded for the refusal, so the freeze cannot be timed out. It \
                    stays suppressed until an outcome is recorded that moves it.
                    """
                )
            }

            let freezeEnds = refusedAt.addingTimeInterval(declinedFreeze)
            if context.now < freezeEnds {
                return .suppressed(
                    reason: """
                    This venue said no on \(Self.dayString(refusedAt)). It is not \
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

/// Asks whether the venue has scanned the code this card is showing.
///
/// Added by `VENUE_ASK_REWRITE_GOAL_LOOP.md` Phase 7, which exists because the
/// answer to "does the card advance on its own when the venue scans" was no. The
/// scan itself was already recorded: `VenueScanHandlers.venueIntroductionScan`
/// writes `venueScannedAt` on the pitch it finds by correlation identifier. What
/// did not exist was any way for the device holding the code to ask.
///
/// Keyed on the correlation identifier rather than the greet, because that is what
/// the scan is joined on and because one greet can carry only one card but the
/// identifier is what makes the join exact.
public struct VenueScanStateRequest: Codable, Equatable, Sendable {

    /// The same identifier the card minted before its eligibility call and encoded
    /// into the scannable link.
    public let clientCorrelationIdentifier: String

    /// The greet the card belongs to, so the server can check the caller is one of
    /// the two people who met rather than anybody holding an identifier.
    public let greetIdentifier: UUID

    public init(clientCorrelationIdentifier: String, greetIdentifier: UUID) {
        self.clientCorrelationIdentifier = clientCorrelationIdentifier
        self.greetIdentifier = greetIdentifier
    }
}

/// Whether a scan has landed, and nothing else.
///
/// Deliberately narrow. The card asks this on a timer while it is on screen, so
/// every field here is a field polled repeatedly; anything the card does not act on
/// is bandwidth spent for nothing and a surface for a future leak.
public struct VenueScanStateResponse: Codable, Equatable, Sendable {

    /// When the venue scanned, or nil if nobody has.
    ///
    /// A date rather than a flag, so the client can tell a scan that has just landed
    /// from one it already knew about without keeping its own bookkeeping, and so a
    /// log of a support case says when.
    public let venueScannedAt: Date?

    public var hasBeenScanned: Bool { venueScannedAt != nil }

    public init(venueScannedAt: Date?) {
        self.venueScannedAt = venueScannedAt
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

    public let outcome: VenueAskOutcome

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
        outcome: VenueAskOutcome,
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
    public let reportedOutcome: VenueAskOutcome?

    /// Whether somebody at the venue actually scanned the code. This is the metric
    /// the whole loop is measured on, so it is the one the user sees.
    public let wasScannedByVenue: Bool

    /// Whether the venue went on to generate a referral code of their own.
    public let venueJoined: Bool

    public init(
        id: UUID,
        venueName: String,
        shownAt: Date,
        reportedOutcome: VenueAskOutcome?,
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

// MARK: - Where a venue stands

/// One introduction at a venue, reduced to the facts that decide where the venue
/// stands.
///
/// Deliberately not `VenuePitch` itself. The fold below is exhaustively tested over
/// combinations of these fields, which is only enumerable while the type is small,
/// and that property is what caught three of the four regressions the machinery
/// this replaces produced.
public struct VenuePitchStanding: Equatable, Sendable {

    /// What this row currently says, if anything. A withdrawal writes `skipped`
    /// over the row's own answer, so a retracted refusal stops reading
    /// `notReceptive` the moment it is taken back, and needs no separate flag.
    public let outcome: VenueAskOutcome?

    /// Which surface said it.
    public let source: VenueOutcomeSource?

    /// When it was said. Absent while the row carries no answer.
    public let outcomeReportedAt: Date?

    /// When the card was shown. Always present, and the tiebreak when two answers
    /// carry the same reporting instant.
    public let shownAt: Date

    /// When somebody at the venue scanned the code, if they did.
    public let venueScannedAt: Date?

    /// When somebody at the venue generated a code of their own, if they did.
    public let venueJoinedAt: Date?

    public init(
        outcome: VenueAskOutcome?,
        source: VenueOutcomeSource?,
        outcomeReportedAt: Date?,
        shownAt: Date,
        venueScannedAt: Date?,
        venueJoinedAt: Date?
    ) {
        self.outcome = outcome
        self.source = source
        self.outcomeReportedAt = outcomeReportedAt
        self.shownAt = shownAt
        self.venueScannedAt = venueScannedAt
        self.venueJoinedAt = venueJoinedAt
    }

    /// When this row last said anything, for ordering.
    var spokeAt: Date {
        outcomeReportedAt ?? shownAt
    }
}

/// Where a venue stands, computed from its introductions as they stand now.
///
/// This replaces a snapshot. Each row used to record the state it displaced when
/// its answer moved the venue, and a withdrawal put that snapshot back. The
/// snapshot is taken at write time and the correct answer depends on what every
/// row carries NOW, so every attempt to make it behave was another guard on top of
/// a value that was already stale. Four consecutive adversarial passes found a
/// defect in it and three of those defects were introduced by the previous pass's
/// fix, which is a stronger argument about the design than any one of the defects.
///
/// Two sequences it could not get right, both of which this fold answers the same
/// way whichever order the taps arrive in:
///
/// - Three taps. A refuses, B says it went well, A takes the refusal back. The old
///   object left the venue frozen for ninety days with nobody on record as having
///   refused it, and the same three answers in the other order gave seven.
/// - Four taps. Both people refuse, both retract, and the venue was frozen with
///   both rows reading `skipped`.
///
/// The order of the terms is the whole of the policy:
///
/// 1. The venue's own standing refusal. Its word outranks a code it made earlier,
///    because asking to be left alone is a later and more specific instruction than
///    having once joined.
/// 2. A code exists. Engagement is monotone against customers: a code cannot be
///    revoked from a customer's report, which is what makes the three transitions
///    out of `engaged` that the table rejects unreachable.
/// 3. Any standing refusal, which by here is a customer's.
/// 4. The most recent word that implies a state, the venue's own ranked above a
///    customer's.
/// 5. Shown, and nothing said since.
public enum VenueAwarenessFold {

    /// What one row implies about the venue, if anything.
    ///
    /// `notReceptive` implies nothing HERE, deliberately. Terms one and three own
    /// refusals, and both bound them by the freeze the refusal bought. If this term
    /// also mapped `notReceptive` to `declined`, a refusal that had aged out would
    /// be excluded by the earlier term and readmitted by this one, and the ninety
    /// days would never end.
    ///
    /// `noChance` implies nothing by design: the customer never got to say
    /// anything, so the venue learned nothing. `skipped` is the same. Both still
    /// spend the venue's pitch budget, which is a fact about the row rather than
    /// about the venue's state, and term five is what carries it.
    static func implication(of row: VenuePitchStanding) -> (state: VenueAwarenessState, at: Date, isVenuesOwnWord: Bool)? {
        // A scan is the venue's own action rather than a customer's report of it,
        // so it needs no outcome to count and no new column to record it.
        if let scannedAt = row.venueScannedAt {
            return (.aware, scannedAt, true)
        }
        switch row.outcome {
        case .receptive, .alreadyKnew:
            return (.aware, row.spokeAt, row.source == .venueBranch)
        case .notReceptive, .noChance, .skipped, .none:
            return nil
        }
    }

    /// Whether this row carries a refusal that nobody took back and that is still
    /// inside the freeze it bought.
    ///
    /// Timed from `shownAt` rather than from when the answer was reported, because
    /// that is the clock ``VenueCooldownPolicy`` times the same ninety days on. Two
    /// clocks for one freeze is a venue that the cooldown will offer again while
    /// this still reads it as declined, or the other way round, and which of the two
    /// a reader gets would depend on how long the customer took to answer.
    ///
    /// Ordering, in term four, uses the reporting instant instead. That is a
    /// different question: which of two answers is the venue's latest word, rather
    /// than how long ago the introduction it belongs to happened.
    static func holdsAStandingRefusal(
        _ row: VenuePitchStanding,
        now: Date,
        freeze: TimeInterval
    ) -> Bool {
        guard row.outcome == .notReceptive else { return false }
        // The venue's own no is aged from when the venue said it.
        //
        // A customer's report is aged from `shownAt`, which is when the exchange
        // at the counter happened and the clock the cooldown times the same ninety
        // days on. The venue's own refusal comes from the App Clip, which is
        // reached by scanning a code that has no age bound at all, so a venue
        // tapping "we are not interested" on a code printed three months ago was
        // told "nobody will be shown this for your venue again for ninety days"
        // and the refusal was dropped on the spot for being older than the card it
        // arrived on. An adversarial pass constructed it. The venue's word is the
        // one thing in this system that should never be discarded for arriving
        // late.
        let spokeAt = row.source == .venueBranch ? row.spokeAt : row.shownAt
        return spokeAt >= now.addingTimeInterval(-freeze)
    }

    /// Where the venue stands, given every introduction it has had.
    public static func state(
        of rows: [VenuePitchStanding],
        now: Date,
        declinedFreeze: TimeInterval = VenueCooldownPolicy.declinedFreeze
    ) -> VenueAwarenessState {
        guard rows.isEmpty == false else { return .unaware }

        let standingRefusals = rows.filter {
            holdsAStandingRefusal($0, now: now, freeze: declinedFreeze)
        }

        // 1 and 2. The venue's own two acts, in the order it made them.
        //
        // A venue that asked to be left alone after making a code is declined: the
        // later instruction is the one it gave. A venue that made a code after
        // refusing has changed its mind in the other direction, and dragging it back
        // to declined would freeze somebody who is now running the thing.
        //
        // Ordering rather than ranking, because the same two facts in the two orders
        // are two different stories, and a rank can only tell one of them.
        let venuesOwnRefusal = standingRefusals
            .filter { $0.source == .venueBranch }
            .map(\.spokeAt)
            .max()
        let joinedAt = rows.compactMap(\.venueJoinedAt).max()

        switch (venuesOwnRefusal, joinedAt) {
        case (.some(let refused), .some(let joined)):
            return refused >= joined ? .declined : .engaged
        case (.some, .none):
            return .declined
        case (.none, .some):
            return .engaged
        case (.none, .none):
            break
        }

        // 3. Somebody there was told no, and said so through a customer.
        if standingRefusals.isEmpty == false {
            return .declined
        }

        // 4. The most recent word that implies anything, the venue's own first.
        let implications = rows.compactMap(implication(of:))
        if let latest = implications.max(by: { left, right in
            if left.isVenuesOwnWord != right.isVenuesOwnWord {
                return right.isVenuesOwnWord
            }
            return left.at < right.at
        }) {
            return latest.state
        }

        // 5. Shown, and nothing said.
        return .pitched
    }
}

// MARK: - Whether one report is written at all

/// Everything the write rules need to decide, gathered in one place.
///
/// This used to decide where the venue moved as well, from a snapshot each row kept
/// of what its own answer displaced. It no longer does: ``VenueAwarenessFold``
/// computes the venue's state from every row as it stands, so the only question
/// left here is whether THIS report replaces what THIS row already says.
///
/// What that deletes is the point. There is no displaced snapshot, no record of
/// which row owns the state, no fact about whether another row holds a refusal, and
/// no separate notion of a withdrawal: taking an answer back writes `skipped` over
/// it like any other answer, and the fold reads the rows again.
public struct VenueOutcomeContext: Equatable, Sendable {

    /// What is being reported now.
    public let reported: VenueAskOutcome

    /// Which surface it came from.
    public let source: VenueOutcomeSource

    /// What this row already holds, if anything.
    public let existing: VenueAskOutcome?

    /// Which surface that existing answer came from.
    public let existingSource: VenueOutcomeSource?

    public init(
        reported: VenueAskOutcome,
        source: VenueOutcomeSource,
        existing: VenueAskOutcome?,
        existingSource: VenueOutcomeSource?
    ) {
        self.reported = reported
        self.source = source
        self.existing = existing
        self.existingSource = existingSource
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

    /// Why, in one sentence, for a log line and for a reader.
    public let reason: String
}

public enum VenueOutcomeAuthority {

    /// Decides one report, from stated facts, with no database and no side effects.
    ///
    /// Three rules, in this order:
    ///
    /// 1. The venue's own word is not overwritten by a customer's guess about it.
    /// 2. A surface may correct itself.
    /// 3. A card outranks a rating screen, because the card is answered at the
    ///    counter and the rating screen is answered from memory hours later.
    public static func decide(_ context: VenueOutcomeContext) -> VenueOutcomeDecision {
        guard let existing = context.existing else {
            return VenueOutcomeDecision(
                writesTheAnswer: true,
                reason: "Nothing was reported for this introduction before, so this is what it says."
            )
        }
        _ = existing

        // 1. The venue answered for itself.
        if context.existingSource == .venueBranch, context.source != .venueBranch {
            return VenueOutcomeDecision(
                writesTheAnswer: false,
                reason: """
                The venue answered for itself on this introduction, and a customer \
                reporting how the counter reacted is a guess about somebody else.
                """
            )
        }

        // 2 and 3. A surface corrects itself, and a card outranks a rating screen.
        //
        // The self-correction clause is what makes a withdrawal work from the
        // rating screen. The chip there is only ever offered when the card went
        // unanswered, so the first tap writes with `ratingScreen` and taking it
        // back is necessarily the second report from that same surface. Without
        // this the withdrawal was a no-op that answered 200, and the customer
        // watched an answer they had retracted go on buying the venue a freeze.
        let sameSurface = context.existingSource == context.source
        guard context.source == .card || sameSurface else {
            return VenueOutcomeDecision(
                writesTheAnswer: false,
                reason: """
                This introduction already carries an answer from a surface this one \
                does not outrank, so it is left as it is.
                """
            )
        }

        return VenueOutcomeDecision(
            writesTheAnswer: true,
            reason: "Recorded, and where the venue stands is read back from every introduction it has had."
        )
    }
}
