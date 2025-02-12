//
//  Greet.Update.Status.swift
//  akin
//
//  Created by Scott Lydon on 8/11/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//

import Foundation

extension Greet.Update {
    
    public enum Status: String, Codable {
        /// After both users confirmed that they met at the meeting point.
        case confirmedMet
//        /// Arrived at the meeting point but haven't confirmed met.
//        case atMeetingPoint
        /// When the user started or is moving towards the meeting point
        case enroute
        /// When a user when too far out of range of the meeting location.
        case exceededRange
        /// When the user rejects the other user for a greeting opportunity.
        case rejectedOther
        /// When the user opens the greet and views it.
        case viewed
    }
}
