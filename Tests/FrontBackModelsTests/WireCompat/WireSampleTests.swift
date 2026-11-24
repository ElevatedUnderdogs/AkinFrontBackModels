//
//  WireSampleTests.swift
//  FrontBackModelsTests
//
//  Saved JSON for types with their own decoding logic must keep decoding, so older apps and servers still work.
//

import Foundation
import XCTest

final class WireSampleTests: XCTestCase {
    static let samplesDir = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .appendingPathComponent("Samples")

    /// Sample files are named `<path>.<n>.payload.json` or `<path>.<n>.response.json`.
    func testSavedSamplesStillDecode() throws {
        let files = try FileManager.default.contentsOfDirectory(atPath: Self.samplesDir.path)
            .filter { $0.hasSuffix(".json") }
            .sorted()
        XCTAssertFalse(files.isEmpty, "No samples in \(Self.samplesDir.path)")
        let byPath = Dictionary(grouping: WireContract.all, by: \.path)

        for file in files {
            let parts = file.split(separator: ".")
            guard parts.count == 4 else {
                XCTFail("\(file): expected <path>.<n>.<payload|response>.json")
                continue
            }
            let path = String(parts[0])
            let isPayload = parts[2] == "payload"
            guard let contracts = byPath[path] else {
                XCTFail("\(file): no contract has path \"\(path)\" anymore. Removing or renaming a route breaks older clients.")
                continue
            }
            let data = try Data(contentsOf: Self.samplesDir.appendingPathComponent(file))
            var errors: [String] = []
            for contract in contracts {
                do {
                    try isPayload ? contract.decodePayload(data) : contract.decodeResponse(data)
                    errors = []
                    break
                } catch {
                    errors.append("\(contract.label): \(error)")
                }
            }
            if !errors.isEmpty {
                XCTFail("\(file) no longer decodes. A new required property or a changed type breaks older clients.\n"
                        + errors.joined(separator: "\n"))
            }
        }
    }
}
