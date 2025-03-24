//
//  AkinURLKey.swift
//  akin
//
//  Created by Scott Lydon on 8/11/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//

import Foundation
#if canImport(FoundationNetworking)
// Provided for `URL` related objects on Linux platforms.
import FoundationNetworking
#endif

enum QueryItemName: String, Codable {
    case access_token
    case allowsCourtesyCalls
    case alwaysInUse
    case assert
    case block
    case context
    case date
    case day_name
    case device_token
    case dob
    case email
    case email_id
    case environment
    case error
    case first_name
    case flag
    case greetStatus = "status"
    case greet_id
    case greet_rating
    case greetr_flutter
    case hand_shake
    case high_five
    case hook_up
    case hour
    case hug
    case importance
    case isHide
    case kiss_on_the_cheek
    case last_name
    case latitude
    case longitude
    case makeModel
    case meetingAddress = "meetingEvent.address"
    case meetingPlaceName = "meetingEvent.placeName"
    case meetingTime = "meetingEvent.meetTime"
    case meeting_schedule
    case metersWillingToTravel
    case minutesFromPoint
    case my
    case my_id
    case new_password
    case old_email
    case old_password
    case other_id
    case other_user_id
    case pageNo
    case password
    case percentTravelled
    case phone
    case plur
    case primary_email
    case pushKitDeviceToken
    case pushNotifToken
    case question
    case question_id
    case reportFlag
    case response
    case response_id
    case ring
    case romance
    case row
    case search
    case selection
    case social
    case submit
    case text
    case their
    case travel_method
    case type
    case url
    case user_id
    case username
    case vibrate
    case viewing
    case wave
    case wet_willy
    case zip

    public func queryItem(from value: String?) -> URLQueryItem {
        URLQueryItem(name: rawValue.scaped ?? "", value: value)
    }

    public func string(from value: String) -> String {
        "\(rawValue.scaped ?? "")=\(value.scaped ?? "")&"
    }
}
