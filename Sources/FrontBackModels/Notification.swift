//
//  AppNotification.swift
//  akin
//
//  Created by Scott Lydon on 4/9/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//

import Foundation

public struct APNSPayload<Payload: Codable>: Codable {
    public let payload: Payload
    public let apnsID: UUID

    public init(payload: Payload, apnsID: UUID) {
        self.payload = payload
        self.apnsID = apnsID
    }
}

extension Greet {

    public enum Notification: Codable, Equatable, Hashable {

        case getRating(Greet.Notification.LocalModel)
        case greet(Greet)
        case silentLocationUpdate

        // Commented out by Scott Lydon + claude on 4/19/26:
        // Moved out of `Greet.Notification` into its own top-level
        // `VoipCallPayload` type.  The `.voipCall` case previously
        // embedded a full `Greet` (with its unbounded `events` array,
        // full `NearbyUser`, full `Venue`, `openers`, etc.) which
        // routinely pushed the VoIP (PushKit) payload past Apple's
        // 5120 byte ceiling, producing APNs `413 PayloadTooLarge`.
        // Keeping the incoming-call shape as a distinct top-level
        // Codable struct prevents any future caller from accidentally
        // stuffing a full `Greet` into the VoIP pipe again.
        //
        // /// A VoIP call notification that carries a callType so the
        // /// client can distinguish ring-to-greet from live VoIP calls.
        // case voipCall(Greet, callType: CallType)

        public init(localNotificationModel: Greet.Notification.LocalModel) {
            self = .getRating(localNotificationModel)
        }

        // Define an enum for case types to avoid stringly-typed values
        private enum CaseType: String, Codable {
            case getRating
            case greet
            case silentLocationUpdate
            // Commented out by Scott Lydon + claude on 4/19/26:
            // the `.voipCall` case has been extracted to the top-level
            // `VoipCallPayload` type.  Discriminator retained here as a
            // comment for grep-ability during the migration.
            // case voipCall
        }

        private enum CodingKeys: String, CodingKey {
            case caseType
            case associatedValue
            // Commented out by Scott Lydon + claude on 4/19/26:
            // The `.callType` coding key was only used by the removed
            // `.voipCall` case.  Left here as a breadcrumb for anyone
            // grepping the migration history.
            // case callType
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

            // Commented out by Scott Lydon + claude on 4/19/26:
            // case .voipCall(let greet, let callType):
            //     try container.encode(CaseType.voipCall, forKey: .caseType)
            //     try container.encode(greet, forKey: .associatedValue)
            //     try container.encode(callType, forKey: .callType)
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

            // Commented out by Scott Lydon + claude on 4/19/26:
            // case .voipCall:
            //     let greet = try container.decode(Greet.self, forKey: .associatedValue)
            //     let callType = try container.decode(CallType.self, forKey: .callType)
            //     self = .voipCall(greet, callType: callType)
            }
        }
    }
}
