import StrongContractClient
@testable import AkinFrontBackModels
import XCTest

final class AppVersionRequirementTests: XCTestCase {

    func testAMissingMinimumDecodesAsNilAndBlocksNobody() throws {
        let decoded = try JSONDecoder().decode(AppVersionRequirement.self, from: Data("{}".utf8))
        XCTAssertNil(decoded.minimumIOSVersion)
        XCTAssertFalse(decoded.requiresUpdate(from: "0.0.1"))
    }

    func testVersionsCompareNumerically() {
        let requirement = AppVersionRequirement(minimumIOSVersion: "2.10.0")
        XCTAssertTrue(requirement.requiresUpdate(from: "2.9.9"))
        XCTAssertFalse(requirement.requiresUpdate(from: "2.10.0"))
        XCTAssertFalse(requirement.requiresUpdate(from: "2.11"))
    }

    func testTheContractIsAnUnauthenticatedGet() {
        XCTAssertEqual(AppVersionCheck.appVersionRequirement.method, .get)
        XCTAssertEqual(AppVersionCheck.appVersionRequirement.path, "appVersionRequirement")
    }
}
