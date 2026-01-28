//
//  GreetEventsTests.swift
//  AkinFrontBackModels
//
//  Created by Scott Lydon on 1/19/26.
//

import Foundation
import XCTest
@testable import AkinFrontBackModels

class GreetEventsTestsTests: XCTestCase {

    let otherUserID: UUID = .init()
    let greetID: UUID = .init()
    let thisID: UUID = .init()
    let otherName: String = "Jeff Martinov"
    let otherImageURLString = "https://i.pravatar.cc/300"
    let openers: [String] = ["What do you like to do for fun?", "Who is your favorite chess player?"]
    let venue: Venue = .init(url: "", name: "BJs", address: "San mateo", latitude: 37, longitude: -12)

    private var calendar: Calendar {
        Calendar.current
    }

    private var today: Date {
        Date()
    }

    var first: Date { today }
    var second: Date { calendar.date(byAdding: .minute, value: 1, to: today)! }
    var third: Date { calendar.date(byAdding: .minute, value: 2, to: today)! }
    var fourth: Date { calendar.date(byAdding: .minute, value: 3, to: today)! }
    var fifth: Date { calendar.date(byAdding: .minute, value: 4, to: today)! }
    var sixth: Date { calendar.date(byAdding: .minute, value: 5, to: today)! }
    var seventh: Date { calendar.date(byAdding: .minute, value: 6, to: today)! }
    var eighth: Date { calendar.date(byAdding: .minute, value: 7, to: today)! }
    var ninth: Date { calendar.date(byAdding: .minute, value: 8, to: today)! }
    var tenth: Date { calendar.date(byAdding: .minute, value: 9, to: today)! }

    var eleventh: Date { calendar.date(byAdding: .minute, value: 10, to: today)! }
    var twelfth: Date { calendar.date(byAdding: .minute, value: 11, to: today)! }
    var thirteenth: Date { calendar.date(byAdding: .minute, value: 12, to: today)! }
    var fourteenth: Date { calendar.date(byAdding: .minute, value: 13, to: today)! }
    var fifteenth: Date { calendar.date(byAdding: .minute, value: 14, to: today)! }
    var sixteenth: Date { calendar.date(byAdding: .minute, value: 15, to: today)! }
    var seventeenth: Date { calendar.date(byAdding: .minute, value: 16, to: today)! }
    var eighteenth: Date { calendar.date(byAdding: .minute, value: 17, to: today)! }
    var nineteenth: Date { calendar.date(byAdding: .minute, value: 18, to: today)! }
    var twentieth: Date { calendar.date(byAdding: .minute, value: 19, to: today)! }

    var twentyFirst: Date { calendar.date(byAdding: .minute, value: 20, to: today)! }
    var twentySecond: Date { calendar.date(byAdding: .minute, value: 21, to: today)! }
    var twentyThird: Date { calendar.date(byAdding: .minute, value: 22, to: today)! }
    var twentyFourth: Date { calendar.date(byAdding: .minute, value: 23, to: today)! }
    var twentyFifth: Date { calendar.date(byAdding: .minute, value: 24, to: today)! }
    var twentySixth: Date { calendar.date(byAdding: .minute, value: 25, to: today)! }
    var twentySeventh: Date { calendar.date(byAdding: .minute, value: 26, to: today)! }
    var twentyEighth: Date { calendar.date(byAdding: .minute, value: 27, to: today)! }
    var twentyNinth: Date { calendar.date(byAdding: .minute, value: 28, to: today)! }
    var thirtieth: Date { calendar.date(byAdding: .minute, value: 29, to: today)! }

    var thirtyFirst: Date { calendar.date(byAdding: .minute, value: 30, to: today)! }
    var thirtySecond: Date { calendar.date(byAdding: .minute, value: 31, to: today)! }
    var thirtyThird: Date { calendar.date(byAdding: .minute, value: 32, to: today)! }
    var thirtyFourth: Date { calendar.date(byAdding: .minute, value: 33, to: today)! }
    var thirtyFifth: Date { calendar.date(byAdding: .minute, value: 34, to: today)! }
    var thirtySixth: Date { calendar.date(byAdding: .minute, value: 35, to: today)! }
    var thirtySeventh: Date { calendar.date(byAdding: .minute, value: 36, to: today)! }
    var thirtyEighth: Date { calendar.date(byAdding: .minute, value: 37, to: today)! }
    var thirtyNinth: Date { calendar.date(byAdding: .minute, value: 38, to: today)! }
    var fortieth: Date { calendar.date(byAdding: .minute, value: 39, to: today)! }

    var basicGreet: Greet {
        Greet(
            thisUserID: thisID,
            otherUser: NearbyUser(
                id: otherUserID,
                name: otherName,
                profileImages: [otherImageURLString],
                verified: true
            ),
            greetID: greetID,
            method: .wave,
            compatitibility: [:],
            openers: openers,
            venue: venue,
            minutesAway: 10,
            otherMinutesAway: 10,
            travelMethod: .bike,
            matchMakingMethodVersion: 1,
            participantUserIDs: [thisID, otherUserID],
            events: []
        )
    }

    func testNeedsRefresh() {
        var greet = basicGreet
        greet.events = [
            .init(serverSequenceNumber: 5, actorUserID: thisID, serverDate: fifth, action: .agreedToMeet(30))
        ]
        XCTAssertEqual(
            greet.viewContents(),
            nil
        )
    }


    func testHappyPath() {
        var greet = basicGreet
        greet.events = []
        XCTAssertEqual(
            greet.viewContents(),
            .negotiation(
                StartViewContents(
                    profilePicURL: otherImageURLString,
                    openers: basicGreet.openers,
                    meetDecisionContents: .init(
                        venueName: basicGreet.venue.name,
                        proposalState: .select(now: .show, in30: .show)
                    )
                )
            )
            //            .start(
            //                StartViewContents(
            //                    profilePicURL: otherImageURLString,
//                    openers: basicGreet.openers,
//                    meetDecisionContents: .init(
//                        venueName: basicGreet.venue.name,
//                        proposalState: .show30MinButton
//                    )
//                )
//            )
        )
        greet.events.append(
            GreetEvent(
                serverSequenceNumber: 1,
                actorUserID: thisID,
                serverDate: first,
                action: .agreedToMeet(0)
            )
        )
        XCTAssertEqual(
            greet.viewContents(now: first),
            .negotiation(
                StartViewContents(
                    profilePicURL: otherImageURLString,
                    openers: openers,
                    meetDecisionContents: MeetDecisionCellContents(
                        venueName: venue.name,
                        proposalState: .select(now: .waiting, in30: .show)
                    )
                )
            )
        )

        /*
         .thisUserAgreed(
             StartViewContents(
                 profilePicURL: otherImageURLString,
                 openers: openers,
                 meetDecisionContents: MeetDecisionCellContents(
                     venueName: venue.name,
                     proposalState: .thisUserIswaiting(0)
                 )
             )
         )
         */
        greet.events.append(
            GreetEvent(
                serverSequenceNumber: 2,
                actorUserID: otherUserID,
                serverDate: second,
                action: .agreedToMeet(0)
            )
        )
        XCTAssertEqual(
            greet.viewContents(now: second),
            .enroute(
                EnrouteContents(
                    profilePicURL: otherImageURLString,
                    openers: openers,
                    address: venue.address,
                    percentTravelled: 0,
                    instructionContents: InstructionCellContents(
                        venueNaeme: venue.name,
                        targetMeetTime: Calendar.current.date(
                            byAdding: .minute,
                            value: [greet.minutesAway, greet.otherMinutesAway].max()!,
                            to: second
                        )!
                    ),
                    otherContents: greet.otherUserContents,
                    alternateRequestCellModel: nil
                )
            )
        )
        greet.events.append(
            GreetEvent(
                serverSequenceNumber: 3,
                actorUserID: otherUserID,
                serverDate: third,
                action: .travelTimeToVenue(changedTo: 9)
            )
        )
        XCTAssertEqual(
            greet.viewContents(now: third),
            .enroute(
                EnrouteContents(
                    profilePicURL: otherImageURLString,
                    openers: openers,
                    address: venue.address,
                    percentTravelled: 0.1,
                    instructionContents: InstructionCellContents(
                        venueNaeme: venue.name,
                        targetMeetTime: Calendar.current.date(
                            byAdding: .minute,
                            value: [greet.minutesAway, greet.otherMinutesAway].max()!,
                            to: second
                        )!
                    ),
                    otherContents: greet.otherUserContents,
                    alternateRequestCellModel: nil
                )
            )
        )
        greet.events.append(
            GreetEvent(
                serverSequenceNumber: 4,
                actorUserID: thisID,
                serverDate: fourth,
                action: .travelTimeToVenue(changedTo: 5)
            )
        )
        XCTAssertEqual(
            greet.viewContents(now: fourth),
            .enroute(
                EnrouteContents(
                    profilePicURL: otherImageURLString,
                    openers: openers,
                    address: venue.address,
                    percentTravelled: 0.1,
                    instructionContents: InstructionCellContents(
                        venueNaeme: venue.name,
                        targetMeetTime: Calendar.current.date(
                            byAdding: .minute,
                            value: [greet.minutesAway, greet.otherMinutesAway].max()!,
                            to: second // because that is when the agreement happened.
                        )!
                    ),
                    otherContents: greet.otherUserContents,
                    alternateRequestCellModel: nil
                )
            )
        )
        greet.events.append(
            GreetEvent(
                serverSequenceNumber: 5,
                actorUserID: otherUserID,
                serverDate: fifth,
                action: .travelTimeToVenue(changedTo: 0)
            )
        )
        // Requirements: match on agree time. no rejections. no confirmed met.
        XCTAssertEqual(
            greet.viewContents(now: fifth),
            .enroute(
                EnrouteContents(
                    profilePicURL: otherImageURLString,
                    openers: openers,
                    address: venue.address,
                    percentTravelled: 1.0,
                    instructionContents: InstructionCellContents(
                        venueNaeme: venue.name,
                        targetMeetTime: Calendar.current.date(
                            byAdding: .minute,
                            value: [greet.minutesAway, greet.otherMinutesAway].max()!,
                            to: second
                        )!
                    ),
                    otherContents: greet.otherUserContents,
                    alternateRequestCellModel: .youAreClose(otherName: greet.otherUser.name)
                )
            )
        )
        greet.events.append(
            GreetEvent(
                serverSequenceNumber: 6,
                actorUserID: otherUserID,
                serverDate: sixth,
                action: .confirmedMet
            )
        )
        XCTAssertEqual(
            greet.viewContents(now: sixth),
            .enroute(
                EnrouteContents(
                    profilePicURL: otherImageURLString,
                    openers: openers,
                    address: venue.address,
                    percentTravelled: 1.0,
                    instructionContents: InstructionCellContents(
                        venueNaeme: venue.name,
                        targetMeetTime: Calendar.current.date(
                            byAdding: .minute,
                            value: [greet.minutesAway, greet.otherMinutesAway].max()!,
                            to: second
                        )!
                    ),
                    otherContents: greet.otherUserContents,
                    alternateRequestCellModel: .theySaidTheyMet(otherName: greet.otherUser.name)
                )
            )
        )
        greet.events.append(
            GreetEvent(
                serverSequenceNumber: 7,
                actorUserID: thisID,
                serverDate: seventh,
                action: .confirmedMet
            )
        )
        // If two users confirmed met, why would we
        XCTAssertEqual(
            greet.viewContents(now: seventh),
            .giveRating
        )
        greet.events.append(
            GreetEvent(
                serverSequenceNumber: 8,
                actorUserID: thisID,
                serverDate: eighth,
                action: .rated(5, outOf: 5)
            )
        )
       XCTAssertEqual(greet.viewContents(now: eighth), .showInHistory)
    }


    /// Verifies that a manual greet initiation places the greet into the correct initial start state.
    func testManualGreetInitiatedStart() {
        var greet = basicGreet
        greet.events = [
            GreetEvent(
                serverSequenceNumber: 1,
                actorUserID: thisID,
                serverDate: first,
                action: .manualGreetInitiated
            )
        ]
        XCTAssertEqual(
            greet.viewContents(),
            .negotiation(
                StartViewContents(
                    profilePicURL: otherImageURLString,
                    openers: basicGreet.openers,
                    meetDecisionContents: .init(
                        venueName: basicGreet.venue.name,
                        proposalState: .select(now: .show, in30: .show)
                    )
                )
            )
        )
        /*
         .start(
             StartViewContents(
                 profilePicURL: otherImageURLString,
                 openers: basicGreet.openers,
                 meetDecisionContents: .init(
                     venueName: basicGreet.venue.name,
                     proposalState: .show30MinButton
                 )
             )
         )
         */
    }

    /// Verifies that the initiating user can accept an alternative proposed meeting time.
    func testAlternativeTimeNegotiationThisAccept() {
        var greet = basicGreet
        greet.events = [
            // other agrees to 30
            GreetEvent(
                serverSequenceNumber: 1,
                actorUserID: otherUserID,
                serverDate: first,
                action: .agreedToMeet(30)
            )
        ]
        // - assert proposed(minutes: Int)
        XCTAssertEqual(
            greet.viewContents(),
            .   negotiation(
                StartViewContents(
                    profilePicURL: otherImageURLString,
                    openers: openers,
                    meetDecisionContents: .init(
                        venueName: venue.name,
                        proposalState: .alternateProposal(.theyProposed(minutes: 30))
                    )
                )
            )
        )
        /*
         .otherAskedIfCanMeetLater(
             AlternateRequestContents(
                 profilePicURL: otherImageURLString,
                 openers: openers,
                 alternateRequestCellModel: .theyProposed(minutes: 30)
             )
         )
         */
        // this user accepts 30
        greet.events.append(
            GreetEvent(
                serverSequenceNumber: 2,
                actorUserID: thisID,
                serverDate: second,
                action: .agreedToMeet(30)
            )
        )
        // - assert enroute with 30 minutes from the user with the highest travel time from date of this user accepts
        XCTAssertEqual(
            greet.viewContents(),
            .enroute(
                EnrouteContents(
                    profilePicURL: otherImageURLString,
                    openers: openers,
                    address: venue.address,
                    percentTravelled: 0,
                    instructionContents: InstructionCellContents(
                        venueNaeme: venue.name,
                        targetMeetTime: Calendar.current.date(
                            byAdding: .minute,
                            value: [greet.minutesAway, greet.otherMinutesAway].max()! + 30,
                            to: second
                        )!
                    ),
                    otherContents: greet.otherUserContents,
                    alternateRequestCellModel: nil
                )
            )
        )
    }

    /// Verifies that the initiating user can reject an alternative proposed meeting time.
    func testAlternativeTimeNegotiationThisReject() {
        var greet = basicGreet
        greet.events = [
            // other agrees to 30
            GreetEvent(
                serverSequenceNumber: 1,
                actorUserID: otherUserID,
                serverDate: first,
                action: .agreedToMeet(30)
            )
        ]
        // - assert proposed(minutes: Int)
        XCTAssertEqual(
            greet.viewContents(),
            .negotiation(
                StartViewContents(
                    profilePicURL: otherImageURLString,
                    openers: openers,
                    meetDecisionContents: .init(venueName: venue.name, proposalState: .alternateProposal(.theyProposed(minutes: 30)))
                )
            )
        )
        /*
         .otherAskedIfCanMeetLater(
             AlternateRequestContents(
                 profilePicURL: otherImageURLString,
                 openers: openers,
                 alternateRequestCellModel: .theyProposed(minutes: 30)
             )
         )
         */
        // this user rejects 30
        greet.events.append(
            GreetEvent(
                serverSequenceNumber: 2,
                actorUserID: thisID,
                serverDate: second,
                action: .rejectTime(30)
            )
        )
        // - assert only shows meet now button as an option, 30 minutes no longer available.
        XCTAssertEqual(
            greet.viewContents(),
            .negotiation(StartViewContents(profilePicURL: otherImageURLString, openers: openers, meetDecisionContents: MeetDecisionCellContents(venueName: venue.name, proposalState: .select(now: .show, in30: .rejectedHidden))))
        )
        /*
         .start(
             StartViewContents(
                 profilePicURL: otherImageURLString,
                 openers: openers,
                 meetDecisionContents: MeetDecisionCellContents(
                     venueName: venue.name,
                     proposalState: .hide30Minbutton
                 )
             )
         )
         */
    }

    /// Verifies that the initiating user can accept an alternative proposed meeting time.
    func testAlternativeTimeNegotiationThisAcceptWithFluke() {
        var greet = basicGreet
        greet.events = [
            // other agrees to 30
            GreetEvent(
                serverSequenceNumber: 1,
                actorUserID: otherUserID,
                serverDate: first,
                action: .agreedToMeet(30)
            )
        ]
        // - assert proposed(minutes: Int)
        XCTAssertEqual(
            greet.viewContents(),
            .negotiation(StartViewContents(profilePicURL: otherImageURLString, openers: openers, meetDecisionContents: MeetDecisionCellContents(venueName: venue.name, proposalState: .alternateProposal(.theyProposed(minutes: 30)))))
        )
        /*
         .otherAskedIfCanMeetLater(
             AlternateRequestContents(
                 profilePicURL: otherImageURLString,
                 openers: openers,
                 alternateRequestCellModel: .theyProposed(minutes: 30)
             )
         )
         */
        // this user accepts 0
        greet.events.append(
            GreetEvent(
                serverSequenceNumber: 2,
                actorUserID: thisID,
                serverDate: second,
                action: .agreedToMeet(0)
            )
        )
        // - assert proposed(minutes: 30
        XCTAssertEqual(
            greet.viewContents(),
            .negotiation(StartViewContents(profilePicURL: otherImageURLString, openers: openers, meetDecisionContents: MeetDecisionCellContents(venueName: venue.name, proposalState: .alternateProposal(.theyProposed(minutes: 30)))))
        )
        /*
         .otherAskedIfCanMeetLater(
             AlternateRequestContents(
                 profilePicURL: otherImageURLString,
                 openers: openers,
                 alternateRequestCellModel: .theyProposed(minutes: 30)
             )
         )
         */
        // this user accepts 30
        greet.events.append(
            GreetEvent(
                serverSequenceNumber: 2,
                actorUserID: thisID,
                serverDate: second,
                action: .agreedToMeet(30)
            )
        )
        // - assert enroute with 30 minutes from the user with the highest travel time from date of this user accepts
        XCTAssertEqual(
            greet.viewContents(),
            .enroute(
                EnrouteContents(
                    profilePicURL: otherImageURLString,
                    openers: openers,
                    address: venue.address,
                    percentTravelled: 0,
                    instructionContents: InstructionCellContents(
                        venueNaeme: venue.name,
                        targetMeetTime: Calendar.current.date(
                            byAdding: .minute,
                            value: [greet.minutesAway, greet.otherMinutesAway].max()! + 30,
                            to: second
                        )!
                    ),
                    otherContents: greet.otherUserContents,
                    alternateRequestCellModel: nil
                )
            )
        )
    }

    /// Verifies that the initiating user can reject an alternative proposed meeting time.
    func testAlternativeTimeNegotiationThisRejectWithFluke() {
        var greet = basicGreet
        greet.events = [
            // other agrees to 30
            GreetEvent(
                serverSequenceNumber: 1,
                actorUserID: otherUserID,
                serverDate: first,
                action: .agreedToMeet(30)
            )
        ]
        // - assert proposed(minutes: Int)
        XCTAssertEqual(
            greet.viewContents(),
            .negotiation(
                StartViewContents(
                    profilePicURL: otherImageURLString, openers: openers, meetDecisionContents: MeetDecisionCellContents(venueName: venue.name, proposalState: .alternateProposal(.theyProposed(minutes: 30)))))
        )
        /*
         .otherAskedIfCanMeetLater(
             AlternateRequestContents(
                 profilePicURL: otherImageURLString,
                 openers: openers,
                 alternateRequestCellModel: .theyProposed(minutes: 30)
             )
         )
         */
        // this user accepts 0
        greet.events.append(
            GreetEvent(
                serverSequenceNumber: 2,
                actorUserID: thisID,
                serverDate: second,
                action: .agreedToMeet(0)
            )
        )
        // - assert proposed(minutes: 30
        XCTAssertEqual(
            greet.viewContents(),
            .negotiation(StartViewContents(profilePicURL: otherImageURLString, openers: openers, meetDecisionContents: MeetDecisionCellContents(venueName: venue.name, proposalState: .alternateProposal(.theyProposed(minutes: 30)))))
        )
        /*
         .otherAskedIfCanMeetLater(
             AlternateRequestContents(
                 profilePicURL: otherImageURLString,
                 openers: openers,
                 alternateRequestCellModel: .theyProposed(minutes: 30)
             )
         )
         */
        greet.events.append(
            GreetEvent(
                serverSequenceNumber: 3,
                actorUserID: thisID,
                serverDate: third,
                action: .rejectTime(30)
            )
        )
        // - assert waiting screen
        XCTAssertEqual(
            greet.viewContents(),
            .negotiation(StartViewContents(profilePicURL: otherImageURLString, openers: openers, meetDecisionContents: MeetDecisionCellContents(venueName: venue.name, proposalState: .select(now: .waiting, in30: .rejectedHidden))))
        )
        /*
         .start(
             StartViewContents(
                 profilePicURL: otherImageURLString,
                 openers: openers,
                 meetDecisionContents: MeetDecisionCellContents(venueName: venue.name, proposalState: .hide30Minbutton)
             )
         )
         */
    }

    /// Verifies that the initiating user can accept an alternative proposed meeting time.
    func testAlternativeTimeNegotiationThisAcceptInverse() {
        var greet = basicGreet
        greet.events = [
            // this agrees to 30
            .init(serverSequenceNumber: 1, actorUserID: thisID, serverDate: first, action: .agreedToMeet(30))

        ]
        // - assert waiting
        XCTAssertEqual(
            greet.viewContents(now: first),
            .negotiation(StartViewContents(profilePicURL: otherImageURLString, openers: openers, meetDecisionContents: MeetDecisionCellContents(venueName: venue.name, proposalState: .select(now: .show, in30: .waiting))))
        )
        /*
         .thisUserAgreed(StartViewContents(profilePicURL: otherImageURLString, openers: openers, meetDecisionContents: MeetDecisionCellContents.init(venueName: venue.name, proposalState: .thisUserIswaiting(30))))
         */
        // other user accepts 30
        greet.events.append(.init(serverSequenceNumber: 2, actorUserID: otherUserID, serverDate: second, action: .agreedToMeet(30)))
        // - assert enroute with 30 minutes from the user with the highest travel time from date of this user accepts

        XCTAssertEqual(
            greet.viewContents(now: second),
            .enroute(
                EnrouteContents(
                    profilePicURL: otherImageURLString,
                    openers: openers,
                    address: venue.address,
                    percentTravelled: 0,
                    instructionContents: InstructionCellContents(
                        venueNaeme: venue.name,
                        targetMeetTime: Calendar.current.date(
                            byAdding: .minute,
                            value: [greet.minutesAway, greet.otherMinutesAway].max()! + 30,
                            to: second
                        )!
                    ),
                    otherContents: greet.otherUserContents,
                    alternateRequestCellModel: nil
                )
            )
        )
    }

    /// Verifies that the initiating user can reject an alternative proposed meeting time.
    func testAlternativeTimeNegotiationThisRejectInverse() {
        var greet = basicGreet
        greet.events = [
            // this agrees to 30
            // other user rejects 30
            .init(serverSequenceNumber: 1, actorUserID: thisID, serverDate: first, action: .agreedToMeet(30)),
            .init(serverSequenceNumber: 2, actorUserID: otherUserID, serverDate: second, action: .rejectTime(30))
        ]
        // - assert only shows meet now button as an option, 30 minutes no longer available, and maybe something to say they can't meet in 30 or that it doesn't work for them...
        XCTAssertEqual(
            greet.viewContents(),
            .negotiation(StartViewContents(profilePicURL: otherImageURLString, openers: openers, meetDecisionContents: MeetDecisionCellContents(venueName: venue.name, proposalState: .select(now: .show, in30: .rejectedHidden))))
        )
        /*
         .start(
             StartViewContents(
                 profilePicURL: otherImageURLString,
                 openers: openers,
                 meetDecisionContents: MeetDecisionCellContents(
                     venueName: venue.name,
                     proposalState: MeetDecisionCellContents.ProposalState.hide30Minbutton
                 )
             )
         )
         */
    }

    /// Verifies that the initiating user can accept an alternative proposed meeting time.
    func testAlternativeTimeNegotiationThisAcceptWithFlukeInverse() {
        var greet = basicGreet
        greet.events = [
            // this agrees to 30
            // other user accepts 0
            .init(serverSequenceNumber: 1, actorUserID: thisID, serverDate: first, action: .agreedToMeet(30)),
            .init(serverSequenceNumber: 2, actorUserID: otherUserID, serverDate: second, action: .agreedToMeet(0))
        ]
        // - assert "Waiting to hear if they can meet in 30." FYI they can meet now...
        // on one hand I figured It should be to preserve the double blind nature of this however if both people want to meet but are just figuring out the time,
        // then that is different. I feel like we should disclose as much information as possible.  That the other wants to meet.
        // I'm unsure what the behavior should be so I'll save it for later.
        // Strongly considering thisUserIsWaiting(30) or creating a new version for when this agreed to a time and the other has or agreeed to another time.

        XCTAssertEqual(
            greet.viewContents(now: second),
            .negotiation(StartViewContents(profilePicURL: otherImageURLString, openers: openers, meetDecisionContents: MeetDecisionCellContents(venueName: venue.name, proposalState: .select(now: .show, in30: .waiting))))
        )
        /*
         .start(
             StartViewContents(
                 profilePicURL: otherImageURLString,
                 openers: openers,
                 meetDecisionContents: MeetDecisionCellContents(
                     venueName: venue.name,
                     proposalState: .otherUserIsWaiting(0)
                 )
             )
         )
         */
        // other user accepts 30
        greet.events.append(.init(serverSequenceNumber: 3, actorUserID: otherUserID, serverDate: third, action: .agreedToMeet(30)))
        // - assert enroute with 30 minutes from the user with the highest travel time from date of this user accepts
         XCTAssertEqual(
            greet.viewContents(now: third),
            .enroute(
                EnrouteContents(
                    profilePicURL: otherImageURLString,
                    openers: openers,
                    address: venue.address,
                    percentTravelled: 0,
                    instructionContents: InstructionCellContents(
                        venueNaeme: venue.name,
                        targetMeetTime: Calendar.current.date(
                            byAdding: .minute,
                            value: [greet.minutesAway, greet.otherMinutesAway].max()! + 30,
                            to: third
                        )!
                    ),
                    otherContents: greet.otherUserContents,
                    alternateRequestCellModel: nil
                )
            )
        )
    }

    /// Verifies that the initiating user can reject an alternative proposed meeting time.
    func testAlternativeTimeNegotiationThisRejectWithFlukeInverse() {
        var greet = basicGreet
        greet.events = [
            // this agrees to 30
            // other user accepts 0
            .init(serverSequenceNumber: 1, actorUserID: thisID, serverDate: first, action: .agreedToMeet(30)),
            .init(serverSequenceNumber: 2, actorUserID: otherUserID, serverDate: second, action: .agreedToMeet(0))
        ]
        // - assert "Waiting to hear if they can meet in 30." FYI they can meet now...
        // Yeah... we have to make it changed to
        XCTAssertEqual(
            greet.viewContents(now: second),
            .negotiation(StartViewContents(profilePicURL: otherImageURLString, openers: openers, meetDecisionContents: MeetDecisionCellContents(venueName: venue.name, proposalState: .select(now: .show, in30: .waiting))))
        )
        /*
         .start(
             StartViewContents(
                 profilePicURL: otherImageURLString,
                 openers: openers,
                 meetDecisionContents: MeetDecisionCellContents(
                     venueName: venue.name,
                     proposalState: .thisUserIswaiting(30)
                 )
             )
         )
         */
        // other user rejects 30
        greet.events.append(GreetEvent(serverSequenceNumber: 3, actorUserID: otherUserID, serverDate: third, action: .rejectTime(30)))
        // - They can't meet in 30...
        XCTAssertEqual(
            greet.viewContents(now: second),
            .negotiation(StartViewContents(profilePicURL: otherImageURLString, openers: openers, meetDecisionContents: MeetDecisionCellContents(venueName: venue.name, proposalState: .select(now: .show, in30: .rejectedHidden))))
        )
        /*
         .start(
             StartViewContents(
                 profilePicURL: otherImageURLString,
                 openers: openers,
                 meetDecisionContents: MeetDecisionCellContents(
                     venueName: venue.name,
                     proposalState: .otherUserIsWaiting(0)
                 )
             )
         )
         */
    }

    /// Verifies that the other user can accept an alternative proposed meeting time.
    func testAlternativeTimeNegotiationOtherAccept() {
        var greet = basicGreet
        let thirtyMin: Int = 30
        greet.events = [
            .init(serverSequenceNumber: 1, actorUserID: thisID, serverDate: first, action: .agreedToMeet(thirtyMin)),
            .init(serverSequenceNumber: 2, actorUserID: otherUserID, serverDate: second, action: .agreedToMeet(thirtyMin))
        ]
        XCTAssertEqual(
           greet.viewContents(now: second),
           .enroute(
               EnrouteContents(
                   profilePicURL: otherImageURLString,
                   openers: openers,
                   address: venue.address,
                   percentTravelled: 0,
                   instructionContents: InstructionCellContents(
                       venueNaeme: venue.name,
                       targetMeetTime: Calendar.current.date(
                           byAdding: .minute,
                           value: [greet.minutesAway, greet.otherMinutesAway].max()! + thirtyMin,
                           to: second
                       )!
                   ),
                   otherContents: greet.otherUserContents,
                   alternateRequestCellModel: nil
               )
           )
       )
    }

    /// Verifies that dismissing a greet before any agreement counts as a regular rejection.
    func testDismissBeforeAgree() {
        var greet = basicGreet
        greet.events = [
            // This dismiss
            .init(serverSequenceNumber: 1, actorUserID: thisID, serverDate: first, action: .dismissGreet)

        ]
        // - assert reject don't worry we closed
        XCTAssertEqual(
            greet.viewContents(now: first),
            .rejected(RejectedContents.thisUserDismissed)
        )
    }

    /// Verifies that dismissing a greet before any agreement counts as a regular rejection.
    func testDismissBeforeAgreeOther() {
        var greet = basicGreet
        greet.events = [
            // other dismiss
            .init(serverSequenceNumber: 1, actorUserID: otherUserID, serverDate: first, action: .dismissGreet)

        ]
        // - assert reject for this
        XCTAssertEqual(
            greet.viewContents(now: first),
            .rejected(.otherUserDismissed)
        )
    }

    /// Verifies that dismissing a greet after an agreement counts as a special rejection.
    func testDismissAfterAgree() {
        var greet = basicGreet
        greet.events = [
            // thisAgree0
            .init(serverSequenceNumber: 1, actorUserID: thisID, serverDate: first, action: .agreedToMeet(0)),
            // otherAgree0
            .init(serverSequenceNumber: 2, actorUserID: otherUserID, serverDate: second, action: .agreedToMeet(0)),
            // thisReject
            .init(serverSequenceNumber: 3, actorUserID: thisID, serverDate: third, action: .dismissGreet)
        ]
        // - assert don't worry we closed it.  // on client side, give some ui to say if you wait a few minutes while they travel before canceling it, we may throttle your matches or something like that.
        XCTAssertEqual(
            greet.viewContents(),
            .rejected(RejectedContents.thisUserDismissed)
        )
    }

    /// Verifies that closing the app after confirming a meetup has no rejection side effects.
    func testCloseAppAfterEnroute() {
        var greet = basicGreet
        greet.events = [
            // thisAgree0
            .init(serverSequenceNumber: 1, actorUserID: thisID, serverDate: first, action: .agreedToMeet(0)),
            // otherAgree0
            .init(serverSequenceNumber: 2, actorUserID: otherUserID, serverDate: second, action: .agreedToMeet(0)),
            // close app
            .init(serverSequenceNumber: 3, actorUserID: thisID, serverDate: third, action: .closeApp)
        ]
        // - assert enroute
        XCTAssertEqual(
            greet.viewContents(now: third),
            .enroute(
                EnrouteContents(
                    profilePicURL: otherImageURLString,
                    openers: openers,
                    address: venue.address,
                    percentTravelled: 0,
                    instructionContents: InstructionCellContents(
                        venueNaeme: venue.name,
                        targetMeetTime: Calendar.current.date(
                            byAdding: .minute,
                            value: [greet.minutesAway, greet.otherMinutesAway].max()!,
                            // Starts from the point where the second person agreed.
                            to: second
                        )!
                    ),
                    otherContents: greet.otherUserContents,
                    alternateRequestCellModel: nil
                )
            )
        )
    }

    /// Verifies behavior when the app is closed before a meetup is confirmed.
    func testCloseAppBeforeEnroute() {
        var greet = basicGreet
        greet.events = [
            // other close app
            .init(serverSequenceNumber: 1, actorUserID: otherUserID, serverDate: first, action: .closeApp)

        ]
        XCTAssertEqual(
            greet.viewContents(now: first),
            .rejected(RejectedContents.otherUserDismissed)
        )
    }

    /// Verifies behavior when the app is closed before a meetup is confirmed.
    func testCloseAppBeforeEnrouteThis() {
        var greet = basicGreet
        greet.events = [
            // this close app
            .init(serverSequenceNumber: 1, actorUserID: thisID, serverDate: first, action: .closeApp)
        ]
        XCTAssertEqual(
            greet.viewContents(),
            .rejected(.thisUserDismissed)
        )
    }

    /// Verifies that rejecting via the red reject action while the other user is waiting
    /// results in the appropriate “didn’t work out” outcome.
    func testRedRejectAfterOtherWaiting() {
        var greet = basicGreet
        greet.events = [
            // other agree 0
            .init(serverSequenceNumber: 1, actorUserID: otherUserID, serverDate: first, action: .agreedToMeet(0)),
            // this tap red reject
            .init(serverSequenceNumber: 2, actorUserID: thisID, serverDate: second, action: .tappedRedVoipReject)

        ]
        // - don't worry we closed it
        XCTAssertEqual(
            greet.viewContents(),
            .rejected(.thisUserDismissed)
        )
    }

    /// Verifies that rejecting via the red reject action while the other user is waiting
    /// results in the appropriate “didn’t work out” outcome.
    func testRedRejectAfterThisWaiting() {
        var greet = basicGreet
        greet.events = [
            // this agree 0
            .init(serverSequenceNumber: 1, actorUserID: thisID, serverDate: first, action: .agreedToMeet(0)),
            // other tap red reject
            .init(serverSequenceNumber: 2, actorUserID: otherUserID, serverDate: second, action: .tappedRedVoipReject)
        ]
        // - more fish in the sea
        XCTAssertEqual(
            greet.viewContents(now: second),
            .rejected(.otherUserDismissed)
        )
    }

    /// Verifies that rejecting an automatic greet before the other user sees it
    /// silently closes or hides the greet.
    func testRedRejectAtStartAutomatic() {
        var greet = basicGreet
        greet.events = [
            // other user tap red reject
            .init(serverSequenceNumber: 1, actorUserID: otherUserID, serverDate: first, action: .tappedRedVoipReject)

        ]
        // - assert hide
        XCTAssertEqual(
            greet.viewContents(now: first),
            .rejected(.otherUserDismissed)
        )
    }

    /// Verifies that rejecting at the start when the other user manually initiated the greet
    /// results in the correct rejection handling.
    func testRedRejectAtStartOtherManual() {
        var greet = basicGreet
        greet.events = [
            // manual initiated other
            .init(serverSequenceNumber: 1, actorUserID: otherUserID, serverDate: first, action: .manualGreetInitiated),
            // this red reject
            .init(serverSequenceNumber: 2, actorUserID: thisID, serverDate: second, action: .tappedRedVoipReject)
        ]
        // - assert don't worry we closed it.
        XCTAssertEqual(
            greet.viewContents(),
            .rejected(.thisUserDismissed)
        )
    }

    /// Verifies that a greet is closed when the travel time allowance is exceeded
    /// and the user is not making progress toward the venue.
    func testTheySlowTravelProgress() {
        var greet = basicGreet
        greet.events = [
            // this agree 0
            .init(serverSequenceNumber: 1, actorUserID: thisID, serverDate: first, action: .agreedToMeet(0)),
            // other agree 0
            .init(serverSequenceNumber: 2, actorUserID: otherUserID, serverDate: second, action: .agreedToMeet(0)),
        ]
        for (indx, time) in [third, fourth, fifth, sixth, seventh, eighth, ninth, tenth, eleventh, twelfth, thirteenth, fourteenth, fifteenth].enumerated() {
            greet.events.append(.init(serverSequenceNumber: indx + 3, actorUserID: otherUserID, serverDate: time, action: .travelTimeToVenue(changedTo: 10)))
        }
        // - assert it seems they weren't moving fast enough.. they were 20 minutes away.  Don't worry there are more fish in the sea.
        XCTAssertEqual(
            greet.viewContents(now: fifteenth),
            .rejected(.theySlowProgress(travelTime: 10))
        )
    }

    func testThisSlowTravelProgress() {
        var greet = basicGreet
        greet.events = [
            // this agree 0
            .init(serverSequenceNumber: 1, actorUserID: thisID, serverDate: first, action: .agreedToMeet(0)),
            // other agree 0
            .init(serverSequenceNumber: 2, actorUserID: otherUserID, serverDate: second, action: .agreedToMeet(0)),
        ]
        for (indx, time) in [third, fourth, fifth, sixth, seventh, eighth, ninth, tenth, eleventh, twelfth, thirteenth, fourteenth, fifteenth].enumerated() {
            greet.events.append(.init(serverSequenceNumber: indx + 3, actorUserID: thisID, serverDate: time, action: .travelTimeToVenue(changedTo: 10)))
        }
        // - assert it seems they weren't moving fast enough.. they were 20 minutes away.  Don't worry there are more fish in the sea.
        XCTAssertEqual(
            greet.viewContents(now: fifteenth),
            .rejected(.thisSlowProgress(travelTime: 10))
        )
    }

    /// Verifies that a greet is closed when the travel time allowance is exceeded
    /// and the user is not making progress toward the venue.
    func testExceededTravelTimeAllowance() {
        var greet = basicGreet
        greet.events = [
            // this agree 0
            GreetEvent(
                serverSequenceNumber: 1,
                actorUserID: thisID,
                serverDate: first,
                action: .agreedToMeet(0)
            ),

            // other agree 0
            GreetEvent(
                serverSequenceNumber: 2,
                actorUserID: otherUserID,
                serverDate: second,
                action: .agreedToMeet(0)
            ),

            // other travel time change to 20
            GreetEvent(
                serverSequenceNumber: 3,
                actorUserID: otherUserID,
                serverDate: third,
                action: .travelTimeToVenue(changedTo: 21)
            )
        ]

        XCTAssertEqual(
            greet.viewContents(now: third),
            .rejected(.theyWrongWay(travelTime: 21))
        )
    }


    /// Verifies that a greet is closed when the travel time allowance is exceeded
    /// and the user is not making progress toward the venue.
    func testExceededTravelTimeAllowanceOther() {
        var greet = basicGreet
        greet.events = [
            // this agree 0
            GreetEvent(
                serverSequenceNumber: 1,
                actorUserID: thisID,
                serverDate: first,
                action: .agreedToMeet(0)
            ),
            // other agree 0
            GreetEvent(
                serverSequenceNumber: 2,
                actorUserID: otherUserID,
                serverDate: second,
                action: .agreedToMeet(0)
            ),
            // this travel time change to 20
            GreetEvent(
                serverSequenceNumber: 3,
                actorUserID: thisID,
                serverDate: third,
                action: .travelTimeToVenue(changedTo: 20)
            )
        ]

        // - assert: It seems you were moving in the wrong direction. they were 20 minutes away. Don't worry there are more fish in the sea.
        XCTAssertEqual(
            greet.viewContents(),
            .rejected(.thisWrongWay(travelTime: 20))
        )
    }

}
