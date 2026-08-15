//
//  VenueAwarenessTests.swift
//  AkinFrontBackModelsTests
//
//  VENUE_PARTNERSHIP_GOAL_LOOP.md items 3.1, 3.2, 3.3, 3.4, and 7.3.
//

import XCTest
@testable import AkinFrontBackModels

final class VenueAwarenessTests: XCTestCase {

    // MARK: - 3.1 Transitions are explicit and total

    /// Every ordered pair of states is decided, and each rejection carries its own
    /// sentence. The point of the test is that nothing falls through a default arm:
    /// twenty five pairs go in, twenty five verdicts come out, and no two rejections
    /// say the same thing.
    func testEveryStatePairIsExplicitlyAllowedOrExplicitlyRejected() {
        let states = VenueAwarenessState.allCases
        XCTAssertEqual(states.count, 5)

        var allowedPairs: [(VenueAwarenessState, VenueAwarenessState)] = []
        var rejectionReasons: [String] = []

        for from in states {
            for to in states {
                switch VenueAwarenessTransition.verdict(from: from, to: to) {
                case .allowed:
                    allowedPairs.append((from, to))
                case .rejected(let rejection):
                    XCTAssertEqual(rejection.from, from)
                    XCTAssertEqual(rejection.to, to)
                    XCTAssertFalse(
                        rejection.reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                        "\(from.rawValue) to \(to.rawValue) was rejected with an empty reason"
                    )
                    XCTAssertFalse(
                        rejection.reason.lowercased().contains("unknown"),
                        "\(from.rawValue) to \(to.rawValue) rejected with an unknown reason"
                    )
                    rejectionReasons.append(rejection.reason)
                }
            }
        }

        XCTAssertEqual(
            allowedPairs.count + rejectionReasons.count,
            states.count * states.count,
            "Every one of the 25 ordered pairs must produce a verdict"
        )

        XCTAssertEqual(
            Set(rejectionReasons).count,
            rejectionReasons.count,
            "Two different rejected transitions share a reason string, so a log line cannot tell them apart"
        )
    }

    /// The exact shape of the transition table, so a change to it is a deliberate
    /// edit to this list rather than an accident.
    func testTheAllowedTransitionTableIsWhatWeIntended() {
        let expectedAllowed: Set<String> = [
            "unaware->unaware", "unaware->pitched", "unaware->aware", "unaware->engaged",
            "unaware->declined",
            "pitched->pitched", "pitched->aware", "pitched->engaged", "pitched->declined",
            "aware->pitched", "aware->aware", "aware->engaged", "aware->declined",
            "engaged->engaged", "engaged->declined",
            "declined->pitched", "declined->aware", "declined->engaged", "declined->declined",
        ]

        var actualAllowed: Set<String> = []
        for from in VenueAwarenessState.allCases {
            for to in VenueAwarenessState.allCases where
                VenueAwarenessTransition.verdict(from: from, to: to).isAllowed {
                actualAllowed.insert("\(from.rawValue)->\(to.rawValue)")
            }
        }

        XCTAssertEqual(actualAllowed, expectedAllowed)
    }

    /// Awareness is knowledge, and knowledge does not un-happen. Nothing may return
    /// to `unaware` once it has left.
    func testNothingEverReturnsToUnaware() {
        for from in VenueAwarenessState.allCases where from != .unaware {
            XCTAssertFalse(
                VenueAwarenessTransition.verdict(from: from, to: .unaware).isAllowed,
                "\(from.rawValue) must not be able to become unaware again"
            )
        }
    }

    /// The state an outcome produces must itself be a legal transition, so the two
    /// halves of the model cannot disagree.
    func testEveryOutcomeProducesALegalTransitionFromEveryState() {
        for from in VenueAwarenessState.allCases {
            for outcome in VenuePitchOutcome.allCases {
                let next = VenueAwarenessTransition.state(after: outcome, from: from)
                XCTAssertTrue(
                    VenueAwarenessTransition.verdict(from: from, to: next).isAllowed,
                    "\(outcome.rawValue) from \(from.rawValue) produced \(next.rawValue), which the table rejects"
                )
            }
        }
    }

    // MARK: - 3.2 Shift buckets

    /// Total across all twenty four hours, with no hour landing in two buckets and
    /// none landing in none.
    func testEveryHourOfTheDayHasExactlyOneBucket() throws {
        var buckets: [VenueShiftBucket] = []
        for hour in 0...23 {
            buckets.append(try VenueShiftBucket.forLocalHour(hour))
        }

        XCTAssertEqual(buckets.count, 24)
        XCTAssertEqual(
            Set(buckets),
            Set(VenueShiftBucket.allCases),
            "Some named bucket covers no hour of the day, which means it can never fire"
        )
    }

    func testHoursOutsideTheDayThrowRatherThanPickABucket() {
        for hour in [-1, 24, 99] {
            XCTAssertThrowsError(try VenueShiftBucket.forLocalHour(hour)) { error in
                guard case VenueAwarenessError.hourOutsideDay(let reported) = error else {
                    return XCTFail("Expected hourOutsideDay, got \(error)")
                }
                XCTAssertEqual(reported, hour)
            }
        }
    }

    /// Bucketing runs on the venue's clock, not the server's. The same instant is a
    /// different shift in Los Angeles and in London.
    func testTheSameInstantBucketsDifferentlyInDifferentVenueTimeZones() throws {
        // 2026-08-14T02:00:00Z. That is 19:00 the previous evening in Los Angeles
        // and 03:00 in London.
        let instant = Date(timeIntervalSince1970: 1_786_672_800)

        let losAngeles = try VenueShiftBucket.forDate(
            instant,
            timeZoneIdentifier: "America/Los_Angeles",
            venueName: "The Corner Bar"
        )
        let london = try VenueShiftBucket.forDate(
            instant,
            timeZoneIdentifier: "Europe/London",
            venueName: "The Corner Bar"
        )

        XCTAssertEqual(losAngeles, .evening)
        XCTAssertEqual(london, .overnight)
        XCTAssertNotEqual(losAngeles, london)
    }

    /// A venue with no timezone throws a named error. It does not quietly bucket in
    /// UTC, which would merge a closing crew with the next morning's.
    func testAVenueWithoutATimeZoneThrowsRatherThanDefaultingToUTC() {
        for missing in [nil, ""] as [String?] {
            XCTAssertThrowsError(
                try VenueShiftBucket.forDate(
                    Date(timeIntervalSince1970: 1_786_672_800),
                    timeZoneIdentifier: missing,
                    venueName: "The Corner Bar"
                )
            ) { error in
                guard case VenueAwarenessError.venueHasNoTimeZone(let venueName) = error else {
                    return XCTFail("Expected venueHasNoTimeZone, got \(error)")
                }
                XCTAssertEqual(venueName, "The Corner Bar")
                XCTAssertTrue(
                    "\(error)".contains("UTC"),
                    "The error should say what defaulting to UTC would have cost"
                )
            }
        }
    }

    func testAnUnrecognisedTimeZoneThrowsRatherThanGuessing() {
        XCTAssertThrowsError(
            try VenueShiftBucket.forDate(
                Date(timeIntervalSince1970: 1_786_672_800),
                timeZoneIdentifier: "Mars/Olympus_Mons",
                venueName: "The Corner Bar"
            )
        ) { error in
            guard case VenueAwarenessError.venueTimeZoneNotRecognised(let venueName, let identifier) = error else {
                return XCTFail("Expected venueTimeZoneNotRecognised, got \(error)")
            }
            XCTAssertEqual(venueName, "The Corner Bar")
            XCTAssertEqual(identifier, "Mars/Olympus_Mons")
        }
    }

    // MARK: - 3.3 Cooldown policy, table driven

    private let referenceNow = Date(timeIntervalSince1970: 1_786_672_800)

    private func context(
        state: VenueAwarenessState,
        outcome: VenuePitchOutcome?,
        pitchCount: Int,
        bucket: VenueShiftBucket = .evening,
        lastBucket: VenueShiftBucket? = nil,
        daysSinceLastPitch: Double?
    ) -> VenuePitchContext {
        VenuePitchContext(
            state: state,
            lastOutcome: outcome,
            pitchCountInWindow: pitchCount,
            shiftBucket: bucket,
            lastPitchShiftBucket: lastBucket,
            lastPitchAt: daysSinceLastPitch.map {
                referenceNow.addingTimeInterval(-$0 * 24 * 60 * 60)
            },
            now: referenceNow
        )
    }

    /// Every state times every outcome times the boundary pitch counts. The
    /// assertion is not on a specific verdict for each cell, it is that every cell
    /// produces a decided verdict and that every suppression carries a distinct,
    /// readable reason. A rule that fires with a borrowed sentence is a rule nobody
    /// can debug from a log.
    func testTheWholeCrossProductProducesDecidedVerdictsWithDistinctReasons() {
        let boundaryPitchCounts = [
            0,
            VenueCooldownPolicy.earlyPitchAllowance - 1,
            VenueCooldownPolicy.earlyPitchAllowance,
            VenueCooldownPolicy.earlyPitchAllowance + 1,
        ]
        let outcomes: [VenuePitchOutcome?] = [nil] + VenuePitchOutcome.allCases.map { $0 }

        var reasonsSeen: Set<String> = []
        var eligibleCells = 0
        var suppressedCells = 0

        for state in VenueAwarenessState.allCases {
            for outcome in outcomes {
                for pitchCount in boundaryPitchCounts {
                    for daysSince in [nil, 0.0, 1.5, 8.0, 31.0, 91.0] as [Double?] {
                        let subject = context(
                            state: state,
                            outcome: outcome,
                            pitchCount: pitchCount,
                            lastBucket: daysSince == nil ? nil : .morning,
                            daysSinceLastPitch: daysSince
                        )

                        switch VenueCooldownPolicy.evaluate(subject) {
                        case .eligible:
                            eligibleCells += 1

                        case .suppressed(let reason):
                            suppressedCells += 1
                            let trimmed = reason.trimmingCharacters(in: .whitespacesAndNewlines)
                            XCTAssertFalse(
                                trimmed.isEmpty,
                                "\(state.rawValue)/\(outcome?.rawValue ?? "none") suppressed with an empty reason"
                            )
                            XCTAssertFalse(
                                trimmed.lowercased().contains("unknown"),
                                "A suppression reason must never be unknown: \(trimmed)"
                            )
                            XCTAssertGreaterThan(
                                trimmed.split(separator: " ").count, 6,
                                "A suppression reason must be a sentence a person can act on: \(trimmed)"
                            )
                            reasonsSeen.insert(trimmed)
                        }
                    }
                }
            }
        }

        XCTAssertGreaterThan(eligibleCells, 0, "No cell was eligible, so the policy never lets anything through")
        XCTAssertGreaterThan(suppressedCells, 0)
        XCTAssertGreaterThanOrEqual(
            reasonsSeen.count, 5,
            "Fewer distinct reasons than rules means two rules are indistinguishable in a log"
        )
    }

    /// Aggressive early: a venue nobody has reported on gets two introductions
    /// before the adaptive rules take over, and they must be on different shifts.
    func testAVenueWithNothingReportedGetsTwoIntroductionsThenTheConservativeFreeze() {
        let first = context(state: .unaware, outcome: nil, pitchCount: 0, daysSinceLastPitch: nil)
        XCTAssertTrue(VenueCooldownPolicy.evaluate(first).isEligible)

        let second = context(
            state: .pitched, outcome: nil, pitchCount: 1,
            bucket: .morning, lastBucket: .evening, daysSinceLastPitch: 1.0
        )
        XCTAssertTrue(
            VenueCooldownPolicy.evaluate(second).isEligible,
            "The second introduction is the aggressive-early allowance"
        )

        let third = context(
            state: .pitched, outcome: nil, pitchCount: 2,
            bucket: .midday, lastBucket: .morning, daysSinceLastPitch: 1.0
        )
        let thirdVerdict = VenueCooldownPolicy.evaluate(third)
        XCTAssertFalse(thirdVerdict.isEligible)
        XCTAssertEqual(
            thirdVerdict.suppressionReason?.contains("nothing reported back"), true,
            "Got: \(thirdVerdict.suppressionReason ?? "no reason")"
        )

        let afterFreeze = context(
            state: .pitched, outcome: nil, pitchCount: 2,
            bucket: .midday, lastBucket: .morning, daysSinceLastPitch: 15.0
        )
        XCTAssertTrue(
            VenueCooldownPolicy.evaluate(afterFreeze).isEligible,
            "The conservative freeze is 14 days, so day 15 is eligible again"
        )
    }

    func testAReceptiveOutcomeShortensTheFreezeAndADeclineLengthensIt() {
        let receptiveInsideFreeze = context(
            state: .aware, outcome: .receptive, pitchCount: 1,
            bucket: .morning, lastBucket: .evening, daysSinceLastPitch: 3.0
        )
        XCTAssertFalse(VenueCooldownPolicy.evaluate(receptiveInsideFreeze).isEligible)

        let receptiveAfterFreeze = context(
            state: .aware, outcome: .receptive, pitchCount: 1,
            bucket: .morning, lastBucket: .evening, daysSinceLastPitch: 8.0
        )
        XCTAssertTrue(
            VenueCooldownPolicy.evaluate(receptiveAfterFreeze).isEligible,
            "Receptive is a 7 day freeze, so day 8 is open again"
        )

        let declinedAfterEightDays = context(
            state: .declined, outcome: .notReceptive, pitchCount: 1,
            bucket: .morning, lastBucket: .evening, daysSinceLastPitch: 8.0
        )
        XCTAssertFalse(
            VenueCooldownPolicy.evaluate(declinedAfterEightDays).isEligible,
            "A decline is a 90 day freeze, not a 7 day one"
        )

        // This assertion was true of the function and false of the system for the
        // whole of its life. `VenueIntroductionService.evaluate` read every pitch
        // through a thirty day counting window, so it could never hand this function
        // a `lastPitchAt` ninety one days old: by then the row had dropped out of the
        // query and the policy took its "no date was recorded" branch instead. The
        // ninety day freeze was permanent in practice, and this test passed
        // throughout, certifying behaviour no call path could reach.
        //
        // The server now reads the most recent pitch without that window.
        // `VenueIntroductionEndpointTests.testAVenueThatDeclinedNinetyOneDaysAgoIsOfferedAgain`
        // makes the same assertion through the real endpoint against a real row,
        // which is the version of it that is about the system. Keep the two together.
        let declinedAfterNinetyOneDays = context(
            state: .declined, outcome: .notReceptive, pitchCount: 1,
            bucket: .morning, lastBucket: .evening, daysSinceLastPitch: 91.0
        )
        XCTAssertTrue(VenueCooldownPolicy.evaluate(declinedAfterNinetyOneDays).isEligible)
    }

    func testAnEngagedVenueIsNeverIntroducedToTheThingItIsAlreadyRunning() {
        for outcome in [nil] + VenuePitchOutcome.allCases.map({ $0 }) {
            let subject = context(
                state: .engaged, outcome: outcome, pitchCount: 0, daysSinceLastPitch: 400.0
            )
            let verdict = VenueCooldownPolicy.evaluate(subject)
            XCTAssertFalse(verdict.isEligible)
            XCTAssertEqual(verdict.suppressionReason?.contains("already has Map Mates"), true)
        }
    }

    // MARK: - 3.4 Showing the card spends the budget

    /// The card was shown, nobody reported anything, and the next customer at the
    /// same venue on the same shift is suppressed. The venue may have been pitched
    /// whether or not the report arrived.
    func testShowingTheCardSuppressesTheNextCheckForTheSameVenueAndShift() {
        let shown = context(state: .unaware, outcome: nil, pitchCount: 0, daysSinceLastPitch: nil)
        XCTAssertTrue(VenueCooldownPolicy.evaluate(shown).isEligible)

        // Same venue, same shift, four minutes later, no outcome reported.
        let nextCustomer = VenuePitchContext(
            state: .pitched,
            lastOutcome: nil,
            pitchCountInWindow: 1,
            shiftBucket: .evening,
            lastPitchShiftBucket: .evening,
            lastPitchAt: referenceNow.addingTimeInterval(-240),
            now: referenceNow
        )

        let verdict = VenueCooldownPolicy.evaluate(nextCustomer)
        XCTAssertFalse(
            verdict.isEligible,
            "Showing the card must spend the budget even with no outcome reported"
        )
        XCTAssertEqual(verdict.suppressionReason?.contains("evening shift"), true)
    }

    /// A different shift on the same day is a different audience, so it opens again.
    func testTheNextShiftIsADifferentAudienceAndOpensAgain() {
        let nextShift = VenuePitchContext(
            state: .pitched,
            lastOutcome: nil,
            pitchCountInWindow: 1,
            shiftBucket: .morning,
            lastPitchShiftBucket: .evening,
            lastPitchAt: referenceNow.addingTimeInterval(-11 * 60 * 60),
            now: referenceNow
        )
        XCTAssertTrue(VenueCooldownPolicy.evaluate(nextShift).isEligible)
    }

    /// The same named bucket a week later is not the same shift.
    func testTheSameBucketAWeekLaterIsNotTheSameShift() {
        let aWeekLater = VenuePitchContext(
            state: .pitched,
            lastOutcome: .noChance,
            pitchCountInWindow: 1,
            shiftBucket: .evening,
            lastPitchShiftBucket: .evening,
            lastPitchAt: referenceNow.addingTimeInterval(-7 * 24 * 60 * 60),
            now: referenceNow
        )
        XCTAssertTrue(
            VenueCooldownPolicy.evaluate(aWeekLater).isEligible,
            "noChance is a one day freeze and a week has passed, so this is open"
        )
    }

    // MARK: - 7.3 Experiment assignment is stable

    func testMotivationArmIsStableForTheSameUserAndReachesBothArms() {
        let identifier = UUID(uuidString: "6BA7B810-9DAD-11D1-80B4-00C04FD430C8")!
        let first = VenueMotivationArm.forUser(identifier)
        for _ in 0..<50 {
            XCTAssertEqual(VenueMotivationArm.forUser(identifier), first)
        }

        var arms: Set<VenueMotivationArm> = []
        for _ in 0..<400 {
            arms.insert(VenueMotivationArm.forUser(UUID()))
        }
        XCTAssertEqual(arms, Set(VenueMotivationArm.allCases), "Both arms must be reachable")
    }

    // MARK: - 3.7 Errors are distinct and none of them just say something went wrong

    func testEveryErrorCaseProducesADistinctMessageAndNoneOfThemSayFailed() {
        let errors: [VenueAwarenessError] = [
            .unknownVenue(identifier: "venue-1"),
            .venueHasNoTimeZone(venueName: "The Corner Bar"),
            .venueTimeZoneNotRecognised(venueName: "The Corner Bar", identifier: "Mars/Olympus_Mons"),
            .malformedOutcome(received: "maybe", accepted: VenuePitchOutcome.allCases.map(\.rawValue)),
            .staleCorrelationIdentifier(identifier: "corr-1", ageInSeconds: 90_000),
            .pitchBudgetExhausted(venueName: "The Corner Bar", shiftBucket: .evening, reason: "Already shown this shift."),
            .hourOutsideDay(hour: 25),
            .unknownGreet(identifier: "greet-1"),
            .callerNotInGreet(callerIdentifier: "user-1", greetIdentifier: "greet-1"),
        ]

        let messages = errors.map(\.description)
        XCTAssertEqual(Set(messages).count, messages.count, "Two error cases produce the same message")

        for message in messages {
            XCTAssertGreaterThan(
                message.split(separator: " ").count, 12,
                "An error must carry enough context to diagnose without reading the caller: \(message)"
            )
            let words = message.lowercased().split(whereSeparator: { !$0.isLetter }).map(String.init)
            XCTAssertFalse(
                words.contains("failed"),
                "An error message must say what went wrong, not just that something failed: \(message)"
            )
        }
    }
}

// MARK: - 6.1 Role routing

final class VenueScanRoleTests: XCTestCase {

    /// A code with no role is a customer code, which is every code printed before
    /// roles existed.
    func testAnAbsentOrEmptyRoleIsACustomer() throws {
        XCTAssertEqual(try VenueScanRole.resolve(rawValue: nil), .customer)
        XCTAssertEqual(try VenueScanRole.resolve(rawValue: ""), .customer)
        XCTAssertEqual(try VenueScanRole.resolve(rawValue: "   "), .customer)
    }

    func testARecognisedRoleResolvesToItself() throws {
        XCTAssertEqual(try VenueScanRole.resolve(rawValue: "customer"), .customer)
        XCTAssertEqual(try VenueScanRole.resolve(rawValue: "venue"), .venue)
        XCTAssertEqual(try VenueScanRole.resolve(rawValue: "  venue  "), .venue)
    }

    /// The case the goal loop calls out: an unrecognised role must not fall through
    /// to the customer path.
    func testAnUnrecognisedRoleThrowsRatherThanFallingThroughToTheCustomerPath() {
        for received in ["owner", "staff", "VENUE", "manager"] {
            XCTAssertThrowsError(try VenueScanRole.resolve(rawValue: received)) { error in
                guard case VenueScanRoleError.unrecognised(let reported, let accepted) = error else {
                    return XCTFail("Expected unrecognised, got \(error)")
                }
                XCTAssertEqual(reported, received)
                XCTAssertEqual(Set(accepted), ["customer", "venue"])
                // What the reader is told, rather than why we chose to fail.
                //
                // This used to require the words "customer screen", which came from
                // a sentence explaining our own design reasoning to whoever was
                // holding the phone, in our words, including "record their scan
                // against the wrong funnel". A professionalism scan caught it: none
                // of that is something a person behind a counter can act on. The
                // reasoning now lives in the type's doc comment, and the message
                // says what to do.
                let message = "\(error)"
                XCTAssertTrue(
                    message.contains("try again") || message.contains("second try"),
                    "The message has to tell the reader what to do. Got: \(message)"
                )
                XCTAssertFalse(
                    message.lowercased().contains("funnel"),
                    "Our words, not theirs. Got: \(message)"
                )
            }
        }
    }

    func testEveryAudienceNamesADistinctVideoAndTitle() {
        let identifiers = VenueAudience.allCases.map(\.videoIdentifier)
        XCTAssertEqual(Set(identifiers).count, identifiers.count)
        let titles = VenueAudience.allCases.map(\.title)
        XCTAssertEqual(Set(titles).count, titles.count)
        for title in titles {
            XCTAssertFalse(title.isEmpty)
        }
    }
}

// MARK: - Version skew

/// An App Clip in the wild is always an older binary than the server it talks to.
///
/// The synthesised decoder threw `keyNotFound` the first time a field was added,
/// and the venue branch answered a real scan with "This code did not resolve. The
/// data couldn't be read because it is missing", which blames the code in the
/// customer's hand for a deployment ordering.
final class VenueWireCompatibilityTests: XCTestCase {

    func testAScanResponseFromAnOlderServerStillDecodes() throws {
        let older = """
        {
          "venueName": "The Corner Bar",
          "usersSentToVenueThisMonth": 14,
          "participatingStaffCount": 2,
          "isOrphan": false
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(VenueScanResponse.self, from: older)
        XCTAssertEqual(decoded.venueName, "The Corner Bar")
        XCTAssertEqual(decoded.usersSentToVenueThisMonth, 14)
        XCTAssertEqual(decoded.participatingStaffNames, [])
        XCTAssertEqual(decoded.periodDescription, "")
        XCTAssertFalse(decoded.isOrphan)
    }

    func testAnEligibilityResponseFromAnOlderServerStillDecodes() throws {
        let older = """
        {
          "isEligible": true,
          "venueName": "The Corner Bar",
          "awarenessState": "pitched",
          "shiftBucket": "evening",
          "usersSentToVenueThisMonth": 14,
          "participatingStaffNames": ["Dana"],
          "experimentArm": "intrinsic"
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(VenueEligibilityResponse.self, from: older)
        XCTAssertTrue(decoded.isEligible)
        XCTAssertEqual(decoded.participatingStaffNames, ["Dana"])
        XCTAssertEqual(decoded.periodDescription, "")
        XCTAssertNil(decoded.venueGooglePlaceIdentifier)
    }

    /// The fields that were there on day one are still required. A decoder that
    /// defaults everything cannot tell a malformed response from an empty one.
    func testAResponseMissingAFoundingFieldStillThrows() {
        let broken = """
        { "usersSentToVenueThisMonth": 14, "participatingStaffCount": 2, "isOrphan": false }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try JSONDecoder().decode(VenueScanResponse.self, from: broken))
    }

    /// A newer server sending a field this binary has never heard of is ignored,
    /// which is the other half of the same problem.
    func testAResponseFromANewerServerIgnoresWhatItDoesNotKnow() throws {
        let newer = """
        {
          "venueName": "The Corner Bar",
          "usersSentToVenueThisMonth": 14,
          "participatingStaffCount": 2,
          "participatingStaffNames": ["Dana", "Ravi"],
          "periodDescription": "1 August to 14 August, America/Chicago",
          "isOrphan": false,
          "somethingInventedNextYear": { "nested": true }
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(VenueScanResponse.self, from: newer)
        XCTAssertEqual(decoded.participatingStaffNames, ["Dana", "Ravi"])
        XCTAssertTrue(decoded.periodDescription.contains("America/Chicago"))
    }
}

/// The write rules, decided exhaustively rather than by example.
///
/// This type used to decide where the venue moved as well, from a snapshot each row
/// kept of what its own answer displaced. Four consecutive adversarial passes found
/// a defect in that machinery and three of those defects were introduced by the
/// previous pass's fix. It is gone: ``VenueAwarenessFold`` computes the state from
/// the rows, and the only question left here is whether one report replaces what one
/// row already says.
final class VenueOutcomeAuthorityTests: XCTestCase {

    /// Every combination of inputs, which is what "total" means here.
    private func allContexts() -> [VenueOutcomeContext] {
        var contexts: [VenueOutcomeContext] = []
        let outcomes = VenuePitchOutcome.allCases
        let sources = VenueOutcomeSource.allCases

        for reported in outcomes {
            for source in sources {
                for existing in [nil] + outcomes.map(Optional.some) {
                    for existingSource in [nil] + sources.map(Optional.some) {
                        contexts.append(
                            VenueOutcomeContext(
                                reported: reported,
                                source: source,
                                existing: existing,
                                existingSource: existingSource
                            )
                        )
                    }
                }
            }
        }
        return contexts
    }

    func testEveryCombinationDecidesAndCarriesAReason() {
        let contexts = allContexts()
        XCTAssertEqual(contexts.count, 5 * 3 * 6 * 4)

        for context in contexts {
            let decision = VenueOutcomeAuthority.decide(context)
            XCTAssertFalse(
                decision.reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                "A decision with no reason cannot be read off a log line"
            )
        }
    }

    /// A customer never overwrites what the venue said for itself.
    func testACustomerNeverOverwritesTheVenuesOwnWord() {
        for context in allContexts() where context.existing != nil
            && context.existingSource == .venueBranch
            && context.source != .venueBranch {
            XCTAssertFalse(
                VenueOutcomeAuthority.decide(context).writesTheAnswer,
                """
                \(context.source.rawValue) overwrote the venue's own \
                \(context.existing?.rawValue ?? "answer")
                """
            )
        }
    }

    /// The venue may always correct itself, and so may any surface.
    func testASurfaceMayAlwaysCorrectItself() {
        for context in allContexts() where context.existing != nil
            && context.existingSource == context.source {
            XCTAssertTrue(
                VenueOutcomeAuthority.decide(context).writesTheAnswer,
                "\(context.source.rawValue) could not correct its own answer"
            )
        }
    }

    /// A rating screen answer, given hours later from memory, does not overwrite the
    /// card answered at the counter. The card overwrites the rating screen.
    func testTheCardOutranksTheRatingScreen() {
        let ratingOverCard = VenueOutcomeContext(
            reported: .receptive,
            source: .ratingScreen,
            existing: .notReceptive,
            existingSource: .card
        )
        XCTAssertFalse(VenueOutcomeAuthority.decide(ratingOverCard).writesTheAnswer)

        let cardOverRating = VenueOutcomeContext(
            reported: .receptive,
            source: .card,
            existing: .notReceptive,
            existingSource: .ratingScreen
        )
        XCTAssertTrue(VenueOutcomeAuthority.decide(cardOverRating).writesTheAnswer)
    }

    /// A row that has never been answered takes whatever arrives first.
    func testAnUnansweredRowTakesTheFirstReportFromAnySurface() {
        for context in allContexts() where context.existing == nil {
            XCTAssertTrue(
                VenueOutcomeAuthority.decide(context).writesTheAnswer,
                "\(context.source.rawValue) could not answer an unanswered introduction"
            )
        }
    }
}

/// Where a venue stands, read back from its introductions.
///
/// The two sequences at the top are the ones the snapshot design could not get
/// right in either setting of its ownership gate. They were pinned here as failing
/// tests asserting the CORRECT answer, so that they would start passing the day the
/// object was fixed rather than needing to be rewritten. They pass now.
final class VenueAwarenessFoldTests: XCTestCase {

    private let now = Date(timeIntervalSince1970: 1_780_000_000)

    private func row(
        _ outcome: VenuePitchOutcome? = nil,
        source: VenueOutcomeSource? = nil,
        secondsAgo: TimeInterval = 60,
        shownSecondsAgo: TimeInterval? = nil,
        scanned: Bool = false,
        joined: Bool = false
    ) -> VenuePitchStanding {
        VenuePitchStanding(
            outcome: outcome,
            source: outcome == nil ? nil : (source ?? .card),
            outcomeReportedAt: outcome == nil ? nil : now.addingTimeInterval(-secondsAgo),
            shownAt: now.addingTimeInterval(-(shownSecondsAgo ?? secondsAgo + 60)),
            venueScannedAt: scanned ? now.addingTimeInterval(-secondsAgo) : nil,
            venueJoinedAt: joined ? now.addingTimeInterval(-secondsAgo) : nil
        )
    }

    private func state(_ rows: [VenuePitchStanding]) -> VenueAwarenessState {
        VenueAwarenessFold.state(of: rows, now: now)
    }

    // MARK: - The two sequences the snapshot could not answer

    /// Three taps. A refuses, B says it went well, A takes the refusal back.
    ///
    /// The venue used to hold ninety days with nobody on record as having refused
    /// it, and the same three answers in the other order gave seven.
    func testARetractedRefusalDoesNotLeaveTheVenueFrozenBehindIt() {
        let aWithdrew = row(.skipped, secondsAgo: 10)
        let bWasWarm = row(.receptive, secondsAgo: 30)

        XCTAssertEqual(state([aWithdrew, bWasWarm]), .aware)
        XCTAssertEqual(
            state([bWasWarm, aWithdrew]), .aware,
            "The same three taps in the other order gave a different answer"
        )
    }

    /// Four taps. Both people refuse, both retract.
    ///
    /// The venue used to be frozen with both rows reading `skipped`.
    func testBothPeopleRefusingAndBothRetractingLeavesNoRefusalStanding() {
        let both = [row(.skipped, secondsAgo: 5), row(.skipped, secondsAgo: 10)]
        XCTAssertEqual(state(both), .pitched)
        XCTAssertEqual(state(both.reversed()), .pitched)
    }

    // MARK: - The terms, in order

    func testNoIntroductionsMeansTheVenueHasNeverHeardOfIt() {
        XCTAssertEqual(state([]), .unaware)
    }

    func testACardShownAndNothingSaidIsPitched() {
        XCTAssertEqual(state([row()]), .pitched)
    }

    func testAnAnswerThatImpliesNothingLeavesTheVenuePitched() {
        XCTAssertEqual(state([row(.noChance), row(.skipped)]), .pitched)
    }

    func testAStandingRefusalDeclinesTheVenue() {
        XCTAssertEqual(state([row(.notReceptive), row(.receptive)]), .declined)
    }

    /// A refusal holds for exactly the freeze it bought, and not a day longer.
    ///
    /// If the term that reads the most recent implying answer also mapped
    /// `notReceptive`, an aged out refusal would be excluded by the refusal term and
    /// readmitted by that one, and the ninety days would never end.
    func testARefusalStopsHoldingOnceItsFreezeHasRunOut() {
        let aged = VenueCooldownPolicy.declinedFreeze + 60
        XCTAssertEqual(state([row(.notReceptive, secondsAgo: aged)]), .pitched)
        XCTAssertEqual(
            state([row(.notReceptive, secondsAgo: aged), row(.receptive, secondsAgo: 30)]),
            .aware
        )
    }

    func testACodeMakesTheVenueEngaged() {
        XCTAssertEqual(state([row(.receptive), row(joined: true)]), .engaged)
    }

    /// A customer's refusal does not revoke a code that exists.
    func testACustomersRefusalDoesNotUnmakeACode() {
        XCTAssertEqual(state([row(joined: true), row(.notReceptive)]), .engaged)
    }

    /// The venue asking to be left alone after making a code is declined.
    func testTheVenuesOwnRefusalAfterItsCodeDeclinesIt() {
        XCTAssertEqual(
            state([row(secondsAgo: 600, joined: true), row(.notReceptive, source: .venueBranch)]),
            .declined
        )
    }

    /// And a venue that made a code after refusing has changed its mind the other
    /// way, so it is not dragged back to declined.
    func testAVenueThatJoinsAfterRefusingIsEngaged() {
        XCTAssertEqual(
            state([row(.notReceptive, source: .venueBranch, secondsAgo: 600), row(secondsAgo: 10, joined: true)]),
            .engaged
        )
    }

    /// A refusal is timed from the introduction it belongs to, on the same clock the
    /// cooldown times its ninety days on.
    func testARefusalAgesOnTheSameClockTheCooldownUses() {
        let stale = VenueCooldownPolicy.declinedFreeze + 86_400
        let answeredJustNow = VenuePitchStanding(
            outcome: .notReceptive,
            source: .card,
            outcomeReportedAt: now,
            shownAt: now.addingTimeInterval(-stale),
            venueScannedAt: nil,
            venueJoinedAt: nil
        )
        XCTAssertEqual(
            state([answeredJustNow]), .pitched,
            "The introduction is a hundred days old, so the freeze it bought has run out"
        )
    }

    /// A scan is the venue's own action, so it needs no reported outcome.
    func testAScanMakesTheVenueAwareWithNothingReported() {
        XCTAssertEqual(state([row(scanned: true)]), .aware)
    }

    /// The venue's own word outranks a customer's, whichever came first.
    func testTheVenuesOwnWordOutranksACustomersLaterOne() {
        let venueSaidSo = row(.alreadyKnew, source: .venueBranch, secondsAgo: 600)
        let customerSaidNothingUseful = row(.skipped, secondsAgo: 10)
        XCTAssertEqual(state([venueSaidSo, customerSaidNothingUseful]), .aware)
    }

    // MARK: - Properties, over every small combination rather than examples

    /// Every set of rows this can be handed, up to three of them, drawn from a set
    /// of standings wide enough to include each term.
    private func allSmallSets() -> [[VenuePitchStanding]] {
        let choices: [VenuePitchStanding] = [
            row(),
            row(.skipped),
            row(.noChance),
            row(.receptive),
            row(.alreadyKnew, source: .venueBranch),
            row(.notReceptive),
            row(.notReceptive, source: .venueBranch),
            row(.notReceptive, secondsAgo: VenueCooldownPolicy.declinedFreeze + 60),
            row(scanned: true),
            row(joined: true),
        ]
        var sets: [[VenuePitchStanding]] = [[]]
        for first in choices {
            sets.append([first])
            for second in choices {
                sets.append([first, second])
                for third in choices {
                    sets.append([first, second, third])
                }
            }
        }
        return sets
    }

    /// The answer does not depend on the order the answers arrived in.
    ///
    /// This is the property the snapshot design could not hold, and it is the reason
    /// the fold takes a set of rows rather than one row and a stored state.
    func testTheStateDoesNotDependOnTheOrderOfTheRows() {
        for rows in allSmallSets() where rows.count <= 3 {
            let forwards = state(rows)
            let backwards = state(rows.reversed())
            XCTAssertEqual(
                forwards, backwards,
                "\(rows.count) rows folded to \(forwards.rawValue) one way and \(backwards.rawValue) the other"
            )
        }
    }

    /// Adding an introduction never takes a venue out of `engaged`, unless the venue
    /// itself is the one refusing.
    ///
    /// This is what makes the three transitions out of `engaged` that the table
    /// rejects unreachable: a code cannot be revoked by a customer.
    func testEngagementIsMonotoneAgainstCustomers() {
        let joined = row(secondsAgo: 600, joined: true)
        for rows in allSmallSets() where rows.count <= 2 {
            let customerRows = rows.filter { $0.source != .venueBranch }
            XCTAssertEqual(
                state([joined] + customerRows), .engaged,
                "A customer's report moved a venue that holds a code"
            )
        }
    }

    /// Every state the fold produces is one the transition table allows from the
    /// state the same rows produced before the newest one was added.
    func testEveryStepIsATransitionTheTableAllows() {
        let joined = row(secondsAgo: 600, joined: true)
        for rows in allSmallSets() where rows.isEmpty == false && rows.count <= 3 {
            let before = state(Array(rows.dropLast()))
            let after = state(rows)
            XCTAssertTrue(
                VenueAwarenessTransition.verdict(from: before, to: after).isAllowed,
                """
                \(rows.count) rows moved the venue from \(before.rawValue) to \
                \(after.rawValue), which the table refuses
                """
            )
        }
        // And the same, starting from a venue that already holds a code.
        for rows in allSmallSets() where rows.isEmpty == false && rows.count <= 2 {
            let before = state([joined] + Array(rows.dropLast()))
            let after = state([joined] + rows)
            XCTAssertTrue(
                VenueAwarenessTransition.verdict(from: before, to: after).isAllowed,
                """
                a venue holding a code moved from \(before.rawValue) to \
                \(after.rawValue), which the table refuses
                """
            )
        }
    }

    /// A venue that has had any introduction at all is never read as never having
    /// heard of it.
    func testAVenueWithAnyIntroductionIsNeverUnaware() {
        for rows in allSmallSets() where rows.isEmpty == false {
            XCTAssertNotEqual(
                state(rows), .unaware,
                "A venue that has been shown the card cannot be unaware"
            )
        }
    }
}

/// The freeze a refusal buys, timed from the refusal.
///
/// Found by an adversarial pass reading the source. The declined branch used to
/// time its ninety days from the last pitch, and every lookup that produces that
/// value excludes the greet being asked about, because a greet's own two rows
/// must not suppress each other. Two sequences fell out of that and both are here.
final class VenueRefusalFreezeTests: XCTestCase {

    private let now = Date(timeIntervalSince1970: 1_780_000_000)

    private func context(lastPitchAt: Date?, lastRefusalAt: Date?) -> VenuePitchContext {
        VenuePitchContext(
            state: .declined,
            lastOutcome: .notReceptive,
            pitchCountInWindow: 1,
            shiftBucket: .evening,
            lastPitchShiftBucket: .morning,
            lastPitchAt: lastPitchAt,
            lastRefusalAt: lastRefusalAt,
            now: now
        )
    }

    /// The other person in the same meet, minutes later. Their own greet's rows
    /// are excluded from `lastPitchAt`, so there was nothing left to time from.
    func testTheOtherPersonInTheSameMeetIsNotAskedMinutesAfterARefusal() {
        let verdict = VenueCooldownPolicy.evaluate(
            context(lastPitchAt: nil, lastRefusalAt: now.addingTimeInterval(-120))
        )
        XCTAssertFalse(verdict.isEligible)
        XCTAssertEqual(
            verdict.isEligible, false,
            "A refusal two minutes old is the newest fact about this venue"
        )
    }

    /// A venue whose last OTHER introduction was three months ago, refused today.
    func testAnOldPitchElsewhereDoesNotAgeOutARefusalMadeToday() {
        let verdict = VenueCooldownPolicy.evaluate(
            context(
                lastPitchAt: now.addingTimeInterval(-VenueCooldownPolicy.declinedFreeze - 86_400),
                lastRefusalAt: now.addingTimeInterval(-3600)
            )
        )
        XCTAssertFalse(verdict.isEligible)
    }

    /// And the freeze still ends, on the refusal's own clock.
    func testARefusalPastItsNinetyDaysStopsSuppressing() {
        let verdict = VenueCooldownPolicy.evaluate(
            context(
                lastPitchAt: now.addingTimeInterval(-3600),
                lastRefusalAt: now.addingTimeInterval(-VenueCooldownPolicy.declinedFreeze - 86_400)
            )
        )
        XCTAssertTrue(verdict.isEligible)
    }

    /// With no refusal recorded, the old behaviour stands rather than throwing the
    /// venue open: a state of `declined` with no date at all stays suppressed.
    func testNoRefusalDateAndNoPitchDateStaysSuppressed() {
        XCTAssertFalse(
            VenueCooldownPolicy.evaluate(context(lastPitchAt: nil, lastRefusalAt: nil)).isEligible
        )
    }
}
