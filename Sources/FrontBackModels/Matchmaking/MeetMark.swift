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

/// Whether a mark was placed from the other member's QUESTION or from their ANSWER.
///
/// GOAL_LOOP34 D1.M1, from Q16. gl29.html's want to meet list writes "On their question: ..." or
/// "On their answer: ...", and its own note calls that line "the only thing on the row that
/// explains why the row exists". The two readings are not interchangeable: a question is what
/// they asked everybody, an answer is what they said to one.
public enum MeetMarkPromptKind: String, Codable, Hashable, Sendable {

    /// The member was reading the other member's question.
    case question

    /// The member was reading the other member's answer.
    case answer
}

/// What the member was reading when they placed a mark.
///
/// A FACT ABOUT THE CALLER'S OWN ACT, which is the only kind of fact this feature stores. It says
/// what THEY were looking at when they marked, so it discloses nothing about the other member
/// that the other member did not already publish, and nothing at all about whether the mark was
/// returned. RULE V is untouched: there is still nowhere here to put a difference between a
/// matched mark and an unmatched one.
///
/// The text is carried as well as the id so a row can be drawn without a second request, and
/// because a question can be edited or withdrawn after a mark is placed: the row says what the
/// member saw.
public struct MeetMarkPrompt: Codable, Hashable, Sendable {

    /// Whether this was the member's question or their answer.
    public let kind: MeetMarkPromptKind

    /// The question this came from, which is what the row taps through to.
    public let questionId: UUID

    /// The words themselves, as the member saw them.
    public let text: String

    /// Memberwise.
    ///
    /// - Parameters:
    ///   - kind: question or answer.
    ///   - questionId: the question it came from.
    ///   - text: the words the member saw.
    public init(kind: MeetMarkPromptKind, questionId: UUID, text: String) {
        self.kind = kind
        self.questionId = questionId
        self.text = text
    }
}

/// The body of a mark: who, and what the member was reading when they marked them.
///
/// IT STILL DECODES A BARE UUID, which is what every client before GOAL_LOOP34 sent and what a
/// TestFlight build in somebody's pocket will keep sending. A payload that only accepted the new
/// object would turn those builds' marks into 400s, which is a worse failure than a row with no
/// prompt line on it.
public struct MarkWantToMeetPayload: Codable, Hashable, Sendable {

    /// The member being marked.
    public let memberId: UUID

    /// What the caller was reading when they marked them, where there was something.
    public let prompt: MeetMarkPrompt?

    /// Memberwise.
    ///
    /// - Parameters:
    ///   - memberId: the member being marked.
    ///   - prompt: what the caller was reading, if anything.
    public init(memberId: UUID, prompt: MeetMarkPrompt? = nil) {
        self.memberId = memberId
        self.prompt = prompt
    }

    private enum CodingKeys: String, CodingKey {
        case memberId
        case prompt
    }

    /// Writes the bare id when there is no prompt, and the object when there is.
    ///
    /// SO A NEW CLIENT KEEPS WORKING AGAINST AN OLD SERVER. The route decoded a bare UUID until
    /// GOAL_LOOP34, and a server that has not shipped this change answers 400 to an object: a
    /// build that always sent the object would break marking everywhere the server is behind it,
    /// which during a staged rollout is everywhere for a while. A mark with nothing to say about
    /// where it came from is exactly the old request, byte for byte, so it stays the old request.
    public func encode(to encoder: any Encoder) throws {
        guard let prompt else {
            var single = encoder.singleValueContainer()
            try single.encode(memberId)
            return
        }
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(memberId, forKey: .memberId)
        try container.encode(prompt, forKey: .prompt)
    }

    /// Decodes the object form, and the bare id older clients send.
    public init(from decoder: any Decoder) throws {
        if let single = try? decoder.singleValueContainer(),
           let identifier = try? single.decode(UUID.self) {
            self.memberId = identifier
            self.prompt = nil
            return
        }
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.memberId = try container.decode(UUID.self, forKey: .memberId)
        self.prompt = try container.decodeIfPresent(MeetMarkPrompt.self, forKey: .prompt)
    }
}

/// Whether a marked member is still named, no longer named, or no longer there.
///
/// GOAL_LOOP34 D1.M15, from Q17. gl29.html draws these as two different rows and two different
/// dialogs, and its own note says why: "one Remove is recoverable while the other is not: the
/// state that decides whether a destructive action can be undone was carried by nothing a member
/// glances at". A member who went anonymous can be marked again if they are ever named again; an
/// account that is gone cannot.
///
/// THE SERVER ALWAYS KNEW. A departed member has no user row and an anonymous one has a row with
/// no name, and the response had no field to say which. This is that field.
///
/// It says nothing about the OTHER member's mark, so RULE V is untouched.
public enum MeetMarkedMemberStatus: String, Codable, Sendable {

    /// They are there and they have a name.
    case named

    /// Their account is there and carries no name any more.
    case anonymous

    /// There is no account any more.
    case departed
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

    /// What the caller was reading when they marked them.
    ///
    /// GOAL_LOOP34 D1.M2. Nil for every mark placed before this field existed, and nil for a mark
    /// placed from a screen with no question on it: the row then draws the name and the date, as
    /// it always did.
    public let prompt: MeetMarkPrompt?

    /// Whether they are still named, no longer named, or no longer there.
    ///
    /// GOAL_LOOP34 D1.M15. A server that predates this field sends none, and the row then falls
    /// back to what a client could already work out from the name alone: named when there is a
    /// name, departed when there is not. That fallback is exactly the reading Q17 is about, so it
    /// is written in one place rather than at each call site.
    public let status: MeetMarkedMemberStatus

    /// Memberwise.
    ///
    /// - Parameters:
    ///   - id: the marked member.
    ///   - name: their display name, if any.
    ///   - markedAt: when the caller marked them.
    ///   - prompt: what the caller was reading when they marked, if anything was stored.
    ///   - status: whether they are still named, no longer named, or no longer there. Defaults to
    ///     the same reading the fallback makes.
    public init(
        id: UUID,
        name: String?,
        markedAt: Date,
        prompt: MeetMarkPrompt? = nil,
        status: MeetMarkedMemberStatus? = nil
    ) {
        self.id = id
        self.name = name
        self.markedAt = markedAt
        self.prompt = prompt
        self.status = status ?? Self.status(forName: name)
    }

    /// What a client can work out from the name alone, which is what a server with no `status`
    /// field leaves it to work out.
    ///
    /// - Parameter name: the name on the row, if any.
    /// - Returns: named, or departed.
    static func status(forName name: String?) -> MeetMarkedMemberStatus {
        guard let name, name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        else { return .departed }
        return .named
    }

    /// Decodes a payload with no `prompt` in it, which is what a server that has not shipped
    /// GOAL_LOOP34 returns.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.markedAt = try container.decode(Date.self, forKey: .markedAt)
        self.prompt = try container.decodeIfPresent(MeetMarkPrompt.self, forKey: .prompt)
        self.status = try container.decodeIfPresent(
            MeetMarkedMemberStatus.self, forKey: .status
        ) ?? Self.status(forName: self.name)
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case markedAt
        case prompt
        case status
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
