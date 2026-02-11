import XCTest
@testable import AkinFrontBackModels

struct GreetDetailsInputOutput {
    let this: Greet.Update.Status
    let otherUser: Greet.Update.Status?
    let withinRange: Bool
    let rejectedProposal: Int?
    let viewForProposal: ViewSetting
    let otherUserName: String

    let output: Greet.Update

    var greetUpdate: Greet.Update {
        return Greet.Update(
            this: this,
            otherUser: otherUser,
            withinRange: withinRange,
            rejectedProposal: rejectedProposal,
            viewForProposal: viewForProposal,
            otherUserName: otherUserName
        )
    }

    var passes: Bool {
        return greetUpdate == output
    }
}

final class FrontBackModelsTests: XCTestCase {

    let zeroEvent: GreetEvent = GreetEvent(eventID: .init(), serverSequenceNumber: 0, actorUserID: .init(), serverDate: Date(), action: .agreedToMeet(30))
    let oneEvent: GreetEvent = GreetEvent(eventID: .init(), serverSequenceNumber: 1, actorUserID: .init(), serverDate: Date(), action: .agreedToMeet(30))
    let twoEvent: GreetEvent = GreetEvent(eventID: .init(), serverSequenceNumber: 2, actorUserID: .init(), serverDate: Date(), action: .agreedToMeet(30))
    let threeEvent: GreetEvent = GreetEvent(eventID: .init(), serverSequenceNumber: 3, actorUserID: .init(), serverDate: Date(), action: .agreedToMeet(30))
    let fourEvent: GreetEvent = GreetEvent(eventID: .init(), serverSequenceNumber: 4, actorUserID: .init(), serverDate: Date(), action: .agreedToMeet(30))
    let fiveEvent: GreetEvent = GreetEvent(eventID: .init(), serverSequenceNumber: 5, actorUserID: .init(), serverDate: Date(), action: .agreedToMeet(30))
    let sixEvent: GreetEvent = GreetEvent(eventID: .init(), serverSequenceNumber: 6, actorUserID: .init(), serverDate: Date(), action: .agreedToMeet(30))
    let sevenEvent: GreetEvent = GreetEvent(eventID: .init(), serverSequenceNumber: 7, actorUserID: .init(), serverDate: Date(), action: .agreedToMeet(30))

    func testEventsAreValid() {
        let invalidEvents: [GreetEvent] = [zeroEvent, zeroEvent]
        XCTAssertFalse(invalidEvents.isValid)
    }

    func testEventsAreValid2() {
        let invalidEvents: [GreetEvent] = [zeroEvent, zeroEvent, twoEvent]
        XCTAssertFalse(invalidEvents.isValid)
    }

    func testEventsAreValid3() {
        let invalidEvents: [GreetEvent] = [zeroEvent, zeroEvent, threeEvent, threeEvent]
        XCTAssertFalse(invalidEvents.isValid)
    }

    func testValidEvents() {
        let validEvents: [GreetEvent] = [zeroEvent, oneEvent, twoEvent]
        XCTAssertTrue(validEvents.isValid)
    }

    func testValidEvents2() {
        let validEvents: [GreetEvent] = []
        XCTAssertTrue(validEvents.isValid)
    }

    func testValidEvents3() {
        let validEvents: [GreetEvent] = [oneEvent, twoEvent, zeroEvent]
        XCTAssertTrue(validEvents.isValid)
    }

    public func testExample() throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods

        print(ModerationAssessment.exampleJSONString)
    
    }

    func testWholePrompt() throws {
        print(String.moderationPromptFormatIntro)
        XCTAssertFalse(String.moderationPromptFormatIntro.contains("\\"), .moderationPromptFormatIntro)
    }

    static var otherName: String { "Tom" }


    var greetDetailsInputsOutputs: [GreetDetailsInputOutput] = [
        GreetDetailsInputOutput(
            this: .exceededRange,
            otherUser: .exceededRange,
            withinRange: true,
            rejectedProposal: 0,
            viewForProposal: .start,
            otherUserName: otherName,
            output: .exitReason(.exceededRange(.my))
        ),
        GreetDetailsInputOutput(
            this: .exceededRange,
            otherUser: nil,
            withinRange: true,
            rejectedProposal: 0,
            viewForProposal: .start,
            otherUserName: otherName,
            output: .exitReason(.exceededRange(.my))
        ),
        GreetDetailsInputOutput(
            this: .exceededRange,
            otherUser: nil,
            withinRange: true,
            rejectedProposal: 0,
            viewForProposal: .otherAskedIfCanMeetLater(30),
            otherUserName: otherName,
            output: .exitReason(.exceededRange(.my))
        ),
        GreetDetailsInputOutput(
            this: .exceededRange,
            otherUser: nil,
            withinRange: true,
            rejectedProposal: 30,
            viewForProposal: .start,
            otherUserName: otherName,
            output: .exitReason(.exceededRange(.my))
        ),
        GreetDetailsInputOutput(
            this: .exceededRange,
            otherUser: nil,
            withinRange: true,
            rejectedProposal: 30,
            viewForProposal: .otherAskedIfCanMeetLater(30),
            otherUserName: otherName,
            output: .exitReason(.exceededRange(.my))
        ),
        GreetDetailsInputOutput(
            this: .exceededRange,
            otherUser: nil,
            withinRange: true,
            rejectedProposal: nil,
            viewForProposal: .start,
            otherUserName: otherName,
            output: .exitReason(.exceededRange(.my))
        ),
        GreetDetailsInputOutput(
            this: .exceededRange,
            otherUser: nil,
            withinRange: true,
            rejectedProposal: nil,
            viewForProposal: .otherAskedIfCanMeetLater(30),
            otherUserName: otherName,
            output: .exitReason(.exceededRange(.my))
        ),
        GreetDetailsInputOutput(
            this: .exceededRange,
            otherUser: nil,
            withinRange: false,
            rejectedProposal: 0,
            viewForProposal: .start,
            otherUserName: otherName,
            output: .exitReason(.exceededRange(.my))
        ),
        GreetDetailsInputOutput(
            this: .exceededRange,
            otherUser: nil,
            withinRange: false,
            rejectedProposal: 0,
            viewForProposal: .otherAskedIfCanMeetLater(30),
            otherUserName: otherName,
            output: .exitReason(.exceededRange(.my))
        ),
        GreetDetailsInputOutput(
            this: .exceededRange,
            otherUser: nil,
            withinRange: false,
            rejectedProposal: 30,
            viewForProposal: .start,
            otherUserName: otherName,
            output: .exitReason(.exceededRange(.my))
        ),
        GreetDetailsInputOutput(
            this: .exceededRange,
            otherUser: nil,
            withinRange: false,
            rejectedProposal: 30,
            viewForProposal: .otherAskedIfCanMeetLater(30),
            otherUserName: otherName,
            output: .exitReason(.exceededRange(.my))
        ),
        GreetDetailsInputOutput(
            this: .exceededRange,
            otherUser: nil,
            withinRange: false,
            rejectedProposal: nil,
            viewForProposal: .start,
            otherUserName: otherName,
            output: .exitReason(.exceededRange(.my))
        ),
        GreetDetailsInputOutput(
            this: .exceededRange,
            otherUser: nil,
            withinRange: false,
            rejectedProposal: nil,
            viewForProposal: .otherAskedIfCanMeetLater(30),
            otherUserName: otherName,
            output: .exitReason(.exceededRange(.my))
        ),
        GreetDetailsInputOutput(
            this: .rejectedOther, otherUser: nil, withinRange: true, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: nil, withinRange: true, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: nil, withinRange: true, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: nil, withinRange: true, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: nil, withinRange: true, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: nil, withinRange: true, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: nil, withinRange: false, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: nil, withinRange: false, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: nil, withinRange: false, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: nil, withinRange: false, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: nil, withinRange: false, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: nil, withinRange: false, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.my))),


        GreetDetailsInputOutput(this: .enroute, otherUser: nil, withinRange: true, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("if the other user is nil, this user should not be enroute")),
        GreetDetailsInputOutput(this: .enroute, otherUser: nil, withinRange: true, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("if the other user is nil, this user should not be enroute")),
        GreetDetailsInputOutput(this: .enroute, otherUser: nil, withinRange: true, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("if the other user is nil, this user should not be enroute")),
        GreetDetailsInputOutput(this: .enroute, otherUser: nil, withinRange: true, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("if the other user is nil, this user should not be enroute")),
        GreetDetailsInputOutput(this: .enroute, otherUser: nil, withinRange: true, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("if the other user is nil, this user should not be enroute")),
        GreetDetailsInputOutput(this: .enroute, otherUser: nil, withinRange: true, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("if the other user is nil, this user should not be enroute")),
        GreetDetailsInputOutput(this: .enroute, otherUser: nil, withinRange: false, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("if the other user is nil, this user should not be enroute")),
        GreetDetailsInputOutput(this: .enroute, otherUser: nil, withinRange: false, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("if the other user is nil, this user should not be enroute")),
        GreetDetailsInputOutput(this: .enroute, otherUser: nil, withinRange: false, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("if the other user is nil, this user should not be enroute")),
        GreetDetailsInputOutput(this: .enroute, otherUser: nil, withinRange: false, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("if the other user is nil, this user should not be enroute")),
        GreetDetailsInputOutput(this: .enroute, otherUser: nil, withinRange: false, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("if the other user is nil, this user should not be enroute")),
        GreetDetailsInputOutput(this: .enroute, otherUser: nil, withinRange: false, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("if the other user is nil, this user should not be enroute")),

        GreetDetailsInputOutput(this: .viewed, otherUser: nil, withinRange: true, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .viewSetting(.start)),
        GreetDetailsInputOutput(this: .viewed, otherUser: nil, withinRange: true, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .viewSetting(.otherAskedIfCanMeetLater(30))),
        GreetDetailsInputOutput(this: .viewed, otherUser: nil, withinRange: true, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .viewSetting(.start)),
        GreetDetailsInputOutput(this: .viewed, otherUser: nil, withinRange: true, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .viewSetting(.otherAskedIfCanMeetLater(30))),
        GreetDetailsInputOutput(this: .viewed, otherUser: nil, withinRange: true, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .viewSetting(.start)),
        GreetDetailsInputOutput(this: .viewed, otherUser: nil, withinRange: true, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .viewSetting(.otherAskedIfCanMeetLater(30))),
        GreetDetailsInputOutput(this: .viewed, otherUser: nil, withinRange: false, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .viewSetting(.start)),
        GreetDetailsInputOutput(this: .viewed, otherUser: nil, withinRange: false, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .viewSetting(.otherAskedIfCanMeetLater(30))),
        GreetDetailsInputOutput(this: .viewed, otherUser: nil, withinRange: false, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .viewSetting(.start)),
        GreetDetailsInputOutput(this: .viewed, otherUser: nil, withinRange: false, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .viewSetting(.otherAskedIfCanMeetLater(30))),
        GreetDetailsInputOutput(this: .viewed, otherUser: nil, withinRange: false, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .viewSetting(.start)),
        GreetDetailsInputOutput(this: .viewed, otherUser: nil, withinRange: false, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .viewSetting(.otherAskedIfCanMeetLater(30))),


        GreetDetailsInputOutput(this: .confirmedMet, otherUser: nil, withinRange: true, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("If this user is confirming that both met, how can the other user be nil?")),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: nil, withinRange: true, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("If this user is confirming that both met, how can the other user be nil?")),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: nil, withinRange: true, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("If this user is confirming that both met, how can the other user be nil?")),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: nil, withinRange: true, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("If this user is confirming that both met, how can the other user be nil?")),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: nil, withinRange: true, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("If this user is confirming that both met, how can the other user be nil?")),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: nil, withinRange: true, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("If this user is confirming that both met, how can the other user be nil?")),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: nil, withinRange: false, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("If this user is confirming that both met, how can the other user be nil?")),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: nil, withinRange: false, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("If this user is confirming that both met, how can the other user be nil?")),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: nil, withinRange: false, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("If this user is confirming that both met, how can the other user be nil?")),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: nil, withinRange: false, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("If this user is confirming that both met, how can the other user be nil?")),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: nil, withinRange: false, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("If this user is confirming that both met, how can the other user be nil?")),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: nil, withinRange: false, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("If this user is confirming that both met, how can the other user be nil?")),


        GreetDetailsInputOutput(this: .exceededRange, otherUser: .exceededRange, withinRange: true, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.exceededRange(.my))),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .exceededRange, withinRange: true, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.exceededRange(.my))),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .exceededRange, withinRange: true, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.exceededRange(.my))),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .exceededRange, withinRange: true, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.exceededRange(.my))),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .exceededRange, withinRange: true, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.exceededRange(.my))),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .exceededRange, withinRange: true, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.exceededRange(.my))),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .exceededRange, withinRange: false, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.exceededRange(.my))),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .exceededRange, withinRange: false, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.exceededRange(.my))),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .exceededRange, withinRange: false, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.exceededRange(.my))),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .exceededRange, withinRange: false, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.exceededRange(.my))),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .exceededRange, withinRange: false, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.exceededRange(.my))),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .exceededRange, withinRange: false, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.exceededRange(.my))),

        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .exceededRange, withinRange: true, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .exceededRange, withinRange: true, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .exceededRange, withinRange: true, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .exceededRange, withinRange: true, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .exceededRange, withinRange: true, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .exceededRange, withinRange: true, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .exceededRange, withinRange: false, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .exceededRange, withinRange: false, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .exceededRange, withinRange: false, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .exceededRange, withinRange: false, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .exceededRange, withinRange: false, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .exceededRange, withinRange: false, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.my))),


        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .rejectedOther, withinRange: true, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .rejectedOther, withinRange: true, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .rejectedOther, withinRange: true, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .rejectedOther, withinRange: true, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .rejectedOther, withinRange: true, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .rejectedOther, withinRange: true, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .rejectedOther, withinRange: false, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .rejectedOther, withinRange: false, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .rejectedOther, withinRange: false, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .rejectedOther, withinRange: false, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .rejectedOther, withinRange: false, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .rejectedOther, withinRange: false, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.my))),



        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .enroute, withinRange: true, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .enroute, withinRange: true, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .enroute, withinRange: true, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .enroute, withinRange: true, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .enroute, withinRange: true, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .enroute, withinRange: true, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .enroute, withinRange: false, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .enroute, withinRange: false, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .enroute, withinRange: false, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .enroute, withinRange: false, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .enroute, withinRange: false, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .enroute, withinRange: false, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.my))),




        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .viewed, withinRange: true, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .viewed, withinRange: true, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .viewed, withinRange: true, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .viewed, withinRange: true, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .viewed, withinRange: true, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .viewed, withinRange: true, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .viewed, withinRange: false, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .viewed, withinRange: false, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .viewed, withinRange: false, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .viewed, withinRange: false, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .viewed, withinRange: false, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .viewed, withinRange: false, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.my))),



        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .confirmedMet, withinRange: true, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .confirmedMet, withinRange: true, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .confirmedMet, withinRange: true, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .confirmedMet, withinRange: true, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .confirmedMet, withinRange: true, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .confirmedMet, withinRange: true, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .confirmedMet, withinRange: false, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .confirmedMet, withinRange: false, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .confirmedMet, withinRange: false, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .confirmedMet, withinRange: false, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .confirmedMet, withinRange: false, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.my))),
        GreetDetailsInputOutput(this: .rejectedOther, otherUser: .confirmedMet, withinRange: false, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.my))),


        GreetDetailsInputOutput(this: .enroute, otherUser: .exceededRange, withinRange: true, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.exceededRange(.their))),
        GreetDetailsInputOutput(this: .enroute, otherUser: .exceededRange, withinRange: true, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.exceededRange(.their))),
        GreetDetailsInputOutput(this: .enroute, otherUser: .exceededRange, withinRange: true, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.exceededRange(.their))),
        GreetDetailsInputOutput(this: .enroute, otherUser: .exceededRange, withinRange: true, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.exceededRange(.their))),
        GreetDetailsInputOutput(this: .enroute, otherUser: .exceededRange, withinRange: true, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.exceededRange(.their))),
        GreetDetailsInputOutput(this: .enroute, otherUser: .exceededRange, withinRange: true, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.exceededRange(.their))),
        GreetDetailsInputOutput(this: .enroute, otherUser: .exceededRange, withinRange: false, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.exceededRange(.their))),
        GreetDetailsInputOutput(this: .enroute, otherUser: .exceededRange, withinRange: false, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.exceededRange(.their))),
        GreetDetailsInputOutput(this: .enroute, otherUser: .exceededRange, withinRange: false, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.exceededRange(.their))),
        GreetDetailsInputOutput(this: .enroute, otherUser: .exceededRange, withinRange: false, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.exceededRange(.their))),
        GreetDetailsInputOutput(this: .enroute, otherUser: .exceededRange, withinRange: false, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.exceededRange(.their))),
        GreetDetailsInputOutput(this: .enroute, otherUser: .exceededRange, withinRange: false, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.exceededRange(.their))),

        GreetDetailsInputOutput(this: .viewed, otherUser: .exceededRange, withinRange: true, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.exceededRange(.their))),
        GreetDetailsInputOutput(this: .viewed, otherUser: .exceededRange, withinRange: true, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.exceededRange(.their))),
        GreetDetailsInputOutput(this: .viewed, otherUser: .exceededRange, withinRange: true, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.exceededRange(.their))),
        GreetDetailsInputOutput(this: .viewed, otherUser: .exceededRange, withinRange: true, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.exceededRange(.their))),
        GreetDetailsInputOutput(this: .viewed, otherUser: .exceededRange, withinRange: true, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.exceededRange(.their))),
        GreetDetailsInputOutput(this: .viewed, otherUser: .exceededRange, withinRange: true, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.exceededRange(.their))),
        GreetDetailsInputOutput(this: .viewed, otherUser: .exceededRange, withinRange: false, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.exceededRange(.their))),
        GreetDetailsInputOutput(this: .viewed, otherUser: .exceededRange, withinRange: false, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.exceededRange(.their))),
        GreetDetailsInputOutput(this: .viewed, otherUser: .exceededRange, withinRange: false, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.exceededRange(.their))),
        GreetDetailsInputOutput(this: .viewed, otherUser: .exceededRange, withinRange: false, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.exceededRange(.their))),
        GreetDetailsInputOutput(this: .viewed, otherUser: .exceededRange, withinRange: false, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.exceededRange(.their))),
        GreetDetailsInputOutput(this: .viewed, otherUser: .exceededRange, withinRange: false, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.exceededRange(.their))),


        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .exceededRange, withinRange: true, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("exceededRange can only happen prior to both user's agreeing to meet.")),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .exceededRange, withinRange: true, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("exceededRange can only happen prior to both user's agreeing to meet.")),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .exceededRange, withinRange: true, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("exceededRange can only happen prior to both user's agreeing to meet.")),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .exceededRange, withinRange: true, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("exceededRange can only happen prior to both user's agreeing to meet.")),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .exceededRange, withinRange: true, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("exceededRange can only happen prior to both user's agreeing to meet.")),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .exceededRange, withinRange: true, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("exceededRange can only happen prior to both user's agreeing to meet.")),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .exceededRange, withinRange: false, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("exceededRange can only happen prior to both user's agreeing to meet.")),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .exceededRange, withinRange: false, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("exceededRange can only happen prior to both user's agreeing to meet.")),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .exceededRange, withinRange: false, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("exceededRange can only happen prior to both user's agreeing to meet.")),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .exceededRange, withinRange: false, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("exceededRange can only happen prior to both user's agreeing to meet.")),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .exceededRange, withinRange: false, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("exceededRange can only happen prior to both user's agreeing to meet.")),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .exceededRange, withinRange: false, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("exceededRange can only happen prior to both user's agreeing to meet.")),



        GreetDetailsInputOutput(this: .exceededRange, otherUser: .rejectedOther, withinRange: true, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.exceededRange(.my))),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .rejectedOther, withinRange: true, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.exceededRange(.my))),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .rejectedOther, withinRange: true, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.exceededRange(.my))),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .rejectedOther, withinRange: true, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.exceededRange(.my))),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .rejectedOther, withinRange: true, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.exceededRange(.my))),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .rejectedOther, withinRange: true, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.exceededRange(.my))),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .rejectedOther, withinRange: false, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.exceededRange(.my))),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .rejectedOther, withinRange: false, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.exceededRange(.my))),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .rejectedOther, withinRange: false, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.exceededRange(.my))),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .rejectedOther, withinRange: false, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.exceededRange(.my))),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .rejectedOther, withinRange: false, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.exceededRange(.my))),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .rejectedOther, withinRange: false, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.exceededRange(.my))),




        GreetDetailsInputOutput(this: .enroute, otherUser: .rejectedOther, withinRange: true, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.their))),
        GreetDetailsInputOutput(this: .enroute, otherUser: .rejectedOther, withinRange: true, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.their))),
        GreetDetailsInputOutput(this: .enroute, otherUser: .rejectedOther, withinRange: true, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.their))),
        GreetDetailsInputOutput(this: .enroute, otherUser: .rejectedOther, withinRange: true, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.their))),
        GreetDetailsInputOutput(this: .enroute, otherUser: .rejectedOther, withinRange: true, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.their))),
        GreetDetailsInputOutput(this: .enroute, otherUser: .rejectedOther, withinRange: true, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.their))),
        GreetDetailsInputOutput(this: .enroute, otherUser: .rejectedOther, withinRange: false, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.their))),
        GreetDetailsInputOutput(this: .enroute, otherUser: .rejectedOther, withinRange: false, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.their))),
        GreetDetailsInputOutput(this: .enroute, otherUser: .rejectedOther, withinRange: false, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.their))),
        GreetDetailsInputOutput(this: .enroute, otherUser: .rejectedOther, withinRange: false, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.their))),
        GreetDetailsInputOutput(this: .enroute, otherUser: .rejectedOther, withinRange: false, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.their))),
        GreetDetailsInputOutput(this: .enroute, otherUser: .rejectedOther, withinRange: false, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.their))),



        GreetDetailsInputOutput(this: .viewed, otherUser: .rejectedOther, withinRange: true, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.their))),
        GreetDetailsInputOutput(this: .viewed, otherUser: .rejectedOther, withinRange: true, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.their))),
        GreetDetailsInputOutput(this: .viewed, otherUser: .rejectedOther, withinRange: true, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.their))),
        GreetDetailsInputOutput(this: .viewed, otherUser: .rejectedOther, withinRange: true, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.their))),
        GreetDetailsInputOutput(this: .viewed, otherUser: .rejectedOther, withinRange: true, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.their))),
        GreetDetailsInputOutput(this: .viewed, otherUser: .rejectedOther, withinRange: true, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.their))),
        GreetDetailsInputOutput(this: .viewed, otherUser: .rejectedOther, withinRange: false, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.their))),
        GreetDetailsInputOutput(this: .viewed, otherUser: .rejectedOther, withinRange: false, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.their))),
        GreetDetailsInputOutput(this: .viewed, otherUser: .rejectedOther, withinRange: false, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.their))),
        GreetDetailsInputOutput(this: .viewed, otherUser: .rejectedOther, withinRange: false, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.their))),
        GreetDetailsInputOutput(this: .viewed, otherUser: .rejectedOther, withinRange: false, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.rejected(.their))),
        GreetDetailsInputOutput(this: .viewed, otherUser: .rejectedOther, withinRange: false, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.rejected(.their))),





        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .rejectedOther, withinRange: true, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("if other user rejected, should exit before this user can confirm met.  If confirmed met, it shoudl have navigated away from GreetVC")),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .rejectedOther, withinRange: true, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("if other user rejected, should exit before this user can confirm met.  If confirmed met, it shoudl have navigated away from GreetVC")),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .rejectedOther, withinRange: true, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("if other user rejected, should exit before this user can confirm met.  If confirmed met, it shoudl have navigated away from GreetVC")),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .rejectedOther, withinRange: true, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("if other user rejected, should exit before this user can confirm met.  If confirmed met, it shoudl have navigated away from GreetVC")),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .rejectedOther, withinRange: true, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("if other user rejected, should exit before this user can confirm met.  If confirmed met, it shoudl have navigated away from GreetVC")),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .rejectedOther, withinRange: true, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("if other user rejected, should exit before this user can confirm met.  If confirmed met, it shoudl have navigated away from GreetVC")),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .rejectedOther, withinRange: false, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("if other user rejected, should exit before this user can confirm met.  If confirmed met, it shoudl have navigated away from GreetVC")),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .rejectedOther, withinRange: false, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("if other user rejected, should exit before this user can confirm met.  If confirmed met, it shoudl have navigated away from GreetVC")),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .rejectedOther, withinRange: false, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("if other user rejected, should exit before this user can confirm met.  If confirmed met, it shoudl have navigated away from GreetVC")),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .rejectedOther, withinRange: false, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("if other user rejected, should exit before this user can confirm met.  If confirmed met, it shoudl have navigated away from GreetVC")),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .rejectedOther, withinRange: false, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("if other user rejected, should exit before this user can confirm met.  If confirmed met, it shoudl have navigated away from GreetVC")),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .rejectedOther, withinRange: false, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("if other user rejected, should exit before this user can confirm met.  If confirmed met, it shoudl have navigated away from GreetVC")),



        GreetDetailsInputOutput(this: .exceededRange, otherUser: .enroute, withinRange: true, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("impossible, report to mustafa, exceeded range can only occur when viewing or none.")),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .enroute, withinRange: true, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("impossible, report to mustafa, exceeded range can only occur when viewing or none.")),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .enroute, withinRange: true, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("impossible, report to mustafa, exceeded range can only occur when viewing or none.")),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .enroute, withinRange: true, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("impossible, report to mustafa, exceeded range can only occur when viewing or none.")),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .enroute, withinRange: true, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("impossible, report to mustafa, exceeded range can only occur when viewing or none.")),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .enroute, withinRange: true, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("impossible, report to mustafa, exceeded range can only occur when viewing or none.")),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .enroute, withinRange: false, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("impossible, report to mustafa, exceeded range can only occur when viewing or none.")),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .enroute, withinRange: false, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("impossible, report to mustafa, exceeded range can only occur when viewing or none.")),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .enroute, withinRange: false, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("impossible, report to mustafa, exceeded range can only occur when viewing or none.")),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .enroute, withinRange: false, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("impossible, report to mustafa, exceeded range can only occur when viewing or none.")),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .enroute, withinRange: false, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("impossible, report to mustafa, exceeded range can only occur when viewing or none.")),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .enroute, withinRange: false, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("impossible, report to mustafa, exceeded range can only occur when viewing or none.")),



        GreetDetailsInputOutput(this: .enroute, otherUser: .enroute, withinRange: true, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .message(.youAreCloseTo(otherName))),
        GreetDetailsInputOutput(this: .enroute, otherUser: .enroute, withinRange: true, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .message(.youAreCloseTo(otherName))),
        GreetDetailsInputOutput(this: .enroute, otherUser: .enroute, withinRange: true, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .message(.youAreCloseTo(otherName))),
        GreetDetailsInputOutput(this: .enroute, otherUser: .enroute, withinRange: true, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .message(.youAreCloseTo(otherName))),
        GreetDetailsInputOutput(this: .enroute, otherUser: .enroute, withinRange: true, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .message(.youAreCloseTo(otherName))),
        GreetDetailsInputOutput(this: .enroute, otherUser: .enroute, withinRange: true, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .message(.youAreCloseTo(otherName))),

        GreetDetailsInputOutput(this: .enroute, otherUser: .enroute, withinRange: false, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .viewSetting(.inGreet)),
        GreetDetailsInputOutput(this: .enroute, otherUser: .enroute, withinRange: false, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .viewSetting(.inGreet)),
        GreetDetailsInputOutput(this: .enroute, otherUser: .enroute, withinRange: false, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .viewSetting(.inGreet)),
        GreetDetailsInputOutput(this: .enroute, otherUser: .enroute, withinRange: false, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .viewSetting(.inGreet)),
        GreetDetailsInputOutput(this: .enroute, otherUser: .enroute, withinRange: false, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .viewSetting(.inGreet)),
        GreetDetailsInputOutput(this: .enroute, otherUser: .enroute, withinRange: false, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .viewSetting(.inGreet)),


        GreetDetailsInputOutput(this: .viewed, otherUser: .enroute, withinRange: true, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("impossible")),
        GreetDetailsInputOutput(this: .viewed, otherUser: .enroute, withinRange: true, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("impossible")),
        GreetDetailsInputOutput(this: .viewed, otherUser: .enroute, withinRange: true, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("impossible")),
        GreetDetailsInputOutput(this: .viewed, otherUser: .enroute, withinRange: true, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("impossible")),
        GreetDetailsInputOutput(this: .viewed, otherUser: .enroute, withinRange: true, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("impossible")),
        GreetDetailsInputOutput(this: .viewed, otherUser: .enroute, withinRange: true, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("impossible")),
        GreetDetailsInputOutput(this: .viewed, otherUser: .enroute, withinRange: false, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("impossible")),
        GreetDetailsInputOutput(this: .viewed, otherUser: .enroute, withinRange: false, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("impossible")),
        GreetDetailsInputOutput(this: .viewed, otherUser: .enroute, withinRange: false, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("impossible")),
        GreetDetailsInputOutput(this: .viewed, otherUser: .enroute, withinRange: false, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("impossible")),
        GreetDetailsInputOutput(this: .viewed, otherUser: .enroute, withinRange: false, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("impossible")),
        GreetDetailsInputOutput(this: .viewed, otherUser: .enroute, withinRange: false, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("impossible")),


        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .enroute, withinRange: true, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.thisConfirmedMet)),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .enroute, withinRange: true, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.thisConfirmedMet)),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .enroute, withinRange: true, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.thisConfirmedMet)),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .enroute, withinRange: true, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.thisConfirmedMet)),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .enroute, withinRange: true, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.thisConfirmedMet)),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .enroute, withinRange: true, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.thisConfirmedMet)),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .enroute, withinRange: false, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.thisConfirmedMet)),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .enroute, withinRange: false, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.thisConfirmedMet)),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .enroute, withinRange: false, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.thisConfirmedMet)),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .enroute, withinRange: false, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.thisConfirmedMet)),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .enroute, withinRange: false, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.thisConfirmedMet)),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .enroute, withinRange: false, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.thisConfirmedMet)),


        GreetDetailsInputOutput(this: .exceededRange, otherUser: .viewed, withinRange: true, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.exceededRange(.my))),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .viewed, withinRange: true, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.exceededRange(.my))),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .viewed, withinRange: true, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.exceededRange(.my))),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .viewed, withinRange: true, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.exceededRange(.my))),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .viewed, withinRange: true, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.exceededRange(.my))),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .viewed, withinRange: true, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.exceededRange(.my))),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .viewed, withinRange: false, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.exceededRange(.my))),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .viewed, withinRange: false, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.exceededRange(.my))),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .viewed, withinRange: false, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.exceededRange(.my))),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .viewed, withinRange: false, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.exceededRange(.my))),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .viewed, withinRange: false, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.exceededRange(.my))),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .viewed, withinRange: false, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.exceededRange(.my))),




        GreetDetailsInputOutput(this: .enroute, otherUser: .viewed, withinRange: true, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("impossible")),
        GreetDetailsInputOutput(this: .enroute, otherUser: .viewed, withinRange: true, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("impossible")),
        GreetDetailsInputOutput(this: .enroute, otherUser: .viewed, withinRange: true, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("impossible")),
        GreetDetailsInputOutput(this: .enroute, otherUser: .viewed, withinRange: true, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("impossible")),
        GreetDetailsInputOutput(this: .enroute, otherUser: .viewed, withinRange: true, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("impossible")),
        GreetDetailsInputOutput(this: .enroute, otherUser: .viewed, withinRange: true, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("impossible")),
        GreetDetailsInputOutput(this: .enroute, otherUser: .viewed, withinRange: false, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("impossible")),
        GreetDetailsInputOutput(this: .enroute, otherUser: .viewed, withinRange: false, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("impossible")),
        GreetDetailsInputOutput(this: .enroute, otherUser: .viewed, withinRange: false, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("impossible")),
        GreetDetailsInputOutput(this: .enroute, otherUser: .viewed, withinRange: false, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("impossible")),
        GreetDetailsInputOutput(this: .enroute, otherUser: .viewed, withinRange: false, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("impossible")),
        GreetDetailsInputOutput(this: .enroute, otherUser: .viewed, withinRange: false, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("impossible")),


        GreetDetailsInputOutput(this: .viewed, otherUser: .viewed, withinRange: true, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .message(.cant(0))),
        GreetDetailsInputOutput(this: .viewed, otherUser: .viewed, withinRange: true, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .message(.cant(0))),
        GreetDetailsInputOutput(this: .viewed, otherUser: .viewed, withinRange: true, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .message(.cant(30))),
        GreetDetailsInputOutput(this: .viewed, otherUser: .viewed, withinRange: true, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .message(.cant(30))),
        GreetDetailsInputOutput(this: .viewed, otherUser: .viewed, withinRange: true, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .viewSetting(.start)),
        GreetDetailsInputOutput(this: .viewed, otherUser: .viewed, withinRange: true, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .viewSetting(.otherAskedIfCanMeetLater(30))),
        GreetDetailsInputOutput(this: .viewed, otherUser: .viewed, withinRange: false, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .message(.cant(0))),
        GreetDetailsInputOutput(this: .viewed, otherUser: .viewed, withinRange: false, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .message(.cant(0))),
        GreetDetailsInputOutput(this: .viewed, otherUser: .viewed, withinRange: false, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .message(.cant(30))),
        GreetDetailsInputOutput(this: .viewed, otherUser: .viewed, withinRange: false, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .message(.cant(30))),
        GreetDetailsInputOutput(this: .viewed, otherUser: .viewed, withinRange: false, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .viewSetting(.start)),
        GreetDetailsInputOutput(this: .viewed, otherUser: .viewed, withinRange: false, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .viewSetting(.otherAskedIfCanMeetLater(30))),


        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .viewed, withinRange: true, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("in order for this user to confirm meeting the other user, both users would have had to have had enroute status, viewed would be impossible.")),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .viewed, withinRange: true, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("in order for this user to confirm meeting the other user, both users would have had to have had enroute status, viewed would be impossible.")),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .viewed, withinRange: true, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("in order for this user to confirm meeting the other user, both users would have had to have had enroute status, viewed would be impossible.")),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .viewed, withinRange: true, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("in order for this user to confirm meeting the other user, both users would have had to have had enroute status, viewed would be impossible.")),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .viewed, withinRange: true, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("in order for this user to confirm meeting the other user, both users would have had to have had enroute status, viewed would be impossible.")),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .viewed, withinRange: true, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("in order for this user to confirm meeting the other user, both users would have had to have had enroute status, viewed would be impossible.")),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .viewed, withinRange: false, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("in order for this user to confirm meeting the other user, both users would have had to have had enroute status, viewed would be impossible.")),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .viewed, withinRange: false, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("in order for this user to confirm meeting the other user, both users would have had to have had enroute status, viewed would be impossible.")),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .viewed, withinRange: false, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("in order for this user to confirm meeting the other user, both users would have had to have had enroute status, viewed would be impossible.")),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .viewed, withinRange: false, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("in order for this user to confirm meeting the other user, both users would have had to have had enroute status, viewed would be impossible.")),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .viewed, withinRange: false, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("in order for this user to confirm meeting the other user, both users would have had to have had enroute status, viewed would be impossible.")),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .viewed, withinRange: false, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("in order for this user to confirm meeting the other user, both users would have had to have had enroute status, viewed would be impossible.")),


        GreetDetailsInputOutput(this: .exceededRange, otherUser: .confirmedMet, withinRange: true, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("impossible, report to mustafa, exceeded range can only occur when viewing or none.")),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .confirmedMet, withinRange: true, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("impossible, report to mustafa, exceeded range can only occur when viewing or none.")),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .confirmedMet, withinRange: true, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("impossible, report to mustafa, exceeded range can only occur when viewing or none.")),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .confirmedMet, withinRange: true, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("impossible, report to mustafa, exceeded range can only occur when viewing or none.")),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .confirmedMet, withinRange: true, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("impossible, report to mustafa, exceeded range can only occur when viewing or none.")),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .confirmedMet, withinRange: true, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("impossible, report to mustafa, exceeded range can only occur when viewing or none.")),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .confirmedMet, withinRange: false, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("impossible, report to mustafa, exceeded range can only occur when viewing or none.")),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .confirmedMet, withinRange: false, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("impossible, report to mustafa, exceeded range can only occur when viewing or none.")),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .confirmedMet, withinRange: false, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("impossible, report to mustafa, exceeded range can only occur when viewing or none.")),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .confirmedMet, withinRange: false, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("impossible, report to mustafa, exceeded range can only occur when viewing or none.")),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .confirmedMet, withinRange: false, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("impossible, report to mustafa, exceeded range can only occur when viewing or none.")),
        GreetDetailsInputOutput(this: .exceededRange, otherUser: .confirmedMet, withinRange: false, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("impossible, report to mustafa, exceeded range can only occur when viewing or none.")),


        GreetDetailsInputOutput(this: .enroute, otherUser: .confirmedMet, withinRange: true, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .message(.theySayTheyMet(otherName))),
        GreetDetailsInputOutput(this: .enroute, otherUser: .confirmedMet, withinRange: true, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .message(.theySayTheyMet(otherName))),
        GreetDetailsInputOutput(this: .enroute, otherUser: .confirmedMet, withinRange: true, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .message(.theySayTheyMet(otherName))),
        GreetDetailsInputOutput(this: .enroute, otherUser: .confirmedMet, withinRange: true, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .message(.theySayTheyMet(otherName))),
        GreetDetailsInputOutput(this: .enroute, otherUser: .confirmedMet, withinRange: true, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .message(.theySayTheyMet(otherName))),
        GreetDetailsInputOutput(this: .enroute, otherUser: .confirmedMet, withinRange: true, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .message(.theySayTheyMet(otherName))),
        GreetDetailsInputOutput(this: .enroute, otherUser: .confirmedMet, withinRange: false, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .message(.theySayTheyMet(otherName))),
        GreetDetailsInputOutput(this: .enroute, otherUser: .confirmedMet, withinRange: false, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .message(.theySayTheyMet(otherName))),
        GreetDetailsInputOutput(this: .enroute, otherUser: .confirmedMet, withinRange: false, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .message(.theySayTheyMet(otherName))),
        GreetDetailsInputOutput(this: .enroute, otherUser: .confirmedMet, withinRange: false, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .message(.theySayTheyMet(otherName))),
        GreetDetailsInputOutput(this: .enroute, otherUser: .confirmedMet, withinRange: false, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .message(.theySayTheyMet(otherName))),
        GreetDetailsInputOutput(this: .enroute, otherUser: .confirmedMet, withinRange: false, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .message(.theySayTheyMet(otherName))),


        GreetDetailsInputOutput(this: .viewed, otherUser: .confirmedMet, withinRange: true, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("impossible")),
        GreetDetailsInputOutput(this: .viewed, otherUser: .confirmedMet, withinRange: true, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("impossible")),
        GreetDetailsInputOutput(this: .viewed, otherUser: .confirmedMet, withinRange: true, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("impossible")),
        GreetDetailsInputOutput(this: .viewed, otherUser: .confirmedMet, withinRange: true, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("impossible")),
        GreetDetailsInputOutput(this: .viewed, otherUser: .confirmedMet, withinRange: true, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("impossible")),
        GreetDetailsInputOutput(this: .viewed, otherUser: .confirmedMet, withinRange: true, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("impossible")),
        GreetDetailsInputOutput(this: .viewed, otherUser: .confirmedMet, withinRange: false, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("impossible")),
        GreetDetailsInputOutput(this: .viewed, otherUser: .confirmedMet, withinRange: false, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("impossible")),
        GreetDetailsInputOutput(this: .viewed, otherUser: .confirmedMet, withinRange: false, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("impossible")),
        GreetDetailsInputOutput(this: .viewed, otherUser: .confirmedMet, withinRange: false, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("impossible")),
        GreetDetailsInputOutput(this: .viewed, otherUser: .confirmedMet, withinRange: false, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .errorMessage("impossible")),
        GreetDetailsInputOutput(this: .viewed, otherUser: .confirmedMet, withinRange: false, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .errorMessage("impossible")),


        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .confirmedMet, withinRange: true, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.thisConfirmedMet)),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .confirmedMet, withinRange: true, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.thisConfirmedMet)),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .confirmedMet, withinRange: true, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.thisConfirmedMet)),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .confirmedMet, withinRange: true, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.thisConfirmedMet)),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .confirmedMet, withinRange: true, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.thisConfirmedMet)),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .confirmedMet, withinRange: true, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.thisConfirmedMet)),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .confirmedMet, withinRange: false, rejectedProposal: 0, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.thisConfirmedMet)),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .confirmedMet, withinRange: false, rejectedProposal: 0, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.thisConfirmedMet)),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .confirmedMet, withinRange: false, rejectedProposal: 30, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.thisConfirmedMet)),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .confirmedMet, withinRange: false, rejectedProposal: 30, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.thisConfirmedMet)),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .confirmedMet, withinRange: false, rejectedProposal: nil, viewForProposal: .start, otherUserName: otherName, output: .exitReason(.thisConfirmedMet)),
        GreetDetailsInputOutput(this: .confirmedMet, otherUser: .confirmedMet, withinRange: false, rejectedProposal: nil, viewForProposal: .otherAskedIfCanMeetLater(30), otherUserName: otherName, output: .exitReason(.thisConfirmedMet)),

        ]
}
