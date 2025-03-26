//
//  AppNotification.swift
//  akin
//
//  Created by Scott Lydon on 4/9/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//

extension Greet {

    public enum Notification: Codable, Equatable, Hashable {

        case getRating(Greet.Notification.LocalModel)
        case greet(Greet)
        case silentLocationUpdate

        public init(localNotificationModel: Greet.Notification.LocalModel) {
            self = .getRating(localNotificationModel)
        }

        // Define an enum for case types to avoid stringly-typed values
        private enum CaseType: String, Codable {
            case getRating
            case greet
            case silentLocationUpdate
        }

        private enum CodingKeys: String, CodingKey {
            case caseType
            case associatedValue
        }

        // Encode
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            switch self {
            case .getRating(let model):
                try container.encode(CaseType.getRating, forKey: .caseType)
                try container.encode(model, forKey: .associatedValue)

            case .greet(let greet):
                try container.encode(CaseType.greet, forKey: .caseType)
                try container.encode(greet, forKey: .associatedValue)

            case .silentLocationUpdate:
                try container.encode(CaseType.silentLocationUpdate, forKey: .caseType)
            }
        }

        // Decode
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let caseType = try container.decode(CaseType.self, forKey: .caseType)

            switch caseType {
            case .getRating:
                let model = try container.decode(Greet.Notification.LocalModel.self, forKey: .associatedValue)
                self = .getRating(model)

            case .greet:
                let greet = try container.decode(Greet.self, forKey: .associatedValue)
                self = .greet(greet)

            case .silentLocationUpdate:
                self = .silentLocationUpdate
            }
        }
    }
}
