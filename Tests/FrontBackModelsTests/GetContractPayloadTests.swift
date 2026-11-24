//
//  GetContractPayloadTests.swift
//  A GET body is never read: StrongContractServer registers a GET only when the payload is
//  Empty, and asserts otherwise. So every contract whose method is .get must have an Empty
//  payload, and a read that needs arguments is a POST.
//

import XCTest

final class GetContractPayloadTests: XCTestCase {

    private static var sourcesDirectory: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Sources")
    }

    /// Source text with comments and string literals blanked, so braces inside them do not
    /// count when blocks are matched.
    private static func stripped(_ source: String) -> String {
        var text = source
        let patterns = [#""""[\s\S]*?""""#, #"//[^\n]*"#, #""(?:\\.|[^"\\\n])*""#]
        for pattern in patterns {
            text = text.replacingOccurrences(of: pattern, with: "\"\"", options: .regularExpression)
        }
        return text
    }

    /// The text between the brace that opens at `openIndex` and its matching close.
    private static func block(in text: [Character], openingAfter openIndex: Int) -> (body: String, end: Int) {
        var depth = 1
        var index = openIndex
        while depth > 0, index < text.count {
            if text[index] == "{" { depth += 1 }
            if text[index] == "}" { depth -= 1 }
            index += 1
        }
        return (String(text[openIndex..<max(openIndex, index - 1)]), index)
    }

    private static func matches(_ pattern: String, in text: String) -> [[String?]] {
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(text.startIndex..., in: text)
        return regex.matches(in: text, range: range).map { match in
            (0..<match.numberOfRanges).map { group in
                Range(match.range(at: group), in: text).map { String(text[$0]) }
            }
        }
    }

    /// Every `.get` contract, as (typealias or extension name, static var, payload type).
    private static func getContracts() throws -> [(owner: String, name: String, payload: String?)] {
        let files = FileManager.default.enumerator(at: sourcesDirectory, includingPropertiesForKeys: nil)?
            .compactMap { $0 as? URL }
            .filter { $0.pathExtension == "swift" } ?? []
        let sources = try files.map { stripped(try String(contentsOf: $0, encoding: .utf8)) }

        var payloadByAlias: [String: String] = [:]
        for source in sources {
            let aliasPattern = #"typealias\s+(\w+)\s*=\s*(?:StrongContractClient\.)?Request<\s*([\w.<>\[\]?]+)\s*,"#
            for groups in matches(aliasPattern, in: source) {
                if let alias = groups[1], let payload = groups[2] { payloadByAlias[alias] = payload }
            }
        }

        var found: [(owner: String, name: String, payload: String?)] = []
        for source in sources {
            let characters = Array(source)
            let regex = try NSRegularExpression(pattern: #"\bextension\s+([\w.]+)\s*(where\s[^{]*)?\{"#)
            let nsRange = NSRange(source.startIndex..., in: source)
            for match in regex.matches(in: source, range: nsRange) {
                guard let ownerRange = Range(match.range(at: 1), in: source),
                      let wholeRange = Range(match.range, in: source) else { continue }
                let owner = String(source[ownerRange])
                let whereClause = Range(match.range(at: 2), in: source).map { String(source[$0]) } ?? ""
                let open = source.distance(from: source.startIndex, to: wholeRange.upperBound)
                let body = block(in: characters, openingAfter: open).body
                let bodyCharacters = Array(body)
                let varRegex = try NSRegularExpression(pattern: #"static var (\w+): Self\s*\{"#)
                for varMatch in varRegex.matches(in: body, range: NSRange(body.startIndex..., in: body)) {
                    guard let nameRange = Range(varMatch.range(at: 1), in: body),
                          let varRange = Range(varMatch.range, in: body) else { continue }
                    let varOpen = body.distance(from: body.startIndex, to: varRange.upperBound)
                    let getter = block(in: bodyCharacters, openingAfter: varOpen).body
                    guard getter.range(of: #"method:\s*\.get\b"#, options: .regularExpression) != nil else {
                        continue
                    }
                    let fromWhere = matches(#"Payload\s*==\s*([\w.]+)"#, in: whereClause).first?[1]
                    found.append((owner, String(body[nameRange]), payloadByAlias[owner] ?? fromWhere))
                }
            }
        }
        return found
    }

    func testEveryGetContractHasAnEmptyPayload() throws {
        let contracts = try Self.getContracts()
        XCTAssertFalse(contracts.isEmpty, "The scan found no GET contracts, so it is not reading the sources.")
        for contract in contracts {
            let payload = try XCTUnwrap(
                contract.payload,
                "\(contract.owner).\(contract.name) is a GET whose payload type could not be read."
            )
            XCTAssertEqual(
                payload.split(separator: ".").last.map(String.init), "Empty",
                "\(contract.owner).\(contract.name) is a GET with payload \(payload). A GET body is "
                    + "never read, so make it a POST."
            )
        }
    }
}
