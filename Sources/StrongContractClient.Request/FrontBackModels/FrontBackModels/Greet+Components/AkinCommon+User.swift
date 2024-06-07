//
//  User.swift
//  akin
//
//  Created by Scott Lydon on 8/4/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//

import Foundation

public typealias UsersAction = ([Greet.User]) -> Void

public struct User: Codable {

    // MARK - properties

    public var privacy: PrivateDetails? // Codable
    public var imgData: Data?
    public var imgLocation: String?
    public var name: String
    public var id: String
    public var email: String
    public var zip: Int?
    public var phoneNumber: Int? = nil
    public var requiredQuestions: [Question] = [] // Codable
    public var birthDate: Date? = nil
    public var profilePicData: Data? = nil
    public var meetingSchedule: [Week.Day] = []
    public var dobString: String?
    public var accessToken: String?

    // MARk - inits

    public init(
        img imgData: Data? = nil,
        imgLocation: String? = nil,
        name: String,
        user_id: String,
        email: String,
        zip: Int? = nil,
        dob: String? = nil,
        accessToken: String? = nil
    ) {
        self.imgData = imgData
        self.id = user_id
        self.imgLocation = imgLocation
        self.name = name
        self.email = email
        self.zip = zip
        self.dobString = dob
        self.accessToken = accessToken
    }
}
