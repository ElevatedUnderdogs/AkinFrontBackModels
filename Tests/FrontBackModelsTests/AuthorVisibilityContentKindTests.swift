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

    /// The sentence names the content it is describing, and never a different one.
    ///
    /// This is the test that would have caught the original defect: with the noun hardcoded, the
    /// response and questionnaire cells both said "question".
    func testCopyNamesItsOwnContentKindAndNoOther() {
        for visibility in AuthorVisibility.allCases {
            for kind in AuthoredContentKind.allCases {
                let copy = visibility.descriptionForUser(for: kind)
                XCTAssertTrue(
                    copy.contains(kind.noun),
                    "\(visibility) x \(kind) never names a \(kind.noun): \(copy)"
                )
                for other in AuthoredContentKind.allCases where other != kind {
                    // "question" is a substring of nothing else here, and "questionnaire" contains
                    // "question", so the containment check only runs in the direction that is safe.
                    guard !other.noun.contains(kind.noun), !kind.noun.contains(other.noun) else { continue }
                    XCTAssertFalse(
                        copy.contains(other.noun),
                        "\(visibility) x \(kind) leaked the noun \(other.noun): \(copy)"
                    )
                }
            }
        }
    }

    /// R21.12 redaction, asserted at the level of the promise made to the member.
    ///
    /// `unattributedAnnounced` must no longer tell a member that their followers will learn it was
    /// them, because the fan-out no longer tells them. A sentence promising disclosure while the
    /// system withholds it is the same defect as the reverse, just in the safer direction.
    func testUnattributedAnnouncedDoesNotPromiseFollowersAreTold() {
        for kind in AuthoredContentKind.allCases {
            let copy = AuthorVisibility.unattributedAnnounced.descriptionForUser(for: kind)
            XCTAssertTrue(
                copy.contains("Nobody is told it was you"),
                "the redaction promise is missing for \(kind): \(copy)"
            )
            XCTAssertFalse(
                copy.lowercased().contains("will be told it was you"),
                "the withdrawn disclosure promise survives for \(kind): \(copy)"
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
