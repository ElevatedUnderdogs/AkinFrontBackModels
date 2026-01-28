//
//  File.swift
//  AkinFrontBackModels
//
//  Created by Scott Lydon on 2/13/25.
//

import Foundation
import XCTest
@testable import AkinFrontBackModels

class GreetNotificationTests: XCTestCase {

    func testEncodingAndDecoding_getRating() throws {
        let originalNotification = Greet.Notification.getRating(Greet.Notification.LocalModel(
            greetID: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440000")!,
            otherUserID: UUID(uuidString: "660933CB-FDEF-4D6E-BC5C-F27F30A668D4")!,
            profileURL: "https://example.com/image.jpg",
            name: "John Doe",
            timeMet: "2024-02-12T14:00:00Z",
            notificationKey: .getReviewTime
        ))

        let encodedData = try JSONEncoder().encode(originalNotification)
        let decodedNotification = try JSONDecoder().decode(Greet.Notification.self, from: encodedData)

        XCTAssertEqual(originalNotification, decodedNotification, "Decoded notification should match the original")
    }

    func testEncodingAndDecoding_silentLocationUpdate() throws {
        let originalNotification = Greet.Notification.silentLocationUpdate

        let encodedData = try JSONEncoder().encode(originalNotification)
        let decodedNotification = try JSONDecoder().decode(Greet.Notification.self, from: encodedData)

        XCTAssertEqual(originalNotification, decodedNotification, "Decoded silentLocationUpdate should match the original")
    }
}
