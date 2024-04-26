//
//  File.swift
//  
//
//  Created by Scott Lydon on 4/7/24.
//

import Foundation

public struct UpdateMidGreetSettingsRequest: Codable {
    public var midGreetSettings: Greet.Settings

    init(midGreetSettings: Greet.Settings) {
        self.midGreetSettings = midGreetSettings
    }
}

public struct UpdateScheduleRequest: Codable {
    // Assuming token and user ID are fetched internally in StrongContractClient, so no explicit properties are required here.
}
public struct UpdateGreetRequest: Codable {
    // Similar assumption as above.
}

public struct UpdateGreetSettingsRequest: Codable {
    // Similar assumption as above.
}

public struct AssertRequest: Codable {
    public var assertion: Bool
    public var message: String
    public var file: String
    public var line: Int

    init(assertion: Bool, message: String, file: String, line: Int) {
        self.assertion = assertion
        self.message = message
        self.file = file
        self.line = line
    }
}

// Argument public structs
public struct UpdateCourtesyCallSettingRequest: Codable {
    public var allows: Bool

    init(allows: Bool) {
        self.allows = allows
    }
}

public struct UpdatePasswordRequest: Codable {
    public var oldPassword: String
    public var newPassword: String
    public var savedEmail: String

    init(oldPassword: String, newPassword: String, savedEmail: String) {
        self.oldPassword = oldPassword
        self.newPassword = newPassword
        self.savedEmail = savedEmail
    }
}

public struct SendMakeRequest: Codable {
    public var deviceString: String

    init(deviceString: String) {
        self.deviceString = deviceString
    }
}

public struct AddQuestionRequest: Codable {
    public var questionText: String // Assuming 'Question' has a 'text' property
    // The date might be generated at the time of the request, so it's not included here.

    init(questionText: String) {
        self.questionText = questionText
    }
}

public struct ManualGreetRequest: Codable {
    public var otherID: Int

    init(otherID: Int) {
        self.otherID = otherID
    }
}

public struct TrackEventsRequest: Codable {
    public var events: [Int: String]

    init(events: [Int : String]) {
        self.events = events
    }
}

public struct UpdateEmailRequest: Codable {
    public var newEmail: String
    public var password: String

    init(newEmail: String, password: String) {
        self.newEmail = newEmail
        self.password = password
    }
}

public struct UpdateImportanceRequest: Codable {
    public var importance: Question.Importance
    public var context: Context
    public var questionID: Int

    init(importance: Question.Importance, context: Context, questionID: Int) {
        self.importance = importance
        self.context = context
        self.questionID = questionID
    }
}

public struct GetUserInformationRequest: Codable {
    public var accessToken: String // Added accessToken to match the provided description

    init(accessToken: String) {
        self.accessToken = accessToken
    }
}

// Define the argument public structs
public struct ReportFlagsQuestion: Codable {
    public var flags: [Int]
    public var questionID: Int

    init(flags: [Int], questionID: Int) {
        self.flags = flags
        self.questionID = questionID
    }
}

// Request public structure for `reportFlags` with question ID
public struct ReportFlagsQuestionRequest: Codable {
    let flags: [Int]
    let questionId: Int

    init(flags: [Int], questionId: Int) {
        self.flags = flags
        self.questionId = questionId
    }
}

// Request public structure for `reportFlags` with response ID and question ID
public struct ReportFlagsResponseRequest: Codable {
    let flags: [Int]
    let responseId: Int
    let questionId: Int

    init(flags: [Int], responseId: Int, questionId: Int) {
        self.flags = flags
        self.responseId = responseId
        self.questionId = questionId
    }
}

// Request public structure for `reportFlags` with pic URL and userID
public struct ReportFlagsPicURLRequest: Codable {
    let flags: [Int]
    let picURL: String
    let userId: Int

    init(flags: [Int], picURL: String, userId: Int) {
        self.flags = flags
        self.picURL = picURL
        self.userId = userId
    }
}

// Request public structure for rating a greet
public struct RateRequest: Codable {
    let greetId: String
    let otherUserId: Int
    let rating: Double

    init(greetId: String, otherUserId: Int, rating: Double) {
        self.greetId = greetId
        self.otherUserId = otherUserId
        self.rating = rating
    }
}

// Request public structure for updating user location with user ID and context ID
public struct UpdateUserLocationRequest: Codable {
    let userId: String
    let contextId: String

    init(userId: String, contextId: String) {
        self.userId = userId
        self.contextId = contextId
    }
}

// Request public structure for silent push location updates
public struct SilentPushLocationUpdatesRequest: Codable {
    let alwaysOn: Bool

    init(alwaysOn: Bool) {
        self.alwaysOn = alwaysOn
    }
}

// Request public structure for updating location with token, userID, latitude, and longitude
public struct UpdateLocationRequest: Codable {
    let token: String?
    let userId: String?
    let latitude: String
    let longitude: String

    init(token: String?, userId: String?, latitude: String, longitude: String) {
        self.token = token
        self.userId = userId
        self.latitude = latitude
        self.longitude = longitude
    }
}


// Define Argument public structs
public struct ResetPasswordRequest: Codable {
    public var email: String

    init(email: String) {
        self.email = email
    }
}

public struct ChangeEmailRequest: Codable {
    public var currentEmail: String
    public var newEmail: String

    init(currentEmail: String, newEmail: String) {
        self.currentEmail = currentEmail
        self.newEmail = newEmail
    }
}

public struct RegisterDeviceTokenErrorRequest: Codable {
    public var error: String

    init(error: String) {
        self.error = error
    }
}

public struct RegisterDeviceTokenRequest: Codable {
    public var deviceToken: String

    init(deviceToken: String) {
        self.deviceToken = deviceToken
    }
}

public struct HideMeRequest: Codable {
    public var hide: Bool

    init(hide: Bool) {
        self.hide = hide
    }
}

public struct RegisterPushKitDeviceTokenRequest: Codable {
    public var pushKitDeviceToken: String

    init(pushKitDeviceToken: String) {
        self.pushKitDeviceToken = pushKitDeviceToken
    }
}

// Define Argument public structs
public struct BlockUserRequest: Codable {
    public var otherUser: Int
    public var shouldBlock: Bool? // Optional to accommodate both block user functions

    init(otherUser: Int, shouldBlock: Bool? = nil) {
        self.otherUser = otherUser
        self.shouldBlock = shouldBlock
    }
}

public struct BlockedUsersRequest: Codable {
    // No additional parameters needed if the access token and user ID are internally managed
}

public struct LoginRequest: Codable {
    public var email: String
    public var password: String

    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}

public struct AddResponseRequest: Codable {
    public var responseText: String
    public var questionID: String

    init(responseText: String, questionID: String) {
        self.responseText = responseText
        self.questionID = questionID
    }
}

public struct NearbyUsersRequest: Codable {
    public var latitude: String
    public var longitude: String

    init(latitude: String, longitude: String) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

public struct MakeUserResponseRequest: Codable {
    public var myChoiceWeightMultiplier: Double?
    public var theirChoiceWeightMultiplier: Double?
    public var responseID: Int
    public var questionID: Int
    public var context: Context.RawValue

    init(
        myChoiceWeightMultiplier: Double? = nil,
        theirChoiceWeightMultiplier: Double? = nil,
        responseID: Int,
        questionID: Int,
        context: Context.RawValue
    ) {
        self.myChoiceWeightMultiplier = myChoiceWeightMultiplier
        self.theirChoiceWeightMultiplier = theirChoiceWeightMultiplier
        self.responseID = responseID
        self.questionID = questionID
        self.context = context
    }
}

public struct GetResponsesRequest: Codable {
    public var questionID: Int
    public var context: Context.RawValue
    public var searchText: String?

    init(questionID: Int, context: Context.RawValue, searchText: String? = nil) {
        self.questionID = questionID
        self.context = context
        self.searchText = searchText
    }
}

public struct GetQuestionsRequest: Codable {
    public var searchText: String?
    public var type: Question.Category.RawValue
    public var page: Int?
    public var context: Context.RawValue
    public var required: Bool

    init(
        searchText: String? = nil,
        type: Question.Category.RawValue,
        page: Int? = nil,
        context: Context.RawValue,
        required: Bool
    ) {
        self.searchText = searchText
        self.type = type
        self.page = page
        self.context = context
        self.required = required
    }
}

// No additional parameters needed if the access token and user ID are internally managed
public struct Empty: Codable {
    public init() {}
}
