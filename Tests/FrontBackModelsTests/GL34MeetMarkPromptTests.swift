//
//  GL34MeetMarkPromptTests.swift
//  AkinFrontBackModels
//
//  GOAL_LOOP34 items D1.M1 and D1.M2, from Q16.
//

import Foundation
import XCTest

@testable import AkinFrontBackModels

/// What the caller was reading when they marked somebody, over the wire.
///
/// THE TWO THINGS THAT MATTER HERE ARE BOTH ABOUT WHAT IS MISSING. A mark placed before this
/// field existed has no prompt, and a client in somebody's pocket sends a bare id rather than an
/// object: both have to keep working, because the alternative is a list that fails to decode and
/// a mark that returns 400. The round trip itself is the easy half.
final class GL34MeetMarkPromptTests: XCTestCase {

    private func encoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }

    private func decoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    // MARK: - The payload

    func test_markPayload_roundTripsItsPrompt() throws {
        let prompt = MeetMarkPrompt(
            kind: .question,
            questionId: UUID(uuidString: "11111111-2222-3333-4444-555555555555")!,
            text: "Where would you take someone on a first afternoon out?"
        )
        let payload = MarkWantToMeetPayload(
            memberId: UUID(uuidString: "66666666-7777-8888-9999-000000000000")!,
            prompt: prompt
        )
        let decoded = try decoder().decode(
            MarkWantToMeetPayload.self, from: try encoder().encode(payload)
        )
        XCTAssertEqual(decoded, payload)
        XCTAssertEqual(decoded.prompt?.kind, .question)
        XCTAssertEqual(decoded.prompt?.text, prompt.text)
    }

    func test_markPayload_decodesABareIdentifier() throws {
        let identifier = UUID(uuidString: "66666666-7777-8888-9999-000000000000")!
        let wire = Data("\"\(identifier.uuidString)\"".utf8)

        let decoded = try decoder().decode(MarkWantToMeetPayload.self, from: wire)

        XCTAssertEqual(decoded.memberId, identifier)
        XCTAssertNil(
            decoded.prompt,
            "a client that sends only an id has no prompt to send, and inventing one here would "
                + "put words on a row the member never read"
        )
    }

    func test_markPayload_decodesAnObjectWithNoPrompt() throws {
        let identifier = UUID(uuidString: "66666666-7777-8888-9999-000000000000")!
        let wire = Data("{\"memberId\":\"\(identifier.uuidString)\"}".utf8)

        let decoded = try decoder().decode(MarkWantToMeetPayload.self, from: wire)

        XCTAssertEqual(decoded.memberId, identifier)
        XCTAssertNil(decoded.prompt)
    }

    func test_markPayload_withNoPromptIsTheOldRequestByteForByte() throws {
        let identifier = UUID(uuidString: "66666666-7777-8888-9999-000000000000")!

        let new = try JSONEncoder().encode(MarkWantToMeetPayload(memberId: identifier))
        let old = try JSONEncoder().encode(identifier)

        XCTAssertEqual(
            String(decoding: new, as: UTF8.self),
            String(decoding: old, as: UTF8.self),
            "a server that has not shipped the prompt decodes a bare id and answers 400 to an "
                + "object, so a mark with nothing to say has to stay the request it was"
        )
    }

    func test_markPayload_withAPromptIsAnObject() throws {
        let payload = MarkWantToMeetPayload(
            memberId: UUID(uuidString: "66666666-7777-8888-9999-000000000000")!,
            prompt: MeetMarkPrompt(kind: .question, questionId: UUID(), text: "Why this one?")
        )

        let wire = String(decoding: try JSONEncoder().encode(payload), as: UTF8.self)

        XCTAssertTrue(wire.hasPrefix("{"), "a prompt needs the object form, and \(wire)")
        XCTAssertTrue(wire.contains("memberId"))
        XCTAssertTrue(wire.contains("questionId"))
    }

    // MARK: - The row

    func test_markedMember_roundTripsItsPrompt() throws {
        let member = MeetMarkedMember(
            id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
            name: "June",
            markedAt: Date(timeIntervalSince1970: 1_700_000_000),
            prompt: MeetMarkPrompt(
                kind: .answer,
                questionId: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
                text: "The Fox, because nobody there is in a hurry."
            )
        )

        let decoded = try decoder().decode(
            MeetMarkedMember.self, from: try encoder().encode(member)
        )

        XCTAssertEqual(decoded, member)
        XCTAssertEqual(decoded.prompt?.kind, .answer)
    }

    func test_markedMember_decodesAPayloadWithNoPromptAtAll() throws {
        // What a server that has not shipped GOAL_LOOP34 returns, and what every mark placed
        // before this field existed will keep returning afterwards.
        let wire = Data(
            """
            {"id":"11111111-1111-1111-1111-111111111111","name":"June",
             "markedAt":"2023-11-14T22:13:20Z"}
            """.utf8
        )

        let decoded = try decoder().decode(MeetMarkedMember.self, from: wire)

        XCTAssertEqual(decoded.name, "June")
        XCTAssertNil(
            decoded.prompt,
            "a row with no stored prompt draws no prompt line, which is D1.M14"
        )
    }

    func test_markedMember_decodesANameThatIsNotThere() throws {
        // A member who has left or is no longer named: the name is absent rather than empty.
        let wire = Data(
            """
            {"id":"11111111-1111-1111-1111-111111111111","markedAt":"2023-11-14T22:13:20Z"}
            """.utf8
        )

        let decoded = try decoder().decode(MeetMarkedMember.self, from: wire)

        XCTAssertNil(decoded.name)
        XCTAssertNil(decoded.prompt)
    }

    // MARK: - The kind

    func test_promptKind_isItsOwnWordOnTheWire() throws {
        XCTAssertEqual(MeetMarkPromptKind.question.rawValue, "question")
        XCTAssertEqual(MeetMarkPromptKind.answer.rawValue, "answer")
        XCTAssertEqual(
            try decoder().decode(MeetMarkPromptKind.self, from: Data("\"answer\"".utf8)),
            .answer
        )
    }
}
