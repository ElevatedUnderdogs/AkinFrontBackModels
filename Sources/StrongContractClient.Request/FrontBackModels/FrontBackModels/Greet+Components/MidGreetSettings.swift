//
//  MidGreetSettings.swift
//  akin
//
//  Created by Scott Lydon on 8/4/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//

import Foundation

extension Greet {

    public struct Settings: Codable, Equatable, Hashable {
        public var rejectedTimeProposals: [Int] = []
        public var agreedTimeProposals: [Int] = []
        public var status: Greet.Update.Status
        public let id: UUID

        public init(
            rejectedTimeProposals: [Int] = [],
            agreedTimeProposals: [Int] = [],
            status: Greet.Update.Status,
            id: UUID
        ) {
            self.rejectedTimeProposals = rejectedTimeProposals
            self.agreedTimeProposals = agreedTimeProposals
            self.status = status
            self.id = id
        }

        public mutating func updateSettings(with otherUserSettings: Settings?) {
            guard let otherUserSettings = otherUserSettings else { return }

            let commonProposedTimes = agreedTimeProposals.filter {
                otherUserSettings.agreedTimeProposals.contains($0)
            }
            let validProposedTimes = commonProposedTimes.filter {
                !rejectedTimeProposals.contains($0) && !otherUserSettings.rejectedTimeProposals.contains($0)
            }

            if !validProposedTimes.isEmpty {
                status = .enroute
            }
        }

        public init(status: Greet.Update.Status, id: UUID) {
            self.status = status
            self.id = id
        }
    }
}
