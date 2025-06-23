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

public struct AppleAuthorization: Hashable, Equatable, Codable {

    public var userID: String
    /// This is only provided on the first attempt.
    public var email: String?
    /// This is only provided on the first attempt.
    public var firstName: String
    public var lastName: String
    public var identityToken: String

    public init(userID: String, email: String?, firstName: String, lastName: String, identityTokenString: String) {
        self.userID = userID
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.identityToken = identityTokenString
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
    var platform = "Unknown"

    #if os(iOS)
    platform = "iOS"
    #elseif os(macOS)
    platform = "macOS"
    #elseif os(tvOS)
    platform = "tvOS"
    #elseif os(watchOS)
    platform = "watchOS"
    #elseif os(Linux)
    platform = "Linux"
    #endif

    #if targetEnvironment(simulator)
    platform += " (Simulator)"
    #endif

    return platform
}

public struct DeviceTokenPayload: Codable, Hashable, Equatable {
    public let deviceToken: String
    public let platform: String
    public let deviceId: UUID?
    public let buildSource: BuildSource

    public init(
        deviceToken: String,
        platform: String? = nil,
        deviceId: UUID?,
        buildSource: BuildSource
    ) {
        self.deviceToken = deviceToken
        self.platform = platform ?? getPlatform
        self.deviceId = deviceId
        self.buildSource = buildSource
    }
}


public typealias HideMe = Bool

public struct LoginPayload: Codable {

    /// Email does not need encryption
    public let email: String

    /// The password is encrypted https to be sent in the body
    /// The password is stored encrypted as well.
    public let password: String

    public let termsPayload: AcceptTermsRequest

    public init(email: String, password: String, termsRequest: AcceptTermsRequest) {
        self.email = email
        self.password = password
        self.termsPayload = termsRequest
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
    public let compatibilityRule: CompatibilityRule

    public init(
        myTheir: Question.Response.Selections.MyTheir,
        choice: Question.Response.Selections.MyTheir.Choice? = nil,
        responseID: UUID,
        questionID: UUID,
        createdAt: Date,
        context: Context,
        compatibilityRule: CompatibilityRule
    ) {
        self.myTheir = myTheir
        self.choice = choice
        self.responseID = responseID
        self.questionID = questionID
        self.createdAt = createdAt
        self.context = context
        self.compatibilityRule = compatibilityRule
    }
}

public struct ResponsesSpecifications: Codable {
    public let questionID: UUID
    public let context: Context.RawValue
    public let searchText: String?
    public let page: Int
    public let limit: Int

    public init(
        questionID: UUID,
        context: Context.RawValue,
        searchText: String? = nil,
        page: Int = 1,
        limit: Int = 20
    ) {
        self.questionID = questionID
        self.context = context
        self.searchText = searchText
        self.page = page
        self.limit = limit
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
