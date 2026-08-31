import XCTest
@testable import AkinFrontBackModels

/// GOAL_LOOP13 R21.2. `AuthorVisibility` used to hardcode the noun "question" into all three
/// of its sentences, which meant serving a response or a questionnaire required either a second
/// copy of the enum or a sentence that named the wrong thing. The copy is now parameterized by
/// `AuthoredContentKind`, and these tests hold the full 3 x 3 grid so a fourth content kind, or a
/// reworded sentence, cannot ship with one of the nine cells stale.
final class AuthorVisibilityContentKindTests: XCTestCase {

    /// Every visibility, for every content kind, says something.
    func testEveryVisibilityAndKindProducesCopy() {
        for visibility in AuthorVisibility.allCases {
            for kind in AuthoredContentKind.allCases {
                XCTAssertFalse(
                    visibility.descriptionForUser(for: kind).isEmpty,
                    "\(visibility) x \(kind) produced no copy"
                )
            }
        }
    }

    /// The sentence names the content it is describing, and never a different one, AS ITS SUBJECT.
    ///
    /// This is the test that would have caught the original defect: with the noun hardcoded, the
    /// response and questionnaire cells both said "question".
    ///
    /// GOAL_LOOP14 narrowed the check from "the other noun appears nowhere in the sentence" to
    /// "the other noun is not the subject". The blanket form started failing on copy that is
    /// correct: the anonymized explanation ends by naming what following the member would have
    /// told the reader about, which is that member's other questions and responses, whatever the
    /// content in hand happens to be. That trailing clause is deliberate, it is the half of the
    /// consequence the retired middle option omitted, and the user's own wording for this switch
    /// names both nouns.
    ///
    /// What the original defect actually looked like was the SUBJECT being wrong: a questionnaire
    /// cell reading "this question". So the assertion is now made against the subject phrase,
    /// which is the thing that was broken, rather than against the whole sentence, which catches
    /// correct copy as collateral.
    func testCopySubjectNamesItsOwnContentKindAndNoOther() {
        for visibility in AuthorVisibility.allCases {
            for kind in AuthoredContentKind.allCases {
                let copy = visibility.descriptionForUser(for: kind)
                XCTAssertTrue(
                    copy.contains("this \(kind.noun)"),
                    "\(visibility) x \(kind) never makes a \(kind.noun) its subject: \(copy)"
                )
                for other in AuthoredContentKind.allCases where other != kind {
                    // "questionnaire" contains "question", so "this question" is a substring of
                    // "this questionnaire". The containment check only runs in the safe direction.
                    guard !other.noun.contains(kind.noun), !kind.noun.contains(other.noun) else { continue }
                    XCTAssertFalse(
                        copy.contains("this \(other.noun)"),
                        "\(visibility) x \(kind) makes a \(other.noun) its subject: \(copy)"
                    )
                }
            }
        }
    }


    /// GOAL_LOOP14 F5. The anonymized description must not promise disclosure, in either
    /// direction, for any content kind.
    ///
    /// This assertion replaces the R21.12 one it grew out of. R21.12 stopped the fan-out naming
    /// the author to followers for `unattributedAnnounced`, which is what left that value
    /// behaviourally identical to `silent` and made the middle option removable. The promise being
    /// checked is the same promise; it now belongs to the single anonymized state.
    func testAnonymizedDoesNotPromiseAnyDisclosure() {
        for kind in AuthoredContentKind.allCases {
            let copy = AuthorVisibility.anonymized.descriptionForUser(for: kind)
            XCTAssertTrue(
                copy.lowercased().contains("not"),
                "the description must state what will not happen for \(kind): \(copy)"
            )
            XCTAssertFalse(
                copy.lowercased().contains("will be told it was you"),
                "the withdrawn disclosure promise survives for \(kind): \(copy)"
            )
            XCTAssertTrue(
                copy.contains(kind.noun),
                "the sentence must name the content it applies to for \(kind): \(copy)"
            )
        }
    }

    /// The picker labels carry no content noun at all, which is why one set serves all three kinds.
    func testDisplayNamesAreContentKindNeutral() {
        for visibility in AuthorVisibility.allCases {
            let label = visibility.displayName
            XCTAssertFalse(label.isEmpty)
            for kind in AuthoredContentKind.allCases {
                XCTAssertFalse(
                    label.lowercased().contains(kind.noun),
                    "\(visibility).displayName names \(kind.noun), so it cannot serve the other kinds: \(label)"
                )
            }
        }
    }

    /// `AuthoredContentKind` is a wire value, so its raw strings are load bearing.
    func testContentKindRawValuesAreStable() {
        XCTAssertEqual(AuthoredContentKind.question.rawValue, "question")
        XCTAssertEqual(AuthoredContentKind.response.rawValue, "response")
        XCTAssertEqual(AuthoredContentKind.questionnaire.rawValue, "questionnaire")
        XCTAssertEqual(AuthoredContentKind.allCases.count, 3)
    }
}
