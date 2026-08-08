//
//  TopLevelModelsBatch7Tests.swift
//  AkinFrontBackModels
//

import XCTest
import StrongContractClient
@testable import AkinFrontBackModels

final class TopLevelModelsBatch7Tests: XCTestCase {

    // MARK: - Shared fixtures

    private func assessment() -> ModerationAssessment {
        ModerationAssessment(entries: [])
    }

    private func flagExplanation() -> FlagExplanation {
        FlagExplanation(flag: .spam, explanation: "looked spammy", source: .manualOtherUser, aiConfidence: 0.5)
    }

    private func imageMetadata() -> ImageMetadata {
        ImageMetadata(width: 20, height: 20, format: "jpeg", assessment: assessment(), id: UUID())
    }

    private func nearbyUser(hasGrantedCallKitConsent: Bool = false) -> NearbyUser {
        NearbyUser(
            id: UUID(),
            name: "Scott",
            profileImage: "profile.jpg",
            imageMetaData: imageMetadata(),
            verified: true,
            lastLocationUpdate: nil,
            hasGrantedCallKitConsent: hasGrantedCallKitConsent
        )
    }

    private func venue() -> Venue {
        Venue(url: "https://example.com", name: "Starbucks", address: "123 Main St", latitude: 37, longitude: 36)
    }

    private func minimalGreet() throws -> Greet {
        let thisID = UUID()
        let otherID = UUID()
        return try Greet(
            thisUserID: thisID,
            otherUser: nearbyUser(),
            greetID: UUID(),
            venue: venue(),
            minutesAway: 10,
            otherMinutesAway: 15,
            initiationMethod: .manual(userID: UUID()),
            travelMethod: .bike,
            matchMakingMethodVersion: 1,
            participantUserIDs: [thisID, otherID]
        )
    }

    private func context(_ theCase: Context.Case) -> Context {
        Context(id: UUID(), case: theCase)
    }

    private func questionResponse(text: String, questionID: UUID) -> Question.Response {
        Question.Response(
            text: text,
            timeStamp: Date(),
            id: UUID(),
            creator: UUID(),
            questionID: questionID,
            originalContextID: UUID(),
            assessment: assessment()
        )
    }

    // MARK: - LocationNotificationModel.swift (Greet.Notification.LocalModel)

    func testLocalModelInitAssignsAllProperties() {
        let greetID = UUID()
        let otherUserID = UUID()
        let model = Greet.Notification.LocalModel(
            greetID: greetID,
            otherUserID: otherUserID,
            profileURL: "https://example.com/pic.jpg",
            name: "Jane",
            timeMet: "2024-02-12T14:00:00Z",
            notificationKey: .getReviewTime
        )
        XCTAssertEqual(model.greetID, greetID)
        XCTAssertEqual(model.otherUserID, otherUserID)
        XCTAssertEqual(model.profileURL, "https://example.com/pic.jpg")
        XCTAssertEqual(model.name, "Jane")
        XCTAssertEqual(model.timeMet, "2024-02-12T14:00:00Z")
        XCTAssertEqual(model.notificationKey, .getReviewTime)
    }

    func testLocalModelInitAllowsNilProfileURL() {
        let model = Greet.Notification.LocalModel(
            greetID: UUID(), otherUserID: UUID(), profileURL: nil, name: "Jane", timeMet: "t", notificationKey: .weClosedTheGreet
        )
        XCTAssertNil(model.profileURL)
    }

    func testLocalModelCodableRoundTripBothKeys() throws {
        for key: Greet.Notification.LocalModel.Key in [.getReviewTime, .weClosedTheGreet] {
            let original = Greet.Notification.LocalModel(
                greetID: UUID(), otherUserID: UUID(), profileURL: "url", name: "Jane", timeMet: "t", notificationKey: key
            )
            let data = try JSONEncoder().encode(original)
            let decoded = try JSONDecoder().decode(Greet.Notification.LocalModel.self, from: data)
            XCTAssertEqual(original, decoded)
        }
    }

    func testLocalModelEquatable() {
        let greetID = UUID()
        let otherUserID = UUID()
        let a = Greet.Notification.LocalModel(greetID: greetID, otherUserID: otherUserID, profileURL: "u", name: "n", timeMet: "t", notificationKey: .getReviewTime)
        let b = Greet.Notification.LocalModel(greetID: greetID, otherUserID: otherUserID, profileURL: "u", name: "n", timeMet: "t", notificationKey: .getReviewTime)
        let c = Greet.Notification.LocalModel(greetID: greetID, otherUserID: otherUserID, profileURL: "u", name: "n", timeMet: "t", notificationKey: .weClosedTheGreet)
        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, c)
    }

    func testLocalModelHashable() {
        let model = Greet.Notification.LocalModel(greetID: UUID(), otherUserID: UUID(), profileURL: "u", name: "n", timeMet: "t", notificationKey: .getReviewTime)
        let set: Set<Greet.Notification.LocalModel> = [model, model]
        XCTAssertEqual(set.count, 1)
    }

    func testLocalModelKeyCodableRawValues() throws {
        let getReview = try JSONEncoder().encode(Greet.Notification.LocalModel.Key.getReviewTime)
        XCTAssertEqual(String(data: getReview, encoding: .utf8), "\"getReviewTime\"")
        let closed = try JSONEncoder().encode(Greet.Notification.LocalModel.Key.weClosedTheGreet)
        XCTAssertEqual(String(data: closed, encoding: .utf8), "\"weClosedTheGreet\"")
    }

    // MARK: - NearbyUser.swift

    func testNearbyUserInitDefaults() {
        let user = NearbyUser(id: UUID(), name: "Jane", profileImage: "pic", imageMetaData: imageMetadata())
        XCTAssertFalse(user.verified)
        XCTAssertNil(user.lastLocationUpdate)
        XCTAssertFalse(user.hasGrantedCallKitConsent)
    }

    func testNearbyUserInitExplicitValues() {
        let date = Date()
        let user = NearbyUser(id: UUID(), name: "Jane", profileImage: "pic", imageMetaData: imageMetadata(), verified: true, lastLocationUpdate: date, hasGrantedCallKitConsent: true)
        XCTAssertTrue(user.verified)
        XCTAssertEqual(user.lastLocationUpdate, date)
        XCTAssertTrue(user.hasGrantedCallKitConsent)
    }

    func testNearbyUserCodableRoundTripPreservesAllFields() throws {
        let original = nearbyUser(hasGrantedCallKitConsent: true)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(NearbyUser.self, from: data)
        XCTAssertEqual(original, decoded)
        XCTAssertTrue(decoded.hasGrantedCallKitConsent)
    }

    func testNearbyUserDecodeMissingHasGrantedCallKitConsentDefaultsFalse() throws {
        let id = UUID()
        let metaID = UUID()
        let json = """
        {"id":"\(id.uuidString)","name":"Jane","profileImage":"pic","imageMetaData":{"width":20,"height":20,"format":"jpeg","assessment":{"entries":[]},"id":"\(metaID.uuidString)"},"verified":true}
        """
        let decoded = try JSONDecoder().decode(NearbyUser.self, from: Data(json.utf8))
        XCTAssertFalse(decoded.hasGrantedCallKitConsent)
        XCTAssertTrue(decoded.verified)
        XCTAssertNil(decoded.lastLocationUpdate)
    }

    func testNearbyUserDecodeMissingVerifiedDefaultsFalse() throws {
        let id = UUID()
        let metaID = UUID()
        let json = """
        {"id":"\(id.uuidString)","name":"Jane","profileImage":"pic","imageMetaData":{"width":20,"height":20,"format":"jpeg","assessment":{"entries":[]},"id":"\(metaID.uuidString)"}}
        """
        let decoded = try JSONDecoder().decode(NearbyUser.self, from: Data(json.utf8))
        XCTAssertFalse(decoded.verified)
        XCTAssertFalse(decoded.hasGrantedCallKitConsent)
    }

    func testProfileImageDetailsCodableRoundTrip() throws {
        let original = ProfileImageDetails(url: "https://example.com", metaDataID: UUID())
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ProfileImageDetails.self, from: data)
        XCTAssertEqual(decoded.url, original.url)
        XCTAssertEqual(decoded.metaDataID, original.metaDataID)
    }

    // MARK: - Notification.swift (Greet.Notification + APNSPayload)

    func testNotificationInitFromLocalModelProducesGetRatingCase() {
        let model = Greet.Notification.LocalModel(greetID: UUID(), otherUserID: UUID(), profileURL: nil, name: "n", timeMet: "t", notificationKey: .getReviewTime)
        let notification = Greet.Notification(localNotificationModel: model)
        if case .getRating(let embedded) = notification {
            XCTAssertEqual(embedded, model)
        } else {
            XCTFail("Expected .getRating case")
        }
    }

    func testNotificationGreetCaseCodableRoundTrip() throws {
        let greet = try minimalGreet()
        let original = Greet.Notification.greet(greet)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Greet.Notification.self, from: data)
        guard case .greet(let decodedGreet) = decoded else {
            return XCTFail("Expected .greet case after decoding")
        }
        XCTAssertEqual(decodedGreet.greetID, greet.greetID)
    }

    func testNotificationEquatableDifferentCasesAreNotEqual() {
        let a = Greet.Notification.silentLocationUpdate
        let b = Greet.Notification.getRating(Greet.Notification.LocalModel(greetID: UUID(), otherUserID: UUID(), profileURL: nil, name: "n", timeMet: "t", notificationKey: .getReviewTime))
        XCTAssertNotEqual(a, b)
    }

    func testNotificationEquatableSameCaseSameValueEqual() {
        XCTAssertEqual(Greet.Notification.silentLocationUpdate, Greet.Notification.silentLocationUpdate)
    }

    func testAPNSPayloadInitAssignsProperties() {
        let apnsID = UUID()
        let payload = APNSPayload(payload: "hello", apnsID: apnsID)
        XCTAssertEqual(payload.payload, "hello")
        XCTAssertEqual(payload.apnsID, apnsID)
    }

    func testAPNSPayloadCodableRoundTrip() throws {
        let original = APNSPayload(payload: UserImage(id: UUID(), name: "pic"), apnsID: UUID())
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(APNSPayload<UserImage>.self, from: data)
        XCTAssertEqual(decoded.payload, original.payload)
        XCTAssertEqual(decoded.apnsID, original.apnsID)
    }

    // MARK: - Question.swift

    func testQuestionEqualityIsByIDOnly() {
        let id = UUID()
        let a = Question(text: "a", id: id, creatorID: UUID(), originalContext: context(.romance), defaultCompatibilityRule: .mandatory, assessment: assessment())
        var b = Question(text: "different text", id: id, creatorID: UUID(), originalContext: context(.social), defaultCompatibilityRule: .weighted, assessment: assessment())
        b.responses = [questionResponse(text: "r", questionID: id)]
        XCTAssertEqual(a, b)
    }

    func testQuestionInequalityWithDifferentID() {
        let a = Question(text: "a", id: UUID(), creatorID: UUID(), originalContext: context(.romance), defaultCompatibilityRule: .mandatory, assessment: assessment())
        let b = Question(text: "a", id: UUID(), creatorID: UUID(), originalContext: context(.romance), defaultCompatibilityRule: .mandatory, assessment: assessment())
        XCTAssertNotEqual(a, b)
    }

    func testQuestionHashIsByIDOnly() {
        let id = UUID()
        let a = Question(text: "a", id: id, creatorID: UUID(), originalContext: context(.romance), defaultCompatibilityRule: .mandatory, assessment: assessment())
        var b = a
        b.text = "totally different"
        let set: Set<Question> = [a, b]
        XCTAssertEqual(set.count, 1)
    }

    func testResponsesContainingIsCaseInsensitive() {
        let questionID = UUID()
        var question = Question(text: "q", id: questionID, creatorID: UUID(), originalContext: context(.romance), defaultCompatibilityRule: .mandatory, assessment: assessment())
        question.responses = [
            questionResponse(text: "Hello World", questionID: questionID),
            questionResponse(text: "goodbye", questionID: questionID)
        ]
        let matches = question.responses(containing: "hello")
        XCTAssertEqual(matches.count, 1)
        XCTAssertEqual(matches.first?.text, "Hello World")
    }

    func testResponsesContainingNoMatchesReturnsEmpty() {
        let questionID = UUID()
        var question = Question(text: "q", id: questionID, creatorID: UUID(), originalContext: context(.romance), defaultCompatibilityRule: .mandatory, assessment: assessment())
        question.responses = [questionResponse(text: "abc", questionID: questionID)]
        XCTAssertTrue(question.responses(containing: "zzz").isEmpty)
    }

    func testIsDeepEqualTrueForIdenticalContent() {
        let id = UUID()
        let creatorID = UUID()
        let ctx = context(.romance)
        let a = Question(text: "same", id: id, creatorID: creatorID, originalContext: ctx, defaultCompatibilityRule: .mandatory, assessment: assessment())
        let b = Question(text: "same", id: id, creatorID: creatorID, originalContext: ctx, defaultCompatibilityRule: .mandatory, assessment: assessment())
        XCTAssertTrue(a.isDeepEqual(to: b))
    }

    func testIsDeepEqualFalseWhenTextDiffers() {
        let id = UUID()
        let a = Question(text: "a", id: id, creatorID: UUID(), originalContext: context(.romance), defaultCompatibilityRule: .mandatory, assessment: assessment())
        var b = a
        b.text = "different"
        XCTAssertFalse(a.isDeepEqual(to: b))
    }

    func testIsDeepEqualFalseWhenResponsesDiffer() {
        let id = UUID()
        let a = Question(text: "a", id: id, creatorID: UUID(), originalContext: context(.romance), defaultCompatibilityRule: .mandatory, assessment: assessment())
        var b = a
        b.responses = [questionResponse(text: "r", questionID: id)]
        XCTAssertFalse(a.isDeepEqual(to: b))
    }

    func testIsDeepEqualFalseWhenCreatorIDDiffers() {
        let a = Question(text: "a", id: UUID(), creatorID: UUID(), originalContext: context(.romance), defaultCompatibilityRule: .mandatory, assessment: assessment())
        var b = a
        b.creatorID = UUID()
        XCTAssertFalse(a.isDeepEqual(to: b))
    }

    func testIsDeepEqualFalseWhenCompatibilityRuleDiffers() {
        let a = Question(text: "a", id: UUID(), creatorID: UUID(), originalContext: context(.romance), defaultCompatibilityRule: .mandatory, assessment: assessment())
        var b = a
        b.defaultCompatibilityRule = .weighted
        XCTAssertFalse(a.isDeepEqual(to: b))
    }

    func testIsDeepEqualFalseWhenImportanceForDiffers() {
        let a = Question(text: "a", id: UUID(), creatorID: UUID(), originalContext: context(.romance), defaultCompatibilityRule: .mandatory, assessment: assessment())
        var b = a
        b.importanceFor = ["romance": .very]
        XCTAssertFalse(a.isDeepEqual(to: b))
    }

    func testIsDeepEqualFalseWhenContextPopularityDiffers() {
        let a = Question(text: "a", id: UUID(), creatorID: UUID(), originalContext: context(.romance), defaultCompatibilityRule: .mandatory, assessment: assessment())
        var b = a
        b.contextPopularity = ["romance": 5]
        XCTAssertFalse(a.isDeepEqual(to: b))
    }

    func testIsDeepEqualFalseWhenOriginalContextDiffers() {
        let a = Question(text: "a", id: UUID(), creatorID: UUID(), originalContext: context(.romance), defaultCompatibilityRule: .mandatory, assessment: assessment())
        var b = a
        b.originalContext = context(.social)
        XCTAssertFalse(a.isDeepEqual(to: b))
    }

    func testIsDeepEqualFalseWhenRequirementsForDiffers() {
        let a = Question(text: "a", id: UUID(), creatorID: UUID(), originalContext: context(.romance), defaultCompatibilityRule: .mandatory, assessment: assessment())
        var b = a
        b.requirementsFor = [context(.romance): [.my]]
        XCTAssertFalse(a.isDeepEqual(to: b))
    }

    func testQuestionCategoryAllCases() {
        XCTAssertEqual(Question.Category.allCases.count, 4)
        XCTAssertEqual(Question.Category.not_answered.rawValue, "not_answered")
        XCTAssertEqual(Question.Category.answered.rawValue, "answered")
        XCTAssertEqual(Question.Category.all.rawValue, "all")
        XCTAssertEqual(Question.Category.created.rawValue, "created")
    }

    func testQuestionCodableRoundTrip() throws {
        let questionID = UUID()
        var original = Question(text: "q", id: questionID, creatorID: UUID(), originalContext: context(.romance), defaultCompatibilityRule: .mandatory, assessment: assessment())
        original.responses = [questionResponse(text: "r", questionID: questionID)]
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Question.self, from: data)
        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.text, original.text)
        XCTAssertEqual(decoded.responses.count, 1)
    }

    // MARK: - ServerEnvironment.swift

    func testServerEnvironmentIDMatchesRawValueForAllCases() {
        for env in ServerEnvironment.allCases {
            XCTAssertEqual(env.id, env.rawValue)
        }
    }

    func testServerEnvironmentAllCasesCount() {
        XCTAssertEqual(ServerEnvironment.allCases.count, 3)
        XCTAssertTrue(ServerEnvironment.allCases.contains(.dev))
        XCTAssertTrue(ServerEnvironment.allCases.contains(.debug))
        XCTAssertTrue(ServerEnvironment.allCases.contains(.prod))
    }

    func testServerEnvironmentCodableRoundTrip() throws {
        for env in ServerEnvironment.allCases {
            let data = try JSONEncoder().encode(env)
            let decoded = try JSONDecoder().decode(ServerEnvironment.self, from: data)
            XCTAssertEqual(decoded, env)
        }
    }

    // MARK: - SignUp.swift

    private func acceptTerms() -> AcceptTermsRequest {
        AcceptTermsRequest(acceptedAt: Date(), deviceInfo: "iPhone", source: "ios")
    }

    func testFindErrorsAllValidProducesNoErrors() {
        let signUp = User.SignUp(email: "person@example.com", password: "password123", firstName: "Jane", lastName: "Doe", referral: nil, acceptTermsRequest: acceptTerms())
        XCTAssertEqual(signUp.errors, "")
    }

    func testFindErrorsMissingEmail() {
        let signUp = User.SignUp(email: nil, password: "password123", firstName: "Jane", lastName: "Doe", referral: nil, acceptTermsRequest: acceptTerms())
        XCTAssertTrue(signUp.errors.contains("No email was provided."))
    }

    func testFindErrorsEmailTooShort() {
        let signUp = User.SignUp(email: "a@", password: "password123", firstName: "Jane", lastName: "Doe", referral: nil, acceptTermsRequest: acceptTerms())
        XCTAssertTrue(signUp.errors.contains("too short"))
    }

    func testFindErrorsEmailInvalidFormat() {
        let signUp = User.SignUp(email: "not-an-email", password: "password123", firstName: "Jane", lastName: "Doe", referral: nil, acceptTermsRequest: acceptTerms())
        XCTAssertTrue(signUp.errors.contains("is not a valid email"))
    }

    func testFindErrorsMissingPassword() {
        let signUp = User.SignUp(email: "person@example.com", password: nil, firstName: "Jane", lastName: "Doe", referral: nil, acceptTermsRequest: acceptTerms())
        XCTAssertTrue(signUp.errors.contains("No password was provided."))
    }

    func testFindErrorsPasswordTooShort() {
        let signUp = User.SignUp(email: "person@example.com", password: "abc", firstName: "Jane", lastName: "Doe", referral: nil, acceptTermsRequest: acceptTerms())
        XCTAssertTrue(signUp.errors.contains("at least 6 characters"))
    }

    func testFindErrorsMissingFirstName() {
        let signUp = User.SignUp(email: "person@example.com", password: "password123", firstName: nil, lastName: "Doe", referral: nil, acceptTermsRequest: acceptTerms())
        XCTAssertTrue(signUp.errors.contains("No first name was provided."))
    }

    func testFindErrorsFirstNameTooShort() {
        let signUp = User.SignUp(email: "person@example.com", password: "password123", firstName: "J", lastName: "Doe", referral: nil, acceptTermsRequest: acceptTerms())
        XCTAssertTrue(signUp.errors.contains("first name has to have at least 2 characters"))
    }

    func testFindErrorsMissingLastName() {
        let signUp = User.SignUp(email: "person@example.com", password: "password123", firstName: "Jane", lastName: nil, referral: nil, acceptTermsRequest: acceptTerms())
        XCTAssertTrue(signUp.errors.contains("No last name was provided."))
    }

    func testFindErrorsLastNameTooShort() {
        let signUp = User.SignUp(email: "person@example.com", password: "password123", firstName: "Jane", lastName: "D", referral: nil, acceptTermsRequest: acceptTerms())
        XCTAssertTrue(signUp.errors.contains("last name has to have at least 2 characters"))
    }

    func testSignUpNilInputsDefaultToEmptyStrings() {
        let signUp = User.SignUp(email: nil, password: nil, firstName: nil, lastName: nil, referral: nil, acceptTermsRequest: acceptTerms())
        XCTAssertEqual(signUp.email, "")
        XCTAssertEqual(signUp.password, "")
        XCTAssertEqual(signUp.firstName, "")
        XCTAssertEqual(signUp.lastName, "")
    }

    func testSignUpRetainsReferralAndAcceptTerms() {
        let referral = ReferralSelection(venue: VenueInfo(googlePlacesid: "gid", name: "Venue", address: "addr", coordinate: Coordinates(latitude: 1, longitude: 2), url: "u", googlePlacesTypes: ["bar"]), personName: "Bob")
        let terms = acceptTerms()
        let signUp = User.SignUp(email: "p@example.com", password: "password123", firstName: "Jane", lastName: "Doe", referral: referral, acceptTermsRequest: terms)
        XCTAssertEqual(signUp.referral?.personName, "Bob")
        XCTAssertEqual(signUp.acceptTermsRequest, terms)
    }

    func testVenueInfoEqualityIsByGooglePlacesIDOnly() {
        let coordinate = Coordinates(latitude: 1, longitude: 2)
        let a = VenueInfo(googlePlacesid: "same-id", name: "A", address: "addr a", coordinate: coordinate, url: "a", googlePlacesTypes: ["bar"])
        let b = VenueInfo(googlePlacesid: "same-id", name: "B", address: "addr b", coordinate: coordinate, url: "b", googlePlacesTypes: ["cafe"])
        XCTAssertEqual(a, b)
    }

    func testVenueInfoHashIsByGooglePlacesIDOnly() {
        let coordinate = Coordinates(latitude: 1, longitude: 2)
        let a = VenueInfo(googlePlacesid: "same-id", name: "A", address: "addr a", coordinate: coordinate, url: "a", googlePlacesTypes: [])
        let b = VenueInfo(googlePlacesid: "same-id", name: "B", address: "addr b", coordinate: coordinate, url: "b", googlePlacesTypes: [])
        XCTAssertEqual(Set([a, b]).count, 1)
    }

    func testReferralSelectionInitAssignsProperties() {
        let venueInfo = VenueInfo(googlePlacesid: "gid", name: "Venue", address: "addr", coordinate: Coordinates(latitude: 1, longitude: 2), url: "u", googlePlacesTypes: [])
        let referral = ReferralSelection(venue: venueInfo, personName: nil)
        XCTAssertEqual(referral.venue, venueInfo)
        XCTAssertNil(referral.personName)
    }

    func testIsValidEmailAcceptsValidAddresses() {
        for email in ["a@b.com", "first.last@example.co.uk", "user+tag@sub.example.com"] {
            XCTAssertTrue(email.isValidEmail, "\(email) should be valid")
            XCTAssertFalse(email.isNotValidEmail, "\(email) should be valid")
        }
    }

    func testIsValidEmailRejectsInvalidAddresses() {
        for email in ["not-an-email", "missing-at.com", "@no-local-part.com", ""] {
            XCTAssertFalse(email.isValidEmail, "\(email) should be invalid")
            XCTAssertTrue(email.isNotValidEmail, "\(email) should be invalid")
        }
    }

    // MARK: - UserImage.swift

    func testUserImageInitAssignsProperties() {
        let id = UUID()
        let image = UserImage(id: id, name: "profile.jpg")
        XCTAssertEqual(image.id, id)
        XCTAssertEqual(image.name, "profile.jpg")
    }

    func testUserImageEquatable() {
        let id = UUID()
        XCTAssertEqual(UserImage(id: id, name: "a"), UserImage(id: id, name: "a"))
        XCTAssertNotEqual(UserImage(id: id, name: "a"), UserImage(id: id, name: "b"))
    }

    func testUserImageCodableRoundTrip() throws {
        let original = UserImage(id: UUID(), name: "profile.jpg")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(UserImage.self, from: data)
        XCTAssertEqual(decoded, original)
    }

    // MARK: - VoipCallPayload.swift

    func testVoipCallPayloadInitDefaults() {
        let payload = VoipCallPayload(
            greetID: UUID(), callUUID: UUID(), callType: .ringToGreet, callerUserID: UUID(),
            callerDisplayName: "Jane", callerHandleValue: "Jane", serverUnixTimestampSeconds: 1000
        )
        XCTAssertFalse(payload.hasVideo)
        XCTAssertNotNil(payload.messageID)
    }

    func testVoipCallPayloadDefaultMessageIDsAreDistinct() {
        let makePayload = {
            VoipCallPayload(
                greetID: UUID(), callUUID: UUID(), callType: .ringToGreet, callerUserID: UUID(),
                callerDisplayName: "Jane", callerHandleValue: "Jane", serverUnixTimestampSeconds: 1000
            )
        }
        XCTAssertNotEqual(makePayload().messageID, makePayload().messageID)
    }

    func testVoipCallPayloadInitExplicitValues() {
        let greetID = UUID()
        let callUUID = UUID()
        let callerUserID = UUID()
        let messageID = UUID()
        let payload = VoipCallPayload(
            greetID: greetID, callUUID: callUUID, callType: .ringToVoipEnroute, callerUserID: callerUserID,
            callerDisplayName: "Jane", callerHandleValue: "555-1234", hasVideo: true,
            serverUnixTimestampSeconds: 12345, messageID: messageID
        )
        XCTAssertEqual(payload.greetID, greetID)
        XCTAssertEqual(payload.callUUID, callUUID)
        XCTAssertEqual(payload.callType, .ringToVoipEnroute)
        XCTAssertEqual(payload.callerUserID, callerUserID)
        XCTAssertEqual(payload.callerDisplayName, "Jane")
        XCTAssertEqual(payload.callerHandleValue, "555-1234")
        XCTAssertTrue(payload.hasVideo)
        XCTAssertEqual(payload.serverUnixTimestampSeconds, 12345)
        XCTAssertEqual(payload.messageID, messageID)
    }

    func testVoipCallPayloadCodableRoundTrip() throws {
        let original = VoipCallPayload(
            greetID: UUID(), callUUID: UUID(), callType: .ringToVoipAfterOtherUserNotViewed, callerUserID: UUID(),
            callerDisplayName: "Jane", callerHandleValue: "555-1234", hasVideo: true, serverUnixTimestampSeconds: 42, messageID: UUID()
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(VoipCallPayload.self, from: data)
        XCTAssertEqual(decoded, original)
        XCTAssertEqual(Set([original, decoded]).count, 1)
    }

    // MARK: - CallType.swift (helper facts used above and by ActionStringConvertible below)

    func testCallTypeOpensLiveVoipConversation() {
        XCTAssertFalse(CallType.ringToGreet.opensLiveVoipConversation)
        XCTAssertTrue(CallType.ringToVoipAfterOtherUserNotViewed.opensLiveVoipConversation)
        XCTAssertTrue(CallType.ringToVoipEnroute.opensLiveVoipConversation)
    }

    func testCallTypeRedButtonClosesGreet() {
        XCTAssertTrue(CallType.ringToGreet.redButtonClosesGreet)
        XCTAssertTrue(CallType.ringToVoipAfterOtherUserNotViewed.redButtonClosesGreet)
        XCTAssertFalse(CallType.ringToVoipEnroute.redButtonClosesGreet)
    }

    // MARK: - ActionStringConvertible.swift

    func testActionStringNoAssociatedValueCasesAreSnakeCased() {
        XCTAssertEqual(GreetAction.manualGreetInitiated.actionString, "manual_greet_initiated")
        XCTAssertEqual(GreetAction.dismissGreet.actionString, "dismiss_greet")
        XCTAssertEqual(GreetAction.closeApp.actionString, "close_app")
        XCTAssertEqual(GreetAction.viewedGreetScreen.actionString, "viewed_greet_screen")
        XCTAssertEqual(GreetAction.confirmedMet.actionString, "confirmed_met")
        XCTAssertEqual(GreetAction.tappedRedVoipReject.actionString, "tapped_red_voip_reject")
    }

    /// Mirror-based extraction only descends one level: for a case with a SINGLE associated
    /// value, `Mirror(reflecting: <that value>)` has zero children when the value is a scalar
    /// (Int/Double/String/UUID) or a payload-less enum, so the value is silently dropped and
    /// only the snake_cased case name remains. Verified empirically (see scratch Mirror probe)
    /// before writing this assertion, since it is easy to assume otherwise from the source.
    func testActionStringSingleScalarAssociatedValueIsDropped() {
        XCTAssertEqual(GreetAction.agreedToMeet(30).actionString, "agreed_to_meet")
        XCTAssertEqual(GreetAction.rejectTime(15).actionString, "reject_time")
        // A single UNLABELED scalar/payload-less-enum value has an outer Mirror
        // with zero children, so it is dropped (the two cases above, and this one).
        XCTAssertEqual(GreetAction.callInitiated(.ringToGreet).actionString, "call_initiated")
        // A single LABELED value (`changedTo:`) is wrapped by Mirror into a
        // 1-element tuple-like child, so it is NOT dropped; verified against the
        // real Int case below. `travelDistanceToVenue(changedTo: Double)` is
        // deliberately NOT exercised here: same crash as the GreetLogEvent note
        // below (Double doesn't match UUID/String/Int/Bool in
        // stringifyAssociatedValue, falls into the `Optional<Any>` catch-all, and
        // infinite-recurses on itself). Verified with a standalone Mirror probe,
        // not via XCTest.
        XCTAssertEqual(GreetAction.travelTimeToVenue(changedTo: 5).actionString, "travel_time_to_venue_5")
    }

    func testActionStringMultiAssociatedValueTupleIsCaptured() {
        XCTAssertEqual(GreetAction.rated(4, outOf: 5).actionString, "rated_4_5")
        XCTAssertEqual(GreetAction.notGettingCloser(start: 10, allowance: 3, current: 20).actionString, "not_getting_closer_10_3_20")
    }

    // NOTE (found while verifying Mirror semantics for this test, not fixed here since only
    // tests were requested): `GreetLogEvent.pushQueued` / `.deliveryConfirmed` pair a plain
    // payload-less enum (`GreetActionChannel`) with an `Optional<UUID>` in the same tuple.
    // `stringifyAssociatedValue` first tries `case let uuid as UUID` etc., none of which match
    // a bare `GreetActionChannel` value; it then falls through to `case let optional as
    // Optional<Any>`, which DOES match (any non-optional value can be cast to `Optional<Any>`),
    // and recurses on the *same unchanged value* forever. Calling `.actionString` on either of
    // those two cases infinite-loops and crashes (verified with a standalone Swift script, not
    // via XCTest, to avoid hanging this shared test target). Deliberately not exercised below.

    func testActionStringNoAssociatedValueGreetLogEventCases() {
        XCTAssertEqual(GreetLogEvent.userViewed.actionString, "user_viewed")
        XCTAssertEqual(GreetLogEvent.greetCreated.actionString, "greet_created")
        XCTAssertEqual(GreetLogEvent.rateLimited.actionString, "rate_limited")
    }

    // MARK: - CompatibilityRule.swift

    func testCompatibilityRuleRawValues() {
        XCTAssertEqual(CompatibilityRule.mandatory.rawValue, "mandatory")
        XCTAssertEqual(CompatibilityRule.weighted.rawValue, "weighted")
    }

    func testCompatibilityRuleCodableRoundTrip() throws {
        for rule: CompatibilityRule in [.mandatory, .weighted] {
            let data = try JSONEncoder().encode(rule)
            XCTAssertEqual(try JSONDecoder().decode(CompatibilityRule.self, from: data), rule)
        }
    }

    func testCompatibilityConstants() {
        XCTAssertEqual(genderResponses, ["Male", "Female"])
        XCTAssertEqual(socialText, "social")
        XCTAssertEqual(romanceText, "romance")
        XCTAssertEqual(ageQuestionText, "What is your age?")
        XCTAssertEqual(genderQuestionText, "What is your gender?")
    }

    func testAgeQuestionAdjustedNilBirthdayReturnsUnchanged() {
        let questionID = UUID()
        var question = Question(text: ageQuestionText, id: questionID, creatorID: UUID(), originalContext: context(.romance), defaultCompatibilityRule: .mandatory, assessment: assessment())
        question.responses = [questionResponse(text: "25", questionID: questionID)]
        let result = [question].ageQuestionAdjusted(birthday: nil)
        XCTAssertTrue(result[0].responses[0].myChoice.isEmpty)
    }

    func testAgeQuestionAdjustedNoAgeQuestionReturnsUnchanged() {
        let questionID = UUID()
        var question = Question(text: "not the age question", id: questionID, creatorID: UUID(), originalContext: context(.romance), defaultCompatibilityRule: .mandatory, assessment: assessment())
        question.responses = [questionResponse(text: "25", questionID: questionID)]
        let birthday = Calendar.current.date(byAdding: .year, value: -25, to: Date())!
        let result = [question].ageQuestionAdjusted(birthday: birthday)
        XCTAssertTrue(result[0].responses[0].myChoice.isEmpty)
    }

    func testAgeQuestionAdjustedNoMatchingResponseReturnsUnchanged() {
        let questionID = UUID()
        var question = Question(text: ageQuestionText, id: questionID, creatorID: UUID(), originalContext: context(.romance), defaultCompatibilityRule: .mandatory, assessment: assessment())
        question.responses = [questionResponse(text: "not-a-number", questionID: questionID)]
        let birthday = Calendar.current.date(byAdding: .year, value: -25, to: Date())!
        let result = [question].ageQuestionAdjusted(birthday: birthday)
        XCTAssertTrue(result[0].responses[0].myChoice.isEmpty)
    }

    func testAgeQuestionAdjustedSetsYesForMatchingAgeAcrossAllContexts() {
        let questionID = UUID()
        var question = Question(text: ageQuestionText, id: questionID, creatorID: UUID(), originalContext: context(.romance), defaultCompatibilityRule: .mandatory, assessment: assessment())
        question.responses = [questionResponse(text: "25", questionID: questionID)]
        let birthday = Calendar.current.date(byAdding: .year, value: -25, to: Date())!
        let result = [question].ageQuestionAdjusted(birthday: birthday)
        let updatedChoice = result[0].responses[0].myChoice
        for aContext in Context.Case.allCases {
            XCTAssertEqual(updatedChoice[aContext.rawValue], .YES, "expected YES for context \(aContext.rawValue)")
        }
    }

    // MARK: - GreetSubProtocols.swift

    func testTravelDistanceInitAssignsProperties() {
        let greetID = UUID()
        let date = Date()
        let distance = TravelDistance(update: .percentTravelled(0.5), date: date, greetID: greetID)
        XCTAssertEqual(distance.update, .percentTravelled(0.5))
        XCTAssertEqual(distance.date, date)
        XCTAssertEqual(distance.greetID, greetID)
    }

    func testTravelUpdateCodableRoundTrip() throws {
        for update: TravelUpdate in [.percentTravelled(0.75), .exceededRange] {
            let data = try JSONEncoder().encode(update)
            XCTAssertEqual(try JSONDecoder().decode(TravelUpdate.self, from: data), update)
        }
    }

    func testTravelUpdateResponseInitAssignsProperties() {
        let greetID = UUID()
        let response = TravelUpdateResponse(greetID: greetID, value: .exceededRange)
        XCTAssertEqual(response.greetID, greetID)
        XCTAssertEqual(response.value, .exceededRange)
    }

    func testTimingUpdateRawValueAgreed() {
        XCTAssertEqual(TimingUpdate.agreed(15).rawValue, "agreed to 15 minutes")
    }

    func testTimingUpdateRawValueRejected() {
        XCTAssertEqual(TimingUpdate.rejected(30).rawValue, "rejected 30 minutes")
    }

    func testTimingUpdateResponseMessageJoinsRawValues() {
        let response = TimingUpdateResponse(greetID: UUID(), value: [.agreed(15), .rejected(30)])
        XCTAssertEqual(response.message, "They agreed to 15 minutes, rejected 30 minutes")
    }

    func testRejectionActionRawValues() {
        XCTAssertEqual(RejectionAction.dismiss.rawValue, "dismiss")
        XCTAssertEqual(RejectionAction.cancel.rawValue, "cancel")
        XCTAssertEqual(RejectionAction.rejectedVoip.rawValue, "rejectedVoip")
        XCTAssertEqual(RejectionAction.closedApp.rawValue, "closedApp")
        XCTAssertEqual(RejectionAction.rejectedByAcceptingAnotherCall.rawValue, "rejectedByAcceptingAnotherCall")
    }

    func testRejectionActionPayloadInitAssignsProperties() {
        let greetID = UUID()
        let payload = RejectionActionPayload(greetID: greetID, action: .cancel)
        XCTAssertEqual(payload.greetID, greetID)
        XCTAssertEqual(payload.action, .cancel)
    }

    func testViewedPayloadAndResponseInitAssignProperties() {
        let greetID = UUID()
        let date = Date()
        let payload = ViewedPayload(date: date, greetID: greetID)
        XCTAssertEqual(payload.date, date)
        XCTAssertEqual(payload.greetID, greetID)
        let response = ViewedResponse(date: date, greetID: greetID)
        XCTAssertEqual(response.date, date)
        XCTAssertEqual(response.greetID, greetID)
    }

    func testClosedDueToViewedTimeLapseInitAssignsProperties() {
        let greetID = UUID()
        let date = Date()
        let value = ClosedDueToViewedTimeLapse(greetID: greetID, date: date)
        XCTAssertEqual(value.greetID, greetID)
        XCTAssertEqual(value.date, date)
    }

    // MARK: - LanguageCodes.swift

    func testLanguageCodeEnumInitRawValueSupported() {
        XCTAssertEqual(LanguageCodeEnum(rawValue: "en"), .supported(.en))
    }

    func testLanguageCodeEnumInitRawValueIsCaseInsensitive() {
        XCTAssertEqual(LanguageCodeEnum(rawValue: "EN"), .supported(.en))
    }

    func testLanguageCodeEnumInitRawValueUnsupportedCode() {
        XCTAssertEqual(LanguageCodeEnum(rawValue: "xx"), .unsupported("xx"))
    }

    func testLanguageCodeEnumInitRawValueEmptyReturnsNil() {
        XCTAssertNil(LanguageCodeEnum(rawValue: ""))
    }

    func testLanguageCodeEnumAllCasesMatchesSupportedLanguageCodeCount() {
        XCTAssertEqual(LanguageCodeEnum.allCases.count, SupportedLanguageCode.allCases.count)
        XCTAssertEqual(SupportedLanguageCode.allCases.count, 40)
    }

    func testLanguageCodeEnumRawValueComputedProperty() {
        XCTAssertEqual(LanguageCodeEnum.supported(.fr).rawValue, "fr")
        XCTAssertEqual(LanguageCodeEnum.unsupported("zz").rawValue, "zz")
    }

    func testLanguageCodeEnumInitSupportedLanguage() {
        XCTAssertEqual(LanguageCodeEnum(supportedLanguage: .ja), .supported(.ja))
    }

    func testLanguageCodeEnumInitStringLiteralValidCode() {
        XCTAssertEqual(LanguageCodeEnum(stringLiteral: "de"), .supported(.de))
    }

    func testLanguageCodeEnumInitStringLiteralEmptyFallsBackToUnsupported() {
        XCTAssertEqual(LanguageCodeEnum(stringLiteral: ""), .unsupported(""))
    }

    func testLanguageCodeEnumLocalizedNameMatchesLocaleAPI() {
        let code = LanguageCodeEnum.supported(.en)
        XCTAssertEqual(code.localizedName, Locale.current.localizedString(forLanguageCode: "en") ?? "en")
    }

    func testLanguageCodeEnumLocalizedNameFallsBackToRawValueWhenLocaleReturnsNil() {
        let code = LanguageCodeEnum.unsupported("not-a-real-code-xyz")
        let expected = Locale.current.localizedString(forLanguageCode: "not-a-real-code-xyz") ?? "not-a-real-code-xyz"
        XCTAssertEqual(code.localizedName, expected)
    }

    func testSupportedLanguageCodeCodableRoundTrip() throws {
        for code in [SupportedLanguageCode.en, .fr, .zh, .eu] {
            let data = try JSONEncoder().encode(code)
            XCTAssertEqual(try JSONDecoder().decode(SupportedLanguageCode.self, from: data), code)
        }
    }

    // MARK: - NearbyUserMessage.swift

    func testNearbyUserMessageAddUserCodableRoundTrip() throws {
        let user = nearbyUser()
        let original = NearbyUserMessage.addUser(user)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(NearbyUserMessage.self, from: data)
        guard case .addUser(let decodedUser) = decoded else { return XCTFail("expected .addUser") }
        XCTAssertEqual(decodedUser, user)
    }

    func testNearbyUserMessageRemoveUserCodableRoundTrip() throws {
        let userID = UUID()
        let original = NearbyUserMessage.removeUser(userID)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(NearbyUserMessage.self, from: data)
        guard case .removeUser(let decodedID) = decoded else { return XCTFail("expected .removeUser") }
        XCTAssertEqual(decodedID, userID)
    }

    func testNearbyUserMessageUpdateUserCodableRoundTrip() throws {
        let user = nearbyUser()
        let original = NearbyUserMessage.updateUser(user)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(NearbyUserMessage.self, from: data)
        guard case .updateUser(let decodedUser) = decoded else { return XCTFail("expected .updateUser") }
        XCTAssertEqual(decodedUser, user)
    }

    func testNearbyUserMessageResetAllCodableRoundTrip() throws {
        let users = [nearbyUser(), nearbyUser()]
        let original = NearbyUserMessage.resetAll(users)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(NearbyUserMessage.self, from: data)
        guard case .resetAll(let decodedUsers) = decoded else { return XCTFail("expected .resetAll") }
        XCTAssertEqual(decodedUsers, users)
    }

    func testNearbyUserMessageDecodeUnknownTypeThrows() {
        let json = """
        {"type":"bogusType"}
        """
        XCTAssertThrowsError(try JSONDecoder().decode(NearbyUserMessage.self, from: Data(json.utf8)))
    }

    // MARK: - RequestStructs.swift

    func testAssertionDefaultsCaptureFileAndLine() {
        let assertion = Assertion(message: "something went wrong")
        XCTAssertFalse(assertion.assertion)
        XCTAssertEqual(assertion.message, "something went wrong")
        XCTAssertTrue(assertion.file.contains(".swift"))
        XCTAssertGreaterThan(assertion.line, 0)
    }

    func testAssertionExplicitValues() {
        let assertion = Assertion(assertion: true, message: "m", file: "custom.swift", line: 42)
        XCTAssertTrue(assertion.assertion)
        XCTAssertEqual(assertion.file, "custom.swift")
        XCTAssertEqual(assertion.line, 42)
    }

    func testPasswordUpdateInitAssignsProperties() {
        let update = PasswordUpdate(oldPassword: "old", newPassword: "new")
        XCTAssertEqual(update.oldPassword, "old")
        XCTAssertEqual(update.newPassword, "new")
    }

    func testCredentialUpdateInitAssignsProperties() {
        let update = CredentialUpdate(newEmail: "a@b.com", password: "pw")
        XCTAssertEqual(update.newEmail, "a@b.com")
        XCTAssertEqual(update.password, "pw")
    }

    func testImportancesUpdateInitAssignsProperties() {
        let questionID = UUID()
        let createdAt = Date()
        let update = ImportancesUpdate(importances: ["romance": .very], questionID: questionID, createdAt: createdAt)
        XCTAssertEqual(update.importances["romance"], .very)
        XCTAssertEqual(update.questionID, questionID)
        XCTAssertEqual(update.createdAt, createdAt)
    }

    func testRatingInitAssignsProperties() {
        let otherUserId = UUID()
        let rating = Rating(otherUserId: otherUserId, rating: 4.5)
        XCTAssertEqual(rating.otherUserId, otherUserId)
        XCTAssertEqual(rating.rating, 4.5)
    }

    func testAppleAuthorizationInitAssignsPropertiesUsingIdentityTokenStringLabel() {
        let auth = AppleAuthorization(userID: "abc", email: "a@b.com", firstName: "Jane", lastName: "Doe", identityTokenString: "token123")
        XCTAssertEqual(auth.userID, "abc")
        XCTAssertEqual(auth.email, "a@b.com")
        XCTAssertEqual(auth.firstName, "Jane")
        XCTAssertEqual(auth.lastName, "Doe")
        XCTAssertEqual(auth.identityToken, "token123")
    }

    func testEmailChangeInitAssignsProperties() {
        let change = EmailChange(currentEmail: "old@b.com", newEmail: "new@b.com")
        XCTAssertEqual(change.currentEmail, "old@b.com")
        XCTAssertEqual(change.newEmail, "new@b.com")
    }

    func testDeviceTokenPayloadNilPlatformUsesGetPlatform() {
        let payload = DeviceTokenPayload(deviceToken: "tok", platform: nil, deviceId: nil, buildSource: .xcode)
        XCTAssertEqual(payload.platform, getPlatform)
        XCTAssertFalse(payload.platform.isEmpty)
    }

    func testDeviceTokenPayloadExplicitPlatformOverridesDefault() {
        let payload = DeviceTokenPayload(deviceToken: "tok", platform: "customPlatform", deviceId: UUID(), buildSource: .testflight)
        XCTAssertEqual(payload.platform, "customPlatform")
        XCTAssertEqual(payload.buildSource, .testflight)
    }

    func testLoginPayloadInitAssignsProperties() {
        let terms = acceptTerms()
        let payload = LoginPayload(email: "a@b.com", password: "pw", termsRequest: terms)
        XCTAssertEqual(payload.email, "a@b.com")
        XCTAssertEqual(payload.password, "pw")
        XCTAssertEqual(payload.termsPayload, terms)
    }

    func testPasscodePayloadInitAssignsProperties() {
        let payload = PasscodePayload(email: "a@b.com", passcode: "123456")
        XCTAssertEqual(payload.email, "a@b.com")
        XCTAssertEqual(payload.passcode, "123456")
    }

    func testAnswerChoiceInitWithNilChoiceDefault() {
        let responseID = UUID()
        let questionID = UUID()
        let createdAt = Date()
        let choice = AnswerChoice(myTheir: .my, responseID: responseID, questionID: questionID, createdAt: createdAt, context: context(.romance), compatibilityRule: .mandatory)
        XCTAssertNil(choice.choice)
        XCTAssertEqual(choice.myTheir, .my)
        XCTAssertEqual(choice.responseID, responseID)
        XCTAssertEqual(choice.questionID, questionID)
        XCTAssertEqual(choice.compatibilityRule, .mandatory)
    }

    func testAnswerChoiceInitWithExplicitChoice() {
        let choice = AnswerChoice(myTheir: .their, choice: .YES, responseID: UUID(), questionID: UUID(), createdAt: Date(), context: context(.social), compatibilityRule: .weighted)
        XCTAssertEqual(choice.choice, .YES)
        XCTAssertEqual(choice.myTheir, .their)
    }

    func testResponsesSpecificationsDefaults() {
        let specs = ResponsesSpecifications(questionID: UUID(), context: "romance")
        XCTAssertNil(specs.searchText)
        XCTAssertEqual(specs.page, 1)
        XCTAssertEqual(specs.limit, 20)
    }

    func testQuestionsSpecificationsInitAssignsProperties() {
        let specs = QuestionsSpecifications(searchText: "abc", type: "all", page: 2, context: "romance", required: true)
        XCTAssertEqual(specs.searchText, "abc")
        XCTAssertEqual(specs.type, "all")
        XCTAssertEqual(specs.page, 2)
        XCTAssertEqual(specs.context, "romance")
        XCTAssertTrue(specs.required)
    }

    // MARK: - ResponseStructs.swift

    func testGreetedClientStatusCodableRoundTrip() throws {
        let cases: [GreetedClientStatus] = [.confirmedMet, .exceededRange, .rejectedOther, .onGoing, .connectionLost]
        for status in cases {
            let data = try JSONEncoder().encode(status)
            XCTAssertEqual(try JSONDecoder().decode(GreetedClientStatus.self, from: data), status)
        }
    }

    func testClientGreetingSettingsInitDefaultsMeetTimeNil() {
        let greetedUser = GreetedUser(id: UUID(), name: "Jane", profileImageURL: "url")
        let initiatedTime = Date()
        let settings = ClientGreetingSettings(greetedUser: greetedUser, initiatedTime: initiatedTime)
        XCTAssertEqual(settings.greetedUser, greetedUser)
        XCTAssertEqual(settings.initiatedTime, initiatedTime)
        XCTAssertNil(settings.meetTime)
    }

    func testNotificationFrequencyIDMatchesRawValueForAllCases() {
        for freq in [NotificationFrequency.hourly, .daily, .weekly, .monthly, .never, .unrestricted] {
            XCTAssertEqual(freq.id, freq.rawValue)
        }
        XCTAssertEqual(NotificationFrequency.hourly.rawValue, "Hourly")
        XCTAssertEqual(NotificationFrequency.unrestricted.rawValue, "Unrestricted")
    }

    func testGreetedUserInitDefaults() {
        let user = GreetedUser(id: UUID(), name: "Jane", profileImageURL: "url")
        XCTAssertFalse(user.isBlocked)
        XCTAssertEqual(user.manualNotificationFrequency, .unrestricted)
        XCTAssertEqual(user.automaticNotificationFrequency, .unrestricted)
        XCTAssertNil(user.rating)
        XCTAssertEqual(user.greetIDs, [])
        XCTAssertNil(user.metOnDate)
    }

    func testGreetedUserInitExplicitValues() {
        let id = UUID()
        let greetIDs = [UUID(), UUID()]
        let metOnDate = Date()
        let user = GreetedUser(id: id, name: "Jane", profileImageURL: "url", isBlocked: true, manualNotificationFrequency: .daily, automaticNotificationFrequency: .never, rating: 0.9, greetIDs: greetIDs, metOnDate: metOnDate)
        XCTAssertTrue(user.isBlocked)
        XCTAssertEqual(user.manualNotificationFrequency, .daily)
        XCTAssertEqual(user.automaticNotificationFrequency, .never)
        XCTAssertEqual(user.rating, 0.9)
        XCTAssertEqual(user.greetIDs, greetIDs)
        XCTAssertEqual(user.metOnDate, metOnDate)
    }

    func testSimpleSuccessMessageResponseStructsAssignProperties() {
        XCTAssertEqual(RegisterResponse(success: true, message: "m", userId: nil).message, "m")
        XCTAssertTrue(StandardPostResponse(success: true).success)
        XCTAssertEqual(StandardPostResponse(success: false, message: "m").message, "m")
        XCTAssertEqual(TwoPersonGreetResponse(success: true, message: "m").message, "m")
        XCTAssertEqual(ReportFlagsResponse(success: true, flaggedCount: 3).flaggedCount, 3)
        XCTAssertNil(ReportFlagsResponse(success: true).flaggedCount)
        XCTAssertEqual(RateResponse(success: true, newRating: 4.2).newRating, 4.2)
        XCTAssertEqual(LocationUpdateResponse(success: true, message: "m").message, "m")
        XCTAssertEqual(TrackEventsResponse(success: true, trackedEventsCount: 5).trackedEventsCount, 5)
        XCTAssertEqual(UpdateEmailResponse(success: true, message: "m").message, "m")
        XCTAssertEqual(ResetPasswordResponse(success: true, message: "m").message, "m")
        XCTAssertEqual(ChangeEmailResponse(success: true, message: "m").message, "m")
        XCTAssertEqual(RegisterDeviceTokenResponse(success: true, message: "m").message, "m")
        XCTAssertEqual(HideMeResponse(success: true, message: "m").message, "m")
        XCTAssertEqual(RegisterPushKitDeviceTokenResponse(success: true, message: "m").message, "m")
        let blockedID = UUID()
        XCTAssertEqual(BlockUserResponse(success: true, blockedUserId: blockedID).blockedUserId, blockedID)
        XCTAssertEqual(LogoutResponse(success: true, message: "m").message, "m")
        XCTAssertEqual(UpdateSettingsResponse(success: true, message: "m").message, "m")
        XCTAssertEqual(AddDisplayPictureResponse(success: true, imageUrl: "u").imageUrl, "u")
        XCTAssertEqual(UploadPicResponse(success: true, imageUrl: "u").imageUrl, "u")
        XCTAssertEqual(RegisterBasicInfoResponse(success: true, userId: nil, message: "m").message, "m")
        XCTAssertEqual(TriggerTwoPersonGreetResponse(success: true, message: "m").message, "m")
        let responseId = UUID()
        XCTAssertEqual(AddResponseResponse(success: true, responseId: responseId).responseId, responseId)
        XCTAssertEqual(MakeResponseResponse(success: true, message: "m").message, "m")
    }

    func testUpdateImportanceResponseInit() {
        let response = UpdateImportanceResponse(success: true, updatedImportance: .very)
        XCTAssertEqual(response.updatedImportance, .very)
        XCTAssertNil(UpdateImportanceResponse(success: true).updatedImportance)
    }

    func testGetUserInformationResponseAndUserInformationInit() {
        let id = UUID()
        let userInfo = UserInformation(id: id, name: "Jane", email: "a@b.com", profileImageUrl: "u", bio: "bio")
        let response = GetUserInformationResponse(user: userInfo)
        XCTAssertEqual(response.user.id, id)
        XCTAssertEqual(response.user.name, "Jane")
        XCTAssertEqual(response.user.email, "a@b.com")
        XCTAssertEqual(response.user.profileImageUrl, "u")
        XCTAssertEqual(response.user.bio, "bio")
    }

    func testUserInformationDefaults() {
        let userInfo = UserInformation(id: UUID(), name: "Jane", email: "a@b.com")
        XCTAssertNil(userInfo.profileImageUrl)
        XCTAssertNil(userInfo.bio)
    }

    func testNearbyUsersResponseInit() {
        let users = [UserInformation(id: UUID(), name: "Jane", email: "a@b.com")]
        let response = NearbyUsersResponse(success: true, users: users)
        XCTAssertEqual(response.users.count, 1)
        XCTAssertTrue(response.success)
    }

    func testQuestionResponsesResponseInitWithNestedQuestionResponse() {
        let nested = QuestionResponsesResponse.QuestionResponse(id: UUID(), text: "abc", selected: true)
        let response = QuestionResponsesResponse(success: true, responses: [nested])
        XCTAssertEqual(response.responses.count, 1)
        XCTAssertEqual(response.responses.first?.text, "abc")
        XCTAssertTrue(response.responses.first?.selected ?? false)
    }

    func testQuestionsResponseInit() {
        let question = Question(text: "q", id: UUID(), creatorID: UUID(), originalContext: context(.romance), defaultCompatibilityRule: .mandatory, assessment: assessment())
        let response = QuestionsResponse(success: true, questions: [question])
        XCTAssertEqual(response.questions.count, 1)
    }

    func testManualGreetResponseCodableRoundTripAllCases() throws {
        let notification = ManualGreetNotification(notification: .silentLocationUpdate, status: .success)
        let cases: [ManualGreetResponse] = [
            .notification(notification),
            .otherUserIsInGreet,
            .thisUserIsInGreet,
            .thisAndOtherUserAlreadyInSameGreet,
            .noNearbyVenuesOpen
        ]
        for original in cases {
            let data = try JSONEncoder().encode(original)
            let decoded = try JSONDecoder().decode(ManualGreetResponse.self, from: data)
            switch (original, decoded) {
            case (.notification, .notification),
                 (.otherUserIsInGreet, .otherUserIsInGreet),
                 (.thisUserIsInGreet, .thisUserIsInGreet),
                 (.thisAndOtherUserAlreadyInSameGreet, .thisAndOtherUserAlreadyInSameGreet),
                 (.noNearbyVenuesOpen, .noNearbyVenuesOpen):
                break
            default:
                XCTFail("Case mismatch after round trip")
            }
        }
    }

    func testManualGreetStatusRawValue() {
        XCTAssertEqual(ManualGreetStatus.success.rawValue, "success")
    }

    func testTokenResponseAppliesRandomEarlierDate() {
        let expiration = Date()
        let token = TokenResponse(token: "abc", expiration: expiration)
        XCTAssertLessThan(token.expiration, expiration)
        XCTAssertGreaterThanOrEqual(token.expiration, expiration.addingTimeInterval(-10.1))
        XCTAssertEqual(token.token, "abc")
    }

    func testLoginResponseInitAssignsProperties() {
        let user = User(firstName: "Jane", lastName: "Doe", user_id: UUID(), email: "a@b.com")
        let authToken = TokenResponse(token: "auth", expiration: Date())
        let refreshToken = TokenResponse(token: "refresh", expiration: Date())
        let response = LoginResponse(success: true, user: user, authToken: authToken, refreshToken: refreshToken)
        XCTAssertTrue(response.success)
        XCTAssertEqual(response.user.email, "a@b.com")
        XCTAssertEqual(response.authToken.token, "auth")
        XCTAssertEqual(response.refreshToken.token, "refresh")
    }

    func testRefreshTokenRequestPayloadInit() {
        let payload = RefreshTokenRequestPayload(refreshToken: "tok")
        XCTAssertEqual(payload.refreshToken, "tok")
    }

    func testAddDisplayPictureResponseAndUploadPicResponseDefaults() {
        XCTAssertNil(AddDisplayPictureResponse(success: true).imageUrl)
        XCTAssertNil(UploadPicResponse(success: true).imageUrl)
    }

    func testPrefetchUserForResponseInitWithNestedUserDetail() {
        let detail = PrefetchUserForResponse.UserDetail(id: UUID(), name: "Jane", profileImageUrl: nil)
        let response = PrefetchUserForResponse(success: true, users: [detail])
        XCTAssertEqual(response.users.count, 1)
        XCTAssertEqual(response.users.first?.name, "Jane")
    }

    func testTermsOfServiceInitAndEttiquetteTypealias() {
        let effectiveDate = Date()
        let terms: Ettiquette = TermsOfService(
            version: "1.0", effectiveDate: effectiveDate, requiresReacceptance: true,
            text: "full text", appName: "MapMates", contactInfo: "support@example.com"
        )
        XCTAssertNil(terms.summary)
        XCTAssertEqual(terms.version, "1.0")
        XCTAssertEqual(terms.effectiveDate, effectiveDate)
        XCTAssertTrue(terms.requiresReacceptance)
        XCTAssertEqual(terms.text, "full text")
        XCTAssertEqual(terms.appName, "MapMates")
        XCTAssertEqual(terms.contactInfo, "support@example.com")
    }

    #if canImport(MapKit)
    func testTravelMethodTransportTypeMapping() {
        XCTAssertEqual(TravelMethod.bike.transportType, .walking)
        XCTAssertEqual(TravelMethod.car.transportType, .automobile)
        XCTAssertEqual(TravelMethod.motorcycle.transportType, .automobile)
        XCTAssertEqual(TravelMethod.none.transportType, .walking)
        XCTAssertEqual(TravelMethod.walk.transportType, .walking)
        XCTAssertEqual(TravelMethod.transit.transportType, .transit)
    }
    #endif

    // MARK: - StrongContractClient.Request.swift: request factory method/mime coverage

    func testRequestFactoriesAuthAndTerms() {
        XCTAssertEqual(LoginRequest.login.method, .post)
        XCTAssertFalse(LoginRequest.login.assertHasAccessToken)
        XCTAssertEqual(LoginWithAccessToken.loginWithAccessToken.method, .post)
        XCTAssertTrue(LoginWithAccessToken.loginWithAccessToken.assertHasAccessToken)
        XCTAssertEqual(RefreshTokenRequest.refreshToken.method, .post)
        XCTAssertEqual(Register.register.method, .post)
        XCTAssertEqual(TermsRequest.latestTerms.method, .get)
        XCTAssertEqual(AcceptTermsRequestType.acceptTerms.method, .post)
        XCTAssertEqual(ForgotPasswordEndpoint.forgotPassword.method, .post)
        XCTAssertEqual(ForgotPasswordEndpoint.resendVerification.method, .post)
        XCTAssertEqual(NewPasswordEndpoint.newPasswordEndpoint.method, .post)
        XCTAssertEqual(ResetPasswordEndpoint.resetPassword.method, .post)
        XCTAssertEqual(PasswordlessAuthenticationRequest.passwordlessAuthentication.method, .post)
        XCTAssertEqual(PasscodeAuthenticationRequest.passcodeAuthentication.method, .post)
        XCTAssertEqual(ChangeEmailRequest.changeEmail.method, .post)
        XCTAssertEqual(UpdatePasswordRequest.updatePassword.method, .put)
        XCTAssertEqual(UpdateEmailRequest.updateEmail.method, .put)
    }

    func testRequestFactoriesImagesAndProfile() {
        XCTAssertEqual(GreetProfilePicRequest.greetProfilePic.method, .post)
        XCTAssertEqual(GreetProfilePicRequest.greetProfilePic.contentType, MimeType.octetStream.rawValue)
        XCTAssertEqual(ProfilePictureRequest.profileImage.method, .get)
        // Not touching ImageRequest.image at all (not even `.method`): it's
        // `typealias ImageRequest = Request<UserImage, Data>` with a `.get`
        // method, but Request's init has `if method == .get { assert(Payload.self
        // == Empty.self, ...) }`. Since Payload is UserImage (not Empty), simply
        // first-accessing this static property crashes the whole xctest process
        // (Swift static properties are lazily initialized on first access). This
        // is a real pre-existing mismatch in StrongContractClient.Request.swift's
        // ImageRequest declaration, not something to work around by tricking the
        // assert; left untested and Sources/ untouched per the batch scope.
        XCTAssertEqual(UploadImageRequest.uploadProfileImage.method, .post)
        XCTAssertEqual(UploadImageRequest.uploadImage.method, .post)
        XCTAssertEqual(SaveImageMetaDataRequest.saveImageMetaData.method, .post)
        XCTAssertEqual(ModeratePicRequest.moderatePic.method, .post)
    }

    func testRequestFactoriesVenuesAndImpact() {
        XCTAssertEqual(SearchSavedVenues.searchSavedVenues.method, .post)
        XCTAssertEqual(VenueByGoogleID.venueByGoogleID.method, .post)
        XCTAssertEqual(EmployeeLeaderboard.employeeLeaderboard.method, .post)
        XCTAssertEqual(EmployeeLeaderboardFromGoogleID.employeeLeaderboard.method, .post)
        XCTAssertEqual(NearbyEmptyStateEndpoint.nearbyEmptyStateDetails.method, .get)
        XCTAssertEqual(NotifyUserCountProgressEndpoint.submitBenchmarkNotificationPreferences.method, .post)
    }

    func testRequestFactoriesQuestionsAndResponses() {
        XCTAssertEqual(QuestionRequest.prefetchQuestion.method, .post)
        XCTAssertEqual(AddQuestion.addQuestion.method, .post)
        XCTAssertEqual(AddQuestions.addQuestions.method, .post)
        XCTAssertEqual(AddResponseRequest.addResponse.method, .post)
        XCTAssertEqual(AddResponsesRequest.addResponses.method, .post)
        XCTAssertEqual(MakeChoiceRequest.makeChoice.method, .post)
        XCTAssertEqual(GetResponsesRequest.getResponses.method, .post)
        XCTAssertEqual(GetQuestionsRequest.getQuestions.method, .post)
        XCTAssertEqual(GetQuestionRequest.getQuestion.method, .post)
        XCTAssertEqual(GetContextsRequest.getContexts.method, .get)
        XCTAssertEqual(UpdateImportanceRequest.updateImportance.method, .put)
    }

    func testRequestFactoriesGreetAndVoip() {
        XCTAssertEqual(TwoPersonGreetRequest.triggerTwoPersonGreet.method, .post)
        XCTAssertEqual(ForceGreetRequest.forceGreet.method, .post)
        XCTAssertEqual(ManualGreetRequest.manualGreet.method, .post)
        XCTAssertEqual(SendGreetEvent.sendGreetEvent.method, .post)
        XCTAssertEqual(GetGreetByID.getGreetByID.method, .post)
        XCTAssertEqual(CheckForActiveGreet.checkForActiveGreet.method, .get)
        XCTAssertEqual(GreetEventRequest.logGreetEvent.method, .put)
        XCTAssertEqual(GreetRatingRequest.rateGreet.method, .post)
        XCTAssertEqual(UpdateScheduleRequest.updateSchedule.method, .put)
        XCTAssertEqual(InitiateVoipCallRequest.initiateVoipCall.method, .post)
        XCTAssertEqual(RelayVoipSignalRequest.relayVoipSignal.method, .post)
        XCTAssertEqual(UpdateCallKitConsentRequest.updateCallKitConsent.method, .post)
        XCTAssertEqual(GetCallKitConsentRequest.getCallKitConsent.method, .get)
    }

    func testRequestFactoriesUserSettingsAndMisc() {
        XCTAssertEqual(FillSettingsRequest.fillSettings.method, .get)
        XCTAssertEqual(UserSettingsRequest.getUserInformation.method, .get)
        XCTAssertEqual(UpdateUserSettingsRequest.updateUserSettings.method, .put)
        XCTAssertEqual(LocationUpdateRequest.updateLocation.method, .post)
        XCTAssertEqual(UpdateUserLocationRequest.updateUserLocation.method, .put)
        XCTAssertEqual(SilentPushLocationUpdatesRequest.shouldUpdateLocation.method, .post)
        XCTAssertEqual(SendAppleTokenRequest.sendAppleAuthID.method, .post)
        XCTAssertEqual(AssertRequest.assert.method, .post)
        XCTAssertEqual(TrackEventsRequest.trackEvents.method, .post)
        XCTAssertFalse(TrackEventsRequest.trackEvents.assertHasAccessToken)
        XCTAssertEqual(CourtesyCallSettingRequest.updateCourtesyCallSetting.method, .post)
        XCTAssertEqual(SendMakeRequest.sendMake.method, .post)
        XCTAssertEqual(RegisterDeviceTokenErrorRequest.registerDeviceTokenError.method, .post)
        XCTAssertEqual(RegisterDeviceTokenRequest.registerDeviceToken.method, .post)
        XCTAssertEqual(RegisterPushKitDeviceTokenRequest.registerPushKitDeviceToken.method, .post)
        XCTAssertEqual(HideFromNearByListRequest.hideUpdate.method, .post)
        XCTAssertEqual(UpdateUserRelationPreferenceRequest.updateUserRelation.method, .patch)
        XCTAssertEqual(GetBlockedUsersRequest.getBlockedUsers.method, .post)
        XCTAssertEqual(GetGreetedUsersRequest.getGreetedUsers.method, .post)
        XCTAssertEqual(NearbyUsersRequest.nearbyUsers.method, .post)
        XCTAssertEqual(LogoutRequest.logout.method, .post)
        XCTAssertEqual(ReportFlagRequest.reportFlags.method, .post)
        XCTAssertEqual(UpdateFlagTreatmentRequest.updateFlagTreatment.method, .put)
        XCTAssertEqual(GetFlagTreatmentRequest.getFlagTreatmentSettings.method, .get)
    }

    // MARK: - StrongContractClient.Request.swift: data structs

    func testVenueImpactSummaryAndImpactEmployeeSummaryComputedID() {
        let venue = ImpactVenue(id: UUID(), name: "Venue", address: "addr")
        let employee = ImpactEmployeeSummary(employeeName: "Bob", referralsCount: 3, usersSentToVenue: 10)
        XCTAssertEqual(employee.id, "Bob-3-10")
        let summary = VenueImpactSummary(venue: venue, totalUsersSentToVenue: 10, employeeImpactSummaries: [employee])
        XCTAssertEqual(summary.venue, venue)
        XCTAssertEqual(summary.totalUsersSentToVenue, 10)
        XCTAssertEqual(summary.employeeImpactSummaries.count, 1)
    }

    func testPayloadWithEventInitAssignsProperties() {
        let event = GreetLogEvent.userViewed
        let payload = PayloadWithEvent(oldPayload: "original", event: event)
        XCTAssertEqual(payload.oldPayload, "original")
        XCTAssertEqual(payload.event.actionString, "user_viewed")
    }

    func testPlaceSuggestionComputedProperties() {
        let withSecondary = PlaceSuggestion(primaryText: "Starbucks", secondaryText: "123 Main St", placeID: "pid")
        XCTAssertEqual(withSecondary.id, "pid")
        XCTAssertEqual(withSecondary.name, "Starbucks")
        XCTAssertEqual(withSecondary.address, "123 Main St")

        let withoutSecondary = PlaceSuggestion(primaryText: "Starbucks", secondaryText: nil, placeID: "pid2")
        XCTAssertNil(withoutSecondary.address)
    }

    func testNearbyEmptyStateResponseInitAssignsProperties() {
        let forecastDate = Date()
        let benchmarkDate = Date()
        let response = NearbyEmptyStateResponse(
            userJoinRank: 5, wantsBenchmarkNotifications: true, nearbyUserCount: 12,
            wantsCalendarReminder: true, savedForecastDate: forecastDate, defaultEmail: "a@b.com",
            cloutLocationDescription: "downtown", hideFoundingMemberTile: false, actualDateOfBenchmark: benchmarkDate
        )
        XCTAssertEqual(response.userJoinRank, 5)
        XCTAssertTrue(response.wantsBenchmarkNotifications)
        XCTAssertEqual(response.nearbyUserCount, 12)
        XCTAssertEqual(response.savedForecastDate, forecastDate)
        XCTAssertEqual(response.defaultEmail, "a@b.com")
        XCTAssertEqual(response.cloutLocationDescription, "downtown")
        XCTAssertFalse(response.hideFoundingMemberTile)
        XCTAssertEqual(response.actualDateOfBenchmark, benchmarkDate)
    }

    func testNearbyEmptyStateSubmitPayloadInitAssignsProperties() {
        let forecastDate = Date()
        let payload = NearbyEmptyStateSubmitPayload(
            email: "a@b.com", notifyForLocalBenchmarks: true, forecastDate: forecastDate,
            forecastLocationHash: "hash", hideFoundingMemberTile: true, wantsCalendarReminder: false,
            locationDescription: "downtown", targetBenchMark: 100
        )
        XCTAssertEqual(payload.email, "a@b.com")
        XCTAssertTrue(payload.notifyForLocalBenchmarks)
        XCTAssertEqual(payload.forecastDate, forecastDate)
        XCTAssertEqual(payload.forecastLocationHash, "hash")
        XCTAssertTrue(payload.hideFoundingMemberTile)
        XCTAssertFalse(payload.wantsCalendarReminder)
        XCTAssertEqual(payload.locationDescription, "downtown")
        XCTAssertEqual(payload.targetBenchMark, 100)
    }

    func testForceGreetPayloadInitAssignsProperties() {
        let userID = UUID()
        let otherUserID = UUID()
        let payload = ForceGreetPayload(continueWithoutToken: true, userID: userID, otherUserID: otherUserID, contextRaw: "romance", greetingMethod: .wave)
        XCTAssertTrue(payload.continueWithoutToken)
        XCTAssertEqual(payload.userID, userID)
        XCTAssertEqual(payload.otherUserID, otherUserID)
        XCTAssertEqual(payload.contextRaw, "romance")
        XCTAssertEqual(payload.greetingMethod, .wave)
    }

    func testGreetMethodRawValuesAndDisplayStr() {
        XCTAssertEqual(Greet.Method.handShake.rawValue, "Hand shake")
        XCTAssertEqual(Greet.Method.hug.rawValue, "hug")
        XCTAssertEqual(Greet.Method.hook_up.rawValue, "Hook up")
        XCTAssertEqual(Greet.Method.allCases.count, 8)
    }

    func testContextCompatibilityStructInitAssignsProperties() {
        let id = UUID()
        let userID = UUID()
        let relatedUserID = UUID()
        let contextID = UUID()
        let value = ContextCompatibilityStruct(
            id: id, isIntroduced: true, compatibility: 0.8, rawCompatibilityScore: 0.75, minThreshold: 0.5,
            accepted: true, rejected: false, userID: userID, relatedUserID: relatedUserID, contextID: contextID, contextRaw: "romance"
        )
        XCTAssertEqual(value.id, id)
        XCTAssertTrue(value.isIntroduced)
        XCTAssertEqual(value.compatibility, 0.8)
        XCTAssertEqual(value.userID, userID)
        XCTAssertEqual(value.relatedUserID, relatedUserID)
        XCTAssertEqual(value.contextID, contextID)
        XCTAssertEqual(value.contextRaw, "romance")
        XCTAssertNil(value.userRelationID)
    }

    func testGreetActionPayloadInitAssignsProperties() {
        let greetID = UUID()
        let payload = GreetActionPayload(greetAction: .dismissGreet, greetID: greetID)
        XCTAssertEqual(payload.greetAction, .dismissGreet)
        XCTAssertEqual(payload.greetID, greetID)
    }

    func testGreetEventPayloadInitAssignsProperties() {
        let greetID = UUID()
        let otherUserID = UUID()
        let payload = GreetEventPayload(event: .userViewed, greetID: greetID, otherUserID: otherUserID, otherUserName: "Jane", otherUSerEmail: "a@b.com")
        XCTAssertEqual(payload.greetID, greetID)
        XCTAssertEqual(payload.otherUserID, otherUserID)
        XCTAssertEqual(payload.otherUserName, "Jane")
        XCTAssertEqual(payload.otherUSerEmail, "a@b.com")
    }

    func testLocationPayloadInitAssignsProperties() {
        let coordinates = Coordinates(latitude: 1, longitude: 2)
        let payload = LocationPayload(
            coordinates: coordinates, cityName: "Austin", timeZoneIdentifier: "America/Chicago",
            localeIdentifier: "en_US", regionCode: "US", languageCode: "en", uses24HourClock: false, calendarIdentifier: "gregorian"
        )
        XCTAssertEqual(payload.coordinates, coordinates)
        XCTAssertEqual(payload.cityName, "Austin")
        XCTAssertEqual(payload.timeZoneIdentifier, "America/Chicago")
        XCTAssertEqual(payload.regionCode, "US")
        XCTAssertEqual(payload.languageCode, "en")
        XCTAssertEqual(payload.uses24HourClock, false)
        XCTAssertEqual(payload.calendarIdentifier, "gregorian")
    }

    func testCallKitConsentPayloadAndResponseInit() {
        let payload = CallKitConsentPayload(hasGrantedCallKitConsent: true)
        XCTAssertTrue(payload.hasGrantedCallKitConsent)
        let updatedAt = Date()
        let response = CallKitConsentResponse(hasGrantedCallKitConsent: false, consentUpdatedAt: updatedAt)
        XCTAssertFalse(response.hasGrantedCallKitConsent)
        XCTAssertEqual(response.consentUpdatedAt, updatedAt)
    }

    func testInitiateVoipCallPayloadInitAssignsProperties() {
        let greetID = UUID()
        let payload = InitiateVoipCallPayload(greetID: greetID, callType: .ringToVoipEnroute)
        XCTAssertEqual(payload.greetID, greetID)
        XCTAssertEqual(payload.callType, .ringToVoipEnroute)
    }

    func testImageMetadataAndImageInfoInit() {
        let metadata = imageMetadata()
        let info = ImageInfo(path: "https://example.com/upload", metaData: metadata)
        XCTAssertEqual(info.imageStorageURL, "https://example.com/upload")
        XCTAssertEqual(info.metaData, metadata)
    }

    func testCloudflareImageURLSInitAssignsProperties() {
        let urls = CloudflareImageURLS(uploadURL: "up", downloadURL: "down")
        XCTAssertEqual(urls.uploadURL, "up")
        XCTAssertEqual(urls.downloadURL, "down")
    }

    func testSubmitFlagRequestInitAssignsProperties() {
        let contentID = UUID()
        let request = SubmitFlagRequest(contentType: .question, contentID: contentID, flagExplanation: flagExplanation())
        XCTAssertEqual(request.contentType, .question)
        XCTAssertEqual(request.contentID, contentID)
        XCTAssertEqual(request.flagExplanation, flagExplanation())
    }

    func testModerationContentTypeRawValues() {
        XCTAssertEqual(ModerationContentType.question.rawValue, "question")
        XCTAssertEqual(ModerationContentType.response.rawValue, "response")
        XCTAssertEqual(ModerationContentType.imageMetaData.rawValue, "imageMetaData")
    }

    func testUpdateFlagTreatmentInitAssignsProperties() {
        let treatment = UpdateFlagTreatment(treatment: .blur, flag: .spam)
        XCTAssertEqual(treatment.treatment, .blur)
        XCTAssertEqual(treatment.flag, .spam)
    }

    func testGetQuestionsRequestPayloadDefaults() {
        let payload = GetQuestionsRequestPayload()
        XCTAssertTrue(payload.specs.isEmpty)
        XCTAssertFalse(payload.isFirst)
        XCTAssertEqual(payload.page, 1)
        XCTAssertEqual(payload.limit, 20)
    }

    func testGetQuestionPayloadInitAssignsProperties() {
        let questionID = UUID()
        let responseID = UUID()
        let payload = GetQuestionPayload(questionID: questionID, responseID: responseID)
        XCTAssertEqual(payload.questionID, questionID)
        XCTAssertEqual(payload.responseID, responseID)
    }

    func testHideOptionAndHideUpdatePayload() {
        let payload = HideUpdatePayload(hideMe: true, hideOption: .manual)
        XCTAssertTrue(payload.hideMe)
        XCTAssertEqual(payload.hideOption, .manual)
        XCTAssertNotEqual(HideOption.automatic, HideOption.manual)
    }

    func testRelationUpdatePayloadAndRelationUpdateCases() {
        let otherUserID = UUID()
        let payload = RelationUpdatePayload(otherUserID: otherUserID, relationUpdate: .blocked(true))
        XCTAssertEqual(payload.otherUserID, otherUserID)
        XCTAssertEqual(payload.relationUpdate, .blocked(true))
        XCTAssertEqual(RelationUpdate.automatic(.daily), .automatic(.daily))
        XCTAssertEqual(RelationUpdate.manual(.weekly), .manual(.weekly))
        XCTAssertNotEqual(RelationUpdate.automatic(.daily), RelationUpdate.manual(.daily))
    }

    func testNearbyUserRequestAndResponseInit() {
        let coordinates = Coordinates(latitude: 1, longitude: 2)
        let request = NearbyUserRequest(coordinates: coordinates, page: 1, limit: 20)
        XCTAssertEqual(request.coordinates, coordinates)
        XCTAssertEqual(request.page, 1)
        XCTAssertEqual(request.limit, 20)

        let response = NearbyUserResponse(nearbyMembers: [nearbyUser()], hideStatusAutomatic: true, hideStatusManual: false)
        XCTAssertEqual(response.nearbyMembers.count, 1)
        XCTAssertTrue(response.hideStatusAutomatic)
        XCTAssertFalse(response.hideStatusManual)
    }

    func testAddResponsePayloadInitAssignsProperties() {
        let response = questionResponse(text: "abc", questionID: UUID())
        let payload = AddResponsePayload(questionText: "some question", responses: [response])
        XCTAssertEqual(payload.questionText, "some question")
        XCTAssertEqual(payload.responses.count, 1)
    }
}
