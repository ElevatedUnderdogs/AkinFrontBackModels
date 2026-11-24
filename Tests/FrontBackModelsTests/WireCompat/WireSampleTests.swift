//
//  WireSampleTests.swift
//  FrontBackModelsTests
//
//  Saved payload/response JSON must keep decoding, so older apps and servers still work.
//  Record missing samples with: WIRE_SAMPLES_RECORD=1 swift test --filter WireSampleTests
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

    /// Writes samples only for contracts that have none, so old samples are never overwritten.
    func testRecordMissingSamples() throws {
        guard ProcessInfo.processInfo.environment["WIRE_SAMPLES_RECORD"] == "1" else {
            throw XCTSkip("Set WIRE_SAMPLES_RECORD=1 to record missing samples.")
        }
        let fm = FileManager.default
        try fm.createDirectory(at: Self.samplesDir, withIntermediateDirectories: true)
        let existing = Set(try fm.contentsOfDirectory(atPath: Self.samplesDir.path))
        var written = 0
        var skipped: [String] = []
        for (path, contracts) in Dictionary(grouping: WireContract.all, by: \.path) {
            for (index, contract) in contracts.enumerated() {
                for (kind, make) in [("payload", contract.makePayload), ("response", contract.makeResponse)] {
                    let name = "\(path).\(index + 1).\(kind).json"
                    guard !existing.contains(name) else { continue }
                    do {
                        guard let data = try make() else { continue }
                        try data.write(to: Self.samplesDir.appendingPathComponent(name))
                        written += 1
                    } catch {
                        skipped.append("\(name): \(error)")
                    }
                }
            }
        }
        print("Wrote \(written) samples. Could not build \(skipped.count):\n" + skipped.joined(separator: "\n"))
    }
}
