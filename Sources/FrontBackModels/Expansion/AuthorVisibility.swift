import Foundation

// Swath N3 contract (item 6.1): how a question's author is shown, if at all.
//
// Every question today is anonymous, so `silent` is the default and existing rows keep exactly the
// meaning they already had. Adding a case with a different default would change what was already
// published on behalf of people who never chose it.

/// Whether, and how, the author of a question is disclosed to the people answering it.
///
/// The display strings live here rather than in each client so the picker reads identically on iOS,
/// on Android, and on the web. A client that writes its own copy is a client that can drift from
/// what the server means by the stored value.
public enum AuthorVisibility: String, Codable, CaseIterable, Hashable, Sendable {
    /// The author is named. Answers can be traced to a person who chose to be named.
    case attributed

    /// Somebody wrote this and said so, without saying who. The question is announced as authored,
    /// which is a different claim from anonymity, and the author is not identified.
    case unattributedAnnounced

    /// Nothing is said about authorship at all. This is the default and the historical behaviour of
    /// every question that existed before this field.
    case silent

    /// The short label a picker shows. Sentence case, because it sits in a list rather than a title.
    public var displayName: String {
        switch self {
        case .attributed: return "Show my name"
        case .unattributedAnnounced: return "Say someone wrote it"
        case .silent: return "Say nothing"
        }
    }

    /// One sentence, addressed to the member, describing what other people will see.
    ///
    /// Written in the second person on purpose: the member is choosing what happens to them, and a
    /// description in the third person reads as documentation of a system rather than a choice.
    public var descriptionForUser: String {
        switch self {
        case .attributed:
            return "People answering will see that you wrote this question."
        case .unattributedAnnounced:
            // Says BOTH halves, because the first half alone is false.
            //
            // This used to read "People will see that a member wrote this question, but not which
            // member", which is true of the public view and untrue of the notification: this value
            // names the author to that member's own followers, by name, which is the whole
            // distinction between it and `silent`. A member choosing it read a sentence promising
            // nobody would learn it was them, and then their followers learned it was them. Found
            // while judging a UX review of the picker that shows this string.
            return """
            People will see that a member wrote this question, but not which member. \
            The people who follow you will be told it was you.
            """
        case .silent:
            return "People will not be told that anyone wrote this question."
        }
    }
}
