# QA adversary, AkinFrontBackModels

How to attack the shared models package, what has already been attacked, and what a failing run
looks like. Written 2026-09-13 by GOAL_LOOP20 Phase S-I, row TC-004, which found this package
carrying 52 tests and no document saying how to run them or what they are for.

## The runner

    swift test                                   every suite
    swift test --filter AutomaticGreetCooldown   one suite
    swift test --filter testTheLongerChosenCooldownWins   one test

The harness is `Tests/FrontBackModelsTests/`. There is no simulator, no database and no network in
this package, which is the property that makes it worth attacking: every rule here is a pure
function over a value, so a failure is always the rule and never the environment.

A passing run prints `Executed N tests, with 0 failures`. ASSERT ON N. This repository has been
bitten by a filter that matched nothing and exited zero, and `acceptance-tests.md` in the app
repository carries that as AT-X6. A run that says `Executed 0 tests` is a run that proved nothing.

## What is worth attacking here

**The cooldown policy is the whole of the app's restraint.** `AutomaticGreetCooldownPolicy.evaluate`
decides whether the product may introduce two members who did not ask. Fifteen rules, evaluated in
one order, and the order is part of the answer: a member who is blocked should be told they are
blocked rather than that a cooldown is running, even when both are true. Attack the ORDER, not only
the rules. `testTheFirstRuleReachedIsTheOneReported` is the shape.

**Every duration is a first guess.** 24 hours between introductions, 30 days after a decline, 90
days after they met, three a day. Attack the boundaries exactly: a test that waits a year passes
against an implementation that never clears at all.

**A context is facts, never verdicts.** Every field of `AutomaticGreetContext` is something the
caller measured. If a test can construct a context that the server could never produce, the test is
attacking a state that does not exist; if the server can produce a context no test constructs, that
is the gap to write next.

**The member facing sentences are shipped copy.** They are read by a member and they carry dates. A
rule that says "we wait a while" when it holds the exact date is a defect, which is what rows UFC-007
and UX-SL-006 found and what 142.49.0 fixed. Attack them as copy: no dash punctuation anywhere, no
process vocabulary, and nothing said about the OTHER member that is not theirs to say. Row SEC-004
is why `unavailableToYou` exists.

## What has already been attacked, and what it found

* An adversarial pass over the passive greet path enumerated eighteen conditions under which an
  automatic greet must not be created, which consolidated into the fifteen rules that ship. Eight of
  the eighteen were being checked for one member and never for the other, because the scan is
  triggered by whichever member moved and the old code called that one "the user". That is why the
  two members in the context are named `scanner` and `candidate`.
* `alreadyMet` reported that it never clears, about a rule that is a ninety day timer.
* The nearest neighbour search behind the member's cooldown choice is still called
  `matching(seconds:)`, which asserts an equality it does not have. Recorded, not fixed, because it
  is a published API with one caller.

## What a failure means

A failing test in this package is a rule that changed, and a rule that changed is a change to what
the product does to members who did not ask for it. There is no flakiness here to blame: no clock is
read inside the policy, every `now` is passed in, and every test constructs its own context. If a
test here fails intermittently, that is itself the finding.
