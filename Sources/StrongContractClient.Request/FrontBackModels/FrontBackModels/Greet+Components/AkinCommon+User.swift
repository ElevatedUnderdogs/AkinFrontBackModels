//
//  User.swift
//  akin
//
//  Created by Scott Lydon on 8/4/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//

import Foundation
import CoreLocation

typealias UsersAction = ([Greet.User]) -> Void

public struct User: Codable {

    // MARK - properties

    public var privacy: PrivateDetails? // Codable
    public var imgData: Data?
    public var imgLocation: String?
    public var name: String
    public var id: Int
    public var email: String
    public var zip: Int?
    public var phoneNumber: Int? = nil
    public var requiredQuestions: [Question] = [] // Codable
    public var birthDate: Date? = nil
    public var profilePicData: Data? = nil
    public var meetingSchedule: [Week.Day] = []
    public var dobString: String?

    // MARk - inits

    init(
        img imgData: Data? = nil,
        imgLocation: String? = nil,
        name: String,
        user_id: Int,
        email: String,
        zip: Int? = nil,
        dob: String? = nil
    ) {
        self.imgData = imgData
        self.id = user_id
        self.imgLocation = imgLocation
        self.name = name
        self.email = email
        self.zip = zip
        self.dobString = dob
    }
}