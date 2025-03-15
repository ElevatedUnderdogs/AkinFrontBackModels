//
//  Params.swift
//  akin
//
//  Created by Scott Lydon on 10/27/18.
//  Copyright © 2018 ElevatedUnderdogs. All rights reserved.
//

import Foundation
#if canImport(os)
import os
let log = OSLog(subsystem: "com.ElevatedUnderdogs.akin1", category: "networking")
#endif

extension URLQueryItem {

    static func row(_ value: Int) -> Self {
        URLQueryItem(.row, String(value))
    }

    static func submit(_ value: Bool) -> Self {
        URLQueryItem(.submit, String(value))
    }

    static func new_password(_ value: String) -> Self {
        URLQueryItem(.new_password, value)
    }

    static func search(text: String?) -> Self {
        URLQueryItem(.search, text)
    }

    static func oldPassword(_ value: String) -> Self {
        URLQueryItem(.old_password, value)
    }

    static func email(_ value: String) -> Self {
        URLQueryItem(.email, value)
    }

    static func reset(email: String) -> Self {
        URLQueryItem(.email, email)
    }

    static func date() -> Self {
        URLQueryItem(.date, Date().apiString)
    }

    static func tracking(events: [Int: String]) -> [Self] {
        events.map { URLQueryItem(name: $0.string, value: $1)}
    }

    static func device(token value: String) -> Self {
        #if canImport(os)
        if value.isEmpty {
            os_log("The device token was empty!", log: log, type: .info)
        }
        #endif
        return URLQueryItem(.device_token, value)
    }

    static func pushKitDevice(token value: String) -> Self {
        #if canImport(os)
        if value.isEmpty {
            os_log("The push device token was empty!", log: log, type: .info)
        }
        #endif
        return URLQueryItem(.pushKitDeviceToken, value)
    }

    static func lat(_ value: String/* = CLLocationCoordinate2D.thisLocation?.latitude.string ?? "1.01"*/) -> Self {
        URLQueryItem(.latitude, value)
    }

    static func lon(_ value: String/* = CLLocationCoordinate2D.thisLocation?.longitude.string ?? "1.1"*/) -> Self {
        URLQueryItem(.longitude, value)
    }

    static func social(_ value: String) -> Self {
        URLQueryItem(.social, value)
    }

    static func viewing(_ value: Int) -> Self {
        URLQueryItem(.viewing, String(value))
    }

    static func ring(_ value: String) -> Self {
        URLQueryItem(.ring, value)
    }

    static func vibrate(_ value: String) -> Self {
        URLQueryItem(.vibrate, value)
    }

    static func wet_willy(_ value: String) -> Self {
        URLQueryItem(.wet_willy, value)
    }

    static func wave(_ value: String) -> Self {
        URLQueryItem(.wave, value)
    }

    static func kiss_on_the_cheek(_ value: String) -> Self {
        URLQueryItem(.kiss_on_the_cheek, value)
    }

    static func high_five(_ value: String) -> Self {
        URLQueryItem(.high_five, value)
    }

    static func hug(_ value: String) -> Self {
        URLQueryItem(.hug, value)
    }

    static func hand_shake(_ value: String) -> Self {
        URLQueryItem(.hand_shake, value)
    }

    static func greetr_flutter(_ value: String) -> Self {
        URLQueryItem(.greetr_flutter, value)
    }

    static func plur(_ value: String) -> Self {
        URLQueryItem(.plur, value)
    }

    static func hook_up(_ value: String) -> Self {
        URLQueryItem(.hook_up, value)
    }

    static func dob(_ value: String) -> Self {
        URLQueryItem(.dob, value)
    }

    static func dob(_ value: Date?) -> Self {
        URLQueryItem(.dob, value?.apiString)
    }

    static func dob(_ date: Date) -> Self {
        URLQueryItem(.dob, date.apiString)
    }

    static func schedule(summary: String/*_ days: [Week.Day]*/) -> Self {
        URLQueryItem(.meeting_schedule, /*days.summary*/summary)
    }

    static func PageNo(_ value: Int?) -> Self {
        URLQueryItem(.pageNo, value?.string)
    }

    static func type(_ value: String) -> Self {
        URLQueryItem(.type, value)
    }

    static func my_id(_ value: String) -> Self {
        URLQueryItem(.my_id, value)
    }

    static func response(_ value: String) -> Self {
        URLQueryItem(.response, value)
    }

    static func responseID(_ value: String) -> Self {
        URLQueryItem(.response_id, value)
    }

    static func their(_ value: Int?) -> Self {
        URLQueryItem(.their, value?.string)
    }

    static func my(_ value: Int?) -> Self {
        URLQueryItem(.my, value?.string)
    }

    static func context(_ value: String) -> Self {
        URLQueryItem(.context, value)
    }

    static func importance(_ importance: Question.Importance) -> Self {
        URLQueryItem(.importance, String(importance.rawValue))
    }

    static func question_id(_ value: String) -> Self {
        URLQueryItem(.question_id, value)
    }

    static func text(_ value: String) -> Self {
        URLQueryItem(.text, value)
    }

    static func question(text: String) -> Self {
        URLQueryItem(.question, text)
    }

    static func make(deviceString: String) -> Self {
        URLQueryItem(.makeModel, deviceString /*UIDevice.current.modelName.filter {$0 != " "}*/)
    }

    static func password(_ value: String) -> Self {
        URLQueryItem(.password, value)
    }

    static func metersWillingToTravel(_ distance: Int) -> Self {
        URLQueryItem(.metersWillingToTravel, distance.string)
    }

    static func primary_email(_ value: String) -> Self {
        URLQueryItem(.primary_email, value)
    }

    static func minutes(away minutes: Int?) -> Self {
        URLQueryItem(.minutesFromPoint, minutes?.string)
    }

    //params for status

    static func meetingPlace(name: String?) -> Self {
        URLQueryItem(.meetingPlaceName, name)
    }

    static func meetingPlace(address: String?) -> Self {
        URLQueryItem(.meetingAddress, address)
    }

    static func meetingPlace(time: String?) -> Self {
        URLQueryItem(.meetingTime, time)
    }

    static func percentTravelled(_ percentTravelled: Double?) -> Self {
        URLQueryItem(.percentTravelled, percentTravelled?.string)
    }

    static func alwaysInUse(_ value: Bool) -> Self {
        URLQueryItem(.alwaysInUse, value.strInt)
    }

    static func hide(me value: Bool) -> Self {
        URLQueryItem(.isHide, value.strInt)
    }

    static func reportFlag(int values: [Int]) -> Self {
        URLQueryItem(.reportFlag, values.data.base64EncodedString())
    }

    static func urlAddress(_ address: String) -> Self {
        URLQueryItem(.url, address.scaped)
    }

    static func flag(int value: Int) -> Self {
        URLQueryItem(.flag, String(value))
    }

    static func allows(_ allows: Bool) -> Self {
        URLQueryItem(.allowsCourtesyCalls, allows.strInt)
    }

    static func assert(_ message: String) -> Self {
        URLQueryItem(.assert, message)
    }

    static func environment(_ environment: String = .environmentString) -> Self {
        URLQueryItem(QueryItemName.environment, environment)
    }

    static func user_id(id: String?/* = Keychain.thisUserID*/) -> Self {
        if let id = id {
            return URLQueryItem(.user_id, id)
        }
        return URLQueryItem(.user_id, "wasnt set correctly")
    }

    static func greet_id(_ value: String) -> Self {
        URLQueryItem(.greet_id, value)
    }

    static func rating(_ value: Double) -> Self {
        URLQueryItem(.greet_rating, String(value))
    }

    static func other_id(_ value: Int) -> Self {
        URLQueryItem(.other_id, String(value))
    }

    static func other_id(_ value: String) -> Self {
        URLQueryItem(.other_id, value)
    }

    static func other_user_id(_ value: String) -> Self {
        URLQueryItem(.other_user_id, value)
    }

    static func block(_ value: Bool) -> Self {
        URLQueryItem(.block, value.description)
    }

    static func email_id(_ value: String) -> Self {
        URLQueryItem(.email_id, value)
    }

    static func romance(_ value: String) -> Self {
        URLQueryItem(.romance, value)
    }

    static func username(_ value: String) -> Self {
        URLQueryItem(.username, value)
    }

    static func first_name(_ value: String) -> Self {
        URLQueryItem(.first_name, value)
    }

    static func last_name(_ value: String) -> Self {
        URLQueryItem(.last_name, value)
    }

    static func zip(_ value: String) -> Self {
        URLQueryItem(.zip, value)
    }

    static func phone(_ value: String) -> Self {
        URLQueryItem(.phone, value)
    }

    static func confirmationStatus(_ confirmationStatus: ConfirmationStatus) -> Self {
        URLQueryItem(.response, String(confirmationStatus.rawValue))
    }

    init(_ key: QueryItemName, _ value: String?) {
        self.init(name: key.rawValue, value: value)
    }

    static func error(_ error: String) -> Self {
        URLQueryItem(.error, error)
    }

    private static func access_token(token: String?/* = Keychain.accessToken*/) -> Self {
        URLQueryItem(.access_token, token)
    }

    /// Set this up front
    /**
     static func access_token_and_user_id(
         token: String? = Keychain.accessToken,
         id: String? = Keychain.thisUserID
     ) -> Self {
         URLQueryItem(
             .user_id,
             (token == nil && id == nil || token != nil && id != nil) ? id :
                 Keychain.thisUserID
         )
     }
     */
    static var access_token_and_user_id: URLQueryItem = URLQueryItem(.access_token, "")
}
