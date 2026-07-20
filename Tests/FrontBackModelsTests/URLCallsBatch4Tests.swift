import XCTest
@testable import AkinFrontBackModels

private func queryDict(_ url: URL?) -> [String: String] {
    guard let url, let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems else { return [:] }
    var dict = [String: String]()
    for item in items { dict[item.name] = item.value }
    return dict
}

final class URLCallsBatch4Tests: XCTestCase {

    // MARK: - Fixtures

    private var fixedDate: Date {
        var components = DateComponents()
        components.year = 2020
        components.month = 1
        components.day = 15
        components.hour = 10
        components.minute = 30
        components.second = 0
        components.timeZone = TimeZone(identifier: "GMT")
        return Calendar(identifier: .gregorian).date(from: components)!
    }

    var sampleGreet: Greet {
        try! Greet(
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

    var sampleQuestion: Question {
        Question(
            text: "What is your favorite color?",
            id: UUID(),
            creatorID: UUID(),
            originalContext: Context(id: UUID(), case: .romance),
            defaultCompatibilityRule: .mandatory,
            assessment: ModerationAssessment(entries: [])
        )
    }

    var sampleResponse: Question.Response {
        Question.Response(
            text: "Blue",
            timeStamp: Date(),
            id: UUID(),
            creator: UUID(),
            questionID: UUID(),
            originalContextID: UUID(),
            assessment: ModerationAssessment(entries: [])
        )
    }

    // MARK: - Double.swift

    func testDoubleStringPositive() {
        XCTAssertEqual(Double(3.14).string, "3.14")
    }

    func testDoubleStringZero() {
        XCTAssertEqual(Double(0).string, "0.0")
    }

    func testDoubleStringNegative() {
        XCTAssertEqual(Double(-2.5).string, "-2.5")
    }

    // MARK: - EnvConfig.swift

    func testIsDebugTrueUnderTests() {
        XCTAssertTrue(EnvConfig.isDebug)
    }

    func testFromAppStoreFalseUnderTests() {
        XCTAssertFalse(EnvConfig.fromAppStore)
    }

    func testAppConfigurationIsDebugUnderTests() {
        switch EnvConfig.appConfiguration {
        case .Debug: break
        default: XCTFail("Expected .Debug configuration under a debug test build")
        }
    }

    // MARK: - NSMutableURLRequest.swift

    func testUrlRequestBridgesToURLRequest() {
        let mutable = NSMutableURLRequest(url: URL(string: "https://example.com/path")!)
        mutable.httpMethod = "PATCH"
        let bridged = mutable.urlRequest
        XCTAssertEqual(bridged.url, URL(string: "https://example.com/path"))
        XCTAssertEqual(bridged.httpMethod, "PATCH")
    }

    func testImgInitSetsPostAndMultipartContentType() {
        let img = Data([0x01, 0x02, 0x03])
        let request = NSMutableURLRequest(img: img, url: URL(string: "https://example.com/upload")!, thisUserID: UUID())
        XCTAssertNotNil(request)
        XCTAssertEqual(request?.httpMethod, "POST")
        let contentType = request?.value(forHTTPHeaderField: "Content-Type")
        XCTAssertTrue(contentType?.hasPrefix("multipart/form-data; boundary=Boundary-") == true)
    }

    func testImgInitBodyContainsUserfileFieldAndImageBytes() throws {
        let img = Data([0xDE, 0xAD, 0xBE, 0xEF])
        let request = try XCTUnwrap(NSMutableURLRequest(img: img, url: URL(string: "https://example.com/upload")!, thisUserID: UUID()))
        let body = try XCTUnwrap(request.httpBody)
        XCTAssertNotNil(body.range(of: Data("userfile".utf8)))
        XCTAssertNotNil(body.range(of: img))
    }

    // MARK: - QueryItemName.swift

    func testDefaultRawValuesMatchCaseName() {
        XCTAssertEqual(QueryItemName.access_token.rawValue, "access_token")
        XCTAssertEqual(QueryItemName.email.rawValue, "email")
        XCTAssertEqual(QueryItemName.zip.rawValue, "zip")
    }

    func testCustomRawValues() {
        XCTAssertEqual(QueryItemName.greetStatus.rawValue, "status")
        XCTAssertEqual(QueryItemName.meetingAddress.rawValue, "meetingEvent.address")
        XCTAssertEqual(QueryItemName.meetingPlaceName.rawValue, "meetingEvent.placeName")
        XCTAssertEqual(QueryItemName.meetingTime.rawValue, "meetingEvent.meetTime")
    }

    func testQueryItemFromValue() {
        let item = QueryItemName.email.queryItem(from: "a@b.com")
        XCTAssertEqual(item.name, "email")
        XCTAssertEqual(item.value, "a@b.com")
    }

    func testQueryItemFromNilValue() {
        let item = QueryItemName.email.queryItem(from: nil)
        XCTAssertEqual(item.name, "email")
        XCTAssertNil(item.value)
    }

    func testStringFromValueEscapesAndFormats() {
        XCTAssertEqual(QueryItemName.email.string(from: "hello world"), "email=hello%20world&")
    }

    func testStringFromValueUsesCustomRawValue() {
        XCTAssertEqual(QueryItemName.greetStatus.string(from: "active"), "status=active&")
    }

    func testQueryItemNameCodableRoundTrip() throws {
        let encoded = try JSONEncoder().encode(QueryItemName.greetStatus)
        let decoded = try JSONDecoder().decode(QueryItemName.self, from: encoded)
        XCTAssertEqual(decoded.rawValue, "status")
    }

    // MARK: - String.swift

    func testScapedEncodesReservedCharacters() {
        XCTAssertEqual("hello world".scaped, "hello%20world")
        // `.scaped` uses `.urlQueryAllowed`, which permits `&`/`=` since they're
        // structurally meaningful within a query string; it does not percent-encode them.
        XCTAssertEqual("a&b=c".scaped, "a&b=c")
        XCTAssertEqual("plain123".scaped, "plain123")
    }

    func testEnvironmentStringIsDebugUnderTests() {
        XCTAssertEqual(String.environmentString, "DEBUG")
    }

    func testIntParsesValidDigits() {
        XCTAssertEqual("42".int, 42)
    }

    func testIntNilForNonDigits() {
        XCTAssertNil("abc".int)
    }

    func testSnakeCasedConvertsCamelCase() {
        XCTAssertEqual("pushProviderAccepted".snakeCased, "push_provider_accepted")
    }

    func testSnakeCasedLeavesLowercaseUnchanged() {
        XCTAssertEqual("already_snake".snakeCased, "already_snake")
    }

    func testSnakeCasedEmptyString() {
        XCTAssertEqual("".snakeCased, "")
    }

    func testSnakeCasedLeadingUppercaseHasNoLeadingUnderscore() {
        XCTAssertEqual("Push".snakeCased, "push")
    }

    func testGenerateBoundaryStringFormat() {
        let boundary = String.generateBoundaryString
        XCTAssertTrue(boundary.hasPrefix("Boundary-"))
        let uuidPart = boundary.replacingOccurrences(of: "Boundary-", with: "")
        XCTAssertNotNil(UUID(uuidString: uuidPart))
    }

    func testAccountNotVerifiedText() {
        XCTAssertEqual(
            String.accountNotVerifed,
            "This account's email hasn't been verified yet.  Would you like us to resend a link?"
        )
    }

    func testQuestionMisunderstandingContainsExample() {
        XCTAssertTrue(String.questionMisunderstanding.contains("How are you?"))
    }

    func testResponseMisunderstandingContainsExample() {
        XCTAssertTrue(String.responseMisunderstanding.contains("skin a cat"))
    }

    func testMisunderstandingAssignmentPromptNoteDefaultsToQuestionMisunderstanding() {
        let note = "".misunderstandingAssignmentPromptNote()
        XCTAssertTrue(note.contains("How are you?"))
    }

    func testMisunderstandingAssignmentPromptNoteAcceptsCustomMiddleContent() {
        let note = "".misunderstandingAssignmentPromptNote(middleContent: "custom middle marker")
        XCTAssertTrue(note.contains("custom middle marker"))
        XCTAssertFalse(note.contains("How are you?"))
    }

    func testModerationPromptFormatIntroContainsFlagSourceAndAllowedFlags() {
        let intro = String.moderationPromptFormatIntro
        XCTAssertTrue(intro.contains(FlagSource.autoServerOpenAI.rawValue))
        XCTAssertTrue(intro.contains(ReportFlag.sexual.rawValue))
        XCTAssertFalse(intro.contains(ReportFlag.childSexualAbuseMaterial.rawValue))
    }

    func testVerifyUserActionQuestionOnly() {
        let prompt = String.verifyUserAction(flagged: .spam, question: "Q1?")
        XCTAssertTrue(prompt.contains("Question: Q1?"))
        XCTAssertTrue(prompt.contains("\"spam\""))
        XCTAssertFalse(prompt.contains("Response:"))
    }

    func testVerifyUserActionQuestionAndResponse() {
        let prompt = String.verifyUserAction(flagged: .spam, question: "Q1?", response: "R1")
        XCTAssertTrue(prompt.contains("Question: Q1?"))
        XCTAssertTrue(prompt.contains("Response: R1"))
    }

    func testModerationPromptForContent() {
        let prompt = String.moderationPrompt(forContent: "some content")
        XCTAssertTrue(prompt.contains("some content"))
        XCTAssertTrue(prompt.contains("Analyze the following content"))
    }

    func testModerationAssessmentDecodeSuccess() throws {
        let assessment = try ModerationAssessment.exampleJSONString.moderationAssessment()
        XCTAssertEqual(assessment.entries.count, 2)
        XCTAssertEqual(assessment.entries.first?.flag, .threatensPhysicalHarm)
    }

    func testModerationAssessmentDecodeFailureThrows() {
        XCTAssertThrowsError(try "not valid json".moderationAssessment())
    }

    func testExampleJSONStringRoundTrips() throws {
        let data = try XCTUnwrap(ModerationAssessment.exampleJSONString.data(using: .utf8))
        let decoded = try JSONDecoder().decode(ModerationAssessment.self, from: data)
        XCTAssertEqual(decoded.entries.map(\.flag), [.threatensPhysicalHarm, .sexual])
    }

    // MARK: - URLComponents.swift

    func testDebugComponents() {
        let components = URLComponents.debug
        XCTAssertEqual(components.scheme, "http")
        XCTAssertEqual(components.host, "127.0.0.1")
        XCTAssertEqual(components.port, 8080)
    }

    func testNotDebugComponents() {
        let components = URLComponents.notDebug
        XCTAssertEqual(components.scheme, "https")
        XCTAssertEqual(components.host, "akindev")
        XCTAssertEqual(components.port, 8080)
    }

    func testBaseURLComponentsIsDebugUnderTests() {
        let components = URLComponents.baseURLComponents
        XCTAssertEqual(components.scheme, "http")
        XCTAssertEqual(components.host, "127.0.0.1")
    }

    func testWithPathPrependsAPI() {
        let components = URLComponents.debug.with(path: "foo/bar")
        XCTAssertEqual(components.path, "/api/foo/bar")
    }

    func testWithQueryItemsVariadicOnFreshComponents() {
        let components = URLComponents.debug.with(queryItems: .access_token_and_user_id, .greet_id("g1"))
        XCTAssertEqual(components.queryItems, [.access_token_and_user_id, .greet_id("g1")])
    }

    func testWithArraySetsWhenPreviouslyNil() {
        let components = URLComponents.debug.with(array: [.greet_id("g1")])
        XCTAssertEqual(components.queryItems, [.greet_id("g1")])
    }

    func testWithArrayEmptyOnFreshComponentsProducesEmptyNonNilArray() {
        let components = URLComponents.debug.with(array: [])
        XCTAssertEqual(components.queryItems, [])
    }

    func testWithArraySecondCallIsDroppedDueToOperatorPrecedence() {
        // `buffer.queryItems ?? [] + array` parses as `buffer.queryItems ?? ([] + array)` since `+`
        // binds tighter than `??`; once queryItems is already non-nil, a second `.with(array:)` call
        // silently drops its items instead of appending them. This locks in that actual behavior.
        let first = URLComponents.debug.with(array: [.access_token_and_user_id])
        let second = first.with(array: [.greet_id("g1")])
        XCTAssertEqual(second.queryItems, [.access_token_and_user_id])
    }

    func testFullURLBuildFromComponents() {
        let url = URLComponents.debug.with(path: "test").with(queryItems: .access_token_and_user_id).url
        XCTAssertEqual(url?.absoluteString, "http://127.0.0.1:8080/api/test?access_token=")
    }

    // MARK: - URLQueryItem.swift

    func testURLQueryItemFactories() {
        let cases: [(item: URLQueryItem, name: String, value: String?)] = [
            (.row(5), "row", "5"),
            (.submit(true), "submit", "true"),
            (.new_password("newpass"), "new_password", "newpass"),
            (.search(text: "hello"), "search", "hello"),
            (.search(text: nil), "search", nil),
            (.oldPassword("old"), "old_password", "old"),
            (.email("a@b.com"), "email", "a@b.com"),
            (.reset(email: "reset@b.com"), "email", "reset@b.com"),
            (.social("fb"), "social", "fb"),
            (.viewing(3), "viewing", "3"),
            (.ring("on"), "ring", "on"),
            (.vibrate("on"), "vibrate", "on"),
            (.wet_willy("x"), "wet_willy", "x"),
            (.wave("x"), "wave", "x"),
            (.kiss_on_the_cheek("x"), "kiss_on_the_cheek", "x"),
            (.high_five("x"), "high_five", "x"),
            (.hug("x"), "hug", "x"),
            (.hand_shake("x"), "hand_shake", "x"),
            (.greetr_flutter("x"), "greetr_flutter", "x"),
            (.plur("x"), "plur", "x"),
            (.hook_up("x"), "hook_up", "x"),
            (.dob("1990-01-01"), "dob", "1990-01-01"),
            (.schedule(summary: "M-F"), "meeting_schedule", "M-F"),
            (.PageNo(2), "pageNo", "2"),
            (.PageNo(nil), "pageNo", nil),
            (.type("t"), "type", "t"),
            (.my_id("m1"), "my_id", "m1"),
            (.response("resp"), "response", "resp"),
            (.responseID("rid"), "response_id", "rid"),
            (.their(5), "their", "5"),
            (.their(nil), "their", nil),
            (.my(7), "my", "7"),
            (.my(nil), "my", nil),
            (.context("ctx"), "context", "ctx"),
            (.importance(.very), "importance", "9"),
            (.question_id("q1"), "question_id", "q1"),
            (.text("txt"), "text", "txt"),
            (.question(text: "why?"), "question", "why?"),
            (.make(deviceString: "iPhone15,2"), "makeModel", "iPhone15,2"),
            (.password("pw"), "password", "pw"),
            (.metersWillingToTravel(500), "metersWillingToTravel", "500"),
            (.primary_email("p@e.com"), "primary_email", "p@e.com"),
            (.minutes(away: 12), "minutesFromPoint", "12"),
            (.minutes(away: nil), "minutesFromPoint", nil),
            (.meetingPlace(name: "Cafe"), "meetingEvent.placeName", "Cafe"),
            (.meetingPlace(name: nil), "meetingEvent.placeName", nil),
            (.meetingPlace(address: "123 St"), "meetingEvent.address", "123 St"),
            (.meetingPlace(time: "10am"), "meetingEvent.meetTime", "10am"),
            (.percentTravelled(0.5), "percentTravelled", "0.5"),
            (.percentTravelled(nil), "percentTravelled", nil),
            (.alwaysInUse(true), "alwaysInUse", "1"),
            (.alwaysInUse(false), "alwaysInUse", "0"),
            (.hide(me: true), "isHide", "1"),
            (.urlAddress("http://x.com/path"), "url", "http://x.com/path"),
            (.flag(int: 4), "flag", "4"),
            (.allows(true), "allowsCourtesyCalls", "1"),
            (.assert("boom"), "assert", "boom"),
            (.environment("DEBUG"), "environment", "DEBUG"),
            (.environment(), "environment", "DEBUG"),
            (.user_id(id: "u1"), "user_id", "u1"),
            (.user_id(id: nil), "user_id", "wasnt set correctly"),
            (.greet_id("g1"), "greet_id", "g1"),
            (.rating(4.5), "greet_rating", "4.5"),
            (.other_id(3), "other_id", "3"),
            (.other_id("s3"), "other_id", "s3"),
            (.other_user_id("ou1"), "other_user_id", "ou1"),
            (.block(true), "block", "true"),
            (.block(false), "block", "false"),
            (.email_id("e1"), "email_id", "e1"),
            (.romance("r1"), "romance", "r1"),
            (.username("uname"), "username", "uname"),
            (.first_name("First"), "first_name", "First"),
            (.last_name("Last"), "last_name", "Last"),
            (.zip("12345"), "zip", "12345"),
            (.phone("555-1234"), "phone", "555-1234"),
            (.confirmationStatus(.yes), "response", "1"),
            (.error("oops"), "error", "oops"),
        ]
        for (index, entry) in cases.enumerated() {
            XCTAssertEqual(entry.item.name, entry.name, "case \(index): \(entry.name)")
            XCTAssertEqual(entry.item.value, entry.value, "case \(index): \(entry.name)")
        }
    }

    func testDobDateOverload() {
        let item = URLQueryItem.dob(fixedDate)
        XCTAssertEqual(item.name, "dob")
        XCTAssertEqual(item.value, "2020-01-15 10:30:00")
    }

    func testDobOptionalDateOverloadSome() {
        let date: Date? = fixedDate
        let item = URLQueryItem.dob(date)
        XCTAssertEqual(item.name, "dob")
        XCTAssertEqual(item.value, "2020-01-15 10:30:00")
    }

    func testDobOptionalDateOverloadNone() {
        let date: Date? = nil
        let item = URLQueryItem.dob(date)
        XCTAssertEqual(item.name, "dob")
        XCTAssertNil(item.value)
    }

    func testDateFactoryProducesTimestampedValue() {
        let item = URLQueryItem.date()
        XCTAssertEqual(item.name, "date")
        let value = item.value ?? ""
        XCTAssertNotNil(value.range(of: #"^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$"#, options: .regularExpression))
    }

    func testTrackingEventsSingle() {
        let items = URLQueryItem.tracking(events: [7: "seven"])
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.name, "7")
        XCTAssertEqual(items.first?.value, "seven")
    }

    func testTrackingEventsMultiple() {
        let items = URLQueryItem.tracking(events: [1: "one", 2: "two"])
        let asSet = Set(items.map { "\($0.name)=\($0.value ?? "")" })
        XCTAssertEqual(asSet, ["1=one", "2=two"])
    }

    func testReportFlagBase64EncodesRawMemory() {
        let values = [1, 2, 3]
        let expected = values.withUnsafeBufferPointer { Data(buffer: $0) }.base64EncodedString()
        let item = URLQueryItem.reportFlag(int: values)
        XCTAssertEqual(item.name, "reportFlag")
        XCTAssertEqual(item.value, expected)
    }

    func testAccessTokenAndUserIdDefault() {
        XCTAssertEqual(URLQueryItem.access_token_and_user_id.name, "access_token")
        XCTAssertEqual(URLQueryItem.access_token_and_user_id.value, "")
    }

    func testCustomInitUsesRawValue() {
        let item = URLQueryItem(.greetStatus, "done")
        XCTAssertEqual(item.name, "status")
        XCTAssertEqual(item.value, "done")
    }

    func testCustomInitNilValue() {
        let item = URLQueryItem(.email, nil)
        XCTAssertEqual(item.name, "email")
        XCTAssertNil(item.value)
    }

    // MARK: - URLRequest.swift: `post` and `method`

    func testPostSetsMethodKeepsRestOfRequest() {
        var request = URLRequest(url: URL(string: "https://example.com")!)
        request.httpBody = Data("x".utf8)
        let posted = request.post
        XCTAssertEqual(posted.httpMethod, "POST")
        XCTAssertEqual(posted.url, request.url)
        XCTAssertEqual(posted.httpBody, request.httpBody)
    }

    func testMethodParsesValidRawValue() {
        var request = URLRequest(url: URL(string: "https://example.com")!)
        request.httpMethod = "PUT"
        XCTAssertEqual(request.method?.rawValue, "PUT")
    }

    func testMethodNilForUnrecognizedRawValue() {
        var request = URLRequest(url: URL(string: "https://example.com")!)
        request.httpMethod = "NOPE"
        XCTAssertNil(request.method)
    }

    func testMethodNilWhenHttpMethodUnset() {
        // Foundation's URLRequest defaults httpMethod to "GET" (never nil/unset),
        // so an otherwise-untouched request parses as .get, not nil.
        let request = URLRequest(url: URL(string: "https://example.com")!)
        XCTAssertEqual(request.method, .get)
    }

    func testAddDisplaySetsPostAndMultipartHeader() {
        let request = URLRequest.addDisplay(img: Data([0xFF, 0xD8, 0xFF]), thisUserID: UUID())
        XCTAssertNotNil(request)
        XCTAssertEqual(request?.httpMethod, "POST")
        let contentType = request?.value(forHTTPHeaderField: "Content-Type")
        XCTAssertTrue(contentType?.hasPrefix("multipart/form-data; boundary=Boundary-") == true)
        XCTAssertNotNil(request?.httpBody)
    }

    // MARK: - URLRequest.swift: `TokenAndPayload` / `TwoIDs`

    func testTokenAndPayloadDefaultsAccessTokenAndEncodesPayload() throws {
        let payload = TokenAndPayload(payload: "hello")
        XCTAssertEqual(payload.accessToken.name, "access_token")
        let data = try JSONEncoder().encode(payload)
        let decoded = try JSONDecoder().decode(TokenAndPayload<String>.self, from: data)
        XCTAssertEqual(decoded.payload, "hello")
    }

    func testTwoIDsCodableRoundTrip() throws {
        let ids = TwoIDs(firstId: UUID(), otherID: UUID())
        let data = try JSONEncoder().encode(ids)
        let decoded = try JSONDecoder().decode(TwoIDs.self, from: data)
        XCTAssertEqual(decoded.firstId, ids.firstId)
        XCTAssertEqual(decoded.otherID, ids.otherID)
    }

    // MARK: - URLRequest.swift: `URL` static factories

    func testReportFlagsByQuestionURL() {
        let flags = [1, 2]
        let expectedFlagValue = flags.withUnsafeBufferPointer { Data(buffer: $0) }.base64EncodedString()
        let url = URL.reportFlags(flags, question: 5)
        XCTAssertEqual(url?.path, "/api/reportFlags")
        let query = queryDict(url)
        XCTAssertEqual(query["question_id"], "5")
        XCTAssertEqual(query["reportFlag"], expectedFlagValue)
        XCTAssertEqual(query["access_token"], "")
    }

    func testReportFlagsWithResponseURL() {
        let url = URL.reportFlags([3], response: 10, for: 20)
        XCTAssertEqual(url?.path, "/api/reportFlags")
        let query = queryDict(url)
        XCTAssertEqual(query["question_id"], "20")
        XCTAssertEqual(query["response_id"], "10")
    }

    func testReportFlagsByPicURL() {
        let url = URL.reportFlags([4], picURL: "http://img.example.com/a.jpg", userID: 1)
        XCTAssertEqual(url?.path, "/api/reportFlag")
        XCTAssertEqual(queryDict(url)["url"], "http://img.example.com/a.jpg")
    }

    func testGetUserInformationURL() {
        XCTAssertEqual(URL.getUserInformation?.absoluteString, "http://127.0.0.1:8080/api/getUserInformation?access_token=")
    }

    func testRateGreetURL() {
        let url = URL.rate(greetid: "g1", otherUser: 9, rating: 4.5)
        XCTAssertEqual(url?.path, "/api/rateGreet")
        let query = queryDict(url)
        XCTAssertEqual(query["other_id"], "9")
        XCTAssertEqual(query["greet_id"], "g1")
        XCTAssertEqual(query["greet_rating"], "4.5")
    }

    func testUpdateScheduleURL() {
        XCTAssertEqual(URL.updateSchedule?.absoluteString, "http://127.0.0.1:8080/api/updateSchedule?access_token=")
    }

    func testUpdateGreetURL() {
        XCTAssertEqual(URL.updateGreet.absoluteString, "http://127.0.0.1:8080/api/updateGreet?access_token=")
    }

    func testUpdateGreetSettingsURL() {
        XCTAssertEqual(URL.updateGreetSettings.absoluteString, "http://127.0.0.1:8080/api/updateGreetSettings?access_token=")
    }

    func testUpdateUserLocationPathURL() {
        let id = UUID()
        let url = URL.updateUserLocation(userId: id, contextId: "ctx1")
        XCTAssertEqual(url.path, "/api/user/\(id)/location/context/ctx1")
    }

    func testSilentPushLocationUpdatesURL() {
        let url = URL.silentPushLocationUpdates(alwaysOn: true)
        XCTAssertEqual(url.path, "/api/shouldUpdateLocation")
        XCTAssertEqual(queryDict(url)["alwaysInUse"], "1")
    }

    func testUpdateLocationURL() {
        let url = URL.updateLocation(token: nil, userID: nil, lat: "10.0", lon: "20.0")
        XCTAssertEqual(url.path, "/api/updateUserLocation")
        let query = queryDict(url)
        XCTAssertEqual(query["latitude"], "10.0")
        XCTAssertEqual(query["longitude"], "20.0")
        XCTAssertEqual(query["context"], "")
    }

    func testAssertURL() {
        let url = URL.assert(message: "boom")
        XCTAssertEqual(url.path, "/api/assert")
        XCTAssertEqual(queryDict(url)["assert"], "boom")
    }

    func testUpdateImportanceURL() {
        let context = Context(id: UUID(), case: .romance)
        let url = URL.update(importance: .very, for: context, questionID: 7)
        XCTAssertEqual(url.path, "/api/updateImportance")
        let query = queryDict(url)
        XCTAssertEqual(query["context"], "romance")
        XCTAssertEqual(query["importance"], "9")
        XCTAssertEqual(query["question_id"], "7")
    }

    func testTermsURL() {
        XCTAssertEqual(URL.terms.absoluteString, "http://127.0.0.1:8080/api/getTerms")
    }

    func testTrackEventsURL() {
        let url = URL.track(events: [1: "one"])
        XCTAssertEqual(url.path, "/api/trackEvents")
        let query = queryDict(url)
        XCTAssertEqual(query["1"], "one")
        XCTAssertEqual(query["access_token"], "")
        XCTAssertNotNil(query["date"])
    }

    func testUpdateEmailURL() {
        let url = URL.updateEmail(new: "new@e.com", password: "pw1")
        XCTAssertEqual(url.path, "/api/updateEmail")
        let query = queryDict(url)
        XCTAssertEqual(query["email"], "new@e.com")
        XCTAssertEqual(query["password"], "pw1")
    }

    func testUpdateCourtesyCallSettingURL() {
        let url = URL.updateCourtesyCallSetting(allows: true)
        XCTAssertEqual(url.path, "/api/allowsCourtesyCall")
        XCTAssertEqual(queryDict(url)["allowsCourtesyCalls"], "1")
    }

    func testUpdatePasswordURLSuccess() {
        let url = URL.update(oldPassword: "old", newPassword: "new", savedEmail: "e@x.com")
        XCTAssertEqual(url?.path, "/api/updatePassByOldPass")
        let query = queryDict(url)
        XCTAssertEqual(query["old_password"], "old")
        XCTAssertEqual(query["new_password"], "new")
        XCTAssertEqual(query["primary_email"], "e@x.com")
    }

    func testUpdatePasswordURLNilWhenEmailMissing() {
        XCTAssertNil(URL.update(oldPassword: "old", newPassword: "new", savedEmail: nil))
    }

    func testSendMakeURL() {
        let url = URL.sendMake(deviceString: "iPhone15,2")
        XCTAssertEqual(url.path, "/api/make")
        XCTAssertEqual(queryDict(url)["makeModel"], "iPhone15,2")
    }

    func testAddQuestionURL() {
        let question = sampleQuestion
        let url = URL.add(question: question)
        XCTAssertEqual(url.path, "/api/addQuestion")
        let query = queryDict(url)
        XCTAssertEqual(query["question"], question.text)
        XCTAssertNotNil(query["date"])
    }

    func testManualGreetURL() {
        let url = URL.manualGreet(otherID: 42)
        XCTAssertEqual(url.path, "/api/manualGreet")
        XCTAssertEqual(queryDict(url)["other_id"], "42")
    }

    func testResetPasswordURL() {
        let url = URL.resetPassword(email: "r@e.com")
        XCTAssertEqual(url.path, "/api/resetPassword")
        XCTAssertEqual(queryDict(url)["email"], "r@e.com")
    }

    func testChangeEmailURL() {
        let url = URL.change(email: "old@e.com", to: "new@e.com")
        XCTAssertEqual(url.path, "/api/changeEmail")
        let query = queryDict(url)
        XCTAssertEqual(query["primary_email"], "old@e.com")
        XCTAssertEqual(query["email"], "new@e.com")
    }

    func testRegisterDeviceTokenErrorURL() {
        let url = URL.registerDeviceToken(error: "failure")
        XCTAssertEqual(url.path, "/api/registerDeviceTokenError")
        let query = queryDict(url)
        XCTAssertEqual(query["error"], "failure")
        XCTAssertEqual(query["environment"], "DEBUG")
    }

    func testRegisterDeviceTokenURL() {
        let url = URL.register(deviceToken: "tok123")
        XCTAssertEqual(url.path, "/api/registerDeviceToken")
        let query = queryDict(url)
        XCTAssertEqual(query["device_token"], "tok123")
        XCTAssertEqual(query["environment"], "DEBUG")
    }

    func testHideMeURL() {
        let url = URL.hide(me: true)
        XCTAssertEqual(url.path, "/api/HideFromNearByList")
        XCTAssertEqual(queryDict(url)["isHide"], "1")
    }

    func testRegisterPushKitDeviceTokenURL() {
        let url = URL.register(pushKitDeviceToken: "pk123")
        XCTAssertEqual(url.path, "/api/registerPushKitDeviceToken")
        XCTAssertEqual(queryDict(url)["pushKitDeviceToken"], "pk123")
    }

    func testBlockUserURL() {
        let url = URL.block(user: 8)
        XCTAssertEqual(url.path, "/api/blockUser")
        XCTAssertEqual(queryDict(url)["other_id"], "8")
    }

    func testBlockOtherIDShouldBlockURL() {
        let url = URL.block(otherID: 9, shouldBlock: false)
        XCTAssertEqual(url.path, "/api/blockUser")
        XCTAssertEqual(queryDict(url)["other_id"], "9")
    }

    func testBlockedUsersURL() {
        XCTAssertEqual(URL.blockedUsers.path, "/api/getBlockedUsersLIst")
    }

    func testLoginURL() {
        let url = URL.login(email: "e@x.com", password: "pw")
        XCTAssertEqual(url.path, "/api/login")
        let query = queryDict(url)
        XCTAssertEqual(query["primary_email"], "e@x.com")
        XCTAssertEqual(query["password"], "pw")
    }

    func testAddResponseURL() {
        let response = sampleResponse
        let url = URL.add(response: response, questionID: "q99")
        XCTAssertEqual(url.path, "/api/addOption")
        let query = queryDict(url)
        XCTAssertEqual(query["question_id"], "q99")
        XCTAssertEqual(query["response"], response.text)
    }

    func testMakeResponseSelectionURL() {
        let context = Context(id: UUID(), case: .social)
        let url = URL.make(my: .YES, their: .NO, for: 5, for: 10, forContext: context)
        XCTAssertEqual(url.path, "/api/addUserResponse")
        let query = queryDict(url)
        XCTAssertEqual(query["context"], "social")
        XCTAssertEqual(query["question_id"], "10")
        XCTAssertEqual(query["response_id"], "5")
        XCTAssertEqual(query["my"], "1")
        XCTAssertEqual(query["their"], "-1")
    }

    func testMakeResponseSelectionNilChoicesURL() {
        let context = Context(id: UUID(), case: .romance)
        let url = URL.make(my: nil, their: nil, for: 1, for: 2, forContext: context)
        let query = queryDict(url)
        XCTAssertNil(query["my"])
        XCTAssertNil(query["their"])
    }

    func testQuestionsURLWithSearchAndPage() {
        let context = Context(id: UUID(), case: .romance)
        let url = URL.questions(search: "hi", type: .answered, page: 2, context: context, required: true)
        XCTAssertEqual(url.path, "/api/getQuestions")
        let query = queryDict(url)
        XCTAssertEqual(query["search"], "hi")
        XCTAssertEqual(query["flag"], "1")
        XCTAssertEqual(query["type"], "answered")
        XCTAssertEqual(query["pageNo"], "2")
        XCTAssertEqual(query["context"], "romance")
    }

    func testQuestionsURLDefaultsNilSearchAndPage() {
        let context = Context(id: UUID(), case: .social)
        let url = URL.questions(type: .all, context: context)
        let query = queryDict(url)
        XCTAssertNil(query["search"])
        XCTAssertNil(query["pageNo"])
        XCTAssertEqual(query["flag"], "0")
        XCTAssertEqual(query["type"], "all")
    }

    func testLogoutURL() {
        XCTAssertEqual(URL.logout.path, "/api/logout")
    }

    func testAddDisplayFuncURL() {
        XCTAssertEqual(URL.addDisplay().path, "/api/addDisplayPicture")
    }

    func testUploadPicURL() {
        XCTAssertEqual(URL.uploadPic.path, "/api/addDisplayPicture")
    }

    func testYelpBusinessURL() {
        let url = URL.yelpBusiness(latitude: 30.5, longitude: -97.7)
        XCTAssertEqual(url?.absoluteString, "https://api.yelp.com/v3/businesses/search?latitude=30.5&longitude=-97.7")
    }

    // MARK: - URLRequest+factory.swift

    func testUpdateScheduleRequest() throws {
        let week = [Week.Day(name: .Monday), Week.Day(name: .Tuesday)]
        let request = URLRequest.update(schedule: week)
        XCTAssertEqual(request?.httpMethod, "POST")
        XCTAssertEqual(request?.url, URL.updateSchedule)
        let decoded = try JSONDecoder().decode([Week.Day].self, from: XCTUnwrap(request?.httpBody))
        XCTAssertEqual(decoded.map(\.name.rawValue), ["Monday", "Tuesday"])
    }

    func testUpdateGreetRequest() throws {
        let greet = sampleGreet
        let request = URLRequest.update(greet: greet)
        XCTAssertEqual(request?.httpMethod, "POST")
        XCTAssertEqual(request?.url, URL.updateGreet)
        let decoded = try JSONDecoder().decode(Greet.self, from: XCTUnwrap(request?.httpBody))
        XCTAssertEqual(decoded, greet)
    }

    func testUpdateMidGreetSettingsRequest() throws {
        let settings = Greet.Settings(
            rejectedTimeProposals: [10],
            agreedTimeProposals: [20, 30],
            status: .enroute,
            id: .init()
        )
        let request = URLRequest.update(midGreetSettings: settings)
        XCTAssertEqual(request?.httpMethod, "POST")
        XCTAssertEqual(request?.url, URL.updateGreetSettings)
        let decoded = try JSONDecoder().decode(Greet.Settings.self, from: XCTUnwrap(request?.httpBody))
        XCTAssertEqual(decoded, settings)
    }

    func testYelpBusinessRequestFactory() {
        let request = URLRequest.yelpBusiness(latitude: 1.0, longitude: 2.0, apikey: "KEY123")
        XCTAssertEqual(request?.httpMethod, "GET")
        XCTAssertEqual(request?.value(forHTTPHeaderField: "Authorization"), "Bearer KEY123")
        XCTAssertEqual(request?.url?.absoluteString, "https://api.yelp.com/v3/businesses/search?latitude=1.0&longitude=2.0")
    }

    func testUpdateUserLocationRequestSuccess() throws {
        let userId = UUID()
        let request = URLRequest.updateUserLocation(userId: userId, latitude: 10.0, longitude: 20.0, contextId: "ctx1")
        XCTAssertEqual(request?.httpMethod, "PUT")
        XCTAssertEqual(request?.value(forHTTPHeaderField: "Content-Type"), "application/octet-stream")
        let decoded = try JSONDecoder().decode(Greet.UserLocationCoordinate.self, from: XCTUnwrap(request?.httpBody))
        XCTAssertEqual(decoded.user.id, userId)
        XCTAssertEqual(decoded.latitude, 10.0)
        XCTAssertEqual(decoded.longitude, 20.0)
    }

    func testUpdateUserLocationRequestNilWhenUserIdMissing() {
        XCTAssertNil(URLRequest.updateUserLocation(userId: nil, latitude: 1, longitude: 2))
    }

    func testUpdateUserLocationRequestNilWhenLatitudeMissing() {
        XCTAssertNil(URLRequest.updateUserLocation(userId: UUID(), latitude: nil, longitude: 2))
    }

    func testUpdateUserLocationRequestNilWhenLongitudeMissing() {
        XCTAssertNil(URLRequest.updateUserLocation(userId: UUID(), latitude: 1, longitude: nil))
    }

    // MARK: - uuid.swift

    func testQuestionResponseUpdatedFixedUUID() {
        XCTAssertEqual(UUID.questionResponseUpdated.uuidString, "3F2504E0-4F89-41D3-9A0C-0305E82C3301")
    }
}
