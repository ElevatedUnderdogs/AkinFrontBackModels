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

    /// Asserts WHICH RULE fired, and optionally when it clears.
    ///
    /// The second parameter is named `sameRuleAs` and not `expected` because only the rule is
    /// compared: the associated values on the case a caller builds are ignored. That was true
    /// before and it read as though it were not, so several call sites carried a plausible looking
    /// date that nothing checked, one of them a `until: now` on a cap that clears a whole window
    /// after a greet made a minute ago, under a comment saying the date was part of the verdict.
    ///
    /// The date is part of the verdict, and where it matters a caller passes `clearsAt:` and it IS
    /// compared. Where it does not, the parameter name now says the case is there to name the rule.
    private func assertSuppressed(
        _ result: AutomaticGreetEligibility,
        sameRuleAs expected: AutomaticGreetSuppression,
        clearsAt: Date? = nil,
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
        if let clearsAt {
            XCTAssertEqual(
                reason.clearsAt,
                clearsAt,
                "\(reason.ruleName) fired but clears at \(String(describing: reason.clearsAt)), "
                    + "so a member would be told the wrong day.",
                file: file,
                line: line
            )
        }
    }

    /// A release: the condition suppresses, and flipping ONLY that condition releases.
    ///
    /// Both halves, in one test, because the second half alone proves nothing. Thirteen release
    /// tests in this file used to be the second half alone, and every one of them evaluated a
    /// context identical to `context()`, so they re asserted the baseline that
    /// `testAQualifyingPairIsEligible` already covers and would have stayed green with the rule
    /// they name deleted. Written as a pair, a release test fails if the rule stops firing and
    /// fails if it stops clearing, which is what a paired release test is for.
    private func assertReleased(
        from suppressed: AutomaticGreetContext,
        by released: AutomaticGreetContext,
        rule: AutomaticGreetSuppression,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        assertSuppressed(
            AutomaticGreetCooldownPolicy.evaluate(suppressed),
            sameRuleAs: rule,
            file: file,
            line: line
        )
        XCTAssertTrue(
            AutomaticGreetCooldownPolicy.evaluate(released).isEligible,
            "\(rule.ruleName) still suppresses after the one thing it is about was changed.",
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
            sameRuleAs: .automaticGreetsOff(isScanner: true)
        )
    }

    func testReleasedWhenTheScannerTurnsAutomaticGreetsBackOn() {
        assertReleased(
            from: context(scanner: member(automaticGreetsEnabled: false)),
            by: context(scanner: member(automaticGreetsEnabled: true)),
            rule: .automaticGreetsOff(isScanner: true)
        )
    }

    func testSuppressedWhenTheCandidateHasAutomaticGreetsOff() {
        assertSuppressed(
            AutomaticGreetCooldownPolicy.evaluate(
                context(candidate: member(automaticGreetsEnabled: false))
            ),
            sameRuleAs: .automaticGreetsOff(isScanner: false)
        )
    }

    func testReleasedWhenTheCandidateTurnsAutomaticGreetsBackOn() {
        assertReleased(
            from: context(candidate: member(automaticGreetsEnabled: false)),
            by: context(candidate: member(automaticGreetsEnabled: true)),
            rule: .automaticGreetsOff(isScanner: false)
        )
    }

    func testSuppressedWhenEitherMemberHasBlockedTheOther() {
        assertSuppressed(
            AutomaticGreetCooldownPolicy.evaluate(context(isBlockedEitherWay: true)),
            sameRuleAs: .blocked
        )
    }

    func testReleasedWhenTheBlockIsRemoved() {
        assertReleased(
            from: context(isBlockedEitherWay: true),
            by: context(isBlockedEitherWay: false),
            rule: .blocked
        )
    }

    func testSuppressedWhenTheScannerIsHiddenFromNearby() {
        assertSuppressed(
            AutomaticGreetCooldownPolicy.evaluate(context(scanner: member(isHiddenFromNearby: true))),
            sameRuleAs: .hiddenFromNearby(isScanner: true)
        )
    }

    func testReleasedWhenTheScannerStopsHiding() {
        assertReleased(
            from: context(scanner: member(isHiddenFromNearby: true)),
            by: context(scanner: member(isHiddenFromNearby: false)),
            rule: .hiddenFromNearby(isScanner: true)
        )
    }

    func testSuppressedWhenTheCandidateIsHiddenFromNearby() {
        assertSuppressed(
            AutomaticGreetCooldownPolicy.evaluate(
                context(candidate: member(isHiddenFromNearby: true))
            ),
            sameRuleAs: .hiddenFromNearby(isScanner: false)
        )
    }

    func testReleasedWhenTheCandidateStopsHiding() {
        assertReleased(
            from: context(candidate: member(isHiddenFromNearby: true)),
            by: context(candidate: member(isHiddenFromNearby: false)),
            rule: .hiddenFromNearby(isScanner: false)
        )
    }

    // MARK: - S-C5 and S-C6. Account state

    func testSuppressedWhenTheScannerIsUnverified() {
        assertSuppressed(
            AutomaticGreetCooldownPolicy.evaluate(context(scanner: member(isEmailVerified: false))),
            sameRuleAs: .unverified(isScanner: true)
        )
    }

    func testReleasedWhenTheScannerVerifies() {
        assertReleased(
            from: context(scanner: member(isEmailVerified: false)),
            by: context(scanner: member(isEmailVerified: true)),
            rule: .unverified(isScanner: true)
        )
    }

    func testSuppressedWhenTheCandidateIsUnverified() {
        assertSuppressed(
            AutomaticGreetCooldownPolicy.evaluate(context(candidate: member(isEmailVerified: false))),
            sameRuleAs: .unverified(isScanner: false)
        )
    }

    func testReleasedWhenTheCandidateVerifies() {
        assertReleased(
            from: context(candidate: member(isEmailVerified: false)),
            by: context(candidate: member(isEmailVerified: true)),
            rule: .unverified(isScanner: false)
        )
    }

    func testSuppressedWhenTheCandidateCarriesAConfirmedModerationFlag() {
        assertSuppressed(
            AutomaticGreetCooldownPolicy.evaluate(
                context(candidate: member(hasConfirmedModerationFlag: true))
            ),
            sameRuleAs: .moderationFlagged
        )
    }

    func testReleasedWhenTheModerationFlagIsCleared() {
        assertReleased(
            from: context(candidate: member(hasConfirmedModerationFlag: true)),
            by: context(candidate: member(hasConfirmedModerationFlag: false)),
            rule: .moderationFlagged
        )
    }

    // MARK: - S-C5 and S-C6. Right now

    func testSuppressedWhenTheScannerIsAlreadyInAGreet() {
        assertSuppressed(
            AutomaticGreetCooldownPolicy.evaluate(context(scannerIsInAGreet: true)),
            sameRuleAs: .alreadyInAGreet(isScanner: true)
        )
    }

    func testReleasedWhenTheScannersGreetEnds() {
        assertReleased(
            from: context(scannerIsInAGreet: true),
            by: context(scannerIsInAGreet: false),
            rule: .alreadyInAGreet(isScanner: true)
        )
    }

    /// The asymmetry `S-C1-suppression-conditions.md` found first, and the one that produced a
    /// real member facing defect: before this policy the candidate's active greet was never
    /// checked at all, so a member mid greet could be pulled into a second one by a stranger
    /// walking past, and would then hold two greets, two venues and two pushes.
    func testSuppressedWhenTheCandidateIsAlreadyInAGreet() {
        assertSuppressed(
            AutomaticGreetCooldownPolicy.evaluate(context(candidateIsInAGreet: true)),
            sameRuleAs: .alreadyInAGreet(isScanner: false)
        )
    }

    func testReleasedWhenTheCandidatesGreetEnds() {
        assertReleased(
            from: context(candidateIsInAGreet: true),
            by: context(candidateIsInAGreet: false),
            rule: .alreadyInAGreet(isScanner: false)
        )
    }

    func testSuppressedWhileTheScannerIsBusy() {
        assertSuppressed(
            AutomaticGreetCooldownPolicy.evaluate(
                context(scanner: member(busyUntil: now.addingTimeInterval(600)))
            ),
            sameRuleAs: .busy(isScanner: true, until: now.addingTimeInterval(600))
        )
    }

    func testReleasedWhenTheScannersBusyTimeEnds() {
        assertReleased(
            from: context(scanner: member(busyUntil: now.addingTimeInterval(600))),
            by: context(scanner: member(busyUntil: now.addingTimeInterval(-1))),
            rule: .busy(isScanner: true, until: now)
        )
    }

    func testSuppressedWhileTheCandidateIsBusy() {
        assertSuppressed(
            AutomaticGreetCooldownPolicy.evaluate(
                context(candidate: member(busyUntil: now.addingTimeInterval(600)))
            ),
            sameRuleAs: .busy(isScanner: false, until: now.addingTimeInterval(600))
        )
    }

    func testReleasedWhenTheCandidatesBusyTimeEnds() {
        assertReleased(
            from: context(candidate: member(busyUntil: now.addingTimeInterval(600))),
            by: context(candidate: member(busyUntil: now.addingTimeInterval(-1))),
            rule: .busy(isScanner: false, until: now)
        )
    }

    func testSuppressedWhenTheCandidateIsUnreachable() {
        assertSuppressed(
            AutomaticGreetCooldownPolicy.evaluate(context(candidate: member(isReachable: false))),
            sameRuleAs: .unreachable
        )
    }

    func testReleasedWhenTheCandidateBecomesReachable() {
        assertReleased(
            from: context(candidate: member(isReachable: false)),
            by: context(candidate: member(isReachable: true)),
            rule: .unreachable
        )
    }

    func testSuppressedWhileAThirdMemberHoldsAFreezeOnTheCandidate() {
        assertSuppressed(
            AutomaticGreetCooldownPolicy.evaluate(
                context(candidateFrozenUntil: now.addingTimeInterval(120))
            ),
            sameRuleAs: .frozenByAnotherMember(until: now.addingTimeInterval(120))
        )
    }

    func testReleasedWhenTheFreezeLapses() {
        assertReleased(
            from: context(candidateFrozenUntil: now.addingTimeInterval(600)),
            by: context(candidateFrozenUntil: now.addingTimeInterval(-1)),
            rule: .frozenByAnotherMember(until: now)
        )
    }

    func testSuppressedOutsideTheScannersStatedAvailability() {
        assertSuppressed(
            AutomaticGreetCooldownPolicy.evaluate(
                context(scanner: member(isWithinStatedAvailability: false))
            ),
            sameRuleAs: .outsideStatedAvailability(isScanner: true)
        )
    }

    func testReleasedInsideTheScannersStatedAvailability() {
        assertReleased(
            from: context(scanner: member(isWithinStatedAvailability: false)),
            by: context(scanner: member(isWithinStatedAvailability: true)),
            rule: .outsideStatedAvailability(isScanner: true)
        )
    }

    func testSuppressedOutsideTheCandidatesStatedAvailability() {
        assertSuppressed(
            AutomaticGreetCooldownPolicy.evaluate(
                context(candidate: member(isWithinStatedAvailability: false))
            ),
            sameRuleAs: .outsideStatedAvailability(isScanner: false)
        )
    }

    func testReleasedInsideTheCandidatesStatedAvailability() {
        assertReleased(
            from: context(candidate: member(isWithinStatedAvailability: false)),
            by: context(candidate: member(isWithinStatedAvailability: true)),
            rule: .outsideStatedAvailability(isScanner: false)
        )
    }

    // MARK: - S-C5 and S-C6. This pair's history

    func testSuppressedWhileThisPairHasAPendingUnansweredGreet() {
        assertSuppressed(
            AutomaticGreetCooldownPolicy.evaluate(context(hasPendingUnansweredGreet: true)),
            sameRuleAs: .pendingGreetUnanswered
        )
    }

    func testReleasedOnceThePendingGreetIsAnswered() {
        assertReleased(
            from: context(hasPendingUnansweredGreet: true),
            by: context(hasPendingUnansweredGreet: false),
            rule: .pendingGreetUnanswered
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
            sameRuleAs: .alreadyMet(until: now),
            // The date is part of the verdict, and this is where it is checked: the rule clears
            // ninety days after the greet they met on, and a member asking why is owed the moment
            // rather than a shrug. The comment used to sit above a value the helper ignored.
            clearsAt: now.addingTimeInterval(-60 * 60)
                .addingTimeInterval(AutomaticGreetCooldownPolicy.metCooldown)
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
            sameRuleAs: .memberCapReached(
                count: AutomaticGreetCooldownPolicy.defaultMemberCap,
                cap: AutomaticGreetCooldownPolicy.defaultMemberCap,
                until: now
            ),
            // The cap clears one window after the OLDEST greet in it, not one window from now, and
            // this is the test that says so. The `until: now` above is a placeholder the helper
            // ignores by design; this line is the assertion.
            clearsAt: now.addingTimeInterval(-60)
                .addingTimeInterval(AutomaticGreetCooldownPolicy.defaultMemberCapWindow)
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
            sameRuleAs: .pairCooldown(until: now)
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
            sameRuleAs: .pairCooldown(until: now)
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
        assertSuppressed(
            result,
            sameRuleAs: .pairCooldown(until: now),
            clearsAt: now.addingTimeInterval(-elapsed).addingTimeInterval(6 * 60 * 60)
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
            .alreadyMet(until: now),
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
            .alreadyMet(until: now),
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
