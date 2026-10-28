//
//  GL34ShippingDefaultTests.swift
//  AkinFrontBackModels
//
//  GOAL_LOOP34 item 0.F1, after the defect that item's own verify could not see.
//

import Foundation
import XCTest

@testable import AkinFrontBackModels

/// The declared default and `shippingDefault(for:)` say the same thing, for every flag.
///
/// WHY THIS TEST EXISTS, AND WHAT IT COST TO LEARN. The value a flag ships with was written in two
/// places: the `static var` declaration, and `shippingDefault(for: )`. Item 0.F1 flipped the nine
/// declarations to `true` and left the function answering `false` for eight of them. 0.F1's verify
/// greps the declarations at the revision the app pins, so it passed.
///
/// The server does not read the declarations. `ReviewedFlagController` resolves a flag as the
/// member's override, then this server's value, then `shippingDefault(for: )`. So production, with
/// the package pinned at the tag that was supposed to have turned the features on, answered
/// `shippedDefault: false` and `resolved: false` for all eight GL29 flags, measured at
/// 2026-10-18 23:10 PDT. The features were off for every member, which is the exact failure
/// GOAL_LOOP34 exists to end.
///
/// ASSERTED AS A PAIRING, not as a list of nine `true`s. A test that said "wantToMeet ships true"
/// would have to be edited the day a flag's default legitimately changes, and a test that has to
/// be edited is a test somebody edits. What must never be true is the two spellings disagreeing,
/// so that is what is asserted, over `Feature.allCases` so a tenth flag is covered the moment it
/// is added.
final class GL34ShippingDefaultTests: XCTestCase {

    /// Whatever any other test did to these flags, they are back to their defaults first.
    ///
    /// These are process wide mutable statics, and XCTest runs cases in one process: a sibling
    /// suite that switched one off and did not restore it would otherwise fail this one, which
    /// would read as a defect in the file under test.
    override func setUp() {
        super.setUp()
        ReviewedFeatureFlag.resetToDefaults()
    }

    override func tearDown() {
        ReviewedFeatureFlag.resetToDefaults()
        super.tearDown()
    }

    /// Every DECLARED default equals what `shippingDefault(for:)` answers, read from the source.
    ///
    /// READ FROM THE SOURCE, and the first version of this test did not and was worthless. It
    /// compared `storedValue(for:)` against `shippingDefault(for:)` after `resetToDefaults()`, and
    /// reset ASSIGNS the function's answer into the stored property: the test compared a value it
    /// had just copied out of the function against the function. It passed against the broken code
    /// it was written to catch, which is the one outcome a regression test must not have.
    ///
    /// The declared literal cannot be read at runtime once anything has written to the property,
    /// and these are process wide mutable statics that other suites in this target do write to. So
    /// the declaration is read where it is written down.
    func testEveryDeclaredDefaultEqualsTheShippingDefault() throws {
        let source = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // FrontBackModelsTests
            .deletingLastPathComponent()  // Tests
            .deletingLastPathComponent()  // the package root
            .appendingPathComponent("Sources/FrontBackModels/Greet+Components/ReviewedFeatureFlag.swift")
        let text = try String(contentsOf: source, encoding: .utf8)

        var declared: [String: Bool] = [:]
        for line in text.split(separator: "\n", omittingEmptySubsequences: false) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.hasPrefix("public static var ") else { continue }
            guard let colon = trimmed.firstIndex(of: ":"), trimmed.contains("Bool = ") else { continue }
            let name = String(trimmed[trimmed.index(trimmed.startIndex, offsetBy: 18)..<colon])
            guard let equals = trimmed.range(of: "Bool = ") else { continue }
            let value = trimmed[equals.upperBound...].trimmingCharacters(in: .whitespaces)
            guard value == "true" || value == "false" else { continue }
            declared[name] = (value == "true")
        }

        // Asserted before the comparison, because an empty dictionary compared against nothing is
        // the shape of green this whole test exists to avoid.
        XCTAssertEqual(
            declared.count, ReviewedFeatureFlag.Feature.allCases.count,
            "read \(declared.count) declarations for \(ReviewedFeatureFlag.Feature.allCases.count) "
                + "flags, so the parsing is wrong and the comparison below means nothing"
        )

        for feature in ReviewedFeatureFlag.Feature.allCases {
            // `declaredPropertyName`, not `propertyName`, since GOAL_LOOP37. The two stopped being
            // one string when the follow flags were renamed to subscribe and their STORED keys
            // were deliberately left alone, so `propertyName` now answers with the retired
            // spelling for two of the nine. This test is about the declarations in the file, which
            // is what `declaredPropertyName` names; `ReviewedFeatureFlagStoredKeyTests` is what
            // holds the stored keys still.
            let name = feature.declaredPropertyName
            let literal = try XCTUnwrap(
                declared[name], "no declaration found for \(name), which Feature.\(feature.rawValue) names"
            )
            XCTAssertEqual(
                literal, ReviewedFeatureFlag.shippingDefault(for: feature),
                "\(name) is declared \(literal) and shippingDefault(for: .\(feature.rawValue)) "
                    + "answers \(ReviewedFeatureFlag.shippingDefault(for: feature)). Two spellings of "
                    + "one fact, which is how the GL29 features shipped off while the declarations "
                    + "read on"
            )
        }
    }

    /// The nine GL29 flags are ON in a build nobody has touched.
    ///
    /// Scott's decision of 2026-10-18 (DR3): the features are to be usable in production. This is
    /// the one assertion that would have failed on the day, and it is deliberately about the
    /// function rather than the declaration, because the function is what the server reads.
    func testTheGL29FlagsShipOn() {
        for feature in ReviewedFeatureFlag.Feature.allCases {
            XCTAssertTrue(
                ReviewedFeatureFlag.shippingDefault(for: feature),
                "\(feature.rawValue) ships off, so the server resolves it off for every member who "
                    + "has no override and no server value"
            )
        }
    }

    /// With the master switch up and nothing touched, every feature reads enabled.
    ///
    /// `isEnabled(for: )` is what a feature's own code path asks, and it is a different function
    /// from both of the two above: a flag could ship on and still be gated off by a master switch
    /// that shipped down, which is what the GL29 features did until this loop.
    func testEveryFeatureReadsEnabledInAShippingBuild() {
        for feature in ReviewedFeatureFlag.Feature.allCases {
            XCTAssertTrue(
                ReviewedFeatureFlag.isEnabled(for: feature),
                "\(feature.rawValue) is not enabled in a build nobody has touched"
            )
        }
    }
}
