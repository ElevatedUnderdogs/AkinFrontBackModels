//
//  GreetCellNames.swift
//  akin
//
//  Created by Scott Lydon on 8/4/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//

import Foundation

extension Greet {
    
    public enum CellName: String, Codable {
        case AlternateDecisionCell
        case BackToTopCell
        case DismissCell
        case GetReadyMeetCell
        case GreetAddressCell
        case GreetMapCell
        case InstructionCell
        case MeetDecisionCell
        case OpenersCell
        case OtherGreeterSettingsCell
        case ProfilePicCell
        case TravelProgressCell
    }
}
