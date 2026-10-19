//
//  GreetDemoAvailability.swift
//  AkinFrontBackModels
//
//  GOAL_LOOP26. Which counterpart actions a Demo Greet can drive RIGHT NOW.
//
//  The first version of the demo cell offered all thirteen actions at all
//  times, which is wrong in a way that is worse than it looks. "They answer
//  your call" with nobody ringing, "They hang up" with no call, "They say you
//  met" before either of you has agreed to meet: each of those writes a row
//  into the ledger that describes a thing that cannot have happened, and the
//  screens downstream are then drawn from a history that is not a history.
//
//  So availability is DERIVED from the ledger rather than assumed, and it is
//  derived HERE, in the shared package, because both ends need the same answer
//  for different reasons. The client needs it to decide what is tappable and
//  what to say under a control that is not. The server needs it to refuse,
//  because a client's idea of what is possible is not a rule, it is a drawing.
//  One derivation, two callers, no drift.
//
//  Why a phase plus a call state rather than one flat enum of permutations.
//  The two are orthogonal: a call can be ringing while nobody has agreed to a
//  time, and two people can be on their way to a venue with no call at all. One
//  enum covering every combination would have had `bothAgreedAndRinging`,
//  `bothAgreedAndConnected`, `awaitingAgreementAndRinging` and so on, which is
//  a product of two independent facts written out by hand: every new case on
//  either axis multiplies, and the compiler cannot tell you which combination
//  you forgot. Two small types that each model one fact do not multiply.
//

import Foundation

/// Where the greet's NEGOTIATION stands, derived from the ledger.
///
/// This axis is only about agreeing on a time. Calls are the other axis, in
/// `GreetDemoCallState`, because the two move independently.
public enum GreetDemoPhase: String, Codable, Sendable, Hashable, CaseIterable {

    /// An ending action has been recorded, or the greeting carries an end date.
    /// Nothing is drivable: a greet that is over cannot acquire new history.
    case ended

    /// Nobody has agreed to a time yet. The opening state of every greet.
    case awaitingAgreement

    /// The VIEWER agreed to a time the counterpart has not matched. This is the
    /// state in which "they reject your time" means something.
    case viewerProposed

    /// The COUNTERPART agreed to a time the viewer has not matched.
    case counterpartProposed

    /// Both agreed to the same time. The greet is live: venue, route, travel
    /// progress, and the did-you-meet prompt all belong to this phase.
    case bothAgreed
}

/// Where the greet's CALL stands, derived from the ledger.
///
/// A call is a sequence, `callInitiated` then one of `callAnswered`,
/// `callDeclined` or `callEnded`, so the live state is decided by the LAST
/// CallKit action rather than by counting them. Reading the last one is also
/// what makes a second call later in the same greet work correctly.
public enum GreetDemoCallState: String, Codable, Sendable, Hashable {

    /// No call has been started, or the last one is over.
    case none

    /// The VIEWER started a call that nobody has answered or declined yet.
    /// This is the only state in which the counterpart answering or declining
    /// is a thing that could happen.
    case ringingFromViewer

    /// The COUNTERPART started a call the viewer has not answered.
    case ringingFromCounterpart

    /// A call is connected. The only state in which hanging up means anything.
    case connected
}

/// Everything the availability rules need, in one value derived once.
///
/// A struct rather than a pile of parameters, because the rules below read it
/// repeatedly and because deriving it once per request is what keeps the
/// server's answer and the client's drawing describing the same instant.
public struct GreetDemoContext: Equatable, Sendable {

    public let phase: GreetDemoPhase
    public let call: GreetDemoCallState

    /// Whether the counterpart has already opened the greet screen. Viewing is
    /// a one-time fact, so offering it twice offers a second first time.
    public let counterpartHasViewed: Bool

    /// The times each side has agreed to, in minutes. `0` is "now".
    public let viewerAgreedMinutes: Set<Int>
    public let counterpartAgreedMinutes: Set<Int>

    /// The times the counterpart has already rejected, so a rejection is not
    /// offered twice for the same proposal.
    public let counterpartRejectedMinutes: Set<Int>

    public init(
        phase: GreetDemoPhase,
        call: GreetDemoCallState,
        counterpartHasViewed: Bool,
        viewerAgreedMinutes: Set<Int>,
        counterpartAgreedMinutes: Set<Int>,
        counterpartRejectedMinutes: Set<Int>
    ) {
        self.phase = phase
        self.call = call
        self.counterpartHasViewed = counterpartHasViewed
        self.viewerAgreedMinutes = viewerAgreedMinutes
        self.counterpartAgreedMinutes = counterpartAgreedMinutes
        self.counterpartRejectedMinutes = counterpartRejectedMinutes
    }

    /// Reads a greet's ledger into the facts the rules need.
    ///
    /// - Parameters:
    ///   - events: every event on the greet. Sorted here rather than assumed
    ///     sorted, because the call state depends on which CallKit action is
    ///     LAST and a caller that passes them in arrival order would otherwise
    ///     get a different answer from one that passes them in sequence order.
    ///   - viewerID: the member looking at the screen, or calling the endpoint.
    ///   - counterpartID: the other member on the greet.
    ///   - hasEnded: whether the greeting itself carries an end date. Passed in
    ///     rather than inferred, because the server knows it directly and an
    ///     ending action can be missing from a client's partial ledger.
    public static func derive(
        events: [GreetEvent],
        viewerID: UUID,
        counterpartID: UUID,
        hasEnded: Bool
    ) -> GreetDemoContext {
        let ordered: [GreetEvent] = events.sorted { $0.serverSequenceNumber < $1.serverSequenceNumber }

        let viewerAgreed: Set<Int> = Set(
            ordered.filter { $0.actorUserID == viewerID }.compactMap { $0.action.agreeToTime }
        )
        let counterpartAgreed: Set<Int> = Set(
            ordered.filter { $0.actorUserID == counterpartID }.compactMap { $0.action.agreeToTime }
        )
        let counterpartRejected: Set<Int> = Set(
            ordered
                .filter { $0.actorUserID == counterpartID }
                .compactMap { event -> Int? in
                    if case .rejectTime(let minutes) = event.action { return minutes }
                    return nil
                }
        )

        let viewed: Bool = ordered.contains {
            $0.actorUserID == counterpartID && $0.action.isViewedGreetScreen
        }

        // The LAST CallKit action decides the call state. A greet can carry more
        // than one call, and counting or searching for "any callInitiated" would
        // report a call in progress forever after the first one ended.
        var call: GreetDemoCallState = .none
        if let lastCall = ordered.last(where: { $0.action.isCallKitAction }) {
            switch lastCall.action {
            case .callInitiated:
                call = lastCall.actorUserID == viewerID ? .ringingFromViewer : .ringingFromCounterpart
            case .callAnswered:
                call = .connected
            case .callDeclined, .callEnded:
                call = .none
            default:
                call = .none
            }
        }

        let endedByAction: Bool = ordered.contains { event in
            switch event.action {
            case .dismissGreet, .closeApp, .tappedRedVoipReject, .confirmedMet, .rated:
                return true
            default:
                return false
            }
        }

        let phase: GreetDemoPhase = {
            if hasEnded || endedByAction { return .ended }
            let shared: Set<Int> = viewerAgreed.intersection(counterpartAgreed)
            if !shared.isEmpty { return .bothAgreed }
            if !viewerAgreed.isEmpty { return .viewerProposed }
            if !counterpartAgreed.isEmpty { return .counterpartProposed }
            return .awaitingAgreement
        }()

        return GreetDemoContext(
            phase: phase,
            call: call,
            counterpartHasViewed: viewed,
            viewerAgreedMinutes: viewerAgreed,
            counterpartAgreedMinutes: counterpartAgreed,
            counterpartRejectedMinutes: counterpartRejected
        )
    }
}

/// Whether one counterpart action can be driven now, and if not, why not.
///
/// The reason is a member-facing sentence rather than a code, because it has
/// exactly two readers and both of them are people: a reviewer looking at a
/// control that is not tappable, and a reviewer reading the refusal when they
/// drive the endpoint directly. One sentence written once serves both.
public enum GreetDemoAvailability: Equatable, Sendable {

    case available

    /// Not now, with the sentence explaining what would have to be true first.
    case unavailable(reason: String)

    public var isAvailable: Bool {
        self == .available
    }

    public var reason: String? {
        if case .unavailable(let reason) = self { return reason }
        return nil
    }
}

public enum GreetDemoRules {

    /// Whether this action describes something that could happen next.
    ///
    /// The counterpart's name is interpolated into the sentences so a reviewer
    /// reads about a person rather than about "the counterpart".
    ///
    /// - Parameters:
    ///   - action: the counterpart action being considered.
    ///   - context: the greet's state, from `GreetDemoContext.derive`.
    ///   - counterpartName: how to refer to the other member.
    public static func availability(
        of action: GreetAction,
        in context: GreetDemoContext,
        counterpartName: String
    ) -> GreetDemoAvailability {

        // Dismiss stays reachable even after the greet has ended. The App Review demo
        // partner needs a way to clear leftover meetup UI at all times; locking every
        // row behind the ended guard left Tom with no dismiss once the greet was over.
        // Other actions still cannot write history onto an ended greet.
        if case .dismissGreet = action {
            return .available
        }

        // One rule above all the others: a greet that is over cannot gain history.
        guard context.phase != .ended else {
            return .unavailable(reason: "This greet has ended, so nothing more can happen on it.")
        }

        switch action {

        case .agreedToMeet(let minutes):
            guard !context.counterpartAgreedMinutes.contains(minutes) else {
                return .unavailable(
                    reason: "\(counterpartName) has already agreed to \(Self.readable(minutes))."
                )
            }
            return .available

        case .rejectTime(let minutes):
            guard context.viewerAgreedMinutes.contains(minutes) else {
                return .unavailable(
                    reason: "There is nothing to reject until you propose \(Self.readable(minutes))."
                )
            }
            guard !context.counterpartRejectedMinutes.contains(minutes) else {
                return .unavailable(
                    reason: "\(counterpartName) has already turned down \(Self.readable(minutes))."
                )
            }
            guard !context.counterpartAgreedMinutes.contains(minutes) else {
                return .unavailable(
                    reason: "\(counterpartName) already agreed to \(Self.readable(minutes))."
                )
            }
            return .available

        case .viewedGreetScreen:
            guard !context.counterpartHasViewed else {
                return .unavailable(reason: "\(counterpartName) has already opened this greet.")
            }
            return .available

        case .callInitiated:
            guard context.call == .none else {
                return .unavailable(reason: "A call is already in progress.")
            }
            return .available

        case .callAnswered:
            guard context.call == .ringingFromViewer else {
                return .unavailable(
                    reason: "\(counterpartName) can only answer a call you have started and that is still ringing."
                )
            }
            return .available

        case .callDeclined:
            guard context.call == .ringingFromViewer else {
                return .unavailable(
                    reason: "\(counterpartName) can only decline a call you have started and that is still ringing."
                )
            }
            return .available

        case .callEnded:
            guard context.call == .connected else {
                return .unavailable(reason: "No call is connected, so there is nothing to hang up.")
            }
            return .available

        case .tappedRedVoipReject:
            guard context.call == .ringingFromViewer || context.call == .ringingFromCounterpart else {
                return .unavailable(reason: "The red button belongs to a ringing call, and nothing is ringing.")
            }
            return .available

        case .notGettingCloser:
            guard context.phase == .bothAgreed else {
                return .unavailable(
                    reason: "Nobody is travelling yet. You and \(counterpartName) have to agree on a time first."
                )
            }
            return .available

        case .confirmedMet:
            guard context.phase == .bothAgreed else {
                return .unavailable(
                    reason: "A meeting cannot be confirmed before you have both agreed to one."
                )
            }
            return .available

        case .dismissGreet:
            // Reached only while the greet is still live; the early return above covers
            // the ended case so the demo partner can always clear leftover UI.
            return .available

        case .closeApp:
            // Walking away via close is available for as long as there is something to
            // walk away from, which the `.ended` guard above has already established.
            return .available

        case .manualGreetInitiated, .travelTimeToVenue, .travelDistanceToVenue, .rated:
            return .unavailable(reason: "This is not one of the actions a demo can drive.")
        }
    }

    /// "now" and "in 30 minutes" rather than "0" and "30", because the sentences
    /// above are read by a person.
    static func readable(_ minutes: Int) -> String {
        minutes == 0 ? "meeting now" : "meeting in \(minutes) minutes"
    }
}
