//
//  ViewSetting.swift
//  akin
//
//  Created by Scott Lydon on 8/4/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//

import Foundation

public enum ViewSetting: Equatable, Codable {

    public enum ConifirmationReason: String, Codable {
        case nearby, theyConfirmed
    }
    
    case inGreet
    case inGreetConfirmedMet(ConifirmationReason)
    case otherAskedIfCanMeetLater(Int)
    case rejected
    case start
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
            return [
                .ProfilePicCell,
                .MeetDecisionCell,
                .OpenersCell,
                .DismissCell,
            ]
            
        case .thisUserAgreed:
            return [
                .ProfilePicCell,
                .MeetDecisionCell,
                .OpenersCell,
                .DismissCell,
            ]
            
        case .otherAskedIfCanMeetLater(_):
            return [
                .ProfilePicCell,
                .AlternateDecisionCell,
                .OpenersCell,
                .DismissCell,
            ]
            
        case .inGreet:
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
            
        case .inGreetConfirmedMet(let reason):
            switch reason {
            case .nearby:
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
            case .theyConfirmed:
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
            }
        }
    }
}
