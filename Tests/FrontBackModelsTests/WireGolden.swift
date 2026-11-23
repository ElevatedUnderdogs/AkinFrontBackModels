//
//  WireGolden.swift
//  FrontBackModelsTests
//
//  One enum case's JSON as it was before this change, used by SchemaReadyEnumGoldens.
//

struct WireGolden {
    /// The enum case this JSON holds, by its Swift name.
    let caseName: String
    /// What a plain `JSONEncoder` with sorted keys wrote.
    let plain: String
    /// What `JSONEncoder.akinWire` with sorted keys wrote: snake_case keys and ISO dates.
    let wire: String
}
