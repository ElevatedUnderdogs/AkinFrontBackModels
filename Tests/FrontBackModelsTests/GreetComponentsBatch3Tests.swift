import XCTest
@testable import AkinFrontBackModels

final class GreetComponentsBatch3Tests: XCTestCase {

    // MARK: - AkinCommon+User.swift (User)

    func testUserInit_setsProvidedFieldsAndDefaults() {
        let id = UUID()
        let user = User(
            cloudFlareImageURL: "https://example.com/a.jpg",
            firstName: "Ada",
            lastName: "Lovelace",
            user_id: id,
            email: "ada@example.com",
            zip: 12345,
            dob: "1990-01-01"
        )

        XCTAssertEqual(user.id, id)
        XCTAssertEqual(user.cloudFlareImageURL, "https://example.com/a.jpg")
        XCTAssertEqual(user.firstName, "Ada")
        XCTAssertEqual(user.lastName, "Lovelace")
        XCTAssertEqual(user.email, "ada@example.com")
        XCTAssertEqual(user.zip, 12345)
        XCTAssertEqual(user.dobString, "1990-01-01")

        XCTAssertNil(user.privacy)
        XCTAssertNil(user.phoneNumber)
        XCTAssertEqual(user.requiredQuestions, [])
        XCTAssertNil(user.birthDate)
        XCTAssertTrue(user.meetingSchedule.isEmpty)
    }

    func testUserInit_omittedOptionalsDefaultToNil() {
        let user = User(
            firstName: "Bob",
            lastName: "Smith",
            user_id: UUID(),
            email: "bob@example.com"
        )

        XCTAssertNil(user.cloudFlareImageURL)
        XCTAssertNil(user.zip)
        XCTAssertNil(user.dobString)
    }

    func testUserCodableRoundTrip_minimal() throws {
        let user = User(
            firstName: "Cleo",
            lastName: "Nile",
            user_id: UUID(),
            email: "cleo@example.com"
        )

        let data = try JSONEncoder().encode(user)
        let decoded = try JSONDecoder().decode(User.self, from: data)

        XCTAssertEqual(decoded.id, user.id)
        XCTAssertEqual(decoded.firstName, user.firstName)
        XCTAssertEqual(decoded.lastName, user.lastName)
        XCTAssertEqual(decoded.email, user.email)
        XCTAssertNil(decoded.cloudFlareImageURL)
        XCTAssertNil(decoded.zip)
        XCTAssertNil(decoded.phoneNumber)
        XCTAssertNil(decoded.birthDate)
        XCTAssertNil(decoded.dobString)
        XCTAssertEqual(decoded.requiredQuestions, [])
        XCTAssertTrue(decoded.meetingSchedule.isEmpty)
    }

    func testUserCodableRoundTrip_allFieldsPopulated() throws {
        var user = User(
            cloudFlareImageURL: "https://example.com/b.jpg",
            firstName: "Dana",
            lastName: "White",
            user_id: UUID(),
            email: "dana@example.com",
            zip: 54321,
            dob: "1985-05-05"
        )
        user.privacy = PrivateDetails(password: "secret", romanceOn: true, accessToken: "tok-123")
        user.phoneNumber = 5551234567
        user.birthDate = Date(timeIntervalSince1970: 1700000000)
        user.meetingSchedule = [Week.Day(name: .Monday, timeBlocks: [])]

        let data = try JSONEncoder().encode(user)
        let decoded = try JSONDecoder().decode(User.self, from: data)

        XCTAssertEqual(decoded.id, user.id)
        XCTAssertEqual(decoded.cloudFlareImageURL, user.cloudFlareImageURL)
        XCTAssertEqual(decoded.firstName, user.firstName)
        XCTAssertEqual(decoded.lastName, user.lastName)
        XCTAssertEqual(decoded.email, user.email)
        XCTAssertEqual(decoded.zip, user.zip)
        XCTAssertEqual(decoded.dobString, user.dobString)
        XCTAssertEqual(decoded.phoneNumber, user.phoneNumber)
        XCTAssertEqual(decoded.birthDate, user.birthDate)

        XCTAssertEqual(decoded.privacy?.password, "secret")
        XCTAssertEqual(decoded.privacy?.romanceOn, true)
        XCTAssertEqual(decoded.privacy?.token, "tok-123")

        XCTAssertEqual(decoded.meetingSchedule.count, 1)
        XCTAssertEqual(decoded.meetingSchedule.first?.name, .Monday)
        XCTAssertEqual(decoded.meetingSchedule.first?.timeBlocks.count, 0)
    }

    func testUsersAction_typealiasInvokesWithNearbyUsers() {
        var received: [NearbyUser] = []
        let action: UsersAction = { users in received = users }

        let nearbyUser = NearbyUser(
            id: .init(),
            name: "Scott",
            profileImage: "",
            imageMetaData: .init(width: 20, height: 20, format: "jpeg", assessment: ModerationAssessment(entries: []), id: .init()),
            verified: true,
            lastLocationUpdate: nil
        )
        action([nearbyUser])

        XCTAssertEqual(received.count, 1)
        XCTAssertEqual(received.first?.name, "Scott")
    }

    // MARK: - AlertContents.swift (Contents)

    func testContentsInit_defaultsOmittedOptionalsToNil() {
        let contents = Contents(title: "Title", message: "Message", confirmation: "Okay")

        XCTAssertEqual(contents.title, "Title")
        XCTAssertEqual(contents.message, "Message")
        XCTAssertEqual(contents.confirmationButtonText, "Okay")
        XCTAssertNil(contents.doNothing)
        XCTAssertNil(contents.alreadyConfirmed)
    }

    func testContentsInit_allFieldsProvided() {
        let contents = Contents(
            title: "Title",
            message: "Message",
            confirmation: "Okay",
            doNothing: "Cancel",
            alreadyConfirmed: true
        )

        XCTAssertEqual(contents.doNothing, "Cancel")
        XCTAssertEqual(contents.alreadyConfirmed, true)
    }

    func testContentsCodableRoundTrip_minimal() throws {
        let contents = Contents(title: "T", message: "M", confirmation: "C")
        let data = try JSONEncoder().encode(contents)
        let decoded = try JSONDecoder().decode(Contents.self, from: data)

        XCTAssertEqual(decoded.title, contents.title)
        XCTAssertEqual(decoded.message, contents.message)
        XCTAssertEqual(decoded.confirmationButtonText, contents.confirmationButtonText)
        XCTAssertNil(decoded.doNothing)
        XCTAssertNil(decoded.alreadyConfirmed)
    }

    func testContentsCodableRoundTrip_allFields() throws {
        let contents = Contents(title: "T", message: "M", confirmation: "C", doNothing: "N", alreadyConfirmed: false)
        let data = try JSONEncoder().encode(contents)
        let decoded = try JSONDecoder().decode(Contents.self, from: data)

        XCTAssertEqual(decoded.doNothing, "N")
        XCTAssertEqual(decoded.alreadyConfirmed, false)
    }

    // MARK: - ContextPreferences.swift

    func testContextPreferencesInit() {
        let context = Context(id: UUID(), case: .romance)
        let prefs = ContextPreferences(
            context: context,
            metersWillingToTravel: 500,
            allowedGreetingMethods: [.wave, .hug],
            isMeetEnabled: true
        )

        XCTAssertEqual(prefs.context, context)
        XCTAssertEqual(prefs.metersWillingToTravel, 500)
        XCTAssertEqual(prefs.allowedGreetingMethods, [.wave, .hug])
        XCTAssertTrue(prefs.isMeetEnabled)
    }

    func testContextPreferencesEquatable() {
        let context = Context(id: UUID(), case: .social)
        let a = ContextPreferences(context: context, metersWillingToTravel: 10, allowedGreetingMethods: [], isMeetEnabled: true)
        let b = ContextPreferences(context: context, metersWillingToTravel: 10, allowedGreetingMethods: [], isMeetEnabled: true)
        let c = ContextPreferences(context: context, metersWillingToTravel: 20, allowedGreetingMethods: [], isMeetEnabled: true)

        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, c)
    }

    func testContextPreferencesHashable() {
        let context = Context(id: UUID(), case: .social)
        let a = ContextPreferences(context: context, metersWillingToTravel: 10, allowedGreetingMethods: [], isMeetEnabled: true)
        let b = ContextPreferences(context: context, metersWillingToTravel: 10, allowedGreetingMethods: [], isMeetEnabled: true)

        let set: Set<ContextPreferences> = [a, b]
        XCTAssertEqual(set.count, 1)
    }

    func testContextPreferencesCodableRoundTrip() throws {
        let context = Context(id: UUID(), case: .romance)
        let prefs = ContextPreferences(context: context, metersWillingToTravel: 250, allowedGreetingMethods: [.kiss], isMeetEnabled: false)

        let data = try JSONEncoder().encode(prefs)
        let decoded = try JSONDecoder().decode(ContextPreferences.self, from: data)

        XCTAssertEqual(decoded, prefs)
    }

    // MARK: - GreetLogEvent.swift: .channel

    func testChannel_pushQueued() {
        XCTAssertEqual(GreetLogEvent.pushQueued(channel: .applePush, providerMessageID: nil).channel, .applePush)
    }

    func testChannel_pushSent() {
        XCTAssertEqual(GreetLogEvent.pushSent(channel: .voicePush, providerMessageID: nil).channel, .voicePush)
    }

    func testChannel_pushFailed() {
        XCTAssertEqual(GreetLogEvent.pushFailed(channel: .websocket).channel, .websocket)
    }

    func testChannel_deliveryConfirmed() {
        XCTAssertEqual(GreetLogEvent.deliveryConfirmed(channel: .applePush, providerMessageID: nil).channel, .applePush)
    }

    func testChannel_fallbackTriggered() {
        XCTAssertEqual(GreetLogEvent.fallbackTriggered(to: .voicePush).channel, .voicePush)
    }

    func testChannel_pushNotifReceived() {
        XCTAssertEqual(GreetLogEvent.pushNotifReceived(providerMessageID: UUID()).channel, .applePush)
    }

    func testChannel_voipReceived() {
        XCTAssertEqual(GreetLogEvent.voipReceived(providerMessageID: UUID()).channel, .voicePush)
    }

    func testChannel_rejectedViaAnotherCall() {
        XCTAssertEqual(GreetLogEvent.rejectedViaAnotherCall.channel, .voicePush)
    }

    func testChannel_webSocketSent() {
        XCTAssertEqual(GreetLogEvent.webSocketSent.channel, .websocket)
    }

    func testChannel_notApplicableGroup() {
        XCTAssertEqual(GreetLogEvent.webSocketFailed.channel, .notApplicable)
        XCTAssertEqual(GreetLogEvent.rateLimited.channel, .notApplicable)
        XCTAssertEqual(GreetLogEvent.greetAction(.manualGreetInitiated).channel, .notApplicable)
        XCTAssertEqual(GreetLogEvent.userViewed.channel, .notApplicable)
        XCTAssertEqual(GreetLogEvent.greetCreated.channel, .notApplicable)
        XCTAssertEqual(GreetLogEvent.greetExpired.channel, .notApplicable)
        XCTAssertEqual(GreetLogEvent.settingsUpdated.channel, .notApplicable)
        XCTAssertEqual(GreetLogEvent.pushProviderAccepted(providerMessageID: UUID()).channel, .notApplicable)
        XCTAssertEqual(GreetLogEvent.serverFound(error: "e").channel, .notApplicable)
        XCTAssertEqual(GreetLogEvent.clientFound(error: "e").channel, .notApplicable)
    }

    // MARK: - GreetLogEvent.swift: .message

    func testMessage_pushQueued_withAndWithoutID() {
        let id = UUID()
        XCTAssertEqual(GreetLogEvent.pushQueued(channel: .applePush, providerMessageID: id).message, id.uuidString)
        XCTAssertNil(GreetLogEvent.pushQueued(channel: .applePush, providerMessageID: nil).message)
    }

    func testMessage_pushSent_withAndWithoutID() {
        let id = UUID()
        XCTAssertEqual(GreetLogEvent.pushSent(channel: .voicePush, providerMessageID: id).message, id.uuidString)
        XCTAssertNil(GreetLogEvent.pushSent(channel: .voicePush, providerMessageID: nil).message)
    }

    func testMessage_pushProviderAccepted() {
        let id = UUID()
        XCTAssertEqual(GreetLogEvent.pushProviderAccepted(providerMessageID: id).message, id.uuidString)
    }

    func testMessage_deliveryConfirmed_withAndWithoutID() {
        let id = UUID()
        XCTAssertEqual(GreetLogEvent.deliveryConfirmed(channel: .applePush, providerMessageID: id).message, id.uuidString)
        XCTAssertNil(GreetLogEvent.deliveryConfirmed(channel: .applePush, providerMessageID: nil).message)
    }

    func testMessage_pushNotifReceived() {
        let id = UUID()
        XCTAssertEqual(GreetLogEvent.pushNotifReceived(providerMessageID: id).message, id.uuidString)
    }

    func testMessage_voipReceived() {
        let id = UUID()
        XCTAssertEqual(GreetLogEvent.voipReceived(providerMessageID: id).message, id.uuidString)
    }

    func testMessage_serverFound() {
        XCTAssertEqual(GreetLogEvent.serverFound(error: "server broke").message, "server broke")
    }

    func testMessage_clientFound() {
        XCTAssertEqual(GreetLogEvent.clientFound(error: "client broke").message, "client broke")
    }

    func testMessage_nilGroup() {
        XCTAssertNil(GreetLogEvent.pushFailed(channel: .applePush).message)
        XCTAssertNil(GreetLogEvent.webSocketSent.message)
        XCTAssertNil(GreetLogEvent.webSocketFailed.message)
        XCTAssertNil(GreetLogEvent.fallbackTriggered(to: .applePush).message)
        XCTAssertNil(GreetLogEvent.rateLimited.message)
        XCTAssertNil(GreetLogEvent.userViewed.message)
        XCTAssertNil(GreetLogEvent.greetCreated.message)
        XCTAssertNil(GreetLogEvent.greetExpired.message)
        XCTAssertNil(GreetLogEvent.settingsUpdated.message)
        XCTAssertNil(GreetLogEvent.rejectedViaAnotherCall.message)
    }

    func testMessage_greetAction_travelTimeToVenue() {
        let event = GreetLogEvent.greetAction(.travelTimeToVenue(changedTo: 45))
        XCTAssertEqual(event.message, "45")
    }

    func testMessage_greetAction_nonTravelTimeCase() {
        let event = GreetLogEvent.greetAction(.manualGreetInitiated)
        XCTAssertNil(event.message)
    }

    // MARK: - GreetLogEvent.swift: .actorKindDefault

    func testActorKindDefault_serverGroup() {
        XCTAssertEqual(GreetLogEvent.pushQueued(channel: .applePush, providerMessageID: nil).actorKindDefault, .server)
        XCTAssertEqual(GreetLogEvent.pushSent(channel: .applePush, providerMessageID: nil).actorKindDefault, .server)
        XCTAssertEqual(GreetLogEvent.pushProviderAccepted(providerMessageID: UUID()).actorKindDefault, .server)
        XCTAssertEqual(GreetLogEvent.pushFailed(channel: .applePush).actorKindDefault, .server)
        XCTAssertEqual(GreetLogEvent.webSocketSent.actorKindDefault, .server)
        XCTAssertEqual(GreetLogEvent.webSocketFailed.actorKindDefault, .server)
        XCTAssertEqual(GreetLogEvent.fallbackTriggered(to: .applePush).actorKindDefault, .server)
        XCTAssertEqual(GreetLogEvent.rateLimited.actorKindDefault, .server)
        XCTAssertEqual(GreetLogEvent.greetCreated.actorKindDefault, .server)
        XCTAssertEqual(GreetLogEvent.settingsUpdated.actorKindDefault, .server)
        XCTAssertEqual(GreetLogEvent.serverFound(error: "e").actorKindDefault, .server)
    }

    func testActorKindDefault_systemGroup() {
        XCTAssertEqual(GreetLogEvent.pushNotifReceived(providerMessageID: UUID()).actorKindDefault, .system)
        XCTAssertEqual(GreetLogEvent.voipReceived(providerMessageID: UUID()).actorKindDefault, .system)
        XCTAssertEqual(GreetLogEvent.deliveryConfirmed(channel: .applePush, providerMessageID: nil).actorKindDefault, .system)
        XCTAssertEqual(GreetLogEvent.greetExpired.actorKindDefault, .system)
        XCTAssertEqual(GreetLogEvent.clientFound(error: "e").actorKindDefault, .system)
    }

    func testActorKindDefault_userGroup() {
        XCTAssertEqual(GreetLogEvent.greetAction(.manualGreetInitiated).actorKindDefault, .user)
        XCTAssertEqual(GreetLogEvent.userViewed.actorKindDefault, .user)
        XCTAssertEqual(GreetLogEvent.rejectedViaAnotherCall.actorKindDefault, .user)
    }

    // MARK: - GreetLogEvent.swift: .action

    func testAction_greetActionBranch_zeroAssociatedValue() {
        XCTAssertEqual(GreetLogEvent.greetAction(.manualGreetInitiated).action, "manual_greet_initiated")
    }

    func testAction_greetActionBranch_singleAssociatedValueIgnoredInName() {
        // A single associated value does not get appended to the action string
        // (mirrors the documented `pushProviderAccepted` -> `push_provider_accepted` example).
        XCTAssertEqual(GreetLogEvent.greetAction(.agreedToMeet(30)).action, "agreed_to_meet")
    }

    func testAction_greetActionBranch_multipleAssociatedIntValues() {
        let action = GreetAction.notGettingCloser(start: 20, allowance: 10, current: 5)
        XCTAssertEqual(GreetLogEvent.greetAction(action).action, "not_getting_closer_20_10_5")
    }

    func testAction_defaultBranch_zeroAssociatedValueCases() {
        XCTAssertEqual(GreetLogEvent.userViewed.action, "user_viewed")
        XCTAssertEqual(GreetLogEvent.greetCreated.action, "greet_created")
        XCTAssertEqual(GreetLogEvent.greetExpired.action, "greet_expired")
        XCTAssertEqual(GreetLogEvent.settingsUpdated.action, "settings_updated")
        XCTAssertEqual(GreetLogEvent.rateLimited.action, "rate_limited")
        XCTAssertEqual(GreetLogEvent.webSocketSent.action, "web_socket_sent")
        XCTAssertEqual(GreetLogEvent.webSocketFailed.action, "web_socket_failed")
        XCTAssertEqual(GreetLogEvent.rejectedViaAnotherCall.action, "rejected_via_another_call")
    }

    func testAction_defaultBranch_documentedSingleAssociatedValueExample() {
        // The single associated UUID is appended to the snake_cased case name,
        // not dropped, so pin a fixed UUID for a deterministic assertion.
        let fixedID = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
        XCTAssertEqual(
            GreetLogEvent.pushProviderAccepted(providerMessageID: fixedID).action,
            "push_provider_accepted_\(fixedID.uuidString.lowercased())"
        )
    }

    // MARK: - GreetActionChannel / GreetActionActorKind

    func testGreetActionChannel_allCasesAndRawValues() {
        XCTAssertEqual(GreetActionChannel.allCases.count, 4)
        XCTAssertEqual(GreetActionChannel.websocket.rawValue, "websocket")
        XCTAssertEqual(GreetActionChannel.applePush.rawValue, "apple_push")
        XCTAssertEqual(GreetActionChannel.voicePush.rawValue, "voice_push")
        XCTAssertEqual(GreetActionChannel.notApplicable.rawValue, "not_applicable")
    }

    func testGreetActionChannel_codableRoundTrip() throws {
        let data = try JSONEncoder().encode(GreetActionChannel.applePush)
        let decoded = try JSONDecoder().decode(GreetActionChannel.self, from: data)
        XCTAssertEqual(decoded, .applePush)
    }

    func testGreetActionActorKind_allCasesAndRawValues() {
        XCTAssertEqual(GreetActionActorKind.allCases.count, 3)
        XCTAssertEqual(GreetActionActorKind.user.rawValue, "user")
        XCTAssertEqual(GreetActionActorKind.server.rawValue, "server")
        XCTAssertEqual(GreetActionActorKind.system.rawValue, "system")
    }

    func testGreetActionActorKind_codableRoundTrip() throws {
        let data = try JSONEncoder().encode(GreetActionActorKind.system)
        let decoded = try JSONDecoder().decode(GreetActionActorKind.self, from: data)
        XCTAssertEqual(decoded, .system)
    }

    // MARK: - GreetUpdate.swift (Greet.Update)

    /// FrontBackModelsTests.greetDetailsInputsOutputs is a large table-driven fixture that
    /// exercises Greet.Update.init across the (this, otherUser) state matrix, but it is never
    /// iterated/asserted anywhere in the existing suite. Exercising it here actually runs
    /// that data through the state machine instead of leaving it dead.
    func testGreetDetailsInputOutputTable_allEntriesPass() {
        let table = FrontBackModelsTests().greetDetailsInputsOutputs
        XCTAssertFalse(table.isEmpty)
        for entry in table {
            XCTAssertTrue(
                entry.passes,
                "this: \(entry.this) otherUser: \(String(describing: entry.otherUser)) withinRange: \(entry.withinRange) rejectedProposal: \(String(describing: entry.rejectedProposal)) viewForProposal: \(entry.viewForProposal) expected: \(entry.output) actual: \(entry.greetUpdate)"
            )
        }
    }

    func testUpdateEquatable_sameCaseSameValue() {
        XCTAssertEqual(Greet.Update.errorMessage("a"), Greet.Update.errorMessage("a"))
        XCTAssertEqual(Greet.Update.exitReason(.thisConfirmedMet), Greet.Update.exitReason(.thisConfirmedMet))
        XCTAssertEqual(Greet.Update.message(.cant(3)), Greet.Update.message(.cant(3)))
        XCTAssertEqual(Greet.Update.viewSetting(.start), Greet.Update.viewSetting(.start))
    }

    func testUpdateEquatable_sameCaseDifferentValue() {
        XCTAssertNotEqual(Greet.Update.errorMessage("a"), Greet.Update.errorMessage("b"))
        XCTAssertNotEqual(Greet.Update.exitReason(.thisConfirmedMet), Greet.Update.exitReason(.exceededRange(.my)))
        XCTAssertNotEqual(Greet.Update.message(.cant(3)), Greet.Update.message(.cant(4)))
        XCTAssertNotEqual(Greet.Update.viewSetting(.start), Greet.Update.viewSetting(.rejected))
    }

    func testUpdateEquatable_differentCasesAreNeverEqual() {
        let errorMessage = Greet.Update.errorMessage("a")
        let exitReason = Greet.Update.exitReason(.thisConfirmedMet)
        let message = Greet.Update.message(.cant(3))
        let viewSetting = Greet.Update.viewSetting(.start)

        XCTAssertNotEqual(errorMessage, exitReason)
        XCTAssertNotEqual(errorMessage, message)
        XCTAssertNotEqual(errorMessage, viewSetting)
        XCTAssertNotEqual(exitReason, message)
        XCTAssertNotEqual(exitReason, viewSetting)
        XCTAssertNotEqual(message, viewSetting)
    }

    func testUpdateCodableRoundTrip_allCases() throws {
        let updates: [Greet.Update] = [
            .errorMessage("boom"),
            .exitReason(.exceededRange(.their)),
            .exitReason(.rejected(.my)),
            .exitReason(.thisConfirmedMet),
            .message(.cant(12)),
            .message(.theySayTheyMet("Tom")),
            .message(.youAreCloseTo("Tom")),
            .viewSetting(.start),
            .viewSetting(.otherAskedIfCanMeetLater(15)),
        ]

        for update in updates {
            let data = try JSONEncoder().encode(update)
            let decoded = try JSONDecoder().decode(Greet.Update.self, from: data)
            XCTAssertEqual(decoded, update)
        }
    }

    // MARK: - GreetUpdate.Message.swift (Greet.Update.Message)

    func testMessageEquatable_sameCaseSameValue() {
        XCTAssertEqual(Greet.Update.Message.cant(5), Greet.Update.Message.cant(5))
        XCTAssertEqual(Greet.Update.Message.theySayTheyMet("Tom"), Greet.Update.Message.theySayTheyMet("Tom"))
        XCTAssertEqual(Greet.Update.Message.youAreCloseTo("Tom"), Greet.Update.Message.youAreCloseTo("Tom"))
    }

    func testMessageEquatable_sameCaseDifferentValue() {
        XCTAssertNotEqual(Greet.Update.Message.cant(5), Greet.Update.Message.cant(6))
        XCTAssertNotEqual(Greet.Update.Message.theySayTheyMet("Tom"), Greet.Update.Message.theySayTheyMet("Sam"))
        XCTAssertNotEqual(Greet.Update.Message.youAreCloseTo("Tom"), Greet.Update.Message.youAreCloseTo("Sam"))
    }

    func testMessageEquatable_differentCasesAreNeverEqual() {
        let cant = Greet.Update.Message.cant(5)
        let theySaid = Greet.Update.Message.theySayTheyMet("Tom")
        let closeTo = Greet.Update.Message.youAreCloseTo("Tom")

        XCTAssertNotEqual(cant, theySaid)
        XCTAssertNotEqual(theySaid, closeTo)
        XCTAssertNotEqual(closeTo, cant)
    }

    func testMessageCodableRoundTrip_allCases() throws {
        let messages: [Greet.Update.Message] = [
            .cant(7),
            .theySayTheyMet("Ada"),
            .youAreCloseTo("Ada"),
        ]

        for message in messages {
            let data = try JSONEncoder().encode(message)
            let decoded = try JSONDecoder().decode(Greet.Update.Message.self, from: data)
            XCTAssertEqual(decoded, message)
        }
    }

    // MARK: - SaveQuestionError.swift (Question.SaveAttemptServerResponse.ServerError)

    func testServerErrorExplanations() {
        XCTAssertEqual(
            Question.SaveAttemptServerResponse.ServerError.incorrectFormatServerError.explanation,
            "Either the json came in the wrong format, or it was parsed incorrectly."
        )
        XCTAssertEqual(
            Question.SaveAttemptServerResponse.ServerError.unknownError.explanation,
            "There is an unknown error from the server."
        )
        XCTAssertEqual(
            Question.SaveAttemptServerResponse.ServerError.repeatQuestion.explanation,
            "This question already exists verbatim."
        )
    }

    func testServerErrorRawValues() {
        XCTAssertEqual(Question.SaveAttemptServerResponse.ServerError.incorrectFormatServerError.rawValue, "incorrectFormatServerError")
        XCTAssertEqual(Question.SaveAttemptServerResponse.ServerError.repeatQuestion.rawValue, "repeatQuestion")
        XCTAssertEqual(Question.SaveAttemptServerResponse.ServerError.unknownError.rawValue, "unknownError")
    }

    func testServerErrorCodableRoundTrip() throws {
        for error in [Question.SaveAttemptServerResponse.ServerError.incorrectFormatServerError, .repeatQuestion, .unknownError] {
            let data = try JSONEncoder().encode(error)
            let decoded = try JSONDecoder().decode(Question.SaveAttemptServerResponse.ServerError.self, from: data)
            XCTAssertEqual(decoded, error)
        }
    }

    func testServerErrorConformsToError() {
        func throwIt() throws {
            throw Question.SaveAttemptServerResponse.ServerError.unknownError
        }

        XCTAssertThrowsError(try throwIt()) { error in
            XCTAssertEqual(error as? Question.SaveAttemptServerResponse.ServerError, .unknownError)
        }
    }

    // MARK: - Settings.swift

    func testSettingsDefaultInit() {
        let settings = Settings()

        XCTAssertFalse(settings.vibrate)
        XCTAssertFalse(settings.ring)
        XCTAssertNil(settings.cloudflareProfileImageURL)
        XCTAssertNil(settings.emailPrimary)
        XCTAssertNil(settings.phone)
        XCTAssertEqual(settings.contextPreferences, [])
        XCTAssertNil(settings.firstName)
        XCTAssertNil(settings.lastName)
        XCTAssertNil(settings.dob)
        XCTAssertNil(settings.birthday)
    }

    func testSettingsConvenienceInit() {
        let id = UUID()
        let settings = Settings(email: "a@b.com", cloudflareProfileImageURL: "url", userID: id)

        XCTAssertEqual(settings.emailPrimary, "a@b.com")
        XCTAssertEqual(settings.cloudflareProfileImageURL, "url")
        XCTAssertTrue(settings.vibrate)
        XCTAssertTrue(settings.ring)
        XCTAssertEqual(settings.userID, id)
    }

    func testIsSocialEnabledAndIsRomanceEnabled() {
        var settings = Settings()
        XCTAssertFalse(settings.isSocialEnabled)
        XCTAssertFalse(settings.isRomanceEnabled)

        settings.contextPreferences = [
            ContextPreferences(context: Context(id: UUID(), case: .social), metersWillingToTravel: 1, allowedGreetingMethods: [], isMeetEnabled: true),
            ContextPreferences(context: Context(id: UUID(), case: .romance), metersWillingToTravel: 1, allowedGreetingMethods: [], isMeetEnabled: false),
        ]

        XCTAssertTrue(settings.isSocialEnabled)
        XCTAssertFalse(settings.isRomanceEnabled)
    }

    func testAdd_appendsWhenShouldAddAndContextFound() {
        var settings = Settings()
        settings.contextPreferences = [
            ContextPreferences(context: Context(id: UUID(), case: .romance), metersWillingToTravel: 1, allowedGreetingMethods: [], isMeetEnabled: false)
        ]

        settings.add(greetingMethod: .wave, shouldAdd: true, for: .romance)

        XCTAssertEqual(settings.contextPreferences.first?.allowedGreetingMethods, [.wave])
    }

    func testAdd_noOpWhenShouldAddIsFalse() {
        var settings = Settings()
        settings.contextPreferences = [
            ContextPreferences(context: Context(id: UUID(), case: .romance), metersWillingToTravel: 1, allowedGreetingMethods: [], isMeetEnabled: false)
        ]

        settings.add(greetingMethod: .wave, shouldAdd: false, for: .romance)

        XCTAssertEqual(settings.contextPreferences.first?.allowedGreetingMethods, [])
    }

    func testAdd_noOpWhenContextNotFound() {
        var settings = Settings()
        settings.contextPreferences = [
            ContextPreferences(context: Context(id: UUID(), case: .romance), metersWillingToTravel: 1, allowedGreetingMethods: [], isMeetEnabled: false)
        ]

        settings.add(greetingMethod: .wave, shouldAdd: true, for: .social)

        XCTAssertEqual(settings.contextPreferences.first?.allowedGreetingMethods, [])
    }

    func testGreetingMethodText_emptyReturnsWave() {
        var settings = Settings()
        settings.contextPreferences = [
            ContextPreferences(context: Context(id: UUID(), case: .social), metersWillingToTravel: 1, allowedGreetingMethods: [], isMeetEnabled: true)
        ]

        XCTAssertEqual(settings.greetingMethodText(for: .social), "wave")
    }

    func testGreetingMethodText_exactlyOneReturnsItsRawValue() {
        var settings = Settings()
        settings.contextPreferences = [
            ContextPreferences(context: Context(id: UUID(), case: .social), metersWillingToTravel: 1, allowedGreetingMethods: [.hug], isMeetEnabled: true)
        ]

        XCTAssertEqual(settings.greetingMethodText(for: .social), "hug")
    }

    func testGreetingMethodText_multipleReturnsMultiple() {
        var settings = Settings()
        settings.contextPreferences = [
            ContextPreferences(context: Context(id: UUID(), case: .social), metersWillingToTravel: 1, allowedGreetingMethods: [.hug, .kiss], isMeetEnabled: true)
        ]

        XCTAssertEqual(settings.greetingMethodText(for: .social), "Multiple")
    }

    func testHasContext_requiresExactContextIdentity() {
        let context = Context(id: UUID(), case: .social)
        var settings = Settings()
        settings.contextPreferences = [
            ContextPreferences(context: context, metersWillingToTravel: 1, allowedGreetingMethods: [], isMeetEnabled: true)
        ]

        XCTAssertTrue(settings.has(context))
        // A different Context instance (different id), even with the same case, does not match.
        XCTAssertFalse(settings.has(Context(id: UUID(), case: .social)))
    }

    func testHasMethodForContext() {
        var settings = Settings()
        settings.contextPreferences = [
            ContextPreferences(context: Context(id: UUID(), case: .social), metersWillingToTravel: 1, allowedGreetingMethods: [.hug], isMeetEnabled: true)
        ]

        XCTAssertTrue(settings.has(method: .hug, for: .social))
        XCTAssertFalse(settings.has(method: .wave, for: .social))
    }

    func testContextText_bothOnOneOnBothOff() {
        var settings = Settings()
        settings.contextPreferences = [
            ContextPreferences(context: Context(id: UUID(), case: .romance), metersWillingToTravel: 1, allowedGreetingMethods: [], isMeetEnabled: true),
            ContextPreferences(context: Context(id: UUID(), case: .social), metersWillingToTravel: 1, allowedGreetingMethods: [], isMeetEnabled: true),
        ]
        XCTAssertEqual(settings.contextText, "Both on")

        settings.contextPreferences[1].isMeetEnabled = false
        XCTAssertEqual(settings.contextText, "romance on")

        settings.contextPreferences[0].isMeetEnabled = false
        XCTAssertEqual(settings.contextText, "Both off")
    }

    func testArrayGreetMethodUpdate_togglesMembership() {
        var methods: [Greet.Method] = []

        methods.update(with: .wave)
        XCTAssertEqual(methods, [.wave])

        methods.update(with: .wave)
        XCTAssertEqual(methods, [])
    }

    func testSettingsCodableRoundTrip() throws {
        var settings = Settings(email: "e@x.com", cloudflareProfileImageURL: "img", userID: UUID())
        settings.phone = "555-1000"
        settings.firstName = "Grace"
        settings.lastName = "Hopper"
        settings.dob = Date(timeIntervalSince1970: 1700000000)
        settings.birthday = DateComponents(year: 1990, month: 1, day: 1)
        settings.contextPreferences = [
            ContextPreferences(context: Context(id: UUID(), case: .romance), metersWillingToTravel: 100, allowedGreetingMethods: [.wave], isMeetEnabled: true)
        ]

        let data = try JSONEncoder().encode(settings)
        let decoded = try JSONDecoder().decode(Settings.self, from: data)

        XCTAssertEqual(decoded.emailPrimary, settings.emailPrimary)
        XCTAssertEqual(decoded.cloudflareProfileImageURL, settings.cloudflareProfileImageURL)
        XCTAssertEqual(decoded.vibrate, settings.vibrate)
        XCTAssertEqual(decoded.ring, settings.ring)
        XCTAssertEqual(decoded.userID, settings.userID)
        XCTAssertEqual(decoded.phone, settings.phone)
        XCTAssertEqual(decoded.firstName, settings.firstName)
        XCTAssertEqual(decoded.lastName, settings.lastName)
        XCTAssertEqual(decoded.dob, settings.dob)
        XCTAssertEqual(decoded.birthday, settings.birthday)
        XCTAssertEqual(decoded.contextPreferences, settings.contextPreferences)
    }

    func testSettingsSharedStaticVarIsSettableAndReadable() {
        let original = Settings.shared
        defer { Settings.shared = original }

        var settings = Settings()
        settings.firstName = "Static"
        Settings.shared = settings
        XCTAssertEqual(Settings.shared?.firstName, "Static")

        Settings.shared = nil
        XCTAssertNil(Settings.shared)
    }
}
