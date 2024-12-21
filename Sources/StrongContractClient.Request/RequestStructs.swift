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
        self.oldPassword = oldPassword.sha512hexa
        self.newPassword = newPassword.sha512hexa
    }
}

public typealias DeviceDescription = String
public typealias AddQuestionRequest = String
// GreetID type has been changed to String to allow storage of Fluent Models identifiers (UUID string)
public typealias GreetID = String
public typealias Events = [Int: String]

public struct CredentialUpdate: Codable {
    public let newEmail, password: String
    public init(newEmail: String, password: String) {
        self.newEmail = newEmail
        self.password = password.sha512hexa
    }
}

public struct ImportancesUpdate: Codable {
    public let importances: [ContextRawValue: Question.Importance]
    public let questionID: UUID

    public init(importances: [ContextRawValue: Question.Importance], questionID: UUID) {
        self.importances = importances
        self.questionID = questionID
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

// Request public structure for updating user location with user ID and context ID
public struct UserLocationUpdate: Codable {
    public let contextId: String
    public let coordinates: Coordinates

    public init(
        contextId: String,
        coordinates: Coordinates
    ) {
        self.contextId = contextId
        self.coordinates = coordinates
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

public typealias DeviceToken = String

public typealias HideMe = Bool

public typealias PushkitDeviceToken = String

public struct LoginPayload: Codable {
    public let email, password: String
    public init(email: String, password: String) {
        self.email = email.sha256hexa
        self.password = password.sha512hexa
    }
}

public struct PasscodePayload: Codable {
    public let email, passcode: String
    public init(email: String, passcode: String) {
        self.email = email.sha256hexa
        self.passcode = passcode.sha512hexa
    }
}


extension Question.Response {

    public struct Parts: Equatable, Codable {
        public let text: String
        public let timeStamp: Date
        public let creatorID: UUID
        public var myChoice: [ContextRawValue: Selections.MyTheir.Choice] = [:]
        public var theirChoices: [ContextRawValue: Selections.MyTheir.Choice] = [:]

        public init(
            text: String,
            timeStamp: Date,
            creatorID: UUID,
            myChoice: [ContextRawValue: Selections.MyTheir.Choice],
            theirChoices: [ContextRawValue: Selections.MyTheir.Choice]
        ) {
            self.text = text
            self.timeStamp = timeStamp
            self.creatorID = creatorID
            self.myChoice = myChoice
            self.theirChoices = theirChoices
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
    public let myTheir: Question.Response.Selections.MyTheir?
    public let choice: Question.Response.Selections.MyTheir.Choice?
    public let responseID: UUID
    public let questionID: UUID
    public let context: Context

    public init(
        myTheir: Question.Response.Selections.MyTheir? = nil,
        choice: Question.Response.Selections.MyTheir.Choice? = nil,
        responseID: UUID,
        questionID: UUID,
        context: Context
    ) {
        self.myTheir = myTheir
        self.choice = choice
        self.responseID = responseID
        self.questionID = questionID
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
    public let required: Bool

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
