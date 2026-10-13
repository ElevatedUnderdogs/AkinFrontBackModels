//
//  MeetMark.swift
//  AkinFrontBackModels
//
//  GOAL_LOOP31 Part 5. Want to meet, double blind and mutual, with a concealed window.
//

import Foundation

/// What the server tells a client about a member the caller may have marked.
///
/// RULE V, and it is the single property the whole mechanism rests on. A marked row with NO match
/// and a marked row with a match WAITING OUT the concealed window must be indistinguishable, in
/// the user interface and in the API response. This type is what makes that true by construction
/// rather than by every call site remembering: it has nowhere to put the difference.
///
/// WHAT IS DELIBERATELY ABSENT, because an absence has to be documented or somebody adds it back
/// as a convenience:
///
/// - no `isMutual`, and no `hasPendingReveal`. Either one is the probe. Mark, read the field,
///   rescind, and the prober has learned what the other member thinks, which is the whole thing
///   the window is for.
/// - no `markedAt` for the OTHER member's mark, and no `revealAt`. A fixed window would make
///   reveal time minus the window exactly when the second person marked; the window is jittered
///   per pair for that reason and the jitter never leaves the server either, because a client that
///   knows the jitter can subtract it.
/// - no count of how many members marked you. A count that goes up is a notification with extra
///   steps.
///
/// What a client CAN know is its own mark, because its own mark is its own act.
public struct MeetMarkState: Codable, Hashable, Sendable {

    /// Whether the caller has marked this member.
    ///
    /// The caller's own act, which they already know about: a client that has just tapped the
    /// control needs the server to confirm it landed, and refusing to say would make the control
    /// unable to show its own state.
    public let isMarkedByYou: Bool

    /// Memberwise.
    ///
    /// - Parameter isMarkedByYou: whether the caller has marked this member.
    public init(isMarkedByYou: Bool) {
        self.isMarkedByYou = isMarkedByYou
    }
}

/// One member on the caller's own "I want to meet" list.
///
/// WHAT IT CARRIES AND WHY THAT IS ALL. RULE V: a marked row with no match and a marked row with a
/// match waiting out the concealed window have to be indistinguishable. This type is how that is
/// made true in the API rather than remembered at each call site: every field on it is a fact about
/// the CALLER'S OWN ACT, and there is nowhere to put a fact about the other member's.
///
/// ``markedAt`` is the caller's own mark time, which they performed and already know. It is not the
/// other member's, and there is no field for that one.
public struct MeetMarkedMember: Codable, Hashable, Sendable, Identifiable {

    /// The marked member's identifier, which is what a row taps through to.
    public let id: UUID

    /// Their display name, or nil when they have none on file.
    public let name: String?

    /// When the CALLER marked them.
    public let markedAt: Date

    /// Memberwise.
    ///
    /// - Parameters:
    ///   - id: the marked member.
    ///   - name: their display name, if any.
    ///   - markedAt: when the caller marked them.
    public init(id: UUID, name: String?, markedAt: Date) {
        self.id = id
        self.name = name
        self.markedAt = markedAt
    }
}

/// A mutual reveal, which is the only thing either member is ever told.
///
/// Both members are told in the same instant, after the concealed window measured from the LATER
/// of the two marks has elapsed. Measured from the later mark rather than from either mark alone:
/// if it ran from the first, somebody who marked you a month ago would get an instant reveal the
/// moment you marked them, which is the probe with extra steps.
public struct MutualMeetReveal: Codable, Hashable, Sendable, Identifiable {

    /// The reveal's own identifier, so a client can tell two reveals apart and can mark one read.
    public let id: UUID

    /// The other member.
    public let otherMemberId: UUID

    /// Their display name, or nil when they have no name on file.
    public let otherMemberName: String?

    /// When both members were told.
    ///
    /// The instant of the REVEAL, which both members receive identically. Not when either of them
    /// marked: that pair of instants is what the window exists to conceal, and a reveal carrying
    /// one of them would hand it over at the end.
    public let revealedAt: Date

    /// Memberwise.
    ///
    /// - Parameters:
    ///   - id: the reveal's identifier.
    ///   - otherMemberId: the other member.
    ///   - otherMemberName: their display name, if any.
    ///   - revealedAt: when both were told.
    public init(id: UUID, otherMemberId: UUID, otherMemberName: String?, revealedAt: Date) {
        self.id = id
        self.otherMemberId = otherMemberId
        self.otherMemberName = otherMemberName
        self.revealedAt = revealedAt
    }

    /// The sentence both members read, written once so the two platforms cannot word it two ways.
    ///
    /// "You both want to meet" stays, per the operator's withdrawal of scope removal 4, along with
    /// the explanation that the other member only found out because they said the same. The double
    /// blind IS the point, so the copy says so.
    public var headline: String { "You both want to meet" }

    /// The line under the headline.
    public var explanation: String {
        guard let otherMemberName else {
            return "They marked you too. Neither of you was told until you both had."
        }
        return "\(otherMemberName) marked you too. Neither of you was told until you both had."
    }
}

/// The bounds of the concealed window, stated in the contract and enforced on the server.
///
/// The VALUE for a given pair never leaves the server. The BOUNDS are in the contract because they
/// are a product decision rather than a secret: note 36 says about a week, and a reader of this
/// package is entitled to know what "about" means without reading the server. Knowing the bounds
/// buys a prober nothing, because a four day range is far wider than the resolution any probe
/// could use, and that width is exactly what the jitter is for.
public enum MeetRevealWindow {

    /// The shortest window any pair can draw.
    public static let minimumSeconds: Int = 5 * 86_400

    /// The longest window any pair can draw.
    public static let maximumSeconds: Int = 9 * 86_400

    /// What the operator's note means by "about a week".
    public static let nominalSeconds: Int = 7 * 86_400

    /// Whether a window is inside the bounds. Used by the server's own tests, and by the jitter
    /// measurement in item 5.3, so the range is asserted against the contract rather than against
    /// a literal typed twice.
    ///
    /// - Parameter seconds: a candidate window.
    /// - Returns: `true` when it is within the bounds.
    public static func isWithinBounds(_ seconds: Int) -> Bool {
        (minimumSeconds...maximumSeconds).contains(seconds)
    }
}

/// What the member is told at the moment they mark somebody.
///
/// Item 5.13. One sentence, because without it the most common outcome of using this feature is
/// silence, and the honest read of silence is that the feature is broken. It says they will be
/// told only if it is mutual, and not straight away.
///
/// It never states or implies a duration. "In about a week" would hand over the window, and the
/// window is the only thing standing between this feature and a prober.
public enum MeetMarkCopy {

    /// The expectation setting sentence, shown once when a mark is placed.
    public static let expectation =
        "They hear nothing unless they mark you too, and not straight away."

    /// The control's own label.
    ///
    /// Item 5.12 forbids an invented verb: every call to action on these screens has to exist in
    /// the app already. "I want to meet" is the operator's own phrase for this feature throughout
    /// the review, and `WantToMeetListView` is the screen named after it.
    public static let markControl = "I want to meet"

    /// The label once the mark is placed, which is the way back out of it.
    public static let rescindControl = "Undo I want to meet"
}
