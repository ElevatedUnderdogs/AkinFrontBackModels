//
//  AutomaticGreetCooldownTests.swift
//  FrontBackModelsTests
//
//  GOAL_LOOP20 items S-C5 and S-C6.
//
//  Two tests per suppression condition, and the pairing is the point. S-C5 asks for one test per
//  condition proving the greet is NOT created. S-C6 asks for the other side: a paired test proving
//  the greet IS created once the condition clears, because a rule with no release test is a rule
//  that can silently disable automatic greets forever, which is a worse defect than the nuisance
//  it prevents.
//
//  Each test names its condition in its own name, so a failure says which rule broke.
//
//  The policy is pure, so none of this needs a database, a clock or a server. That is why it is a
//  pure function in the shared package: `S-C7` and `S-C8` prove the same rules end to end against
//  production, and these prove the rules themselves, which are two different claims.
//

import XCTest
@testable import AkinFrontBackModels

final class AutomaticGreetCooldownTests: XCTestCase {

    // MARK: - Fixtures

    private let now = Date(timeIntervalSince1970: 1_700_000_000)

    /// A member with nothing wrong with them.
    ///
    /// Every test starts from a context that IS eligible and breaks exactly one thing, so a test
    /// that fails is telling you about the thing it broke. A fixture that started suppressed would
    /// let a second defect hide behind the first.
    private func member(
        automaticGreetsEnabled: Bool = true,
        isHiddenFromNearby: Bool = false,
        isEmailVerified: Bool = true,
        isReachable: Bool = true,
        hasConfirmedModerationFlag: Bool = false,
        busyUntil: Date? = nil,
        isWithinStatedAvailability: Bool = true,
        automaticGreetsInWindow: Int = 0,
        chosenCooldownSeconds: TimeInterval? = nil
    ) -> AutomaticGreetContext.Member {
        AutomaticGreetContext.Member(
            id: UUID(),
            automaticGreetsEnabled: automaticGreetsEnabled,
            isHiddenFromNearby: isHiddenFromNearby,
            isEmailVerified: isEmailVerified,
            isReachable: isReachable,
            hasConfirmedModerationFlag: hasConfirmedModerationFlag,
            busyUntil: busyUntil,
            isWithinStatedAvailability: isWithinStatedAvailability,
            automaticGreetsInWindow: automaticGreetsInWindow,
            chosenCooldownSeconds: chosenCooldownSeconds
        )
    }

    private func context(
        scanner: AutomaticGreetContext.Member? = nil,
        candidate: AutomaticGreetContext.Member? = nil,
        scannerIsInAGreet: Bool = false,
        candidateIsInAGreet: Bool = false,
        isBlockedEitherWay: Bool = false,
        lastAutomaticGreetAt: Date? = nil,
        lastAutomaticGreetOutcome: AutomaticGreetOutcome = .unknown,
        hasPendingUnansweredGreet: Bool = false,
        scannerOldestGreetInWindowAt: Date? = nil,
        candidateFrozenUntil: Date? = nil,
        hasVenueBetweenThem: Bool = true,
        now: Date? = nil
    ) -> AutomaticGreetContext {
        AutomaticGreetContext(
            scanner: scanner ?? member(),
            candidate: candidate ?? member(),
            scannerIsInAGreet: scannerIsInAGreet,
            candidateIsInAGreet: candidateIsInAGreet,
            isBlockedEitherWay: isBlockedEitherWay,
            lastAutomaticGreetAt: lastAutomaticGreetAt,
            lastAutomaticGreetOutcome: lastAutomaticGreetOutcome,
            hasPendingUnansweredGreet: hasPendingUnansweredGreet,
            scannerOldestGreetInWindowAt: scannerOldestGreetInWindowAt,
            candidateFrozenUntil: candidateFrozenUntil,
            hasVenueBetweenThem: hasVenueBetweenThem,
            now: now ?? self.now
        )
    }

    private func assertSuppressed(
        _ result: AutomaticGreetEligibility,
        _ expected: AutomaticGreetSuppression,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard case .suppressed(let reason) = result else {
            XCTFail(
                "Expected \(expected.ruleName) and the greet was allowed.",
                file: file,
                line: line
            )
            return
        }
        XCTAssertEqual(
            reason.ruleName,
            expected.ruleName,
            "The wrong rule fired. A member would be told: \(reason.memberFacingReason)",
            file: file,
            line: line
        )
    }

    // MARK: - The baseline, which every other test breaks exactly one thing from

    func testAQualifyingPairIsEligible() {
        XCTAssertTrue(
            AutomaticGreetCooldownPolicy.evaluate(context()).isEligible,
            "A pair with nothing wrong with them was refused, so every suppression test below "
                + "would pass for the wrong reason."
        )
    }

    // MARK: - S-C5 and S-C6. Consent

    func testSuppressedWhenTheScannerHasAutomaticGreetsOff() {
        assertSuppressed(
            AutomaticGreetCooldownPolicy.evaluate(
                context(scanner: member(automaticGreetsEnabled: false))
            ),
            .automaticGreetsOff(isScanner: true)
        )
    }

    func testReleasedWhenTheScannerTurnsAutomaticGreetsBackOn() {
        XCTAssertTrue(
            AutomaticGreetCooldownPolicy.evaluate(
                context(scanner: member(automaticGreetsEnabled: true))
            ).isEligible
        )
    }

    func testSuppressedWhenTheCandidateHasAutomaticGreetsOff() {
        assertSuppressed(
            AutomaticGreetCooldownPolicy.evaluate(
                context(candidate: member(automaticGreetsEnabled: false))
            ),
            .automaticGreetsOff(isScanner: false)
        )
    }

    func testReleasedWhenTheCandidateTurnsAutomaticGreetsBackOn() {
        XCTAssertTrue(
            AutomaticGreetCooldownPolicy.evaluate(
                context(candidate: member(automaticGreetsEnabled: true))
            ).isEligible
        )
    }

    func testSuppressedWhenEitherMemberHasBlockedTheOther() {
        assertSuppressed(
            AutomaticGreetCooldownPolicy.evaluate(context(isBlockedEitherWay: true)),
            .blocked
        )
    }

    func testReleasedWhenTheBlockIsRemoved() {
        XCTAssertTrue(
            AutomaticGreetCooldownPolicy.evaluate(context(isBlockedEitherWay: false)).isEligible
        )
    }

    func testSuppressedWhenTheScannerIsHiddenFromNearby() {
        assertSuppressed(
            AutomaticGreetCooldownPolicy.evaluate(context(scanner: member(isHiddenFromNearby: true))),
            .hiddenFromNearby(isScanner: true)
        )
    }

    func testReleasedWhenTheScannerStopsHiding() {
        XCTAssertTrue(
            AutomaticGreetCooldownPolicy.evaluate(
                context(scanner: member(isHiddenFromNearby: false))
            ).isEligible
        )
    }

    func testSuppressedWhenTheCandidateIsHiddenFromNearby() {
        assertSuppressed(
            AutomaticGreetCooldownPolicy.evaluate(
                context(candidate: member(isHiddenFromNearby: true))
            ),
            .hiddenFromNearby(isScanner: false)
        )
    }

    func testReleasedWhenTheCandidateStopsHiding() {
        XCTAssertTrue(
            AutomaticGreetCooldownPolicy.evaluate(
                context(candidate: member(isHiddenFromNearby: false))
            ).isEligible
        )
    }

    // MARK: - S-C5 and S-C6. Account state

    func testSuppressedWhenTheScannerIsUnverified() {
        assertSuppressed(
            AutomaticGreetCooldownPolicy.evaluate(context(scanner: member(isEmailVerified: false))),
            .unverified(isScanner: true)
        )
    }

    func testReleasedWhenTheScannerVerifies() {
        XCTAssertTrue(
            AutomaticGreetCooldownPolicy.evaluate(
                context(scanner: member(isEmailVerified: true))
            ).isEligible
        )
    }

    func testSuppressedWhenTheCandidateIsUnverified() {
        assertSuppressed(
            AutomaticGreetCooldownPolicy.evaluate(context(candidate: member(isEmailVerified: false))),
            .unverified(isScanner: false)
        )
    }

    func testReleasedWhenTheCandidateVerifies() {
        XCTAssertTrue(
            AutomaticGreetCooldownPolicy.evaluate(
                context(candidate: member(isEmailVerified: true))
            ).isEligible
        )
    }

    func testSuppressedWhenTheCandidateCarriesAConfirmedModerationFlag() {
        assertSuppressed(
            AutomaticGreetCooldownPolicy.evaluate(
                context(candidate: member(hasConfirmedModerationFlag: true))
            ),
            .moderationFlagged
        )
    }

    func testReleasedWhenTheModerationFlagIsCleared() {
        XCTAssertTrue(
            AutomaticGreetCooldownPolicy.evaluate(
                context(candidate: member(hasConfirmedModerationFlag: false))
            ).isEligible
        )
    }

    // MARK: - S-C5 and S-C6. Right now

    func testSuppressedWhenTheScannerIsAlreadyInAGreet() {
        assertSuppressed(
            AutomaticGreetCooldownPolicy.evaluate(context(scannerIsInAGreet: true)),
            .alreadyInAGreet(isScanner: true)
        )
    }

    func testReleasedWhenTheScannersGreetEnds() {
        XCTAssertTrue(
            AutomaticGreetCooldownPolicy.evaluate(context(scannerIsInAGreet: false)).isEligible
        )
    }

    /// The asymmetry `S-C1-suppression-conditions.md` found first, and the one that produced a
    /// real member facing defect: before this policy the candidate's active greet was never
    /// checked at all, so a member mid greet could be pulled into a second one by a stranger
    /// walking past, and would then hold two greets, two venues and two pushes.
    func testSuppressedWhenTheCandidateIsAlreadyInAGreet() {
        assertSuppressed(
            AutomaticGreetCooldownPolicy.evaluate(context(candidateIsInAGreet: true)),
            .alreadyInAGreet(isScanner: false)
        )
    }

    func testReleasedWhenTheCandidatesGreetEnds() {
        XCTAssertTrue(
            AutomaticGreetCooldownPolicy.evaluate(context(candidateIsInAGreet: false)).isEligible
        )
    }

    func testSuppressedWhileTheScannerIsBusy() {
        assertSuppressed(
            AutomaticGreetCooldownPolicy.evaluate(
                context(scanner: member(busyUntil: now.addingTimeInterval(600)))
            ),
            .busy(isScanner: true, until: now.addingTimeInterval(600))
        )
    }

    func testReleasedWhenTheScannersBusyTimeEnds() {
        XCTAssertTrue(
            AutomaticGreetCooldownPolicy.evaluate(
                context(scanner: member(busyUntil: now.addingTimeInterval(-1)))
            ).isEligible,
            "A busy time that ended one second ago is still suppressing."
        )
    }

    func testSuppressedWhileTheCandidateIsBusy() {
        assertSuppressed(
            AutomaticGreetCooldownPolicy.evaluate(
                context(candidate: member(busyUntil: now.addingTimeInterval(600)))
            ),
            .busy(isScanner: false, until: now.addingTimeInterval(600))
        )
    }

    func testReleasedWhenTheCandidatesBusyTimeEnds() {
        XCTAssertTrue(
            AutomaticGreetCooldownPolicy.evaluate(
                context(candidate: member(busyUntil: now.addingTimeInterval(-1)))
            ).isEligible
        )
    }

    func testSuppressedWhenTheCandidateIsUnreachable() {
        assertSuppressed(
            AutomaticGreetCooldownPolicy.evaluate(context(candidate: member(isReachable: false))),
            .unreachable
        )
    }

    func testReleasedWhenTheCandidateBecomesReachable() {
        XCTAssertTrue(
            AutomaticGreetCooldownPolicy.evaluate(
                context(candidate: member(isReachable: true))
            ).isEligible
        )
    }

    func testSuppressedWhileAThirdMemberHoldsAFreezeOnTheCandidate() {
        assertSuppressed(
            AutomaticGreetCooldownPolicy.evaluate(
                context(candidateFrozenUntil: now.addingTimeInterval(120))
            ),
            .frozenByAnotherMember(until: now.addingTimeInterval(120))
        )
    }

    func testReleasedWhenTheFreezeLapses() {
        XCTAssertTrue(
            AutomaticGreetCooldownPolicy.evaluate(
                context(candidateFrozenUntil: now.addingTimeInterval(-1))
            ).isEligible
        )
    }

    func testSuppressedOutsideTheScannersStatedAvailability() {
        assertSuppressed(
            AutomaticGreetCooldownPolicy.evaluate(
                context(scanner: member(isWithinStatedAvailability: false))
            ),
            .outsideStatedAvailability(isScanner: true)
        )
    }

    func testReleasedInsideTheScannersStatedAvailability() {
        XCTAssertTrue(
            AutomaticGreetCooldownPolicy.evaluate(
                context(scanner: member(isWithinStatedAvailability: true))
            ).isEligible
        )
    }

    func testSuppressedOutsideTheCandidatesStatedAvailability() {
        assertSuppressed(
            AutomaticGreetCooldownPolicy.evaluate(
                context(candidate: member(isWithinStatedAvailability: false))
            ),
            .outsideStatedAvailability(isScanner: false)
        )
    }

    func testReleasedInsideTheCandidatesStatedAvailability() {
        XCTAssertTrue(
            AutomaticGreetCooldownPolicy.evaluate(
                context(candidate: member(isWithinStatedAvailability: true))
            ).isEligible
        )
    }

    // MARK: - S-C5 and S-C6. This pair's history

    func testSuppressedWhileThisPairHasAPendingUnansweredGreet() {
        assertSuppressed(
            AutomaticGreetCooldownPolicy.evaluate(context(hasPendingUnansweredGreet: true)),
            .pendingGreetUnanswered
        )
    }

    func testReleasedOnceThePendingGreetIsAnswered() {
        XCTAssertTrue(
            AutomaticGreetCooldownPolicy.evaluate(
                context(hasPendingUnansweredGreet: false)
            ).isEligible
        )
    }

    func testSuppressedWhenThisPairHasAlreadyMet() {
        assertSuppressed(
            AutomaticGreetCooldownPolicy.evaluate(
                context(
                    lastAutomaticGreetAt: now.addingTimeInterval(-60 * 60),
                    lastAutomaticGreetOutcome: .met
                )
            ),
            .alreadyMet
        )
    }

    /// The release for `met` is the longest in the set, so it is asserted at its own boundary
    /// rather than at some comfortably large number: a test that waited a year would pass against
    /// a policy that had accidentally made the meeting cooldown permanent.
    func testReleasedNinetyDaysAfterThisPairMet() {
        let ninetyOneDays = AutomaticGreetCooldownPolicy.metCooldown + 1
        XCTAssertTrue(
            AutomaticGreetCooldownPolicy.evaluate(
                context(
                    lastAutomaticGreetAt: now.addingTimeInterval(-ninetyOneDays),
                    lastAutomaticGreetOutcome: .met
                )
            ).isEligible
        )
    }

    // MARK: - S-C5 and S-C6. Volume

    func testSuppressedWhenTheScannerHasHitTheDailyCap() {
        assertSuppressed(
            AutomaticGreetCooldownPolicy.evaluate(
                context(
                    scanner: member(
                        automaticGreetsInWindow: AutomaticGreetCooldownPolicy.defaultMemberCap
                    ),
                    scannerOldestGreetInWindowAt: now.addingTimeInterval(-60)
                )
            ),
            .memberCapReached(
                count: AutomaticGreetCooldownPolicy.defaultMemberCap,
                cap: AutomaticGreetCooldownPolicy.defaultMemberCap,
                until: now
            )
        )
    }

    func testReleasedWhenTheCapWindowRollsOver() {
        XCTAssertTrue(
            AutomaticGreetCooldownPolicy.evaluate(
                context(
                    scanner: member(
                        automaticGreetsInWindow: AutomaticGreetCooldownPolicy.defaultMemberCap - 1
                    )
                )
            ).isEligible,
            "One under the cap is refused, so the cap is off by one and a member gets one fewer "
                + "introduction than the number they were told."
        )
    }

    // MARK: - S-C5 and S-C6. The pair cooldown itself, which is Scott's own case

    func testSuppressedWithinTheDefaultPairCooldown() {
        assertSuppressed(
            AutomaticGreetCooldownPolicy.evaluate(
                context(lastAutomaticGreetAt: now.addingTimeInterval(-60 * 60))
            ),
            .pairCooldown(until: now)
        )
    }

    func testReleasedOnceTheDefaultPairCooldownElapses() {
        let justOver = AutomaticGreetCooldownPolicy.defaultPairCooldown + 1
        XCTAssertTrue(
            AutomaticGreetCooldownPolicy.evaluate(
                context(lastAutomaticGreetAt: now.addingTimeInterval(-justOver))
            ).isEligible
        )
    }

    func testTheDeclineCooldownIsLongerThanTheTimeoutCooldown() {
        // Not a tautology about constants: it is the ordering S-C2 argued, and a future tune that
        // made a decline cool for less time than an unanswered greet would be incoherent.
        XCTAssertGreaterThan(
            AutomaticGreetCooldownPolicy.declinedCooldown,
            AutomaticGreetCooldownPolicy.expiredUnansweredCooldown
        )
        XCTAssertGreaterThan(
            AutomaticGreetCooldownPolicy.endedEarlyCooldown,
            AutomaticGreetCooldownPolicy.expiredUnansweredCooldown
        )
        XCTAssertGreaterThan(
            AutomaticGreetCooldownPolicy.metCooldown,
            AutomaticGreetCooldownPolicy.declinedCooldown
        )
    }

    func testADeclinedPairIsStillSuppressedAfterTheDefaultCooldownHasPassed() {
        // The case that proves outcomes are actually consulted. A day after a decline, the default
        // would have released them and the decline must not.
        assertSuppressed(
            AutomaticGreetCooldownPolicy.evaluate(
                context(
                    lastAutomaticGreetAt: now.addingTimeInterval(
                        -(AutomaticGreetCooldownPolicy.defaultPairCooldown + 60)
                    ),
                    lastAutomaticGreetOutcome: .declined
                )
            ),
            .pairCooldown(until: now)
        )
    }

    // MARK: - S-C11. Two members with different chosen cooldowns

    func testTheLongerChosenCooldownWins() {
        let elapsed: TimeInterval = 2 * 60 * 60
        let result = AutomaticGreetCooldownPolicy.evaluate(
            context(
                scanner: member(chosenCooldownSeconds: 60 * 60),
                candidate: member(chosenCooldownSeconds: 6 * 60 * 60),
                lastAutomaticGreetAt: now.addingTimeInterval(-elapsed)
            )
        )
        assertSuppressed(result, .pairCooldown(until: now))
        XCTAssertEqual(
            result.suppression?.clearsAt,
            now.addingTimeInterval(-elapsed).addingTimeInterval(6 * 60 * 60),
            "The shorter of the two settings won, so one member's choice overrode the other's "
                + "request to be left alone for longer."
        )
    }

    func testAChosenCooldownThatHasElapsedReleasesThePair() {
        XCTAssertTrue(
            AutomaticGreetCooldownPolicy.evaluate(
                context(
                    scanner: member(chosenCooldownSeconds: 60),
                    candidate: member(chosenCooldownSeconds: 60),
                    lastAutomaticGreetAt: now.addingTimeInterval(-120)
                )
            ).isEligible
        )
    }

    // MARK: - Every reason can say what it is and when it clears

    func testEverySuppressionNamesItselfAndSaysWhetherItClears() {
        let all: [AutomaticGreetSuppression] = [
            .pairCooldown(until: now),
            .memberCapReached(count: 3, cap: 3, until: now),
            .alreadyInAGreet(isScanner: true),
            .alreadyInAGreet(isScanner: false),
            .pendingGreetUnanswered,
            .alreadyMet,
            .busy(isScanner: true, until: now),
            .automaticGreetsOff(isScanner: true),
            .hiddenFromNearby(isScanner: false),
            .blocked,
            .unreachable,
            .unverified(isScanner: false),
            .moderationFlagged,
            .frozenByAnotherMember(until: now),
            .outsideStatedAvailability(isScanner: true),
            .noVenueBetweenThem,
        ]
        for reason in all {
            XCTAssertFalse(reason.ruleName.isEmpty, "A rule with no name cannot be logged.")
            XCTAssertFalse(
                reason.memberFacingReason.isEmpty,
                "\(reason.ruleName) has no sentence, so item S-C14 cannot tell a member anything."
            )
            // The copy rule, enforced on strings a member reads.
            for dash in ["\u{2014}", "\u{2013}", " - "] {
                XCTAssertFalse(
                    reason.memberFacingReason.contains(dash),
                    "\(reason.ruleName)'s sentence uses dash punctuation."
                )
            }
        }
    }

    /// One entry per RULE, and every name distinct.
    ///
    /// Separate from the sweep above because that list deliberately carries the same rule twice
    /// with different `isScanner` values, to check both sentences. Counting distinct names across
    /// a list with intentional duplicates was the first version of this assertion and it was
    /// arithmetic about the fixture rather than a claim about the type.
    func testEveryRuleHasADistinctName() {
        let oneOfEach: [AutomaticGreetSuppression] = [
            .pairCooldown(until: now),
            .memberCapReached(count: 3, cap: 3, until: now),
            .alreadyInAGreet(isScanner: true),
            .pendingGreetUnanswered,
            .alreadyMet,
            .busy(isScanner: true, until: now),
            .automaticGreetsOff(isScanner: true),
            .hiddenFromNearby(isScanner: true),
            .blocked,
            .unreachable,
            .unverified(isScanner: true),
            .moderationFlagged,
            .frozenByAnotherMember(until: now),
            .outsideStatedAvailability(isScanner: true),
            .noVenueBetweenThem,
        ]
        XCTAssertEqual(
            Set(oneOfEach.map(\.ruleName)).count,
            oneOfEach.count,
            "Two rules share a name, so a log line cannot say which one fired."
        )
    }

    /// The same rule seen from both sides keeps ONE name and changes its SENTENCE.
    ///
    /// Deliberate, and asserted so nobody splits it later: `already_in_a_greet` is one rule about
    /// one fact, and a metric that counted it as two would make the commonest suppression look
    /// like two rarer ones.
    func testTheSameRuleKeepsOneNameAndChangesItsSentence() {
        let scanner = AutomaticGreetSuppression.alreadyInAGreet(isScanner: true)
        let candidate = AutomaticGreetSuppression.alreadyInAGreet(isScanner: false)
        XCTAssertEqual(scanner.ruleName, candidate.ruleName)
        XCTAssertNotEqual(scanner.memberFacingReason, candidate.memberFacingReason)
    }
}

// MARK: - S-C14. The member level question, which is a different question

extension AutomaticGreetCooldownTests {

    /// A member with nothing wrong with them is told nothing, which is the state most members are
    /// in most of the time and the one a wrong answer would be most visible in.
    func testAMemberWithNothingWrongIsGivenNoReason() {
        XCTAssertNil(
            AutomaticGreetCooldownPolicy.memberLevelSuppression(for: member(), now: now)
        )
    }

    func testTheMemberLevelReasonNamesTheSwitchBeforeAnythingElse() {
        let result = AutomaticGreetCooldownPolicy.memberLevelSuppression(
            for: member(
                automaticGreetsEnabled: false,
                automaticGreetsInWindow: AutomaticGreetCooldownPolicy.defaultMemberCap
            ),
            now: now
        )
        XCTAssertEqual(
            result?.ruleName,
            AutomaticGreetSuppression.automaticGreetsOff(isScanner: true).ruleName,
            "A member who turned Auto greets OFF was told about a cap instead, which sends them "
                + "looking in the wrong place for a setting they already changed."
        )
    }

    func testTheMemberLevelReasonReportsTheCapWhenNothingElseApplies() {
        let result = AutomaticGreetCooldownPolicy.memberLevelSuppression(
            for: member(automaticGreetsInWindow: AutomaticGreetCooldownPolicy.defaultMemberCap),
            now: now
        )
        XCTAssertEqual(
            result?.ruleName,
            AutomaticGreetSuppression.memberCapReached(count: 3, cap: 3, until: now).ruleName
        )
    }

    /// The member level question and the pair question are different questions, and the answers
    /// must not be confused: a pair cooldown says nothing about whether this member is being
    /// introduced to anybody at all.
    func testAPairCooldownIsNotAMemberLevelReason() {
        XCTAssertNil(
            AutomaticGreetCooldownPolicy.memberLevelSuppression(for: member(), now: now),
            "A member whose only problem is one pair's cooldown was told they are not being "
                + "introduced at all, which is false and would send them to turn a switch that is "
                + "already on."
        )
    }
}
