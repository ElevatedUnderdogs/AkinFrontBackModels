//
//  MeetMarkedMemberStatusTests.swift
//  AkinFrontBackModels
//
//  GOAL_LOOP34 items D1.M15 and D1.M16, from Q17.
//

import Foundation
import XCTest

@testable import AkinFrontBackModels

/// Whether a marked member is still named, no longer named, or no longer there.
///
/// WHAT THIS FIELD IS FOR. gl29.html draws the two cases as different rows with different
/// dialogs, because one Remove can be taken back and the other cannot: a member who went
/// anonymous can be marked again if they are ever named again, and an account that is gone
/// cannot. A client could only ever see "no name" for both.
///
/// THE FALLBACK IS THE HALF THAT MATTERS. A server that predates the field sends none, and the
/// row then has to read as it did before rather than as something new: named when there is a
/// name, departed when there is not.
final class MeetMarkedMemberStatusTests: XCTestCase {

    private var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }

    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    private func member(
        name: String?, status: MeetMarkedMemberStatus?
    ) -> MeetMarkedMember {
        MeetMarkedMember(
            id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
            name: name,
            markedAt: Date(timeIntervalSince1970: 1_700_000_000),
            status: status
        )
    }

    func test_eachCaseRoundTrips() throws {
        for status in [MeetMarkedMemberStatus.named, .anonymous, .departed] {
            let row = member(name: status == .named ? "June" : nil, status: status)
            let decoded = try decoder.decode(
                MeetMarkedMember.self, from: try encoder.encode(row)
            )
            XCTAssertEqual(decoded.status, status, "\(status) did not survive the wire")
            XCTAssertEqual(decoded, row)
        }
    }

    func test_eachCaseIsItsOwnWordOnTheWire() {
        XCTAssertEqual(MeetMarkedMemberStatus.named.rawValue, "named")
        XCTAssertEqual(MeetMarkedMemberStatus.anonymous.rawValue, "anonymous")
        XCTAssertEqual(MeetMarkedMemberStatus.departed.rawValue, "departed")
    }

    func test_aPayloadWithNoStatusAndANameReadsAsNamed() throws {
        let wire = Data(
            """
            {"id":"11111111-1111-1111-1111-111111111111","name":"June",
             "markedAt":"2023-11-14T22:13:20Z"}
            """.utf8
        )

        let decoded = try decoder.decode(MeetMarkedMember.self, from: wire)

        XCTAssertEqual(decoded.status, .named)
    }

    func test_aPayloadWithNoStatusAndNoNameReadsAsDeparted() throws {
        // The reading a client could already make, and the one the app made before this field:
        // no name meant gone. Q17 is that the two cases were indistinguishable, not that this
        // reading was wrong for the case it does cover.
        let wire = Data(
            """
            {"id":"11111111-1111-1111-1111-111111111111","markedAt":"2023-11-14T22:13:20Z"}
            """.utf8
        )

        let decoded = try decoder.decode(MeetMarkedMember.self, from: wire)

        XCTAssertEqual(decoded.status, .departed)
    }

    func test_aPayloadWithNoStatusAndAnEmptyNameReadsAsDeparted() throws {
        let wire = Data(
            """
            {"id":"11111111-1111-1111-1111-111111111111","name":"  ",
             "markedAt":"2023-11-14T22:13:20Z"}
            """.utf8
        )

        let decoded = try decoder.decode(MeetMarkedMember.self, from: wire)

        XCTAssertEqual(decoded.status, .departed)
    }

    func test_anAnonymousRowKeepsItsStatusEvenWithNoName() throws {
        // The whole point: a server that DOES send the field is believed over the name.
        let wire = Data(
            """
            {"id":"11111111-1111-1111-1111-111111111111","markedAt":"2023-11-14T22:13:20Z",
             "status":"anonymous"}
            """.utf8
        )

        let decoded = try decoder.decode(MeetMarkedMember.self, from: wire)

        XCTAssertEqual(decoded.status, .anonymous)
        XCTAssertNil(decoded.name)
    }
}
