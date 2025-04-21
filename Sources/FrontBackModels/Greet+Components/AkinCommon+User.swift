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
    public var cloudFlareImageID: String?
    public var firstName: String
    public var lastName: String
    public var id: UUID
    public var email: String
    public var zip: Int?
    public var phoneNumber: Int? = nil
    public var requiredQuestions: [Question] = [] // Codable
    public var birthDate: Date? = nil
    public var meetingSchedule: [Week.Day] = []
    public var dobString: String?

    // MARk - inits

    public init(
        cloudFlareImageID: String? = nil,
        firstName: String,
        lastName: String,
        user_id: UUID,
        email: String,
        zip: Int? = nil,
        dob: String? = nil
    ) {
        self.id = user_id
        self.cloudFlareImageID = cloudFlareImageID
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.zip = zip
        self.dobString = dob
    }
}
