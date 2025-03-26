//
//  PrivateDetails.swift
//  akin
//
//  Created by Scott Lydon on 8/4/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//

import Foundation

public struct PrivateDetails: Codable {
    public var password: String
    public var romanceOn: Bool
    public var token: String

    public init(password: String, romanceOn: Bool, accessToken: String) {
        self.password = password
        self.romanceOn = romanceOn
        self.token = accessToken
    }
}
