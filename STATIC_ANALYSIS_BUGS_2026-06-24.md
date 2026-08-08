# Static analysis: AkinFrontBackModels

Date: 2026-06-24. Method: deep read of every file under `Sources/`. This package is a dependency of BOTH the iOS app and the Vapor server, so each bug ships to both sides and a decode break here can desync client and server across versions. Every item cites `path:line`.

## Headline

The dominant risk is Codable forward-compatibility: several shared payload types either decode external data with the wrong Swift type (so they throw on every real response) or are raw-value enums with no unknown-case fallback (so the day the server adds a case, every older client crashes decoding the whole payload). There is also a token-expiration value object that silently corrupts the expiration it is given.

Counts: High 6, Medium 2, Low 2.

---

## HIGH

- **`TokenResponse.init` overwrites the real expiration with a random earlier time.** `Sources/ResponseStructs.swift:322`. `self.expiration = expiration.randomEarlierDate` (0.0001 to 10 seconds earlier) instead of storing the value passed in. Any code constructing `TokenResponse(token:expiration:)` (the server issuing tokens, tests) emits a nondeterministic, wrong expiration, so tokens appear to expire up to 10 seconds early. Fix: `self.expiration = expiration`.
- **`Business.id` typed `UUID` but Yelp ids are opaque strings.** `Sources/FrontBackModels/Greet+Components/YelpBusinesses.swift:24`. Real ids like `WavvLdfdP6g8aZTtbBQHTw` are not UUIDs, so `JSONDecoder` throws `DataCorrupted` on every Yelp response and the whole Business to Venue decode path fails. Fix: change `id` to `String` (and audit other external-API string ids).
- **`Business.price` and `Business.phone` are non-optional.** `YelpBusinesses.swift:22-23`. Yelp routinely omits `price` (and sometimes `phone`), so decoding throws `keyNotFound` and drops the entire businesses array. Fix: make them `String?`.
- **`Greet.Method` raw-value enum has no unknown-case fallback.** `Sources/FrontBackModels/Greet+Components/Method.swift:13`. It is embedded in `Greet`, a frequently fetched payload, so a new server-side method makes `JSONDecoder` throw on older clients and fails the whole `Greet` decode. Fix: custom `init(from:)` mapping unknown raw values to a sentinel case.
- **`TravelMethod` raw-value enum has no unknown-case fallback.** `Sources/FrontBackModels/Greet+Components/TravelMethod.swift:11`. Same embedding in `Greet`, same forward-compat break. Fix: same.
- **`ReportFlag` raw-value enum has no unknown-case fallback.** `Sources/FrontBackModels/Flagging/ReportFlag.swift:13`. It is embedded (via `FlagExplanation` to `ModerationAssessment`) inside `Question`, `Question.Response`, `ImageMetadata`, and `NearbyUser`, so a new server flag drops core content payloads on old clients. Fix: custom `init(from:)` with an `.unknown` fallback.

Systemic note: the same raw-value-enum forward-compat hazard applies to `RiskLevel`, `CallType`, `Greet.Update.Status`, `FlagSource`, `ModerationContentType`, `NotificationFrequency`, and `CompatibilityRule`. The three above are the highest-traffic; the rest are worth the same `init(from:)` fallback treatment.

## MEDIUM

- **Unconstrained `Array.data` reinterprets raw element bytes.** `Sources/FrontBackModels/Greet+Components/Array.swift:11-13`. `extension Array { var data: Data }` via `withUnsafeBufferPointer`/`Data(buffer:)` is callable on any element type; on `[String]`, class refs, or pointer-bearing structs it yields garbage or leaks pointer bits. Fix: constrain to `where Element: FixedWidthInteger` (or specifically `UInt8`).
- **`[ReportFlag: ModerationTreatment]` serializes as a flat JSON array, not an object.** `Sources/StrongContractClient.Request.swift:604`. A dictionary keyed by a `RawRepresentable`-String enum is not special-cased by `JSONEncoder`, so it encodes as `[key,value,key,value,...]`. Round-trips between two Swift peers but breaks any non-Swift consumer or a future server emitting a JSON object. Fix: key by `String` (`rawValue`), or lock and document the array shape.

## LOW

- **`Question.Response.==` compares only `id`.** `Sources/FrontBackModels/QuestionManagement/Response.swift:19-21`. Identity equality is fine if intended, but `firstIndex(where:)` and dedup or diffing can treat a content-changed response as unchanged. Fix: confirm intent; use a deep compare where content diffing is needed.
- **`components(separatedBy:).first!` force-unwrap.** `Sources/ActionStringConvertible.swift:21-23`. Safe in practice (always at least one element) but a latent `!` in shared code. Fix: `.first ?? ""`.

## Checked and found OK

`init(from:)`/`encode(to:)` in `NearbyUserMessage`, `Greet.Notification`, `VoipSignal`, and `NearbyUser` are correct and field-complete. `Question`/`VenueInfo` pair id-only `==` with id-only `hash` consistently. `ExitReason` custom `==` covers all cases. The `UUID(uuidString:)!` at `uuid.swift:13` is a hardcoded valid literal. `ReportFlag`'s `displayName`/`int` switches are exhaustive over all 20 cases.
