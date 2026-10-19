//
//  MeetMark.swift
//  AkinFrontBackModels
//
//  GOAL_LOOP31 Part 5, as revised by GOAL_LOOP29 decision D3. Want to meet, private and one
//  sided. There is no reveal, so there is no concealed window either: the window only ever
//  existed to delay a telling that no longer happens.
//

import Foundation

/// What the server tells a client about a member the caller may have marked.
///
/// RULE V, and it is the single property the whole mechanism rests on. A marked row where the
/// other member has NOT marked back and a marked row where they HAVE must be indistinguishable,
/// in the user interface and in the API response. Decision D3 made that permanent rather than
/// temporary: mutuality is never disclosed, at any point, so there is no later moment at which
/// the two cases are allowed to diverge. This type is what makes it true by construction rather
/// than by every call site remembering: it has nowhere to put the difference.
///
/// WHAT IS DELIBERATELY ABSENT, because an absence has to be documented or somebody adds it back
/// as a convenience:
///
/// - no `isMutual`. It is the probe. Mark, read the field, rescind, and the prober has learned
///   what the other member thinks.
/// - no `markedAt` for the OTHER member's mark. Their timing is their own act, and the caller is
///   not a party to it.
/// - no count of how many members marked you. A count that goes up is a notification with extra
///   steps.
///
/// What a client CAN know is its own mark, because its own mark is its own act. What mutuality
/// does instead is sort: see `MeetMarkController.rankedByMeetMarks` on the server, which is the
/// whole of what a second mark buys and says nothing on any screen.
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
/// WHAT IT CARRIES AND WHY THAT IS ALL. RULE V: a marked row the other member has not marked back
/// and a marked row they have must be indistinguishable, permanently, under decision D3. This type
/// is how that is made true in the API rather than remembered at each call site: every field on it
/// is a fact about the CALLER'S OWN ACT, and there is nowhere to put a fact about the other
/// member's.
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

/// What the member is told at the moment they mark somebody.
///
/// Item 5.13. One sentence, because without it the most common outcome of using this feature is
/// silence, and the honest read of silence is that the feature is broken.
///
/// WHAT THE SENTENCE MAY NOT DO, under decision D3. It may not promise a later telling, because
/// there is no later telling: the mark is private and one sided, always, and the other member is
/// never informed at any point. The previous wording held out a condition, that they would hear
/// something if they marked back, and a condition that can be satisfied is a promise. So the
/// sentence states the silence flatly and then says what a mark is actually worth, which is the
/// sort order and nothing else.
public enum MeetMarkCopy {

    /// The expectation setting sentence, shown once when a mark is placed.
    ///
    /// It names the ranking because that is the entire effect, and a sentence that said only
    /// "nobody is told" would describe a control that does nothing.
    public static let expectation =
        "Nobody is told, at any point. It only moves you up their nearby list."

    /// The control's own label.
    ///
    /// Item 5.12 forbids an invented verb: every call to action on these screens has to exist in
    /// the app already. "I want to meet" is the operator's own phrase for this feature throughout
    /// the review, and `WantToMeetListView` is the screen named after it.
    public static let markControl = "I want to meet"

    /// The label once the mark is placed, which is the way back out of it.
    public static let rescindControl = "Undo I want to meet"
}
