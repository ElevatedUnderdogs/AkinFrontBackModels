//
//  LocalNotifications.swift
//  akin
//
//  Created by Scott Lydon on 4/9/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//

import Foundation

extension Greet.Notification {
    
    public struct LocalModel: Codable {

        public enum Key: String, Codable {
            case getReviewTime, weClosedTheGreet
        }
        
        public var greetIdentifier: String
        public var otherUserID: Int
        public var profileURL: String?
        public var name: String
        public var timeMet: String
        public var notificationKey: LocalModel.Key

        public init(
            identifier: String,
            otherUserID: Int,
            profileURL: String?,
            name: String,
            timeMet: String,
            notificationKey: LocalModel.Key
        ) {
            self.greetIdentifier = identifier
            self.otherUserID = otherUserID
            self.profileURL = profileURL
            self.name = name
            self.timeMet = timeMet
            self.notificationKey = notificationKey
        }
    }
}
