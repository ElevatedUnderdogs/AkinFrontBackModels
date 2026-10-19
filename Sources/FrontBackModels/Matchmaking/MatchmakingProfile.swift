import Foundation

// Swath N4 contracts (item 7.1): a named, activatable set of question selections owned by one
// member inside one context.
//
// The shape comes from the operator's own example: a badminton profile activated to meet a
// badminton partner, without re-answering anything. That is the whole design constraint. A profile
// is a VIEW over answers the member has already given, plus the ones they changed for this
// purpose, so switching profiles must never feel like starting again.

/// One named set of selections, owned by a member, scoped to a context.
public struct MatchmakingProfile: Codable, Hashable, Sendable, Identifiable {
    /// The profile's own identifier.
    ///
    /// Spelled `id` rather than `profileID` because it is the identifier OF this value, and
    /// `Identifiable` gives it a meaning every consumer already knows.
    public let id: UUID
    /// The member who owns it.
    ///
    /// Ends `Id`, not `ID`, and that is load bearing. The server installs
    /// `.convertToSnakeCase` / `.convertFromSnakeCase` process wide, and Foundation's conversion is
    /// not its own inverse when a name ends in an acronym: `ownerID` encodes to `owner_id` and
    /// decodes back as `ownerId`, a different coding key, so the payload cannot be read by a client
    /// using the same coders. This defect has been shipped three times in this expansion already.
    public let ownerId: UUID
    /// The context it applies in. A member matches in one context at a time.
    public let contextId: UUID
    /// What the member calls it. "Badminton", "work", "the one for weekends".
    public let name: String
    /// Whether this is the profile the matcher currently reads for this member and context.
    public let isActive: Bool
    /// When it was created.
    public let createdAt: Date

    /// Memberwise initializer.
    /// - Parameters:
    ///   - id: the profile's identifier.
    ///   - ownerId: the member who owns it.
    ///   - contextId: the context it applies in.
    ///   - name: the member's name for it.
    ///   - isActive: whether the matcher currently reads it.
    ///   - createdAt: when it was created.
    public init(
        id: UUID,
        ownerId: UUID,
        contextId: UUID,
        name: String,
        isActive: Bool,
        createdAt: Date
    ) {
        self.id = id
        self.ownerId = ownerId
        self.contextId = contextId
        self.name = name
        self.isActive = isActive
        self.createdAt = createdAt
    }
}

/// Whether a profile answer describes the member or the partner they are looking for.
///
/// Mirrors `Question.Response.Selections.MyTheir`, because a profile answer has to be able to sit
/// exactly where a member's own answer sits. Compatibility is computed by comparing what one member
/// wants (`their`) against what the other IS (`my`), so a profile that could not say which of the
/// two it meant would be unusable by the matcher no matter how well it was stored.
public enum ProfileSelectionSide: String, Codable, CaseIterable, Hashable, Sendable {
    /// Describes the member.
    case my
    /// Describes the partner the member is looking for.
    case their
}

/// One question's answer inside one profile.
///
/// Separate from the member's raw selection rather than replacing it. Item 7.5 requires that no
/// member loses an answer when profiles arrive, so a profile holds its own selections and the
/// member's existing answers become the default profile's, rather than being migrated away.
public struct ProfileSelection: Codable, Hashable, Sendable {
    /// The profile this selection belongs to.
    public let profileId: UUID
    /// The question being answered.
    public let questionId: UUID
    /// The specific response being chosen.
    ///
    /// Carried as well as the question because compatibility is computed per RESPONSE: one
    /// question has several responses and a member picks among them. A selection that named only
    /// its question could be stored and shown but could never be scored, which would make profiles
    /// cosmetic.
    public let responseId: UUID
    /// Whether this answer describes the member or the partner they want.
    public let side: ProfileSelectionSide
    /// The answer, in the same vocabulary the member's raw selections use.
    public let selection: String
    /// How much this profile cares about this question, when it differs from the member's own
    /// rating.
    ///
    /// Optional because most selections in a duplicated profile will not override anything, and an
    /// override that defaults to a number cannot be told apart from one the member chose. Item 7.6
    /// makes duplication the cheapest way to build a profile, so most of these are nil by design.
    public let importance: Double?

    /// Memberwise initializer.
    /// - Parameters:
    ///   - profileId: the profile this belongs to.
    ///   - questionId: the question answered.
    ///   - responseId: the response chosen.
    ///   - side: whether it describes the member or the partner they want.
    ///   - selection: the answer.
    ///   - importance: an override, or nil to use the member's own rating.
    public init(
        profileId: UUID,
        questionId: UUID,
        responseId: UUID,
        side: ProfileSelectionSide,
        selection: String,
        importance: Double? = nil
    ) {
        self.profileId = profileId
        self.questionId = questionId
        self.responseId = responseId
        self.side = side
        self.selection = selection
        self.importance = importance
    }
}
