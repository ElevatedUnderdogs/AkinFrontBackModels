//
//  File.swift
//  AkinFrontBackModels
//
//  Created by Scott Lydon on 10/1/25.
//

import Foundation

// MARK: Client → Server

public struct TravelDistance: Codable, Equatable {
    public let update: TravelUpdate          // meters to venue at `date`
    public let date: Date             // when measured on device
    public let greetID: UUID

    public init(update: TravelUpdate, date: Date, greetID: UUID) {
        self.update = update
        self.date = date
        self.greetID = greetID
    }
}

// MARK: Server → Client

public enum TravelUpdate: Codable, Equatable {
    case percentTravelled(Double)     // 0.0 ... 1.0
    case exceededRange
}

public struct TravelUpdateResponse: Codable, Equatable {
    public let greetID: UUID
    public let value: TravelUpdate

    public init(greetID: UUID, value: TravelUpdate) {
        self.greetID = greetID
        self.value = value
    }
}

// MARK: Server → Client (incremental updates)

public enum TimingUpdate: Codable, Equatable {

    case agreed(Int)     // minutes
    case rejected(Int)   // minutes

    public var rawValue: String {
        switch self {
        case .agreed(let minutes):
            return "agreed to \(minutes) minutes"
        case .rejected(let minutes):
            return "rejected \(minutes) minutes"
        }
    }
}

public struct TimingUpdateResponse: Codable, Equatable {
    public let greetID: UUID
    public let value: [TimingUpdate]

    public init(greetID: UUID, value: [TimingUpdate]) {
        self.greetID = greetID
        self.value = value
    }

    var message: String {
        "They \(value.map(\.rawValue).joined(separator: ", "))"
    }
}

// MARK: Client → Server

public enum RejectionAction: String, Codable, Equatable {
    case dismiss   // before agreeing
    case cancel    // after agreeing
    case rejectedVoip // tapped red close call button.
    case closedApp // user closed the app
    case rejectedByAcceptingAnotherCall
}

/// Can be used as the payload from client > server and as a response from server > other client.
public struct RejectionActionPayload: Codable, Equatable {
    public let greetID: UUID
    public let action: RejectionAction

    public init(greetID: UUID, action: RejectionAction) {
        self.greetID = greetID
        self.action = action
    }
}

public struct ViewedPayload {
    /// When the user opened the greet UI (e.g., in viewDidAppear).
    public let date: Date
    /// The greet this view pertains to.
    public let greetID: UUID

    public init(date: Date, greetID: UUID) {
        self.date = date
        self.greetID = greetID
    }
}

public struct ViewedResponse {
    /// When the user opened the greet UI (e.g., in viewDidAppear).
    public let date: Date
    /// The greet this view pertains to.
    public let greetID: UUID

    public init(date: Date, greetID: UUID) {
        self.date = date
        self.greetID = greetID
    }
}

public struct ClosedDueToViewedTimeLapse {
    public let greetID: UUID
    public let date: Date

    public init(greetID: UUID, date: Date) {
        self.greetID = greetID
        self.date = date
    }
}

