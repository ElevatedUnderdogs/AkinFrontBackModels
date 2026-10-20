//
//  ContextNameSuggestion.swift
//  AkinFrontBackModels
//
//  GOAL_LOOP31 item 2.13. What the create sheet says about a name that is close to one that
//  already exists, and why it never refuses.
//

import Foundation

/// What the create sheet has noticed about the name being typed.
///
/// FOUR STATES, AND THE ONE THING THEY HAVE IN COMMON: none of them blocks. `D5` is explicit that
/// no refusal is built on what a context is called, and `D1`'s deduplication is a JOIN rather than
/// a rejection. Every case below either offers an existing context or says nothing, and in every
/// case the member can carry on with the name they typed.
///
/// WHY THE DISTINCTION BETWEEN THE LAST TWO MATTERS. "Boulder" against "Bouldering" is a member
/// typing a shorter name for the same thing, and the cost of getting it wrong is a split
/// population: two contexts with nearly the same name, neither able to find the other.
/// "Bouldring" against "Bouldering" is a typo, and the cost of getting it wrong is one member
/// alone in a context nobody else will ever type. They need different sentences because they are
/// different mistakes, and the comp writes them differently.
public enum ContextNameSuggestion: Hashable, Sendable {

    /// Nothing to say. The name is new, or too short to compare.
    case none

    /// The name IS an existing context's name, letter for letter.
    ///
    /// - Parameter existing: the context already there.
    case alreadyExists(ContextCatalogEntry)

    /// The name folds onto an existing context under a DIFFERENT spelling, so creating it is
    /// joining that one and seeing its name rather than the one just typed.
    ///
    /// GOAL_LOOP34 A5.Pg, from gl29.html's `case-collapse`: the comp draws this as its own
    /// state, "You are joining Bouldering" over "This context is already here under that
    /// spelling, so you join the members in it and see their spelling of the name.", where an
    /// exact match says "Bouldering already exists." The two sentences answer different
    /// questions: one tells the member the context is there, the other tells them the name they
    /// are about to see is not the one they typed. The copy for both has been in this file since
    /// GOAL_LOOP31; only the exact case was ever returned.
    ///
    /// - Parameter existing: the context already there.
    case joining(ContextCatalogEntry)

    /// The name is a near duplicate: it is contained in, or contains, an existing name.
    ///
    /// - Parameter existing: the context already there.
    case nearDuplicate(ContextCatalogEntry)

    /// The name looks like a misspelling of an existing one.
    ///
    /// - Parameter existing: the context already there.
    case probableMisspelling(ContextCatalogEntry)

    /// The context this suggestion is about, where there is one.
    public var existing: ContextCatalogEntry? {
        switch self {
        case .none: return nil
        case .alreadyExists(let entry), .joining(let entry), .nearDuplicate(let entry),
             .probableMisspelling(let entry):
            return entry
        }
    }

    /// Whether this suggestion stops the member creating what they typed.
    ///
    /// Always `false`, and it is a property rather than a comment so a future case cannot quietly
    /// become a refusal. Item 2.13: the sheet WARNS and never blocks.
    public var blocksCreation: Bool { false }
}

/// Works out what to say about a name that is close to one that already exists.
///
/// IN THE SHARED PACKAGE rather than in the client, for the reason `ContextName` is: the server
/// enforces the fold and the client offers the match while the member is still typing, and two
/// implementations of "is this the same context" disagree the first time one of them changes.
public enum ContextNameSuggestions {

    /// The shortest typed name worth comparing.
    ///
    /// Below this almost everything looks like a near duplicate of something: "ch" is contained in
    /// "chess", "church" and "chemistry", and a sheet that says so on the second keystroke is a
    /// sheet nobody reads by the fourth.
    public static let minimumLengthToCompare: Int = 4

    /// The largest edit distance that still reads as a misspelling rather than a different word.
    ///
    /// Two, which covers a dropped letter, a doubled letter, a transposition and one wrong letter.
    /// At three, "chess" and "chem" would pair, and they are different things.
    public static let maximumMisspellingDistance: Int = 2

    /// What to say about this name.
    ///
    /// - Parameters:
    ///   - typed: whatever the member has typed so far.
    ///   - catalog: the contexts to compare against.
    /// - Returns: the suggestion, which is `.none` when there is nothing worth saying.
    public static func suggestion(
        for typed: String, in catalog: [ContextCatalogEntry]
    ) -> ContextNameSuggestion {
        let key = ContextName.normalisedKey(typed)
        guard key.isEmpty == false else { return .none }

        // An exact fold first, because it is not a warning at all: it is the deduplication `D1`
        // asks for, and the member is joining rather than creating.
        //
        // TWO ANSWERS, NOT ONE, which is what gl29.html draws. A name typed exactly as the
        // existing one is told the context already exists; a name that only folds onto it after
        // normalisation is told it is JOINING that context, because the name it is about to see
        // is the other spelling rather than the one just typed. Returning the first for both put
        // "Bouldering already exists." in front of a member who typed "bouldering" and never told
        // them whose spelling would win.
        if let exact = catalog.first(where: { $0.normalisedKey == key }) {
            let typedName = typed.trimmingCharacters(in: .whitespacesAndNewlines)
            return typedName == exact.displayName ? .alreadyExists(exact) : .joining(exact)
        }
        guard key.count >= minimumLengthToCompare else { return .none }

        // Containment next. Checked before edit distance because "Boulder" inside "Bouldering" is
        // eight edits away and would never be reached by the distance test, and it is the case
        // that costs a split population.
        let contained = catalog
            .filter { $0.normalisedKey.contains(key) || key.contains($0.normalisedKey) }
            .filter { $0.normalisedKey.count >= minimumLengthToCompare }
            .max { $0.memberCount < $1.memberCount }
        if let contained { return .nearDuplicate(contained) }

        let close = catalog
            .filter { editDistance(key, $0.normalisedKey) <= maximumMisspellingDistance }
            .max { $0.memberCount < $1.memberCount }
        if let close { return .probableMisspelling(close) }

        return .none
    }

    /// Levenshtein distance between two strings.
    ///
    /// Written out rather than taken from a dependency, because it is twenty lines and the two
    /// things that would otherwise supply it, `NSString.compare` with a diacritic option and
    /// `SwiftUI`'s fuzzy matching, answer different questions.
    ///
    /// - Parameters:
    ///   - one: a string.
    ///   - other: another string.
    /// - Returns: how many single character edits turn one into the other.
    public static func editDistance(_ one: String, _ other: String) -> Int {
        let left = Array(one)
        let right = Array(other)
        if left.isEmpty { return right.count }
        if right.isEmpty { return left.count }

        // One row at a time rather than the whole matrix: the distance only ever needs the
        // previous row, and a context name is short enough that this is about readability rather
        // than about memory.
        var previous = Array(0...right.count)
        var current = [Int](repeating: 0, count: right.count + 1)

        for i in 1...left.count {
            current[0] = i
            for j in 1...right.count {
                let substitution = previous[j - 1] + (left[i - 1] == right[j - 1] ? 0 : 1)
                let insertion = current[j - 1] + 1
                let deletion = previous[j] + 1
                current[j] = min(substitution, insertion, deletion)
            }
            swap(&previous, &current)
        }
        return previous[right.count]
    }
}

/// The sentences the create sheet shows, written once so the client cannot reword them.
///
/// Every string here is the comp's, from `annotation-site/public/comps/ContextCreateSheet.html`.
/// RULE D: the published comp for a screen is what that screen must look like, and that includes
/// what it says.
public enum ContextCreateCopy {

    /// The sheet's title.
    public static let title = "Create a context"

    /// What a member is agreeing to by creating one.
    public static let subtitle =
        "Everyone can see a context you create, and anyone can join it. Name it for the thing you "
        + "want to do, not for yourself."

    /// The field's label.
    public static let fieldLabel = "Context name"

    /// Why the preview chip is violet.
    public static let colourNote =
        "Every context members create shares this colour. The built in ones have their own."

    /// What the suggestion chips are for, shown while the field is empty.
    public static let suggestionsLabel = "Tap one of these to fill the field"

    /// The consequences, shown above the button at every state.
    public static let consequences =
        "Creating it publishes the name to everyone, and you cannot change the name afterwards. "
        + "You can stop participating any time, in Settings under Contexts."

    /// The primary action when the name is new.
    public static let createAction = "Create"

    /// The counter, shown once the name is long enough to be worth counting.
    ///
    /// - Parameters:
    ///   - count: how many characters are typed.
    ///   - maximum: the ceiling.
    /// - Returns: "27 of 32 characters".
    public static func counter(count: Int, maximum: Int) -> String {
        "\(count) of \(maximum) characters"
    }

    /// Where the counter starts appearing.
    ///
    /// At 24 of 32, which is the comp's own state: the counter is absent at "Bouldering" and
    /// present at "Bouldering after work group". A counter that is always there is a limit the
    /// member is being measured against from the first letter.
    public static let counterAppearsAt: Int = 24

    /// The headline when the typed name folds onto an existing context.
    ///
    /// - Parameter existing: the context already there.
    /// - Returns: "Bouldering already exists."
    public static func alreadyExistsHeadline(_ existing: String) -> String {
        "\(existing) already exists."
    }

    /// The line under it.
    public static let alreadyExistsBody =
        "Switch it on and other members will find you alongside everyone already in it."

    /// The headline when the spelling differs but the context is the same.
    ///
    /// - Parameter existing: the context already there.
    /// - Returns: "You are joining Bouldering".
    public static func joiningHeadline(_ existing: String) -> String {
        "You are joining \(existing)"
    }

    /// The line under it.
    public static let joiningBody =
        "This context is already here under that spelling, so you join the members in it and see "
        + "their spelling of the name."

    /// The action that joins.
    ///
    /// - Parameter existing: the context already there.
    /// - Returns: "Join Bouldering".
    public static func joinAction(_ existing: String) -> String { "Join \(existing)" }

    /// The headline for a near duplicate.
    ///
    /// - Parameter existing: the context already there.
    /// - Returns: "Bouldering already exists".
    public static func nearDuplicateHeadline(_ existing: String) -> String {
        "\(existing) already exists"
    }

    /// What a near duplicate would cost.
    ///
    /// - Parameters:
    ///   - memberCount: how many are already in it.
    ///   - existing: the context already there.
    /// - Returns: the sentence the comp carries.
    public static func nearDuplicateBody(memberCount: Int, existing: String) -> String {
        "\(memberCount) members are already in it. Creating a second context with nearly the same "
            + "name would split them from you, and neither group would be able to find the other."
    }

    /// The choice, spelled out.
    ///
    /// - Parameter existing: the context already there.
    /// - Returns: the sentence the comp carries.
    public static func nearDuplicateGuidance(_ existing: String) -> String {
        "Add \(existing) and you will be in it with everyone already there. If you meant something "
            + "different, keep your own name."
    }

    /// The action that joins the existing context.
    ///
    /// - Parameter existing: the context already there.
    /// - Returns: "Add Bouldering".
    public static func addAction(_ existing: String) -> String { "Add \(existing)" }

    /// The action that keeps what the member typed.
    ///
    /// - Parameter typed: what they typed.
    /// - Returns: "Keep Boulder".
    public static func keepAction(_ typed: String) -> String { "Keep \(typed)" }

    /// The headline for a probable misspelling.
    ///
    /// - Parameter existing: the context already there.
    /// - Returns: "Did you mean Bouldering?"
    public static func misspellingHeadline(_ existing: String) -> String {
        "Did you mean \(existing)?"
    }

    /// The line under it.
    ///
    /// - Parameters:
    ///   - memberCount: how many are in the existing context.
    ///   - existing: the context already there.
    /// - Returns: the sentence the comp carries.
    public static func misspellingBody(memberCount: Int, existing: String) -> String {
        "\(memberCount) members are in \(existing). Keep your spelling if you meant it."
    }

    /// The action that takes the existing spelling.
    ///
    /// - Parameter existing: the context already there.
    /// - Returns: "Use Bouldering".
    public static func useAction(_ existing: String) -> String { "Use \(existing)" }

    /// How many members are in a context, on the offered row.
    ///
    /// - Parameter count: the member count.
    /// - Returns: "412 members".
    public static func memberCountLine(_ count: Int) -> String {
        count == 1 ? "1 member" : "\(count) members"
    }

    /// What the sheet says when the create request did not land.
    ///
    /// NOT A JUDGEMENT, and that is the whole reason this string exists. The first version of the
    /// sheet had one `catch`, and that `catch` built the moderation refusal, so a member whose
    /// phone dropped its connection, or whose account lacks the create entitlement, or who created
    /// while the moderation vendor was down, was told their name could be considered vulgar. An
    /// accusation the product cannot support, for a condition the member did not cause, about a
    /// name nothing judged.
    ///
    /// The comp has its own state for this: `annotation-site/public/comps/ContextCreateSheet.html`
    /// section `data-state="failed"` keeps the Create capsule live and adds this one destructive
    /// caption under it.
    ///
    /// THE THIRD SENTENCE IS THE ONE THAT MATTERS. The member has just tried to publish a name to
    /// a global catalog, so their live question is whether a half created context is now sitting in
    /// it with their name on it. It says no.
    ///
    /// THE COMP AND THE SPEC DISAGREE about that third sentence, and this follows the comp under
    /// RULE D. `design-coverage/specs/ContextCreateSheet.md` writes "Nothing has been published
    /// yet."; the comp writes what is here. The apostrophe is the typographic one the comp uses.
    public static let createFailed =
        "That did not go through. Check your connection and tap Create again. "
        + "You haven\u{2019}t created it yet."

    /// The control that dismisses a refusal.
    ///
    /// The comp's own label, on the secondary that replaces the Create capsule while a refusal is
    /// up: `data-state="moderation-declined"` draws `<button class="btn-secondary">Okay</button>`.
    public static let refusalDismiss = "Okay"
}
