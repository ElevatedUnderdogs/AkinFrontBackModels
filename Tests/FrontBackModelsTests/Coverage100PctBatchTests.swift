import XCTest
@testable import AkinFrontBackModels

/// Targeted tests closing the last measured per-file line-coverage gaps.
/// Each test names the source file + lines it exercises.
final class Coverage100PctBatchTests: XCTestCase {

    // MARK: IceServersRequest.swift (lines 32-34)

    func testIceServersRequestStaticEndpoint() {
        let request = IceServersRequestType.iceServers
        XCTAssertEqual(request.method, .get)
    }

    // MARK: StrongContractClient.Request.swift

    // NOTE: StrongContractClient.Request.swift lines 68-70 (`ImageRequest.image`)
    // are intentionally NOT covered. `ImageRequest = Request<UserImage, Data>`,
    // and `image` builds it with `method: .get`. The library's `Request.init`
    // runs `assert(Payload.self == Empty.self)` for GET requests, so constructing
    // `ImageRequest.image` traps in any debug (test) build. This is a latent
    // source bug (a GET declared with a non-Empty payload), not a test gap.

    // lines 383-386
    func testResetPasswordRequestInit() {
        let request = ResetPasswordRequest(token: "tok123", newPassword: "newpass")
        XCTAssertEqual(request.token, "tok123")
        XCTAssertEqual(request.newPassword, "newpass")
    }

    // lines 541-543
    func testSetMetersWillingToTravelStaticEndpoint() {
        let request = MetersWillingToTravelRequest.setMetersWillingToTravel
        XCTAssertEqual(request.method, .post)
    }

    // MARK: URLQueryItem.swift

    // lines 59-61: empty device token os_log branch
    func testDeviceTokenEmptyBranch() {
        let item = URLQueryItem.device(token: "")
        XCTAssertEqual(item.value, "")
    }

    // lines 68-70: empty pushKit device token os_log branch
    func testPushKitDeviceTokenEmptyBranch() {
        let item = URLQueryItem.pushKitDevice(token: "")
        XCTAssertEqual(item.value, "")
    }

    // MARK: URLRequest+factory.swift

    // lines 91-94: encode failure catch in updateUserLocation (non-conforming float throws)
    func testUpdateUserLocationEncodeFailureReturnsNil() {
        let request = URLRequest.updateUserLocation(
            userId: UUID(),
            latitude: .infinity,
            longitude: 1.0,
            contextId: ""
        )
        XCTAssertNil(request)
    }

    // lines 38-41: encode failure catch in update(greet:) (non-conforming float throws)
    func testUpdateGreetEncodeFailureReturnsNil() throws {
        var greet = try makeSampleGreet()
        greet.matchMakingMethodVersion = .infinity
        let request = URLRequest.update(greet: greet)
        XCTAssertNil(request)
    }

    // MARK: Settings.swift

    // line 50: `greetingMethods(for:)` nil-coalescing `?? []` when the context
    // has no preference entry (first(where:) returns nil).
    func testGreetingMethodTextForAbsentContext() {
        let settings = Settings()
        XCTAssertTrue(settings.contextPreferences.isEmpty)
        XCTAssertEqual(settings.greetingMethodText(for: Context.Case.romance), "wave")
    }

    // MARK: EnvConfig.swift

    // lines 16-30 (DEBUG-reachable paths). isTestFlight (line 13) and the
    // else branches (lines 32-35) are unreachable in a DEBUG test build:
    // `isDebug` is compile-time `true`, so `appConfiguration` always returns
    // `.Debug` and `fromAppStore` short-circuits before evaluating isTestFlight.
    func testEnvConfigDebugPaths() {
        XCTAssertTrue(EnvConfig.isDebug)
        XCTAssertFalse(EnvConfig.fromAppStore)
        XCTAssertEqual(String(describing: EnvConfig.appConfiguration), "Debug")
    }

    // MARK: ActionStringConvertible.swift

    // line 48 (String branch)
    func testActionStringConvertibleStringBranch() {
        let result = CoverageActionEnum.pairOfStrings("alpha", "beta").actionString
        XCTAssertTrue(result.contains("alpha"))
        XCTAssertTrue(result.contains("beta"))
    }

    // line 54 (Bool branch)
    func testActionStringConvertibleBoolBranch() {
        let result = CoverageActionEnum.boolAndInt(true, 3).actionString
        XCTAssertTrue(result.contains("true"))
        XCTAssertTrue(result.contains("3"))
    }

    // line 57 (Optional.none branch)
    func testActionStringConvertibleOptionalNilBranch() {
        let result = CoverageActionEnum.optionalNilAndInt(nil, 7).actionString
        XCTAssertTrue(result.contains("nil"))
        XCTAssertTrue(result.contains("7"))
    }

    // line 60 (optional.map non-nil branch) — reached safely via a double optional
    // set to `.some(.none)`, which unwraps one level and terminates at the
    // Optional.none case. A `.some(nonPrimitive)` here would recurse forever
    // (the known stringifyAssociatedValue trap), so we deliberately use the
    // double-optional form to hit line 60 without triggering it.
    func testActionStringConvertibleOptionalMapBranch() {
        let value: String?? = .some(.none)
        let result = CoverageActionEnum.doubleOptionalAndInt(value, 9).actionString
        XCTAssertTrue(result.contains("nil"))
        XCTAssertTrue(result.contains("9"))
    }

    // MARK: Helpers

    private func makeSampleGreet() throws -> Greet {
        try Greet(
            thisUserID: UUID(),
            otherUser: NearbyUser(
                id: UUID(),
                name: "Scott",
                profileImage: "",
                imageMetaData: ImageMetadata(
                    width: 20,
                    height: 20,
                    format: "jpeg",
                    assessment: ModerationAssessment(entries: []),
                    id: UUID()
                ),
                verified: true,
                lastLocationUpdate: nil
            ),
            greetID: UUID(),
            venue: Venue(url: "", name: "Starbucks", address: "", latitude: 37, longitude: 36),
            minutesAway: 10,
            otherMinutesAway: 15,
            initiationMethod: .manual(userID: UUID()),
            travelMethod: .bike,
            matchMakingMethodVersion: 1,
            participantUserIDs: [UUID(), UUID()]
        )
    }
}

/// Enum whose associated-value shapes drive `stringifyAssociatedValue` into
/// its String (48), Bool (54), Optional.none (57), and optional-map (60)
/// branches. Multi-value (tuple) cases are required because the extension's
/// double `Mirror` reflection only descends into associated values when the
/// child value is a tuple.
private enum CoverageActionEnum: ActionStringConvertible {
    case pairOfStrings(String, String)
    case boolAndInt(Bool, Int)
    case optionalNilAndInt(String?, Int)
    case doubleOptionalAndInt(String??, Int)
}
