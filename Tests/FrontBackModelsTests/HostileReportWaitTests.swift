//
//  HostileReportWaitTests.swift
//  AkinFrontBackModelsTests
//
//  GOAL_LOOP40 item 655, the D2 hostile wait.
//
//  Why this file exists: on 2026-11-08 the escalation rule had no test in any of the three
//  repositories. Nothing in AkinFrontBackModels, akin-server-side or VenueReferralAppClipTests
//  referenced `hostileReportWait`, `currentWait`, `declineWaitDays` or `hideLengthPhrase`, and
//  three copy items in that loop were blocked waiting on the behaviour.
//
//  What this file deliberately does NOT pin. `hostileReportWait` takes the current wait as an
//  argument, and the open question is what the CALLER passes: the server's loop seeds it with
//  zero, so a venue holding at the ninety day refusal freeze drops to ten on its first counted
//  hostile report. Whether that is intended is a product question (decision 3 of the loop's
//  handoff), and it lives in the caller, not here. Everything below tests the rule the decisions
//  table states, "at least ten days, otherwise three times the current wait, capped at ninety",
//  which is true whatever the caller seeds.
//

import XCTest
@testable import AkinFrontBackModels

final class HostileReportWaitTests: XCTestCase {

    private typealias Policy = VenueCooldownPolicy
    private let day: TimeInterval = 24 * 60 * 60

    // MARK: - The two bounds the rule names

    /// "At least ten days". A venue with nothing banked still gets the floor, because the point
    /// of the floor is that a first report is never worth nothing.
    func testAFirstReportFromNothingGivesExactlyTheFloor() {
        XCTAssertEqual(Policy.hostileReportWait(currentWait: 0), Policy.hostileReportFloor)
        XCTAssertEqual(Policy.hostileReportFloor, 10 * day, "the floor is ten days")
    }

    /// "Capped at ninety". Three times thirty is ninety, and three times ninety is not two
    /// hundred and seventy. The cap is the only thing standing between a handful of reports and
    /// a permanent hold.
    func testTheCeilingHoldsAndNothingEverExceedsIt() {
        XCTAssertEqual(Policy.hostileReportWait(currentWait: 30 * day), 90 * day)
        XCTAssertEqual(Policy.hostileReportWait(currentWait: 90 * day), Policy.hostileReportCeiling)
        XCTAssertEqual(Policy.hostileReportWait(currentWait: 365 * day), Policy.hostileReportCeiling)
        XCTAssertEqual(Policy.hostileReportCeiling, 90 * day, "the ceiling is ninety days")
    }

    /// Every input lands inside the two bounds, including the ones a caller should never send.
    /// A negative wait is not reachable through the server's own path, but the rule is public and
    /// `max` is what keeps it honest, so the floor is asserted rather than assumed.
    func testEveryResultSitsBetweenTheFloorAndTheCeiling() {
        let inputs: [TimeInterval] = [-1, 0, 1, day, 3 * day, 10 * day, 29 * day, 30 * day,
                                      31 * day, 89 * day, 90 * day, 1_000 * day]
        for input in inputs {
            let result = Policy.hostileReportWait(currentWait: input)
            XCTAssertGreaterThanOrEqual(result, Policy.hostileReportFloor,
                                        "a wait of \(input / day) days fell below the floor")
            XCTAssertLessThanOrEqual(result, Policy.hostileReportCeiling,
                                     "a wait of \(input / day) days exceeded the ceiling")
        }
    }

    // MARK: - "Three times the current wait"

    /// The tripling, in the one band where neither bound is binding: above the floor after
    /// tripling and below the ceiling after tripling.
    func testItTriplesWhereNeitherBoundBinds() {
        XCTAssertEqual(Policy.hostileReportWait(currentWait: 10 * day), 30 * day)
        XCTAssertEqual(Policy.hostileReportWait(currentWait: 20 * day), 60 * day)
        XCTAssertEqual(Policy.hostileReportWait(currentWait: 29 * day), 87 * day)
    }

    /// A longer wait never produces a shorter one. This is the property that makes the thing an
    /// escalation at all, and it is the one a future change to the floor or the cap could break
    /// without breaking any single example above.
    func testTheRuleNeverRewardsAWorseRecord() {
        var previous = Policy.hostileReportWait(currentWait: 0)
        for days in 1...200 {
            let next = Policy.hostileReportWait(currentWait: TimeInterval(days) * day)
            XCTAssertGreaterThanOrEqual(next, previous,
                                        "a wait of \(days) days produced less than \(days - 1)")
            previous = next
        }
    }

    /// Applying it repeatedly settles rather than growing without bound, and it settles ON the
    /// ceiling. A fixed point below the ceiling would mean a venue could stall part way up.
    func testRepeatedApplicationSettlesOnTheCeiling() {
        var wait: TimeInterval = 0
        var seen: [TimeInterval] = []
        for _ in 0..<12 {
            wait = Policy.hostileReportWait(currentWait: wait)
            seen.append(wait)
        }
        XCTAssertEqual(seen.prefix(3).map { $0 / day }, [10, 30, 90],
                       "the ladder from nothing is ten, thirty, ninety")
        XCTAssertEqual(wait, Policy.hostileReportCeiling,
                       "repeated reports settle on the ceiling, not above it")
        XCTAssertEqual(Policy.hostileReportWait(currentWait: Policy.hostileReportCeiling),
                       Policy.hostileReportCeiling, "the ceiling is a fixed point")
    }

    // MARK: - The floor against the other freezes

    /// Where the hostile floor sits among the other freezes, pinned as facts rather than as
    /// approvals, so that moving any of them is visible here.
    ///
    /// One of these is worth a second look rather than a nod. The floor is ten days and
    /// `alreadyKnewFreeze` is thirty, so a FIRST report that the staff were rude or made the
    /// member feel unwelcome buys less quiet than a report that the venue had simply heard of
    /// the app already. That is the same shape as the question in decision 3 of GOAL_LOOP40's
    /// handoff, where the first hostile report takes a refusing venue's hold down from ninety
    /// days to ten. Both come from the floor being a starting rung rather than a minimum applied
    /// to whatever the venue already had. This test asserts today's values; it does not claim
    /// they are the ones Scott wants.
    func testWhereTheFloorSitsAmongTheOtherFreezes() {
        XCTAssertGreaterThan(Policy.hostileReportFloor, Policy.noChanceFreeze,
                             "a hostile report outlasts a no chance answer")
        XCTAssertGreaterThan(Policy.hostileReportFloor, Policy.receptiveFreeze,
                             "a hostile report outlasts an interested answer")
        XCTAssertLessThan(Policy.hostileReportFloor, Policy.alreadyKnewFreeze,
                          "today a first hostile report buys LESS quiet than already knew")
        XCTAssertEqual(Policy.hostileReportCeiling, Policy.declinedFreeze,
                       "the cap and the refusal freeze are the same ninety days")
    }
}
