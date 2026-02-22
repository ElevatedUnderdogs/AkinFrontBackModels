//
//  File.swift
//  
//
//  Created by Scott Lydon on 4/7/24.
//

import Foundation

public enum GreetedClientStatus: Codable, Equatable, Hashable {
    /// After both users confirmed that they met at the meeting point.
    case confirmedMet
    /// When the user started or is moving towards the meeting point
    /// When a user when too far out of range of the meeting location.
    case exceededRange
    /// When the user rejects the other user for a greeting opportunity.
    case rejectedOther
    /// When the user opens the greet and views it.
    case onGoing
    // The other rejected or did something to end the greet.
    case connectionLost
}

public struct ClientGreetingSettings: Codable, Equatable, Hashable {
    public var greetedUser: GreetedUser
    public var initiatedTime: Date
    public var meetTime: Date?

    public init(greetedUser: GreetedUser, initiatedTime: Date, meetTime: Date? = nil) {
        self.greetedUser = greetedUser
        self.initiatedTime = initiatedTime
        self.meetTime = meetTime
    }
}

public enum NotificationFrequency: String, CaseIterable, Identifiable, Codable, Equatable, Hashable {
    case hourly = "Hourly"
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case never = "Never"
    case unrestricted = "Unrestricted"

    public var id: String { self.rawValue }
}

public struct GreetedUser: Identifiable, Codable, Equatable, Hashable {
    public let id: UUID
    public var name: String
    public var profileImageURL: String
    public var isBlocked: Bool
    public var manualNotificationFrequency: NotificationFrequency
    public var automaticNotificationFrequency: NotificationFrequency
    /// 0.0 - 1.0 represents 100%
    public var rating: Double?
    public var greetIDs: [UUID] = []
    public var metOnDate: Date?

    public init(
        id: UUID,
        name: String,
        profileImageURL: String,
        isBlocked: Bool = false,
        manualNotificationFrequency: NotificationFrequency = .unrestricted,
        automaticNotificationFrequency: NotificationFrequency = .unrestricted,
        rating: Double? = nil,
        greetIDs: [UUID] = [],
        metOnDate: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.profileImageURL = profileImageURL
        self.isBlocked = isBlocked
        self.manualNotificationFrequency = manualNotificationFrequency
        self.automaticNotificationFrequency = automaticNotificationFrequency
        self.rating = rating
        self.greetIDs = greetIDs
        self.metOnDate = metOnDate
    }
}

// Response model for `register(basicInfo:)` API call
public struct RegisterResponse: Codable {
    public var success: Bool
    public var message: String?
    public var userId: UUID?

    public init(success: Bool, message: String?, userId: UUID?) {
        self.success = success
        self.message = message
        self.userId = userId
    }
}

//public struct GeneralUser: Codable {
//    public let id: UUID
//    public let name: String
//    public let profilePictures: [String]
//    public let verified: Bool
//    public init(
//        id: UUID,
//        name: String,
//        profilePictures: [String] = [],
//        verified: Bool = false
//    ) {
//        self.id = id
//        self.name = name
//        self.profilePictures = profilePictures
//        self.verified = verified
//    }
//}

public struct StandardPostResponse: Codable {
    public var success: Bool
    public var message: String?

    public init(success: Bool, message: String? = nil) {
        self.success = success
        self.message = message
    }
}

// Response model for `triggerTwoPersonGreet(twoIDs:)` API call
public struct TwoPersonGreetResponse: Codable {
    public var success: Bool
    public var message: String?

    public init(success: Bool, message: String? = nil) {
        self.success = success
        self.message = message
    }
}

// Response model for `reportFlags(_:question:)`, `reportFlags(_:response:for:)`, `reportFlags(_:picURL:userID:)` API calls
public struct ReportFlagsResponse: Codable {
    public var success: Bool
    public var flaggedCount: Int?

    public init(success: Bool, flaggedCount: Int? = nil) {
        self.success = success
        self.flaggedCount = flaggedCount
    }
}

// Response model for `getUserInformation` API call
public struct GetUserInformationResponse: Codable {
    public var user: UserInformation

    public init(user: UserInformation) {
        self.user = user
    }
}

public struct UserInformation: Codable {
    public var id: UUID
    public var name: String
    public var email: String
    public var profileImageUrl: String?
    public var bio: String?

    public init(id: UUID, name: String, email: String, profileImageUrl: String? = nil, bio: String? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.profileImageUrl = profileImageUrl
        self.bio = bio
    }
}

// Response model for `rate(greetid:otherUser:rating:)` API call
public struct RateResponse: Codable {
    public var success: Bool
    public var newRating: Double?

    public init(success: Bool, newRating: Double? = nil) {
        self.success = success
        self.newRating = newRating
    }
}


// Response model for `updateUserLocation(userId:contextId:)`, `silentPushLocationUpdates(alwaysOn:)`, `updateLocation(token:userID:lat:lon:)` API calls
public struct LocationUpdateResponse: Codable {
    public var success: Bool
    public var message: String?

    public init(success: Bool, message: String? = nil) {
        self.success = success
        self.message = message
    }
}


// Response model for `update(importance:for:questionID:)` API call
public struct UpdateImportanceResponse: Codable {
    public var success: Bool
    public var updatedImportance: Question.Importance?

    public init(success: Bool, updatedImportance: Question.Importance? = nil) {
        self.success = success
        self.updatedImportance = updatedImportance
    }
}

// Response model for `track(events:)` API call
public struct TrackEventsResponse: Codable {
    public var success: Bool
    public var trackedEventsCount: Int?

    public init(success: Bool, trackedEventsCount: Int? = nil) {
        self.success = success
        self.trackedEventsCount = trackedEventsCount
    }
}

// Response model for `updateEmail(new:password:)`, `updateCourtesyCallSetting(allows:)`, `update(oldPassword:newPassword:savedEmail:)` API calls
public struct UpdateEmailResponse: Codable {
    public var success: Bool
    public var message: String?

    public init(success: Bool, message: String? = nil) {
        self.success = success
        self.message = message
    }
}

public enum ManualGreetResponse: Codable {
    case notification(ManualGreetNotification)
    case otherUserIsInGreet
    case thisUserIsInGreet
    case thisAndOtherUserAlreadyInSameGreet
    case noNearbyVenuesOpen
}

public struct ManualGreetNotification: Codable {

    public let notification: Greet.Notification
    public let status: ManualGreetStatus

    public init(notification: Greet.Notification, status: ManualGreetStatus) {
        self.notification = notification
        self.status = status
    }
}

public enum ManualGreetStatus: String, Codable, Equatable, Hashable {
    case success
}

// Response model for `resetPassword(email:)` API call
public struct ResetPasswordResponse: Codable {
    public var success: Bool
    public var message: String?

    public init(success: Bool, message: String? = nil) {
        self.success = success
        self.message = message
    }
}

// Response model for `change(email:to:)` API call
public struct ChangeEmailResponse: Codable {
    public var success: Bool
    public var message: String?

    public init(success: Bool, message: String? = nil) {
        self.success = success
        self.message = message
    }
}

// Response model for `registerDeviceToken(error:)` and `register(deviceToken:)` API calls
public struct RegisterDeviceTokenResponse: Codable {
    public var success: Bool
    public var message: String?

    public init(success: Bool, message: String? = nil) {
        self.success = success
        self.message = message
    }
}

// Response model for `hide(me:)` API call
public struct HideMeResponse: Codable {
    public var success: Bool
    public var message: String?

    public init(success: Bool, message: String? = nil) {
        self.success = success
        self.message = message
    }
}

// Response model for `register(pushKitDeviceToken:)` API call
public struct RegisterPushKitDeviceTokenResponse: Codable {
    public var success: Bool
    public var message: String?

    public init(success: Bool, message: String? = nil) {
        self.success = success
        self.message = message
    }
}

// Response model for `block(user:)` and `block(otherID:shouldBlock:)` API calls
public struct BlockUserResponse: Codable {
    public var success: Bool
    public var blockedUserId: UUID?

    public init(success: Bool, blockedUserId: UUID? = nil) {
        self.success = success
        self.blockedUserId = blockedUserId
    }
}

public struct TokenResponse: Codable, Hashable, Equatable {
    public let token: String
    public let expiration: Date

    public init(token: String, expiration: Date) {
        self.token = token
        self.expiration = expiration.randomEarlierDate
    }
}

// Response model for `login(email:password:)` API call
public struct LoginResponse: Codable {
    public var success: Bool
    public var user: User
    public var authToken: TokenResponse
    public var refreshToken: TokenResponse

    public init(success: Bool, user: User, authToken: TokenResponse, refreshToken: TokenResponse) {
        self.success = success
        self.user = user
        self.authToken = authToken
        self.refreshToken = refreshToken
    }
}

/// Helper struct for decoding the refresh token from the body
/// Used to request a new access token
public struct RefreshTokenRequestPayload: Codable {
    public let refreshToken: String

    public init(refreshToken: String) {
        self.refreshToken = refreshToken
    }
}

// Response model for `add(response:questionID:)` API call
public struct AddResponseResponse: Codable {
    public var success: Bool
    public var responseId: UUID?

    public init(success: Bool, responseId: UUID? = nil) {
        self.success = success
        self.responseId = responseId
    }
}

// Response model for `nearbyUsers(location:)` API call
public struct NearbyUsersResponse: Codable {
    public var success: Bool
    public var users: [UserInformation] // Reusing UserInformation public struct from earlier

    public init(success: Bool, users: [UserInformation]) {
        self.success = success
        self.users = users
    }
}

// Response model for `make(my:their:for:for:forContext:)` API call
public struct MakeResponseResponse: Codable {
    public var success: Bool
    public var message: String?

    public init(success: Bool, message: String? = nil) {
        self.success = success
        self.message = message
    }
}

// Response model for `responses(question:context:)` and `responses(search:question:context:)` API calls
public struct QuestionResponsesResponse: Codable {
    public var success: Bool
    public var responses: [QuestionResponse]

    public struct QuestionResponse: Codable {
        public var id: UUID
        public var text: String
        public var selected: Bool
    }

    public init(success: Bool, responses: [QuestionResponse]) {
        self.success = success
        self.responses = responses
    }
}

// Response model for `questions(search:type:page:context:required:)` API call
public struct QuestionsResponse: Codable {
    public var success: Bool
    public var questions: [Question]

    // Reusing Question public struct from earlier

    public init(success: Bool, questions: [Question]) {
        self.success = success
        self.questions = questions
    }
}

// Response model for `logout` API call
public struct LogoutResponse: Codable {
    public var success: Bool
    public var message: String?

    public init(success: Bool, message: String? = nil) {
        self.success = success
        self.message = message
    }
}

// Response model for `update(settings:)` API call
public struct UpdateSettingsResponse: Codable {
    public var success: Bool
    public var message: String?

    public init(success: Bool, message: String? = nil) {
        self.success = success
        self.message = message
    }
}

// Response model for `addDisplay()` and `uploadPic` API calls
public struct AddDisplayPictureResponse: Codable {
    public var success: Bool
    public var imageUrl: String?

    public init(success: Bool, imageUrl: String? = nil) {
        self.success = success
        self.imageUrl = imageUrl
    }
}

// Response model for the `uploadPic` API call
public struct UploadPicResponse: Codable {
    public var success: Bool
    public var imageUrl: String?

    public init(success: Bool, imageUrl: String? = nil) {
        self.success = success
        self.imageUrl = imageUrl
    }
}

// Assuming a response model for the commented-out `register(basicInfo:)` URL creation function
public struct RegisterBasicInfoResponse: Codable {
    public var success: Bool
    public var userId: UUID?
    public var message: String?

    public init(success: Bool, userId: UUID? = nil, message: String? = nil) {
        self.success = success
        self.userId = userId
        self.message = message
    }
}

// Assuming a response model for the commented-out `prefetchUser(for:)` URL creation function
public struct PrefetchUserForResponse: Codable {
    public var success: Bool
    public var users: [UserDetail]

    public struct UserDetail: Codable {
        public var id: UUID
        public var name: String
        public var profileImageUrl: String?
    }

    public init(success: Bool, users: [UserDetail]) {
        self.success = success
        self.users = users
    }
}

// Assuming a response model for the commented-out `triggerTwoPersonGreet(with:and:)` URL creation function
public struct TriggerTwoPersonGreetResponse: Codable {
    public var success: Bool
    public var message: String?

    public init(success: Bool, message: String? = nil) {
        self.success = success
        self.message = message
    }
}

public typealias Ettiquette = TermsOfService

public struct TermsOfService: Codable, Equatable, Hashable {
    public var version: String
    public var effectiveDate: Date
    public var requiresReacceptance: Bool
    public var summary: String?

    public var text: String
    public var appName: String
    public var contactInfo: String

    public init(
        version: String,
        effectiveDate: Date,
        requiresReacceptance: Bool,
        summary: String? = nil,
        text: String,
        appName: String,
        contactInfo: String
    ) {
        self.version = version
        self.effectiveDate = effectiveDate
        self.requiresReacceptance = requiresReacceptance
        self.summary = summary
        self.text = text
        self.appName = appName
        self.contactInfo = contactInfo
    }
}

#if canImport(MapKit)
import MapKit

extension TravelMethod {

    public var transportType: MKDirectionsTransportType {
        switch self {
        case .bike: return .walking
        case .car, .motorcycle: return .automobile
        case .none: return .walking
        case .walk: return .walking
        case .transit: return .transit
        }
    }
}
#endif
