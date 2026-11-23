//
//  ViewSetting.swift
//  akin
//
//  Created by Scott Lydon on 8/4/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//

import Foundation

public enum ViewSetting: Equatable, Codable {
    /// Why do we need explicit coding keys when they match what would be synthesized?
    /// In order to give them CaseIterable conformance for schema generators to list every case.
    enum CodingKeys: String, CodingKey, CaseIterable {
        case inGreet, inGreetConfirmedMet, otherAskedIfCanMeetLater, rejected, start, thisUserAgreed
    }

    public enum ConifirmationReason: String, Codable, CaseIterable {
        case nearby
        case theyConfirmed
    }

    /// When both users agreed to meet, but haven't met yet.
    case inGreet
    /// When either this user is nearby or confirmed that they met the other user.
    case inGreetConfirmedMet(ConifirmationReason)
    /// This is a proposal for a time ot meet.
    case otherAskedIfCanMeetLater(Int)
    /// This is when this user rejected the other user.
    case rejected
    /// When the first greet screen prompt displays.
    case start
    /// When this user agreed to meet, but the other user hasn't made a decision yet.
    case thisUserAgreed
    
    public static func == (lhs: ViewSetting, rhs: ViewSetting) -> Bool {
        switch (lhs, rhs)  {
        case (.start, .start): return true
        case (.thisUserAgreed, .thisUserAgreed): return true
        case (.otherAskedIfCanMeetLater(_), .otherAskedIfCanMeetLater(_)): return true
        case (.inGreet, .inGreet): return true
        case (.rejected, .rejected): return true
        default: return false
        }
    }
    
    public var cellTypes: [Greet.CellName] {
        switch self {
        case .start:
            return [.ProfilePicCell,.MeetDecisionCell,.OpenersCell,.DismissCell]
            
        case .thisUserAgreed:
            return [.ProfilePicCell,.MeetDecisionCell,.OpenersCell,.DismissCell]
            
        case .otherAskedIfCanMeetLater(_):
            return [.ProfilePicCell,.AlternateDecisionCell,.OpenersCell,.DismissCell]

        case .inGreet:
            // Both users agreed to meet.
            return [
                .InstructionCell,
                .TravelProgressCell,
                .DismissCell,
                .GreetMapCell,
                .GreetAddressCell,
                .ProfilePicCell,
                .OtherGreeterSettingsCell,
                .OpenersCell,
                .BackToTopCell,
            ]
            
        case .rejected:
            return []

        case .inGreetConfirmedMet:
            // Both users agreed to meet AND are nearby or the
            // other user confirmed they met this (I think)
            return [
                .InstructionCell,
                .TravelProgressCell,
                .DismissCell,
                .GreetMapCell,
                .AlternateDecisionCell,
                .GreetAddressCell,
                .ProfilePicCell,
                .OtherGreeterSettingsCell,
                .OpenersCell,
                .BackToTopCell,
            ]
        }
    }
}
