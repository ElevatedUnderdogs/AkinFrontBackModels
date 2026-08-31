import Foundation

// GOAL_LOOP14 item F1. Looking at a question, there was no way to see who wrote
// it, and the same was true of every response. The reason was not the views: the
// wire types carried a creator's UUID and nothing a person could read.
//
// `Question.creatorID` and `Question.Response.creator` are already gated on
// disclosure, so they answer "may this author be named". They do not answer
// "what is their name", and a client cannot turn a UUID into a name without a
// second round trip per row.
//
// Questionnaires already solved this: `BrowseQuestionnaire` and
// `QuestionnaireDetail` carry a creator id AND a creator name, populated by a
// real lookup gated through `AuthorDisclosure`. This type is that shape, named
// and shared, so questions and responses stop being the two content kinds that
// cannot show an author.

/// Enough about an author to draw them, when they have been disclosed.
///
/// Present only when the content's `AuthorVisibility` allows it. That is the
/// whole contract: a value here means the author chose to be named, and its
/// absence means they did not. Making it optional rather than making the fields
/// optional is deliberate, because "an author with no name" is not a state that
/// should be representable, and the two serializers that had to invent a value
/// for the undisclosed case previously invented different ones, one a leak and
/// one a fabricated identifier.
public struct AuthorSummary: Codable, Hashable, Sendable, Identifiable {

    /// The member. Present because a chip has to be tappable through to a
    /// profile, which is F1.7.
    public let id: UUID

    /// What to show. Already resolved server side, so a list of twenty
    /// responses is one request rather than twenty one.
    public let displayName: String

    /// Their picture, when they have one.
    ///
    /// A string rather than a `URL` to match every other image field on these
    /// types, and because a malformed value from an older row should render a
    /// placeholder rather than fail the whole decode of the content it belongs
    /// to.
    public let profileImageURL: String?

    public init(id: UUID, displayName: String, profileImageURL: String? = nil) {
        self.id = id
        self.displayName = displayName
        self.profileImageURL = profileImageURL
    }

    /// What a chip shows when there is a name but it is empty or blank.
    ///
    /// A row whose member never set a name would otherwise render an avatar
    /// beside nothing, which reads as a broken chip rather than as a person.
    /// F1.8 asks that an anonymised author look deliberate; this asks the same
    /// of a named one whose name happens to be missing.
    public static let unnamedFallback = "A member"

    /// The name to draw, never empty.
    public var resolvedDisplayName: String {
        let trimmed = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? Self.unnamedFallback : trimmed
    }
}
