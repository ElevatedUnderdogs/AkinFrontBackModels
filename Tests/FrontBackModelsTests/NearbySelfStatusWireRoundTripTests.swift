//
//  NearbySelfStatusWireRoundTripTests.swift
//  AkinFrontBackModelsTests
//
//  GOAL_LOOP27. The test that would have caught a dead feature, and did not exist.
//
//  ## What shipped broken, and for how long
//
//  GOAL_LOOP26 added two fields to `NearbySelfStatus`, the server to client status that travels with
//  the nearby list: `mayTriggerDemoGreet` and a counterpart identifier. The identifier was spelled with
//  a trailing capitalised `ID`. The server encodes with `.convertToSnakeCase` and the app decodes with
//  `.convertFromSnakeCase`, and Foundation's conversion is not its own inverse for a trailing acronym.
//  Measured, not reasoned about:
//
//      server wrote: {"demo_greet_counterpart_id":"11111111-...","may_trigger_demo_greet":true}
//      client read mayTriggerDemoGreet:    true
//      client read demoGreetCounterpartID: nil
//
//  The boolean survived and the identifier did not. Both of the places that decide whether a reviewer
//  sees anything AND the two facts together:
//
//      NearbyUsersViewModel.swift:1158
//          selfStatus.mayTriggerDemoGreet && selfStatus.demoGreetCounterpartId != nil
//      DemoReviewSession.swift:85
//          recordedMayDriveDemo = status.mayTriggerDemoGreet && status.demoGreetCounterpartId != nil
//
//  So against the real server the Demo Greet control never drew, and the demo counterpart section on
//  the greet screen never drew either. The whole of GOAL_LOOP26's "reviewer's second hand" was dead on
//  arrival, and an App Review reviewer holding one device could reach none of it.
//
//  ## Why every existing test passed over it
//
//  There were tests, and they were careful ones. They tested the default status, and they tested a
//  payload from a server that predates the fields. What none of them did was decode a payload the real
//  server would actually send: they used a bare `JSONDecoder()` with no key strategy, so a camelCase
//  payload decoded fine and the snake_case round trip was never exercised. The bug lived in the gap
//  between the two coders, and no test put both coders in the same sentence.
//
//  That is what this file is. It asserts the round trip through BOTH strategies, which is the only
//  arrangement in which the defect is visible.
//

import XCTest
@testable import AkinFrontBackModels

final class NearbySelfStatusWireRoundTripTests: XCTestCase {

    /// The server's encoder, configured as `configure.swift` configures it.
    private var serverEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }

    /// The app's decoder, configured as the app configures it.
    private var clientDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    /// The counterpart identifier survives the server to client round trip.
    ///
    /// This is the assertion whose absence let the feature ship dead. It fails on the `...ID` spelling
    /// and passes on `...Id`, with the bytes on the wire identical either way.
    func testTheCounterpartIdentifierSurvivesTheServerToClientRoundTrip() throws {
        let counterpart = UUID()
        let sent = NearbySelfStatus(mayTriggerDemoGreet: true, demoGreetCounterpartId: counterpart)

        let bytes = try serverEncoder.encode(sent)
        let received = try clientDecoder.decode(NearbySelfStatus.self, from: bytes)

        XCTAssertTrue(
            received.mayTriggerDemoGreet,
            "the boolean always survived, which is why the defect was invisible: one of the two facts "
                + "arrived and the other did not"
        )
        XCTAssertEqual(
            received.demoGreetCounterpartId,
            counterpart,
            """
            The counterpart identifier did not survive the round trip, so both
            `NearbyUsersViewModel.demoGreetIsAvailable` and `DemoReviewSession.record` compute false
            and a reviewer sees no demonstration controls at all. Check the property's spelling: a
            trailing capitalised ID does not survive `.convertToSnakeCase` followed by
            `.convertFromSnakeCase`, and `IdentifierSpellingGuardTests` explains why.
            """
        )
    }

    /// The wire key is the one the deployed server already writes, so the spelling fix is not a
    /// contract change.
    ///
    /// Worth pinning, because the obvious worry about renaming a Codable property is that it moves the
    /// wire key and breaks a deployment. For a trailing acronym under `.convertToSnakeCase` it does
    /// not: both spellings produce the same key, which is exactly why the fix is safe and why the bug
    /// was so quiet.
    func testTheWireKeyIsUnchangedByTheSpelling() throws {
        let bytes = try serverEncoder.encode(
            NearbySelfStatus(mayTriggerDemoGreet: true, demoGreetCounterpartId: UUID())
        )
        let json = try XCTUnwrap(
            try JSONSerialization.jsonObject(with: bytes) as? [String: Any],
            "the status must encode as an object"
        )
        XCTAssertNotNil(
            json["demo_greet_counterpart_id"],
            "the deployed server writes this key and a client must keep reading it: \(json.keys.sorted())"
        )
        XCTAssertNil(
            json["demo_greet_counterpart_i_d"],
            "a key split on the acronym would be a real contract change rather than a spelling fix"
        )
    }

    /// A server that predates the fields still disables everything, which was already true and must
    /// stay true. Decoded through the real strategy this time, which the original test did not do.
    func testAServerThatPredatesTheFieldsStillDrawsNothing() throws {
        let legacy = Data("""
        {"pause_default_seconds":3600,"freezes_remaining_today":2,"freeze_allowance_per_day":3,
         "outstanding_reservations":0,"reservation_allowance":2,"people_waiting_for_you":0}
        """.utf8)
        let decoded = try clientDecoder.decode(NearbySelfStatus.self, from: legacy)
        XCTAssertFalse(decoded.mayTriggerDemoGreet)
        XCTAssertNil(decoded.demoGreetCounterpartId)
    }

    /// Every other field on this type survives the same round trip.
    ///
    /// The counterpart identifier was the one that broke, and the reason it broke applies to any
    /// field added later with the same spelling habit. Rather than assert the one field, assert the
    /// whole type, so the next field added is covered by construction.
    func testEveryFieldOnTheStatusSurvivesTheRoundTrip() throws {
        let sent = NearbySelfStatus(
            pausedUntil: nil,
            pauseDefaultSeconds: 1800,
            freezesRemainingToday: 2,
            freezeAllowancePerDay: 3,
            outstandingReservations: 1,
            reservationAllowance: 2,
            peopleWaitingForYou: 4,
            mayTriggerDemoGreet: true,
            demoGreetCounterpartId: UUID()
        )
        let received = try clientDecoder.decode(
            NearbySelfStatus.self,
            from: try serverEncoder.encode(sent)
        )
        XCTAssertEqual(received.pauseDefaultSeconds, sent.pauseDefaultSeconds)
        XCTAssertEqual(received.freezesRemainingToday, sent.freezesRemainingToday)
        XCTAssertEqual(received.freezeAllowancePerDay, sent.freezeAllowancePerDay)
        XCTAssertEqual(received.outstandingReservations, sent.outstandingReservations)
        XCTAssertEqual(received.reservationAllowance, sent.reservationAllowance)
        XCTAssertEqual(received.peopleWaitingForYou, sent.peopleWaitingForYou)
        XCTAssertEqual(received.mayTriggerDemoGreet, sent.mayTriggerDemoGreet)
        XCTAssertEqual(received.demoGreetCounterpartId, sent.demoGreetCounterpartId)
    }
}
