//
//  DisplayName.swift
//  AkinFrontBackModels
//
//  GOAL_LOOP27 note 2, and the defect that note exposed.
//
//  ## Why how a name reads is a shared contract rather than a detail of either side
//
//  Note 2 renamed the two review accounts and asked that every surface showing a demo account's name
//  show the new one. Three surfaces read that name by three different paths: the nearby list cell, the
//  greet screen's counterpart title, and the refusal sentence the server writes into the greet ledger.
//  GOAL_LOOP26 already caught those paths disagreeing once. The server's refusal used `firstName`
//  while the app's greyed control used the full name, so the same person was named two different ways
//  in two sentences built from the SAME function, `GreetDemoAvailability.availability(counterpartName:)`,
//  which takes the name as a String and therefore cannot tell that its callers disagree.
//
//  That is the shape of a contract living in neither place. So it lives here, in the package both
//  sides already build against, and the two sides stop being able to differ.
//
//  ## The defect this also fixes, which was live before the rename
//
//  The server composed a display name as `firstName + " " + lastName`. That emits a TRAILING SPACE
//  whenever the last name is empty, and it was not hypothetical: measured on 2026-10-01, one of the
//  fourteen production rows had an empty `last_name`, so every surface reading that member's name was
//  rendering it with a space stuck on the end. Note 2 then made it matter on two more rows, because
//  the review accounts were given a single given name and no surname.
//
//  Joining the non empty parts rather than trimming the concatenation, so a member with a surname and
//  no given name composes correctly too, which `firstName + " " + lastName` also got wrong in the
//  other direction by emitting a LEADING space.
//

import Foundation

/// How a person's name reads, composed once for both sides.
///
/// Not a stored model. A member's name is stored as its parts, and this is the one place that decides
/// what those parts look like when a human reads them, so a sentence built on the server and the same
/// sentence built in the app cannot name the same person differently.
public enum DisplayName {

    /// A member's display name, from the parts a `users` row stores.
    ///
    /// Empty and whitespace-only parts are dropped rather than joined, so no surface ever renders a
    /// name with punctuation or a space where a missing part used to be.
    ///
    /// - Parameters:
    ///   - firstName: the given name as stored, which may be empty.
    ///   - lastName: the family name as stored, which may be empty.
    /// - Returns: the name as a reader should see it, possibly empty when both parts are.
    public static func compose(firstName: String?, lastName: String?) -> String {
        [firstName, lastName]
            .compactMap { $0 }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    /// How to refer to a member in a sentence, falling back when there is no name to use.
    ///
    /// `GreetDemoAvailability.availability(counterpartName:)` interpolates its argument into sentences
    /// like "<name> has already opened this greet." A name that composed to nothing would produce
    /// " has already opened this greet.", which reads as a bug rather than as a missing name, so there
    /// is one fallback and both sides use it.
    ///
    /// - Parameters:
    ///   - firstName: the given name as stored, which may be empty.
    ///   - lastName: the family name as stored, which may be empty.
    ///   - fallback: what to say when both parts are empty. Defaults to the house wording.
    /// - Returns: a name that is safe to interpolate into a sentence.
    public static func forSentence(
        firstName: String?,
        lastName: String?,
        fallback: String = "This person"
    ) -> String {
        let composed = compose(firstName: firstName, lastName: lastName)
        return composed.isEmpty ? fallback : composed
    }
}
