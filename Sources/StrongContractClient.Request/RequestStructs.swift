//
//  RequestStructs.swift
//
//
//  Created by Scott Lydon on 4/7/24.
//
import Foundation

public typealias UpdateMidGreetSettingsRequest = Greet.Settings

public struct Assertion: Codable {
    public let assertion: Bool
    public let message: String
    public let file: String
    public let line: Int

    public init(
        assertion: Bool = false,
        message: String,
        file: String = #file,
        line: Int = #line
    ) {
        self.assertion = assertion
        self.message = message
        self.file = file
        self.line = line
    }
}

typealias UpdateCourtesyCallSettingRequest = Bool

public struct PasswordUpdate: Codable {
    public let oldPassword, newPassword: String
    public init(oldPassword: String, newPassword: String) {
        self.oldPassword = oldPassword
        self.newPassword = newPassword
    }
}

public typealias DeviceDescription = String
public typealias AddQuestionRequest = String
// GreetID type has been changed to String to allow storage of Fluent Models identifiers (UUID string)
public typealias GreetID = UUID
public typealias Events = [Int: String]

public struct CredentialUpdate: Codable {
    public let newEmail, password: String
    public init(newEmail: String, password: String) {
        self.newEmail = newEmail
        self.password = password
    }
}

public struct ImportancesUpdate: Codable {
    public let importances: [ContextRawValue: Question.Importance]
    public let questionID: UUID
    public let createdAt: Date

    public init(importances: [ContextRawValue: Question.Importance], questionID: UUID, createdAt: Date) {
        self.importances = importances
        self.questionID = questionID
        self.createdAt = createdAt
    }
}

// Define the argument public structs
public struct ReportFlagsQuestion: Codable {
    public let flags: [Int]
    public let questionID: UUID

    public init(flags: [Int], questionID: UUID) {
        self.flags = flags
        self.questionID = questionID
    }
}

// Request public structure for `reportFlags` with question ID
public struct ReportFlagsQuestionRequest: Codable {
    public let flags: [Int]
    public let questionId: UUID

    public init(flags: [Int], questionId: UUID) {
        self.flags = flags
        self.questionId = questionId
    }
}

// Request public structure for `reportFlags` with response ID and question ID
public struct ResponseFlags: Codable {
    public let flags: [Int]
    public let responseId: UUID
    public let questionId: UUID

    public init(flags: [Int], responseId: UUID, questionId: UUID) {
        self.flags = flags
        self.responseId = responseId
        self.questionId = questionId
    }
}

// Request public structure for `reportFlags` with pic URL and userID
public struct PicFlags: Codable {
    public let flags: [Int]
    public let picURL: String

    public init(flags: [Int], picURL: String) {
        self.flags = flags
        self.picURL = picURL
    }
}

// Request public structure for rating a greet
public struct Rating: Codable {
    public let greetId: UUID
    public let otherUserId: UUID
    public let rating: Double

    public init(greetId: UUID, otherUserId: UUID, rating: Double) {
        self.greetId = greetId
        self.otherUserId = otherUserId
        self.rating = rating
    }
}

public typealias ShouldEnableSilentPushNoticeUpdates = Bool

public typealias PasswordlessAuthentication = String

public struct EmailChange: Codable {
    public let currentEmail: String
    public let newEmail: String

    public init(currentEmail: String, newEmail: String) {
        self.currentEmail = currentEmail
        self.newEmail = newEmail
    }
}

// Helper method to determine the platform
var getPlatform: String {
    #if os(iOS)
    return "iOS"
    #elseif os(macOS)
    return "macOS"
    #elseif os(tvOS)
    return "tvOS"
    #elseif os(watchOS)
    return "watchOS"
    #elseif os(Linux)
    return "Linux"
    #else
    return "Unknown"
    #endif
}

public struct DeviceTokenPayload: Codable, Hashable, Equatable {
    public let deviceToken: String
    public let platform: String

    public init(deviceToken: String, platform: String? = nil) {
        self.deviceToken = deviceToken
        self.platform = platform ?? getPlatform
    }
}


public typealias HideMe = Bool

public typealias PushkitDeviceToken = String

public struct LoginPayload: Codable {

    /// Email does not need encryption
    public let email: String

    /// The password is encrypted https to be sent in the body
    /// The password is stored encrypted as well.
    public let password: String

    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}

/// I need to check if this is used for the email verification.. 
public struct PasscodePayload: Codable {
    public let email, passcode: String
    public init(email: String, passcode: String) {
        self.email = email
        self.passcode = passcode
    }
}

extension Question.Response {

    public struct Parts: Equatable, Codable {
        public let text: String
        public let timeStamp: Date
        public let creatorID: UUID
        public let originalContextID: UUID
        public let originalContextRaw: String
        public var myChoice: [ContextRawValue: Selections.MyTheir.Choice] = [:]
        public var theirChoices: [ContextRawValue: Selections.MyTheir.Choice] = [:]

        public init(
            text: String,
            timeStamp: Date,
            creatorID: UUID,
            originalContextId: UUID,
            originalContextRaw: String,
            myChoice: [ContextRawValue: Selections.MyTheir.Choice],
            theirChoices: [ContextRawValue: Selections.MyTheir.Choice]
        ) {
            self.originalContextID = originalContextId
            self.text = text
            self.timeStamp = timeStamp
            self.creatorID = creatorID
            self.myChoice = myChoice
            self.theirChoices = theirChoices
            self.originalContextRaw = originalContextRaw
        }
    }
}

/// Adding a response when the question was saved, and its id is known - Question and Responses QuestionResponseParts (questionid, response'parts)
public struct AddResponses: Codable {
    public let responsesParts: [Question.Response.Parts]
    public let questionID: UUID

    public init(responsesParts: [Question.Response.Parts], questionID: UUID) {
        self.responsesParts = responsesParts
        self.questionID = questionID
    }
}

/// Adding a response when the question was saved, and its id is known - Question and Responses QuestionResponseParts (questionid, response'parts)
public struct AddResponse: Codable {
    public let responsesParts: Question.Response.Parts
    public let questionID: UUID

    public init(responsesParts: Question.Response.Parts, questionID: UUID) {
        self.responsesParts = responsesParts
        self.questionID = questionID
    }
}

public struct AnswerChoice: Codable {
    public let myTheir: Question.Response.Selections.MyTheir

    /// This one is optional, because a user may deselect a choice.
    /// This should update the backend as being nil, or delete the choice.
    /// mathematically this is redundant to neutral, but with neutral, the app saves the explicit
    /// communication that the user feels neutral about the choice, this makes some users feel better (Albert Yu).
    public let choice: Question.Response.Selections.MyTheir.Choice?
    public let responseID: UUID

    /// While this is a bit redundant, it helps with denormalization, saves a query
    public let questionID: UUID
    public let createdAt: Date
    public let context: Context

    public init(
        myTheir: Question.Response.Selections.MyTheir,
        choice: Question.Response.Selections.MyTheir.Choice? = nil,
        responseID: UUID,
        questionID: UUID,
        createdAt: Date,
        context: Context
    ) {
        self.myTheir = myTheir
        self.choice = choice
        self.responseID = responseID
        self.questionID = questionID
        self.createdAt = createdAt
        self.context = context
    }
}

public struct ResponsesSpecifications: Codable {
    public let questionID: UUID
    public let context: Context.RawValue
    public let searchText: String?

    public init(questionID: UUID, context: Context.RawValue, searchText: String? = nil) {
        self.questionID = questionID
        self.context = context
        self.searchText = searchText
    }
}

public struct QuestionsSpecifications: Codable {
    public let searchText: String?
    public let type: Question.Category.RawValue
    public let page: Int?
    public let context: Context.RawValue

    /// Specifies if this user has marked the question to be required for the given context.
    /// This means that in order for another user to be considered compatile, they must answer
    /// questions marked as required.  
    public let required: Bool


    /// <#Description#>
    /// - Parameters:
    ///   - searchText: <#searchText description#>
    ///   - type: <#type description#>
    ///   - page: <#page description#>
    ///   - context: The context for which questions are popularly answered, or
    ///    popularly important, there will be an algorithm for this.
    ///   - required: <#required description#>
    public init(
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
