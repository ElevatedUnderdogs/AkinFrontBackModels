import XCTest
import Foundation
@testable import AkinFrontBackModels

/// Compiled verifies for the Phase 1 expansion contracts (items 1.4 through 1.10). Each test is the
/// machine check the goal loop names for its swath's contract types.
final class ExpansionContractTests: XCTestCase {

    // 1.4: the similarity types exist and round-trip.
    func testSemanticSimilarityRoundTrips() throws {
        let s = QuestionSimilarity(questionA: UUID(), questionB: UUID(), cosine: 0.82, model: "e5-large", computedAt: Date(timeIntervalSince1970: 0))
        let back = try JSONDecoder().decode(QuestionSimilarity.self, from: JSONEncoder().encode(s))
        XCTAssertEqual(back, s)
        let f = SemanticFamily(id: UUID(), memberQuestionIDs: [UUID(), UUID()], centroidLabel: "outdoorsy")
        XCTAssertEqual(f.memberQuestionIDs.count, 2)
    }

    // 1.5: MatchingAlgorithmChoice is Codable, CaseIterable, Hashable and carries user copy.
    func testMatchingAlgorithmChoiceConformances() throws {
        XCTAssertEqual(MatchingAlgorithmChoice.allCases.count, 2)                 // CaseIterable
        let set: Set<MatchingAlgorithmChoice> = [.percentileWeighted, .latentFactor] // Hashable
        XCTAssertEqual(set.count, 2)
        let decoded = try JSONDecoder().decode(MatchingAlgorithmChoice.self,     // Codable
                                               from: JSONEncoder().encode(MatchingAlgorithmChoice.latentFactor))
        XCTAssertEqual(decoded, .latentFactor)
        for c in MatchingAlgorithmChoice.allCases {
            XCTAssertFalse(c.displayName.isEmpty)
            XCTAssertFalse(c.descriptionForUser.isEmpty)
        }
    }

    // 1.6: exhaustive switch over QuestionRequirement with NO default clause.
    func testQuestionRequirementIsExhaustivelyHandledWithoutDefault() {
        func classify(_ r: QuestionRequirement) -> String {
            switch r {
            case .mustHaveAnswered:     return "answered"
            case .mustNotHaveChosen:    return "not-chosen"
            case .mustHaveChosenOneOf:  return "chosen-one-of"
            }
        }
        XCTAssertEqual(classify(.mustHaveAnswered(questionID: UUID())), "answered")
        XCTAssertEqual(classify(.mustNotHaveChosen(questionID: UUID(), responseIDs: [UUID()])), "not-chosen")
        XCTAssertEqual(classify(.mustHaveChosenOneOf(questionID: UUID(), responseIDs: [UUID()])), "chosen-one-of")
    }

    // 1.7: tiers nest — pro is a superset of plus, and prices are 0 / 4.99 / 9.99.
    func testSubscriptionTiersNestAndPrice() {
        XCTAssertTrue(SubscriptionTier.pro.capabilities.isSuperset(of: SubscriptionTier.plus.capabilities))
        XCTAssertTrue(SubscriptionTier.plus.capabilities.isSuperset(of: SubscriptionTier.free.capabilities))
        XCTAssertEqual(SubscriptionTier.free.priceUSD, 0)
        XCTAssertEqual(SubscriptionTier.plus.priceUSD, 4.99, accuracy: 0.0001)
        XCTAssertEqual(SubscriptionTier.pro.priceUSD, 9.99, accuracy: 0.0001)
    }

    // 1.8: the exclusion warning carries the honest cost of a blacklist.
    func testExclusionWarningCarriesCost() {
        let w = ExclusionWarning(excludedMatchCount: 12, excludedFraction: 0.3, reason: "blocked 2 venues")
        XCTAssertEqual(w.excludedMatchCount, 12)
    }

    // 1.9: AdCreative has NO field capable of carrying a user identifier.
    func testAdCreativeCarriesNoUserIdentifier() {
        let c = AdCreative(headline: "h", bodyText: "b", imageURL: nil, callToAction: "Go", disclosure: .sponsored)
        for child in Mirror(reflecting: c).children {
            XCTAssertFalse(child.value is UUID, "AdCreative field \(child.label ?? "?") is a UUID")
            let label = (child.label ?? "").lowercased()
            XCTAssertFalse(label.contains("user"), "AdCreative field \(label) names a user")
            XCTAssertFalse(label.contains("member"), "AdCreative field \(label) names a member")
        }
    }

    // 1.11: a member-created context is first-class; the closed enum is gone but romance/social and
    // the bare-string Codable wire format survive.
    func testContextAcceptsMemberCreatedRawValues() throws {
        XCTAssertNotNil(Context(id: UUID(), rawValue: "climbing partners"))
        XCTAssertEqual(Context.Case.romance.rawValue, "romance")
        XCTAssertEqual(Context.Case.social.rawValue, "social")
        XCTAssertEqual(Context.Case.allCases, [.romance, .social])
        // wire format unchanged: a Case encodes as a bare string, not an object
        let data = try JSONEncoder().encode(Context.Case.social)
        XCTAssertEqual(String(decoding: data, as: UTF8.self), "\"social\"")
        let back = try JSONDecoder().decode(Context.Case.self, from: Data("\"climbing partners\"".utf8))
        XCTAssertEqual(back.rawValue, "climbing partners")
    }

    // 1.10: a MarketAnswer cannot be built below the k-anonymity floor.
    func testMarketAnswerHonoursKAnonymityFloor() {
        XCTAssertNil(MarketAnswer(value: 1, cohortSize: KAnonymityFloor - 1, noiseScale: 0.1))
        XCTAssertNotNil(MarketAnswer(value: 1, cohortSize: KAnonymityFloor, noiseScale: 0.1))
    }
}
