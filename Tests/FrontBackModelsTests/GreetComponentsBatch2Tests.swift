import XCTest
import Foundation
@testable import AkinFrontBackModels

private typealias ResponseChoice = Question.Response.Selections.MyTheir.Choice

private func makeResponse(
    myChoice: [String: ResponseChoice] = [:],
    theirChoices: [String: ResponseChoice] = [:]
) -> Question.Response {
    Question.Response(
        text: "sample",
        timeStamp: Date(),
        id: UUID(),
        creator: UUID(),
        questionID: UUID(),
        myChoice: myChoice,
        theirChoices: theirChoices,
        popularity: [:],
        originalContextID: UUID(),
        assessment: ModerationAssessment(entries: [])
    )
}

private func makeImageMetadata() -> ImageMetadata {
    ImageMetadata(
        width: 10,
        height: 10,
        format: "jpeg",
        assessment: ModerationAssessment(entries: []),
        id: UUID()
    )
}

private func makeNearbyUser(id: UUID = UUID(), name: String = "Test User") -> NearbyUser {
    NearbyUser(
        id: id,
        name: name,
        profileImage: "",
        imageMetaData: makeImageMetadata()
    )
}

private func makeBusiness(
    location: Location = Location(
        city: "San Francisco",
        country: "US",
        address2: "",
        address3: "",
        state: "CA",
        address1: "1 Main St",
        zipCode: "94107"
    )
) -> Business {
    Business(
        rating: 4.2,
        price: "$$$",
        phone: "555-0100",
        id: UUID(),
        categories: [Category(alias: "coffee", title: "Coffee & Tea")],
        reviewCount: 10,
        name: "Java House",
        url: "https://java.house",
        coordinates: Coordinates(latitude: 10, longitude: 20),
        imageURL: "https://img/java.jpg",
        location: location
    )
}

final class GreetComponentsBatch2Tests: XCTestCase {

    // MARK: - Array.swift

    func testArrayDataConvertsUInt8Buffer() {
        let bytes: [UInt8] = [0x01, 0x02, 0x03]
        XCTAssertEqual(bytes.data, Data(bytes))
    }

    func testArrayDataEmptyBuffer() {
        let bytes: [UInt8] = []
        XCTAssertEqual(bytes.data, Data())
    }

    func testHasSelectionMyTrueForYes() {
        let context = Context(id: UUID(), case: .romance)
        let response = makeResponse(myChoice: [context.rawValue: .YES])
        XCTAssertTrue([response].hasSelection(context: context, for: .my))
    }

    func testHasSelectionMyTrueForNo() {
        let context = Context(id: UUID(), case: .romance)
        let response = makeResponse(myChoice: [context.rawValue: .NO])
        XCTAssertTrue([response].hasSelection(context: context, for: .my))
    }

    func testHasSelectionMyFalseForEmptyChoice() {
        let context = Context(id: UUID(), case: .romance)
        let response = makeResponse(myChoice: [context.rawValue: .empty])
        XCTAssertFalse([response].hasSelection(context: context, for: .my))
    }

    func testHasSelectionMyFalseForNeutralChoice() {
        let context = Context(id: UUID(), case: .romance)
        let response = makeResponse(myChoice: [context.rawValue: .NEUTRAL])
        XCTAssertFalse([response].hasSelection(context: context, for: .my))
    }

    func testHasSelectionMyFalseWhenContextMissing() {
        let context = Context(id: UUID(), case: .romance)
        let response = makeResponse(myChoice: [:])
        XCTAssertFalse([response].hasSelection(context: context, for: .my))
    }

    func testHasSelectionTheirTrueForYes() {
        let context = Context(id: UUID(), case: .social)
        let response = makeResponse(theirChoices: [context.rawValue: .YES])
        XCTAssertTrue([response].hasSelection(context: context, for: .their))
    }

    func testHasSelectionTheirFalseWhenOnlyMySet() {
        let context = Context(id: UUID(), case: .social)
        let response = makeResponse(myChoice: [context.rawValue: .YES])
        XCTAssertFalse([response].hasSelection(context: context, for: .their))
    }

    func testHasSelectionEmptyArrayIsFalse() {
        let context = Context(id: UUID(), case: .romance)
        let responses: [Question.Response] = []
        XCTAssertFalse(responses.hasSelection(context: context, for: .my))
    }

    func testHasSelectionTrueWhenAnyElementMatches() {
        let context = Context(id: UUID(), case: .romance)
        let nonMatching = makeResponse(myChoice: [context.rawValue: .empty])
        let matching = makeResponse(myChoice: [context.rawValue: .YES])
        XCTAssertTrue([nonMatching, matching].hasSelection(context: context, for: .my))
    }

    func testRemoveGreetingMethodRemovesAllMatches() {
        var methods: [Greet.Method] = [.hug, .kiss, .hug, .wave]
        methods.remove(greetingMethod: .hug)
        XCTAssertEqual(methods, [.kiss, .wave])
    }

    func testRemoveGreetingMethodNoMatchLeavesArrayUnchanged() {
        var methods: [Greet.Method] = [.kiss, .wave]
        methods.remove(greetingMethod: .hug)
        XCTAssertEqual(methods, [.kiss, .wave])
    }

    func testRemoveGreetingMethodOnEmptyArray() {
        var methods: [Greet.Method] = []
        methods.remove(greetingMethod: .hug)
        XCTAssertTrue(methods.isEmpty)
    }

    func testNearbyUserIndexOfFindsMatchingID() {
        let first = makeNearbyUser(name: "First")
        let second = makeNearbyUser(name: "Second")
        let users = [first, second]
        XCTAssertEqual(users.index(of: second.id), 1)
        XCTAssertEqual(users.index(of: first.id), 0)
    }

    func testNearbyUserIndexOfReturnsNilWhenMissing() {
        let users = [makeNearbyUser()]
        XCTAssertNil(users.index(of: UUID()))
    }

    // MARK: - Bool.swift

    func testBoolStrIntTrue() {
        XCTAssertEqual(true.strInt, "1")
    }

    func testBoolStrIntFalse() {
        XCTAssertEqual(false.strInt, "0")
    }

    func testBoolIntTrue() {
        XCTAssertEqual(true.int, 1)
    }

    func testBoolIntFalse() {
        XCTAssertEqual(false.int, 0)
    }

    func testBoolIsDebugMatchesActiveBuildConfiguration() {
        #if DEBUG
        XCTAssertTrue(Bool.isDebug)
        #else
        XCTAssertFalse(Bool.isDebug)
        #endif
    }

    // MARK: - Collection.swift

    func testHasExactlyOneTrueForSingleElementArray() {
        XCTAssertTrue([1].hasExactlyOne)
    }

    func testHasExactlyOneFalseForEmptyArray() {
        XCTAssertFalse(([] as [Int]).hasExactlyOne)
    }

    func testHasExactlyOneFalseForMultipleElements() {
        XCTAssertFalse([1, 2].hasExactlyOne)
    }

    func testHasExactlyOneTrueForSingleCharacterString() {
        XCTAssertTrue("a".hasExactlyOne)
    }

    func testHasExactlyOneFalseForEmptyString() {
        XCTAssertFalse("".hasExactlyOne)
    }

    // MARK: - Data.swift

    func testMultipartDataInitWithParametersAndFilePath() throws {
        let thisUserID = UUID()
        let imageData = try XCTUnwrap("img-bytes".data(using: .utf8))
        let data = Data(
            parameters: ["caption": "hello"],
            filePathKey: "file",
            imageDataKey: imageData,
            boundary: "BOUNDARY123",
            thisUserID: thisUserID
        )
        let unwrapped = try XCTUnwrap(data)
        let string = try XCTUnwrap(String(data: unwrapped, encoding: .utf8))
        XCTAssertTrue(string.contains("--BOUNDARY123\r\n"))
        XCTAssertTrue(string.contains("Content-Disposition: form-data; name=\"caption\""))
        XCTAssertTrue(string.contains("hello"))
        XCTAssertTrue(string.contains("Content-Disposition: form-data; name=\"file\"; filename=\"123display_\(String(describing: thisUserID)).jpeg\""))
        XCTAssertTrue(string.contains("Content-Type: image/jpeg"))
        XCTAssertTrue(string.contains("img-bytes"))
        XCTAssertTrue(string.hasSuffix("--BOUNDARY123--\r\n"))
    }

    func testMultipartDataInitWithNilParametersSkipsParameterLoop() throws {
        let data = Data(parameters: nil, filePathKey: "file", imageDataKey: Data(), boundary: "B", thisUserID: UUID())
        XCTAssertNotNil(data)
    }

    func testMultipartDataInitWithEmptyParametersDictionary() throws {
        let data = Data(parameters: [:], filePathKey: "file", imageDataKey: Data(), boundary: "B", thisUserID: UUID())
        XCTAssertNotNil(data)
    }

    func testMultipartDataInitReturnsNilWithoutFilePathKey() {
        let data = Data(parameters: nil, filePathKey: nil, imageDataKey: Data(), boundary: "B", thisUserID: UUID())
        XCTAssertNil(data)
    }

    func testAppendStringAppendsUTF8Bytes() throws {
        var data = Data()
        data.appendString(string: "hello")
        XCTAssertEqual(data, try XCTUnwrap("hello".data(using: .utf8)))
    }

    func testAppendStringWithEmptyStringAppendsNothing() {
        var data = Data()
        data.appendString(string: "")
        XCTAssertEqual(data, Data())
    }

    // MARK: - Date.swift

    func testApiStringFormatsInGMT() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try XCTUnwrap(TimeZone(identifier: "GMT"))
        var comps = DateComponents()
        comps.year = 2023
        comps.month = 7
        comps.day = 4
        comps.hour = 15
        comps.minute = 30
        comps.second = 45
        let date = try XCTUnwrap(calendar.date(from: comps))
        XCTAssertEqual(date.apiString, "2023-07-04 15:30:45")
    }

    func testRandomEarlierDateIsBeforeOriginalWithinBounds() {
        let now = Date()
        let earlier = now.randomEarlierDate
        let diff = now.timeIntervalSince(earlier)
        XCTAssertGreaterThan(diff, 0)
        XCTAssertLessThanOrEqual(diff, 10.001)
    }

    func testAgeExactlyOnBirthday() throws {
        let birthday = try makeDate(year: 2000, month: 6, day: 15)
        let current = try makeDate(year: 2024, month: 6, day: 15)
        XCTAssertEqual(birthday.age(currentDate: current), 24)
    }

    func testAgeDayBeforeBirthdayHasNotIncremented() throws {
        let birthday = try makeDate(year: 2000, month: 6, day: 15)
        let current = try makeDate(year: 2024, month: 6, day: 14)
        XCTAssertEqual(birthday.age(currentDate: current), 23)
    }

    func testAgeDayAfterBirthdayHasIncremented() throws {
        let birthday = try makeDate(year: 2000, month: 6, day: 15)
        let current = try makeDate(year: 2024, month: 6, day: 16)
        XCTAssertEqual(birthday.age(currentDate: current), 24)
    }

    func testAgeUsesCurrentDateByDefault() throws {
        let birthday = try XCTUnwrap(Calendar.current.date(byAdding: .year, value: -30, to: Date()))
        XCTAssertEqual(birthday.age(), 30)
    }

    func testBirthdayReadableFormatsMonthDayYear() throws {
        let date = try makeDate(year: 1993, month: 1, day: 5)
        XCTAssertEqual(date.birthdayReadable, "January 5, 1993")
    }

    private func makeDate(year: Int, month: Int, day: Int) throws -> Date {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        comps.hour = 12
        return try XCTUnwrap(Calendar.current.date(from: comps))
    }

    // MARK: - Dictionary-String-Any.swift

    func testDatabaseTimeLapsePresent() {
        let dict: [String: Any] = ["databaseTimeLapse": Float(1.5)]
        XCTAssertEqual(dict.databaseTimeLapse, 1.5)
    }

    func testDatabaseTimeLapseMissingKey() {
        let dict: [String: Any] = [:]
        XCTAssertNil(dict.databaseTimeLapse)
    }

    func testDatabaseTimeLapseWrongType() {
        let dict: [String: Any] = ["databaseTimeLapse": "not a float"]
        XCTAssertNil(dict.databaseTimeLapse)
    }

    func testServersideOnlyTimeLapsePresent() {
        let dict: [String: Any] = ["serversideOnlyTimeLapse": Float(2.5)]
        XCTAssertEqual(dict.serversideOnlyTimeLapse, 2.5)
    }

    func testServersideOnlyTimeLapseMissingKey() {
        let dict: [String: Any] = [:]
        XCTAssertNil(dict.serversideOnlyTimeLapse)
    }

    func testServersideOnlyTimeLapseWrongType() {
        let dict: [String: Any] = ["serversideOnlyTimeLapse": "nope"]
        XCTAssertNil(dict.serversideOnlyTimeLapse)
    }

    func testValueForKeyGenericSuccess() {
        let dict: [String: Any] = ["count": 42]
        let result: Int? = dict.value(for: "count")
        XCTAssertEqual(result, 42)
    }

    func testValueForKeyGenericMissingKey() {
        let dict: [String: Any] = [:]
        let result: Int? = dict.value(for: "count")
        XCTAssertNil(result)
    }

    func testValueForKeyGenericWrongType() {
        let dict: [String: Any] = ["count": "42"]
        let result: Int? = dict.value(for: "count")
        XCTAssertNil(result)
    }

    // MARK: - Int.swift

    func testIntStringPositive() {
        XCTAssertEqual(5.string, "5")
    }

    func testIntStringZero() {
        XCTAssertEqual(0.string, "0")
    }

    func testIntStringNegative() {
        XCTAssertEqual((-42).string, "-42")
    }

    func testIntBoolValueZeroIsFalse() {
        XCTAssertFalse(0.boolValue)
    }

    func testIntBoolValuePositiveIsTrue() {
        XCTAssertTrue(1.boolValue)
    }

    func testIntBoolValueNegativeIsTrue() {
        XCTAssertTrue((-1).boolValue)
    }

    func testIntDoubleConversion() {
        XCTAssertEqual(5.double, 5.0)
    }

    func testIntDoubleConversionNegative() {
        XCTAssertEqual((-3).double, -3.0)
    }

    // MARK: - TimeInterval.swift

    func testRandomSecondsIsWithinDocumentedBounds() {
        for _ in 0..<50 {
            let value = TimeInterval.randomSeconds
            XCTAssertGreaterThanOrEqual(value, 0.0001)
            XCTAssertLessThanOrEqual(value, 10.0000)
        }
    }

    // MARK: - BuildSource.swift

    func testBuildSourceIDMatchesRawValue() {
        XCTAssertEqual(BuildSource.xcode.id, "xcode")
        XCTAssertEqual(BuildSource.testflight.id, "testflight")
        XCTAssertEqual(BuildSource.appStore.id, "appStore")
    }

    func testBuildSourceAllCasesContainsAllThree() {
        XCTAssertEqual(BuildSource.allCases.count, 3)
        XCTAssertTrue(BuildSource.allCases.contains(.xcode))
        XCTAssertTrue(BuildSource.allCases.contains(.testflight))
        XCTAssertTrue(BuildSource.allCases.contains(.appStore))
    }

    func testBuildSourceCodableRoundTrip() throws {
        for source in BuildSource.allCases {
            let encoded = try JSONEncoder().encode(source)
            let decoded = try JSONDecoder().decode(BuildSource.self, from: encoded)
            XCTAssertEqual(decoded, source)
        }
    }

    func testBuildSourceEquatableAndHashable() {
        XCTAssertEqual(BuildSource.xcode, BuildSource.xcode)
        XCTAssertNotEqual(BuildSource.xcode, BuildSource.testflight)
        let set: Set<BuildSource> = [.xcode, .xcode, .testflight]
        XCTAssertEqual(set.count, 2)
    }

    // MARK: - PrivateDetails.swift

    func testPrivateDetailsInitMapsAccessTokenArgumentToTokenProperty() {
        let details = PrivateDetails(password: "pw", romanceOn: true, accessToken: "tok123")
        XCTAssertEqual(details.password, "pw")
        XCTAssertTrue(details.romanceOn)
        XCTAssertEqual(details.token, "tok123")
    }

    func testPrivateDetailsInitWithRomanceOff() {
        let details = PrivateDetails(password: "pw2", romanceOn: false, accessToken: "tok456")
        XCTAssertFalse(details.romanceOn)
    }

    func testPrivateDetailsCodableRoundTrip() throws {
        let details = PrivateDetails(password: "secret", romanceOn: false, accessToken: "tok456")
        let encoded = try JSONEncoder().encode(details)
        let decoded = try JSONDecoder().decode(PrivateDetails.self, from: encoded)
        XCTAssertEqual(decoded.password, details.password)
        XCTAssertEqual(decoded.romanceOn, details.romanceOn)
        XCTAssertEqual(decoded.token, details.token)
    }

    func testPrivateDetailsEncodesTokenKeyNotAccessToken() throws {
        let details = PrivateDetails(password: "pw", romanceOn: true, accessToken: "tok789")
        let encoded = try JSONEncoder().encode(details)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        XCTAssertEqual(json["token"] as? String, "tok789")
        XCTAssertNil(json["accessToken"])
    }

    // MARK: - YelpBusinesses.swift

    func testYelpDecodesFromJSON() throws {
        let json = """
        {
            "total": 1,
            "businesses": [
                {
                    "rating": 4.5,
                    "price": "$$",
                    "phone": "+15551234567",
                    "id": "11111111-1111-1111-1111-111111111111",
                    "categories": [{"alias": "coffee", "title": "Coffee & Tea"}],
                    "review_count": 120,
                    "name": "Blue Bottle",
                    "url": "https://yelp.com/blue-bottle",
                    "coordinates": {"latitude": 37.7, "longitude": -122.4},
                    "image_url": "https://img/blue.jpg",
                    "location": {
                        "city": "San Francisco",
                        "country": "US",
                        "address2": "",
                        "address3": "",
                        "state": "CA",
                        "address1": "123 Main St",
                        "zip_code": "94107"
                    }
                }
            ]
        }
        """
        let data = try XCTUnwrap(json.data(using: .utf8))
        let yelp = try JSONDecoder().decode(Yelp.self, from: data)

        XCTAssertEqual(yelp.total, 1)
        XCTAssertEqual(yelp.businesses.count, 1)

        let business = yelp.businesses[0]
        XCTAssertEqual(business.rating, 4.5)
        XCTAssertEqual(business.price, "$$")
        XCTAssertEqual(business.phone, "+15551234567")
        XCTAssertEqual(business.id, UUID(uuidString: "11111111-1111-1111-1111-111111111111"))
        XCTAssertEqual(business.categories.count, 1)
        XCTAssertEqual(business.categories[0].alias, "coffee")
        XCTAssertEqual(business.categories[0].title, "Coffee & Tea")
        XCTAssertEqual(business.reviewCount, 120)
        XCTAssertEqual(business.name, "Blue Bottle")
        XCTAssertEqual(business.url, "https://yelp.com/blue-bottle")
        XCTAssertEqual(business.coordinates.latitude, 37.7)
        XCTAssertEqual(business.coordinates.longitude, -122.4)
        XCTAssertEqual(business.imageURL, "https://img/blue.jpg")
        XCTAssertEqual(business.location.city, "San Francisco")
        XCTAssertEqual(business.location.zipCode, "94107")
    }

    func testCategoryInitAndProperties() {
        let category = Category(alias: "bars", title: "Bars")
        XCTAssertEqual(category.alias, "bars")
        XCTAssertEqual(category.title, "Bars")
    }

    func testCategoryCodableRoundTrip() throws {
        let category = Category(alias: "bars", title: "Bars")
        let encoded = try JSONEncoder().encode(category)
        let decoded = try JSONDecoder().decode(Category.self, from: encoded)
        XCTAssertEqual(decoded.alias, category.alias)
        XCTAssertEqual(decoded.title, category.title)
    }

    func testCoordinatesInitAndEquatable() {
        let a = Coordinates(latitude: 1.0, longitude: 2.0)
        let b = Coordinates(latitude: 1.0, longitude: 2.0)
        let c = Coordinates(latitude: 3.0, longitude: 2.0)
        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, c)
        XCTAssertEqual(a.latitude, 1.0)
        XCTAssertEqual(a.longitude, 2.0)
    }

    func testCoordinatesHashable() {
        let a = Coordinates(latitude: 1.0, longitude: 2.0)
        let b = Coordinates(latitude: 1.0, longitude: 2.0)
        let set: Set<Coordinates> = [a, b]
        XCTAssertEqual(set.count, 1)
    }

    func testBusinessVenueComputedProperty() {
        let business = makeBusiness()
        let venue = business.venue
        XCTAssertEqual(venue.url, business.url)
        XCTAssertEqual(venue.name, business.name)
        XCTAssertEqual(venue.address, business.location.displayAddress)
        XCTAssertEqual(venue.latitude, business.coordinates.latitude)
        XCTAssertEqual(venue.longitude, business.coordinates.longitude)
    }

    func testDisplayAddressWithAllFieldsPresent() {
        let location = Location(
            city: "SF",
            country: "US",
            address2: "Apt 2",
            address3: "Bldg 3",
            state: "CA",
            address1: "123 Main",
            zipCode: "94107"
        )
        XCTAssertEqual(location.displayAddress, "123 Main, Apt 2, Bldg 3, SF, CA, 94107, US")
    }

    func testDisplayAddressWithAllFieldsEmpty() {
        let location = Location(
            city: "",
            country: "",
            address2: "",
            address3: "",
            state: "",
            address1: "",
            zipCode: ""
        )
        XCTAssertEqual(location.displayAddress, "")
    }

    func testDisplayAddressSkipsEmptyFieldsOnly() {
        let location = Location(
            city: "SF",
            country: "",
            address2: "",
            address3: "",
            state: "CA",
            address1: "123 Main",
            zipCode: ""
        )
        XCTAssertEqual(location.displayAddress, "123 Main, SF, CA")
    }

    func testLocationCodableRoundTripMapsZipCodeKey() throws {
        let location = Location(
            city: "SF",
            country: "US",
            address2: "",
            address3: "",
            state: "CA",
            address1: "123 Main",
            zipCode: "94107"
        )
        let encoded = try JSONEncoder().encode(location)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        XCTAssertEqual(json["zip_code"] as? String, "94107")
        XCTAssertNil(json["zipCode"])
        let decoded = try JSONDecoder().decode(Location.self, from: encoded)
        XCTAssertEqual(decoded.zipCode, "94107")
    }

    // MARK: - Venue.swift

    func testVenueInitAndProperties() {
        let venue = Venue(url: "https://x", name: "Cafe", address: "1 Main", latitude: 1.1, longitude: 2.2)
        XCTAssertEqual(venue.url, "https://x")
        XCTAssertEqual(venue.name, "Cafe")
        XCTAssertEqual(venue.address, "1 Main")
        XCTAssertEqual(venue.latitude, 1.1)
        XCTAssertEqual(venue.longitude, 2.2)
    }

    func testVenueCodableRoundTrip() throws {
        let venue = Venue(url: "u", name: "n", address: "a", latitude: 3, longitude: 4)
        let encoded = try JSONEncoder().encode(venue)
        let decoded = try JSONDecoder().decode(Venue.self, from: encoded)
        XCTAssertEqual(decoded, venue)
    }

    func testVenueEquatableAndHashable() {
        let a = Venue(url: "u", name: "n", address: "a", latitude: 1, longitude: 2)
        let b = Venue(url: "u", name: "n", address: "a", latitude: 1, longitude: 2)
        let c = Venue(url: "different", name: "n", address: "a", latitude: 1, longitude: 2)
        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, c)
        let set: Set<Venue> = [a, b, c]
        XCTAssertEqual(set.count, 2)
    }

    func testImpactVenueInitAndProperties() {
        let id = UUID()
        let venue = ImpactVenue(id: id, name: "Park", address: "2 Elm")
        XCTAssertEqual(venue.id, id)
        XCTAssertEqual(venue.name, "Park")
        XCTAssertEqual(venue.address, "2 Elm")
    }

    func testImpactVenueCodableRoundTrip() throws {
        let venue = ImpactVenue(id: UUID(), name: "n", address: "a")
        let encoded = try JSONEncoder().encode(venue)
        let decoded = try JSONDecoder().decode(ImpactVenue.self, from: encoded)
        XCTAssertEqual(decoded, venue)
    }

    func testImpactVenueEquatableAndHashable() {
        let id = UUID()
        let a = ImpactVenue(id: id, name: "n", address: "a")
        let b = ImpactVenue(id: id, name: "n", address: "a")
        let c = ImpactVenue(id: UUID(), name: "n", address: "a")
        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, c)
        let set: Set<ImpactVenue> = [a, b, c]
        XCTAssertEqual(set.count, 2)
    }
}
