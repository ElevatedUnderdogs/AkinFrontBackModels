//
//  GreetDemoAvailabilityTests.swift
//  FrontBackModelsTests
//
//  GOAL_LOOP26. The demo cell shipped offering all thirteen counterpart actions
//  at all times, including "they answer your call" with nobody ringing and
//  "they say you met" before either side had agreed to meet. Each of those
//  would have written a row describing something that cannot have happened, and
//  every screen downstream is drawn from that ledger.
//
//  Red before green: with `GreetDemoRules.availability` returning `.available`
//  unconditionally, every test below that expects an `.unavailable` fails.
//

import XCTest
@testable import AkinFrontBackModels

final class GreetDemoAvailabilityTests: XCTestCase {

    private let viewer = UUID()
    private let counterpart = UUID()
    private let greet = UUID()
    private let counterpartName = "App Reviewer"

    private func event(_ action: GreetAction, by actor: UUID, seq: Int) -> GreetEvent {
        GreetEvent(
            serverSequenceNumber: seq,
            actorUserID: actor,
            serverDate: Date(timeIntervalSince1970: TimeInterval(seq)),
            action: action,
            greetID: greet
        )
    }

    private func context(_ events: [GreetEvent], hasEnded: Bool = false) -> GreetDemoContext {
        GreetDemoContext.derive(
            events: events,
            viewerID: viewer,
            counterpartID: counterpart,
            hasEnded: hasEnded
        )
    }

    private func check(_ action: GreetAction, _ ctx: GreetDemoContext) -> GreetDemoAvailability {
        GreetDemoRules.availability(of: action, in: ctx, counterpartName: counterpartName)
    }

    // MARK: - The opening state

    func testAFreshGreetOffersTheThingsThatCanActuallyHappenNext() {
        let ctx = context([])
        XCTAssertEqual(ctx.phase, .awaitingAgreement)
        XCTAssertEqual(ctx.call, .none)

        for action in [
            GreetAction.agreedToMeet(0),
            .agreedToMeet(30),
            .viewedGreetScreen,
            .callInitiated(.ringToGreet),
            .dismissGreet,
            .closeApp
        ] {
            XCTAssertTrue(
                check(action, ctx).isAvailable,
                "\(action.actionString) is a reasonable next thing on a fresh greet."
            )
        }
    }

    /// The four that were offered on a fresh greet and could not possibly happen.
    func testAFreshGreetRefusesTheImpossibleOnes() {
        let ctx = context([])
        let cases: [(GreetAction, String)] = [
            (.callAnswered(.ringToGreet), "still ringing"),
            (.callDeclined(.ringToGreet), "still ringing"),
            (.callEnded(.ringToGreet), "nothing to hang up"),
            (.tappedRedVoipReject, "nothing is ringing"),
            (.confirmedMet, "cannot be confirmed before"),
            (.notGettingCloser(start: 5, allowance: 5, current: 20), "Nobody is travelling yet"),
            (.rejectTime(30), "nothing to reject")
        ]
        for (action, fragment) in cases {
            let result = check(action, ctx)
            XCTAssertFalse(result.isAvailable, "\(action.actionString) cannot happen on a fresh greet.")
            XCTAssertTrue(
                (result.reason ?? "").localizedCaseInsensitiveContains(fragment),
                "The refusal must say why. Got: \(result.reason ?? "nil")"
            )
        }
    }

    // MARK: - The call sequence

    func testAnsweringAndDecliningNeedACallYouStarted() {
        var ctx = context([event(.callInitiated(.ringToGreet), by: viewer, seq: 1)])
        XCTAssertEqual(ctx.call, .ringingFromViewer)
        XCTAssertTrue(check(.callAnswered(.ringToGreet), ctx).isAvailable)
        XCTAssertTrue(check(.callDeclined(.ringToGreet), ctx).isAvailable)
        XCTAssertTrue(check(.tappedRedVoipReject, ctx).isAvailable)
        XCTAssertFalse(check(.callEnded(.ringToGreet), ctx).isAvailable, "Ringing is not connected.")
        XCTAssertFalse(check(.callInitiated(.ringToGreet), ctx).isAvailable, "A call is already ringing.")

        ctx = context([
            event(.callInitiated(.ringToGreet), by: viewer, seq: 1),
            event(.callAnswered(.ringToGreet), by: counterpart, seq: 2)
        ])
        XCTAssertEqual(ctx.call, .connected)
        XCTAssertTrue(check(.callEnded(.ringToGreet), ctx).isAvailable, "A connected call can be hung up.")
        XCTAssertFalse(check(.callAnswered(.ringToGreet), ctx).isAvailable, "Already answered.")
    }

    /// The state is the LAST CallKit action, not "has there ever been a call".
    /// Searching for any `callInitiated` would report a call in progress forever
    /// after the first one ended, and a second call could never be started.
    func testASecondCallIsPossibleAfterTheFirstOneEnds() {
        let ctx = context([
            event(.callInitiated(.ringToGreet), by: viewer, seq: 1),
            event(.callAnswered(.ringToGreet), by: counterpart, seq: 2),
            event(.callEnded(.ringToGreet), by: viewer, seq: 3)
        ])
        XCTAssertEqual(ctx.call, .none)
        XCTAssertTrue(check(.callInitiated(.ringToGreet), ctx).isAvailable)
        XCTAssertFalse(check(.callEnded(.ringToGreet), ctx).isAvailable)
    }

    /// Events are sorted inside `derive`, so a caller passing them in arrival
    /// order cannot get a different answer from one passing them in sequence order.
    func testOutOfOrderEventsDeriveTheSameState() {
        let inOrder = context([
            event(.callInitiated(.ringToGreet), by: viewer, seq: 1),
            event(.callAnswered(.ringToGreet), by: counterpart, seq: 2)
        ])
        let shuffled = context([
            event(.callAnswered(.ringToGreet), by: counterpart, seq: 2),
            event(.callInitiated(.ringToGreet), by: viewer, seq: 1)
        ])
        XCTAssertEqual(inOrder, shuffled)
        XCTAssertEqual(shuffled.call, .connected)
    }

    // MARK: - The negotiation

    func testRejectingATimeNeedsYouToHaveProposedIt() {
        let ctx = context([event(.agreedToMeet(30), by: viewer, seq: 1)])
        XCTAssertEqual(ctx.phase, .viewerProposed)
        XCTAssertTrue(check(.rejectTime(30), ctx).isAvailable)
        XCTAssertFalse(check(.rejectTime(0), ctx).isAvailable, "You proposed 30, not now.")
    }

    func testATimeIsNotOfferedTwiceOnceTheyHaveAgreedToIt() {
        let ctx = context([event(.agreedToMeet(0), by: counterpart, seq: 1)])
        XCTAssertEqual(ctx.phase, .counterpartProposed)
        XCTAssertFalse(check(.agreedToMeet(0), ctx).isAvailable)
        XCTAssertTrue(check(.agreedToMeet(30), ctx).isAvailable, "A different time is still open.")
    }

    func testTravelAndConfirmationNeedBothSidesToHaveAgreed() {
        let ctx = context([
            event(.agreedToMeet(0), by: viewer, seq: 1),
            event(.agreedToMeet(0), by: counterpart, seq: 2)
        ])
        XCTAssertEqual(ctx.phase, .bothAgreed)
        XCTAssertTrue(check(.confirmedMet, ctx).isAvailable)
        XCTAssertTrue(check(.notGettingCloser(start: 5, allowance: 5, current: 20), ctx).isAvailable)
    }

    // MARK: - Viewing is a one-time fact

    func testOpeningTheGreetIsOfferedOnlyOnce() {
        let before = context([])
        XCTAssertTrue(check(.viewedGreetScreen, before).isAvailable)
        let after = context([event(.viewedGreetScreen, by: counterpart, seq: 1)])
        XCTAssertTrue(after.counterpartHasViewed)
        XCTAssertFalse(check(.viewedGreetScreen, after).isAvailable)
    }

    /// The viewer opening their own greet says nothing about the counterpart.
    func testTheViewersOwnViewDoesNotCountAsTheirs() {
        let ctx = context([event(.viewedGreetScreen, by: viewer, seq: 1)])
        XCTAssertFalse(ctx.counterpartHasViewed)
        XCTAssertTrue(check(.viewedGreetScreen, ctx).isAvailable)
    }

    // MARK: - The end

    func testNothingIsDrivableOnceTheGreetHasEnded() {
        for ctx in [
            context([event(.dismissGreet, by: counterpart, seq: 1)]),
            context([], hasEnded: true)
        ] {
            XCTAssertEqual(ctx.phase, .ended)
            for action in [
                GreetAction.agreedToMeet(0),
                .viewedGreetScreen,
                .callInitiated(.ringToGreet),
                .closeApp,
                .confirmedMet
            ] {
                let result = check(action, ctx)
                XCTAssertFalse(result.isAvailable, "\(action.actionString) after the end.")
                // This sentence is what a reviewer reads under every disabled control once the
                // greet is over, and what the server answers when one is driven anyway, so the
                // two have to be the same words.
                // literal-ok: the member facing sentence IS the specification here
                XCTAssertEqual(result.reason, "This greet has ended, so nothing more can happen on it.")
            }
            // Dismiss stays live after the end so the demo partner can clear leftover UI.
            XCTAssertTrue(check(.dismissGreet, ctx).isAvailable, "dismiss must stay reachable after the end")
        }
    }

    func testDismissStaysAvailableAfterTheGreetHasEnded() {
        for ctx in [
            context([event(.dismissGreet, by: counterpart, seq: 1)]),
            context([event(.confirmedMet, by: counterpart, seq: 1)]),
            context([], hasEnded: true)
        ] {
            XCTAssertEqual(ctx.phase, .ended)
            XCTAssertTrue(check(.dismissGreet, ctx).isAvailable)
            XCTAssertNil(check(.dismissGreet, ctx).reason)
        }
    }

    /// `confirmedMet` ends the greet, so it must not leave the greet looking live.
    func testConfirmingAMeetingEndsIt() {
        let ctx = context([
            event(.agreedToMeet(0), by: viewer, seq: 1),
            event(.agreedToMeet(0), by: counterpart, seq: 2),
            event(.confirmedMet, by: counterpart, seq: 3)
        ])
        XCTAssertEqual(ctx.phase, .ended)
    }

    // MARK: - The actions that are never drivable

    func testActionsOffTheDemoListAreNeverAvailable() {
        let ctx = context([])
        for action in [
            GreetAction.manualGreetInitiated,
            .travelTimeToVenue(changedTo: 4),
            .travelDistanceToVenue(changedTo: 120),
            .rated(5, outOf: 5)
        ] {
            XCTAssertFalse(check(action, ctx).isAvailable, "\(action.actionString) is not a demo action.")
        }
    }

    // MARK: - The sentences

    /// Every refusal names the other member rather than saying "the counterpart",
    /// and reads as a sentence rather than a code.
    func testRefusalsAreWrittenForAPersonToRead() {
        let ctx = context([])
        let reason = check(.callEnded(.ringToGreet), ctx).reason ?? ""
        XCTAssertTrue(reason.hasSuffix("."), "A sentence ends in a full stop. Got: \(reason)")
        let named = check(.callAnswered(.ringToGreet), ctx).reason ?? ""
        XCTAssertTrue(named.contains(counterpartName), "The refusal should name them. Got: \(named)")
    }
}
