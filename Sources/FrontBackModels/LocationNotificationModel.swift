//
//  LocalNotifications.swift
//  akin
//
//  Created by Scott Lydon on 4/9/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//

import Foundation

extension Greet.Notification {
    
    public struct LocalModel: Codable, Equatable, Hashable {

        public enum Key: String, Codable {
            case getReviewTime, weClosedTheGreet
        }
        
        public var greetID: UUID
        public var otherUserID: UUID
        public var profileURL: String?
        public var name: String
        public var timeMet: String
        public var notificationKey: LocalModel.Key

        public init(
            greetID: UUID,
            otherUserID: UUID,
            profileURL: String?,
            name: String,
            timeMet: String,
            notificationKey: LocalModel.Key
        ) {
            self.greetID = greetID
            self.otherUserID = otherUserID
            self.profileURL = profileURL
            self.name = name
            self.timeMet = timeMet
            self.notificationKey = notificationKey
        }
    }
}
