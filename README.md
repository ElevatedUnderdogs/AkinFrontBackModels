# AkinFrontBackModels

The Swift package holding the request and response types shared between the Map Mates
iOS client and its Vapor server. Both sides depend on it, so a type here is the contract:
if the two repositories disagree about a payload, they disagree here first.

## What is in it

- `Sources/FrontBackModels/` holds the plain `Codable` value types the two sides exchange,
  plus the pieces of domain logic that must give the same answer on both, such as
  `VenueAwarenessFold` and `VenueCooldownPolicy`.
- `Sources/StrongContractClient.Request.swift` declares each endpoint as a typed
  `Request<Payload, Response>`, so a route's shape is stated once and both the caller and
  the handler are checked against it.

## Building and testing

```bash
swift build
swift test
swift test --filter Venue     # one area
```

Both are fast, and there is no database, network, or simulator involved.

## The gap worth knowing before you edit anything

Consumers resolve this package from its GitHub remote by version, not from a local path.
The iOS client pins an exact version in `akin.xcodeproj`'s package reference, and the
server pins a floor in its `Package.swift`. So editing a file in a local checkout changes
nothing anywhere until you have:

1. committed and pushed to `main`,
2. tagged the new version and pushed the tag,
3. moved the pin in each consumer and re-resolved.

Skipping step 3 is the usual way an afternoon disappears: the code is correct, the tests
pass here, and the client keeps compiling against the version it was already pinned to.
