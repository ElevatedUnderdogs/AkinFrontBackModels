import Foundation

// GOAL_LOOP14 item F5. This was a three-case enum: `attributed`,
// `unattributedAnnounced`, `silent`. The middle case is retired.
//
// It was already dead in behaviour before it was retired in type. GOAL_LOOP13
// R21.12 stopped a notification arising from `unattributedAnnounced` content
// from carrying an author id or naming the creator, even to a follower who had
// chosen to follow them. That was the last thing separating it from `silent`.
// After R21.12 the two values disclose the author to nobody, on any surface,
// and differ only in what the surface CLAIMS: one says a member wrote this, the
// other says nothing. A member was being asked to reason about a distinction
// that changed nothing they could observe.
//
// What replaces it is one switch, "Anonymize me", off by default. The contract,
// the migration mapping for every legacy value, and why an unknown value
// decodes closed rather than open, are in
// `akin/docs/GOAL_LOOP14_AUTHORSHIP_CONTRACT.md`.

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

    /// The plural noun, for copy that talks about a member's other content.
    public var pluralNoun: String {
        switch self {
        case .question: return "questions"
        case .response: return "responses"
        case .questionnaire: return "questionnaires"
        }
    }
}

/// Whether the author of a piece of content is disclosed.
///
/// Two states, because the member is making one decision: put my name on this, or do not. The
/// display strings live here rather than in each client so the switch reads identically on iOS,
/// on Android, and on the web. A client that writes its own copy is a client that can drift from
/// what the server means by the stored value.
public enum AuthorVisibility: String, Codable, CaseIterable, Hashable, Sendable {

    /// The author is named on the content and can be followed from it. This is the default: the
    /// switch is off, and the ordinary case is that people see who wrote what they are reading.
    case attributed

    /// The author is not named anywhere, and cannot be followed from this content. No notification
    /// arising from it names them either, which after R21.12 is already true of both values this
    /// case absorbs.
    case anonymized

    // MARK: - Legacy storage

    /// Raw values written before this type became two-state.
    ///
    /// These are not cases. Nothing can select one, store one, or switch over one. They exist so
    /// that a row written by an older build decodes to a defined answer instead of throwing, which
    /// turns a stale row into a slightly stale label rather than a 500.
    public enum Legacy {

        /// Nothing was said about authorship, and the author could not be followed from the
        /// content. That is what ``AuthorVisibility/anonymized`` means.
        public static let silent = "silent"

        /// The surface claimed a member wrote it, without saying which member. After R21.12 it
        /// disclosed the author to nobody, including followers, so it and ``silent`` had become
        /// the same thing behind two labels.
        public static let unattributedAnnounced = "unattributedAnnounced"

        /// Every raw value this type has ever written, current cases included.
        ///
        /// The database CHECK constraint has to admit all of these until the GOAL_LOOP14 backfill
        /// has run and been proven revertible, because a constraint narrower than the data is a
        /// failed write, not a clean migration.
        public static let allStoredRawValues: [String] = [
            AuthorVisibility.attributed.rawValue,
            AuthorVisibility.anonymized.rawValue,
            silent,
            unattributedAnnounced
        ]

        /// The documented mapping from any stored value to a current case.
        ///
        /// - Parameter rawValue: whatever the storage holds.
        /// - Returns: the case that value means today.
        public static func visibility(forStored rawValue: String) -> AuthorVisibility {
            if let known = AuthorVisibility(knownRawValue: rawValue) {
                return known
            }
            // An unrecognised value is one this build does not understand. The two possible
            // guesses are not symmetric: guessing `attributed` publishes a name the value might
            // have been withholding, which the member cannot take back from anyone who saw it.
            // Guessing `anonymized` withholds a name it might have published, which is visible,
            // reportable and fixable. Fail closed.
            return .anonymized
        }
    }

    /// The plain lookup, without the unknown-value fallback.
    ///
    /// Separated out so ``Legacy/visibility(forStored:)`` can ask "is this a value I recognise?"
    /// without recursing through its own default.
    private init?(knownRawValue rawValue: String) {
        switch rawValue {
        case AuthorVisibility.attributed.rawValue: self = .attributed
        case AuthorVisibility.anonymized.rawValue: self = .anonymized
        case Legacy.silent, Legacy.unattributedAnnounced: self = .anonymized
        default: return nil
        }
    }

    /// Decoding routes every stored value through the documented mapping, so a row written by any
    /// past build decodes rather than throwing.
    public init(from decoder: Decoder) throws {
        let rawValue = try decoder.singleValueContainer().decode(String.self)
        self = Legacy.visibility(forStored: rawValue)
    }

    /// The state the switch is in when a member has expressed no preference.
    ///
    /// Off, meaning ``attributed``. Named rather than left implicit at each call site, so "what is
    /// the default" has exactly one answer to change.
    public static let `default`: AuthorVisibility = .attributed

    // MARK: - The switch

    /// The switch's label. The member is turning anonymity ON, so the label names the thing being
    /// turned on rather than the state being left behind.
    public static let switchLabel: String = "Anonymize me"

    /// Whether the switch is on for this value.
    public var isAnonymized: Bool { self == .anonymized }

    /// The value the switch produces.
    ///
    /// The single conversion from switch state to stored value, so authorship cannot come to mean
    /// two different things depending on which sheet the member used.
    ///
    /// - Parameter isAnonymized: whether the member turned the switch on.
    public static func from(isAnonymized: Bool) -> AuthorVisibility {
        isAnonymized ? .anonymized : .attributed
    }

    /// The explanation shown beside the switch, in the second person because the member is
    /// choosing what happens to them.
    ///
    /// Names both consequences. The first half alone is the sentence the retired middle option
    /// shipped for most of its life, and it was not the whole truth; a control whose consequence is
    /// not stated beside the control is how a member ends up surprised by their own choice.
    ///
    /// - Parameter kind: the content the choice applies to, which supplies the nouns.
    /// - Returns: the sentence to show beneath the switch.
    public static func switchExplanation(for kind: AuthoredContentKind) -> String {
        """
        We will not show you as the creator of this \(kind.noun), and people will not be able to \
        follow you from it to find out when you create other questions and responses.
        """
    }

    /// One sentence describing what other people will see, for each state.
    ///
    /// - Parameter kind: the content the choice applies to, which supplies the noun.
    /// - Returns: the sentence to show beneath the choice.
    public func descriptionForUser(for kind: AuthoredContentKind) -> String {
        switch self {
        case .attributed:
            return "People will see that you wrote this \(kind.noun), and can follow you from it."
        case .anonymized:
            return AuthorVisibility.switchExplanation(for: kind)
        }
    }

    /// The short label, kept because call sites outside the switch still read it.
    ///
    /// Deliberately free of any content noun: the same labels read correctly above a question, a
    /// response, or a questionnaire, so there is nothing here to keep in sync.
    public var displayName: String {
        switch self {
        case .attributed: return "Show my name"
        case .anonymized: return AuthorVisibility.switchLabel
        }
    }
}
