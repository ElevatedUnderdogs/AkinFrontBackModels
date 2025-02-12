//
//  File.swift
//
//
//  Created by Scott Lydon on 4/7/24.
//

import Foundation
import StrongContractClient

public typealias LoginRequest = Request<LoginPayload, LoginResponse>
extension LoginRequest {

    /// Purpose: Authenticates the user using their credentials (email and password, or other methods like OAuth).
    public static var login: Self {
        .init(method: .post, assertHasAccessToken: false)
    }
}

public typealias LoginWithAccessToken = Request<Empty, LoginResponse>
extension LoginWithAccessToken {

    /// Purpose: Verifies the validity of an existing access token to allow the user to reauthenticate without re-entering credentials.
    public static var loginWithAccessToken: Self {
        .init(method: .post)
    }
}

/// Send a Refresh token in the body, get an access token in the response.
public typealias RefreshTokenRequest = Request<RefreshTokenRequestPayload, LoginResponse>
extension RefreshTokenRequest {

    /// Issues a new access token when the current one expires.
    public static var refreshToken: Self {
        .init(method: .post)
    }
}

public typealias FillSettingsRequest = Request<Empty, Settings>
extension FillSettingsRequest {

    public static var fillSettings: Self {
        .init(method: .get)
    }
}

public typealias ProfilePictureRequest = Request<Empty, Data>
extension ProfilePictureRequest {

    public static var profileImage: Self {
        .init(method: .get, mimType: .octetStream)
    }
}

public typealias ImageRequest = Request<UserImage, Data>
extension ImageRequest {

    public static var image: Self {
        .init(method: .get, mimType: .octetStream)
    }
}

public typealias UploadImageRequest = Request<Empty, StandardPostResponse>
extension UploadImageRequest {

    public static var uploadProfileImage: Self {
        .init(method: .post, mimType: .octetStream)
    }

    public static var uploadImage: Self {
        .init(method: .post, mimType: .octetStream)
    }
}

public typealias Register = Request<User.SignUp, RegisterResponse>
extension Register {

    /// Registers a new user
    public static var register: Self {
        .init(method: .post)
    }
}

public typealias TermsRequest = Request<Empty, TermsOfService>
extension TermsRequest {
    /// Gets the terms and conditions of using the app
    public static var terms: Self {
        .init(method: .get)
    }
}

/// Passes the last uuid so the backend can send more... the server side shouldn't have to keep track of what questions were sent already...
/// Need to research how server side pagination works on the backend.
public typealias QuestionRequest = Request<UUID?, Question>
extension QuestionRequest {
    /// Gets a question based on the index in a list, for the purpose of smooth scrolling.
    public static var prefetchQuestion: Self {
        .init(method: .post)
    }
}

public typealias TwoPersonGreetRequest = Request<TwoIDs, TwoPersonGreetResponse>
extension TwoPersonGreetRequest {
    /// Used for manually triggering a "two-person-right-now-meetup" which entails several steps
    /// 1. Server side takes the two ids, and finds the corresponding two users. (Started by this `Request`)
    /// 2. Sends a push notification to the client side.
    /// 3. Client side converts the push notification (on both user's client devices) to a Greet type.
    /// 4. Client side presents the option to meet the other user in a double blind fashion.
    public static var triggerTwoPersonGreet: Self {
        .init(method: .post)
    }
}

public struct ForceGreetPayload: Codable {
    var continueWithoutToken: Bool
    var userID: UUID
    var otherUserID: UUID
    var contextCompatibilityStructs: [UUID: ContextCompatibilityValue]
}


public struct ContextCompatibilityValue: Codable {
    let contextCompatibility: ContextCompatibilityStruct
    let inverseCompatibility: ContextCompatibilityStruct
}

/// Struct version of `ContextCompatibility` Model, used for Codable operations.
public struct ContextCompatibilityStruct: Codable {

    public var id: UUID
    public var isIntroduced: Bool
    public var compatibility: Double?
    public var rawCompatibilityScore: Double?
    public var minThreshold: Double?
    public var accepted: Bool
    public var rejected: Bool
    public var createdAt: Date?
    public var updatedAt: Date?
    public var userID: UUID
    public var relatedUserID: UUID
    public var contextID: UUID
    public var userRelationID: UUID?
    public var contextRaw: String

    /// Initializer for `ContextCompatibilityStruct`
    init(
        id: UUID,
        isIntroduced: Bool,
        compatibility: Double? = nil,
        rawCompatibilityScore: Double? = nil,
        minThreshold: Double? = nil,
        accepted: Bool,
        rejected: Bool,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        userID: UUID,
        relatedUserID: UUID,
        contextID: UUID,
        userRelationID: UUID? = nil,
        contextRaw: String
    ) {
        self.id = id
        self.isIntroduced = isIntroduced
        self.compatibility = compatibility
        self.rawCompatibilityScore = rawCompatibilityScore
        self.minThreshold = minThreshold
        self.accepted = accepted
        self.rejected = rejected
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.userID = userID
        self.relatedUserID = relatedUserID
        self.contextID = contextID
        self.userRelationID = userRelationID
        self.contextRaw = contextRaw
    }
}




public typealias ForceGreetRequest = Request<ForceGreetPayload, StandardPostResponse>
extension ForceGreetRequest {

    public static var forceGreet: Self {
        .init(method: .post)
    }
}


public typealias ManualGreetRequest = Request<GreetID, ManualGreetResponse>
extension ManualGreetRequest {
    /// When a user taps on a nearby user, they can attempt to initiate a manual Greet.
    /// Or a meetup triggered by one user tapping on another nearby user in a list.
    public static var manualGreet: Self {
        .init(method: .post)
    }
}

public typealias MetersWillingToTravelRequest = Request<Int, StandardPostResponse>
extension MetersWillingToTravelRequest {
    /// This updates the meters a user is willing to travel for a greet/in-person meetup
    public static var setMetersWillingToTravel: Self {
        .init(method: .post)
    }
}

public typealias LogoutRequest = Request<Empty, StandardPostResponse>
extension LogoutRequest {
    /// Logs out the current user
    public static var logout: Self {
        .init(method: .post)
    }
}


public typealias ReportQuestionRequest = Request<ReportFlagsQuestion, StandardPostResponse>
extension ReportQuestionRequest {
    /// If a user believes a `Question` violates the terms or is otherwise dangerous, this sends that opinion.
    public static var reportFlagsQuestion: Self {
        .init(method: .post)
    }
}

public typealias ReportResponseRequest = Request<ResponseFlags, ReportFlagsResponse>
extension ReportResponseRequest {
    /// If a user believes a `Response` violates the terms or is otherwise dangerous, this sends that opinion.
    public static var reportFlagsQuestionResponse: Self {
        .init(method: .post)
    }
}

public typealias ReportPicRequest = Request<PicFlags, ReportFlagsResponse>
extension ReportPicRequest {
    /// If a user believes an image violates the terms or is otherwise dangerous, this sends that opinion.
    public static var reportFlagsPic: Self {
        .init(method: .post)
    }
}

public typealias UserSettingsRequest = Request<Empty, Settings>
extension UserSettingsRequest {
    /// Gets the user's Settings information.
    public static var getUserInformation: Self {
        .init(method: .get)
    }
}

public typealias GreetRatingRequest = Request<Rating, RateResponse>
extension GreetRatingRequest {
    /// After a Greet/two-person-meetup concludes (either one opts to end the meetup or both users met up and concluded),
    /// then each user may send in their rating of how well the greet went.
    public static var rateGreet: Self {
        .init(method: .post)
    }
}

public typealias LocationUpdateRequest = Request<Location, StandardPostResponse>
extension LocationUpdateRequest {
    /// In order for the system to determine whether two compatible users are close enough to meet up,
    /// the system must know each's approximate location.
    public static var updateLocation: Self {
        .init(method: .post)
    }
}

public typealias AssertRequest = Request<Assertion, StandardPostResponse>
extension AssertRequest {
    /// I believe this was added to update the server side with issues.
    public static var assert: Self {
        .init(method: .post)
    }
}

public typealias UpdateImportanceRequest = Request<ImportancesUpdate, StandardPostResponse>
extension UpdateImportanceRequest {
    /// This Request is provided so that users can rate the importance of a question. A user can answer each question
    /// twice, once to convey how they would answer and once to say how their ideal match would answer.
    /// Some questions are more important than others. For example, "what is your favorite ice cream flavor?"
    /// might be less important for matchmaking than "What is your moral philosophy?" for one user and the inverse for
    /// another. And so you may rate the importance of one as `Question.Importance` as `.very` important whereas another
    /// might be rated as `.trivial`.
    public static var updateImportance: Self {
        .init(method: .put)
    }
}

public typealias GetContextsRequest = Request<Empty, [Context]>
extension GetContextsRequest {

    /// Get the contexts
    public static var getContexts: Self {
        .init(method: .get)
    }
}

public typealias TrackEventsRequest = Request<Events, StandardPostResponse>
extension TrackEventsRequest {
    /// Used to track user activity for the purpose of `UX`. And to understand how users are interacting and using the app.
    /// See `class Tracking {`. You can add events, and then update the server side by pinging this `Request`
    public static var trackEvents: Self {
        .init(method: .post, assertHasAccessToken: false)
    }
}

public typealias UpdateEmailRequest = Request<CredentialUpdate, StandardPostResponse>
extension UpdateEmailRequest {
    /// For a user to update/change their email address.
    public static var updateEmail: Self {
        .init(method: .put)
    }
}

public typealias AllowsCourtesyCall = Bool
public typealias CourtesyCallSettingRequest = Request<AllowsCourtesyCall, StandardPostResponse>
extension CourtesyCallSettingRequest {
    /// For the two person greet, sometimes a push notification might not be loud enough or prominent enough.
    /// To avoid missing opportunities, this request is provided for people to opt in or out of a courtesy call when a
    /// meetup is initiated.
    public static var updateCourtesyCallSetting: Self {
        .init(method: .post)
    }
}

public typealias UpdatePasswordRequest = Request<PasswordUpdate, StandardPostResponse>
extension UpdatePasswordRequest {
    /// Updates this user's password.
    public static var updatePassword: Self {
        .init(method: .put)
    }
}

public typealias SendMakeRequest = Request<DeviceDescription, StandardPostResponse>
extension SendMakeRequest {
    /// Sends the phone information for documentation to learn about user research.
    public static var sendMake: Self {
        .init(method: .post)
    }
}

/// This is intended for normal behavior, a happy path.
public typealias AddQuestion = Request<Question.Parts, Question>

extension AddQuestion {
    /// Any user can add questions to the shared questionnaire.
    /// This adds a question.
    /// The -Response is of type Question because the question ID is determined by the server side.
    ///
    /// - Parameters:
    ///   - payload: The payload is the newly added question with a placeholder identifier.
    ///   - response: The response is the question with the correct identifier.
    public static var addQuestion: Self {
        .init(method: .post)
    }
}

/// This is intended for non happy path, the wifi or data connection prevented uploading and multiple questions were added.
public typealias AddQuestions = Request<[Question.Parts], [Question]>

extension AddQuestions {
    /// Any user can add questions to the shared questionnaire.
    /// This adds a question.
    /// The -Response is of type Question because the question ID is determined by the server side.
    ///
    /// - Parameters:
    ///   - payload: The payload is the newly added question with a placeholder identifier.
    ///   - response: The response is the question with the correct identifier.
    public static var addQuestions: Self {
        .init(method: .post)
    }
}

public typealias PasswordlessAuthenticationRequest = Request<PasswordlessAuthentication, StandardPostResponse>
extension PasswordlessAuthenticationRequest {
    /// Used to reset the password.
    public static var passwordlessAuthentication: Self {
        .init(method: .post)
    }
}

public typealias PasscodeAuthenticationRequest = Request<PasscodePayload, StandardPostResponse>
extension PasscodeAuthenticationRequest {
    /// Used to reset the password.
    public static var passcodeAuthentication: Self {
        .init(method: .post)
    }
}


public typealias ChangeEmailRequest = Request<EmailChange, StandardPostResponse>
extension ChangeEmailRequest {
    /// Used to reset the email.
    public static var changeEmail: Self {
        .init(method: .post)
    }
}

public typealias RegisterDeviceTokenErrorRequest = Request<Empty, StandardPostResponse>
extension RegisterDeviceTokenErrorRequest {
    /// Notifies the server of an error registering the device token.
    public static var registerDeviceTokenError: Self {
        .init(method: .post)
    }
}

public typealias RegisterDeviceTokenRequest = Request<DeviceTokenPayload, StandardPostResponse>
extension RegisterDeviceTokenRequest {
    /// Sends the device token to the server.
    public static var registerDeviceToken: Self {
        .init(method: .post)
    }
}

public typealias HideFromNearByListRequest = Request<HideMe, StandardPostResponse>
extension HideFromNearByListRequest {
    /// Disables greet. Makes it so that this user doesn't show up as a greet
    /// option when there are more than one potential meetup options.
    public static var hideFromNearByList: Self {
        .init(method: .post)
    }
}

public typealias RegisterPushKitDeviceTokenRequest = Request<PushkitDeviceToken, StandardPostResponse>
extension RegisterPushKitDeviceTokenRequest {
    /// Registers push kit device token.
    public static var registerPushKitDeviceToken: Self {
        .init(method: .post)
    }
}

public typealias BlockUserRequest = Request<UUID, StandardPostResponse>
extension BlockUserRequest {
    /// Blocks a user from being considered for meetups with this user.
    public static var blockUser: Self {
        .init(method: .post)
    }
}

public typealias UnblockUserRequest = Request<UUID, StandardPostResponse>
extension UnblockUserRequest {
    /// Blocks a user from being considered for meetups with this user.
    public static var unblockUser: Self {
        .init(method: .delete)
    }
}

public typealias GetBlockedUsersRequest = Request<Empty, [GeneralUser]>
extension GetBlockedUsersRequest {
    /// Returns a list of users that are blocked by this user.
    public static var getBlockedUsers: Self {
        .init(method: .get)
    }
}

public typealias AddResponseRequest = Request<AddResponse, Question.Response>

extension AddResponseRequest {
    /// To deprecate `add(response: Question.Response, questionID: String)`
    /// Add a Response to a question.
    public static var addResponse: Self {
        .init(method: .post)
    }
}

public typealias AddResponsesRequest = Request<AddResponses, [Question.Response]>

extension AddResponsesRequest {
    /// To deprecate `add(response: Question.Response, questionID: String)`
    /// Add a Response to a question.
    public static var addResponses: Self {
        .init(method: .post)
    }
}


public typealias NearbyUsersRequest = Request<Coordinates, [Greet.User]>

/// Change the result back to Greet.User so that I can switch back and forth on the server side
/// with little consequences this way, and just know to not use the nil properties, or not expect
/// much, but the current ui doesn't use those nil properties anyway except one point to try to
/// get an image from data, but we shouldn't be sending nested data in a list anyway, we should
///  be sending/using the url, and maybe assigning data dynamically.
extension NearbyUsersRequest {
    /// To deprecate:  `static var nearbyUsers: URL {`
    /// Get a list of nearby users.
    public static var nearbyUsers: Self {
        .init(method: .post)
    }
}

public typealias MakeChoiceRequest = Request<AnswerChoice, StandardPostResponse>
extension MakeChoiceRequest {
    /**
     **Deprecates**:
     ```
     public static func make(
         my: Question.Response.Selections.MyTheir.Choice?,
         their: Question.Response.Selections.MyTheir.Choice?,
         forResponseID: UUID,
         forQuestionID: UUID,
         forContext: Context
     )
     ```
        This is intended for adding choices. For example, there might be a question: "Do you smoke cigarettes?"
        If someone smokes but they want to quit and meet people that don't smoke, they might choose the option: "Yes"
        And for the other person, they might choose "No" because they want to meet people that don't smoke.
     */
    public static var makeChoice: Self {
        .init(method: .post)
    }
}

public typealias GetResponsesRequest = Request<ResponsesSpecifications, [Question.Response]>
extension GetResponsesRequest {
    /// Gets responses that have been added to a question.
    public static var getResponses: Self {
        .init(method: .post)
    }
}

public typealias GetQuestionsRequest = Request<[QuestionsSpecifications], [Question]>
extension GetQuestionsRequest {
    /// Gets questions for the matchmaking questionnaire.
    public static var getQuestions: Self {
        .init(method: .post)
    }
}

public typealias UpdateUserSettingsRequest = Request<Settings, StandardPostResponse>
extension UpdateUserSettingsRequest {
    /// Update this user's settings, different from midGreet settings.
    public static var updateUserSettings: Self {
        .init(method: .put)
    }
}

public typealias AddDisplayPicRequest = Request<Data, StandardPostResponse>
extension AddDisplayPicRequest {
    /// Add a display image.
    public static var addDisplayPic: Self {
        .init(method: .post, mimType: .octetStream)
    }
}

public typealias UpdateGreetRequest = Request<Greet, Greet>
extension UpdateGreetRequest {
    /// Send other user updates to the Greet. For example, if the user exceeded the range of the meetup location.
    /// Look to the Greet Unit tests to get a sense of which combination of events create which outcomes.
    /// - Parameters:
    ///   - payload: Sends the current greet (Meet up object) updated by the user information.
    ///   - response: Returns a Greet that is updated by the other user information.
    public static var updateGreet: Self {
        .init(method: .put)
    }
}

public typealias UpdateMidGreetSettings = Request<Greet.Settings, StandardPostResponse>
extension UpdateMidGreetSettings {
    /// Deprecates: `URLRequest.update(midGreetSettings: self.greet.thisSettings)?.post.task()`
    /// There are multiple phases and permutations that users go through during the meetup process.
    /// This sends the user's intention to conclude the greet either because the users met up, or because this user wants to reject the meetup.
    public static var updateMidGreetSettings: Self {
        .init(method: .put)
    }
}

public typealias UpdateScheduleRequest = Request<[Week.Day], StandardPostResponse>
extension UpdateScheduleRequest {
    /// This is used to update when people are available to meet up with others.
    public static var updateSchedule: Self {
        .init(method: .put)
    }
}

public typealias UpdateUserLocationRequest = Request<Coordinates, StandardPostResponse>
extension UpdateUserLocationRequest {
    /// Sends an updated user location.
    public static var updateUserLocation: Self {
        .init(method: .put)
    }
}


public typealias SilentPushLocationUpdatesRequest = Request<ShouldEnableSilentPushNoticeUpdates, StandardPostResponse>
extension SilentPushLocationUpdatesRequest {
    /// Disables/enables silent push notification updates.
    public static var shouldUpdateLocation: Self {
        .init(method: .post)
    }
}
