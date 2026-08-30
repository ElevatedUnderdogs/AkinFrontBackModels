import Foundation

// Swath N3 contract (item 6.1): how the author of a piece of content is shown, if at all.
//
// Every question today is anonymous, so `silent` is the default and existing rows keep exactly the
// meaning they already had. Adding a case with a different default would change what was already
// published on behalf of people who never chose it.

/// The kind of authored content a visibility choice is being described for.
///
/// This exists so `AuthorVisibility` can serve questions, responses and questionnaires from one
/// enum. The alternative, three near-copies of the visibility type, is how a fourth content kind
/// later ships with one of the three sets of copy silently stale.
///
/// The noun is spelled out per case rather than derived from the case name, so renaming a Swift
/// case cannot quietly change a sentence shown to a member.
public enum AuthoredContentKind: String, Codable, CaseIterable, Hashable, Sendable {

    /// A question a member wrote.
    case question

    /// A response a member gave.
    case response

    /// A questionnaire a member assembled.
    case questionnaire

    /// The noun as it appears mid sentence, lowercase.
    public var noun: String {
        switch self {
        case .question: return "question"
        case .response: return "response"
        case .questionnaire: return "questionnaire"
        }
    }
}

/// Whether, and how, the author of a piece of content is disclosed.
///
/// The display strings live here rather than in each client so the picker reads identically on iOS,
/// on Android, and on the web. A client that writes its own copy is a client that can drift from
/// what the server means by the stored value.
public enum AuthorVisibility: String, Codable, CaseIterable, Hashable, Sendable {
    /// The author is named. Answers can be traced to a person who chose to be named.
    case attributed

    /// Somebody wrote this and said so, without saying who. The content is announced as authored,
    /// which is a different claim from anonymity, and the author is not identified.
    case unattributedAnnounced

    /// Nothing is said about authorship at all. This is the default and the historical behaviour of
    /// every question that existed before this field.
    case silent

    /// The short label a picker shows. Sentence case, because it sits in a list rather than a title.
    ///
    /// Deliberately free of any content noun: the same three labels read correctly above a question,
    /// a response, or a questionnaire, so there is nothing here to keep in sync.
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
    ///
    /// - Parameter kind: the content the choice applies to, which supplies the noun.
    /// - Returns: the sentence to show beneath the choice.
    public func descriptionForUser(for kind: AuthoredContentKind) -> String {
        switch self {
        case .attributed:
            return "People answering will see that you wrote this \(kind.noun)."
        case .unattributedAnnounced:
            // Says BOTH halves, because the first half alone is incomplete.
            //
            // The second half used to read "The people who follow you will be told it was you",
            // which was true of the notification fan-out as it was then built. GOAL_LOOP13 R21.12
            // reverses that: a notification about content created under this value must not carry
            // an author id and must not name the creator, even to a follower who already chose to
            // follow them. The sentence moves with the behaviour, in the safer direction. Leaving
            // the old promise in place would have made this the one string in the app that tells a
            // member their name WILL be disclosed when it no longer is.
            //
            // Recorded in docs/GOAL_LOOP13_R21_ATTRIBUTION_SPEC.md, section 3.
            return """
            People will see that a member wrote this \(kind.noun), but not which member. \
            Nobody is told it was you.
            """
        case .silent:
            return "People will not be told that anyone wrote this \(kind.noun)."
        }
    }
}
