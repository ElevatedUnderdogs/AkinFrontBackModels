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

public typealias GreetProfilePicRequest = Request<UUID, Data>
extension GreetProfilePicRequest {

    public static var greetProfilePic: Self {
        // This is marked as post because we send the uuid through the body for security reasons
        // Even though the state doesn't change.  A trade off in "restfulness" its fine.
        .init(method: .post, mimType: .octetStream)
    }
}

public typealias ProfilePictureRequest = Request<Empty, Data?>
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

// MARK: - Data Contracts

public struct VenueImpactSummary: Hashable, Codable, Equatable {

    public let venue: ImpactVenue

    /// Total users sent to the venue from this app regardless of the reason why sent them.
    public let totalUsersSentToVenue: Int

    public let employeeImpactSummaries: [ImpactEmployeeSummary]

    public init(
        venue: ImpactVenue,
        totalUsersSentToVenue: Int,
        employeeImpactSummaries: [ImpactEmployeeSummary]
    ) {
        self.venue = venue
        self.totalUsersSentToVenue = totalUsersSentToVenue
        self.employeeImpactSummaries = employeeImpactSummaries
    }
}


/// Wraps any request payload so that it always includes a `GreetActionEvent`.
/// - Parameters:
///   - oldPayload: The previous payload you were already sending for this endpoint (unchanged type).
///   - event: The `GreetActionEvent` describing the client action that caused this request.
/// - Usage:
///   ```swift
///   Request.login.taskit(
///       payload: PayloadWithEvent(oldPayload: LoginPayload(email: ..., password: ...),
///                                 event: .didTapLoginButton),
///       callback: { result in ... }
///   )
///   ```
public struct PayloadWithEvent<Payload: Codable>: Codable {
    public let oldPayload: Payload
    public let event: GreetActionEvent

    /// Creates a payload that augments the original body with a `GreetActionEvent`.
    /// - Parameters:
    ///   - oldPayload: The original payload (exact type you already used for this endpoint).
    ///   - event: The client-side action metadata (`GreetActionEvent`).
    public init(
        oldPayload: Payload,
        event: GreetActionEvent
    ) {
        self.oldPayload = oldPayload
        self.event = event
    }
}


public struct ImpactEmployeeSummary: Identifiable, Hashable, Codable, Equatable {

    /// Employee who is referring user/s to this app.
    public let employeeName: String

    /// The number of user/s this employee has referred to this app.
    public let referralsCount: Int

    /// Estimated user/s routed due to/attributed to this employee's referrals
    public let usersSentToVenue: Int

    public var id: String {
        "\(employeeName)-\(referralsCount)-\(usersSentToVenue)"
    }

    public init(
        employeeName: String,
        referralsCount: Int,
        usersSentToVenue: Int
    ) {
        self.employeeName = employeeName
        self.referralsCount = referralsCount
        self.usersSentToVenue = usersSentToVenue
    }
}

/// String is search query.
public typealias SearchSavedVenues = Request<String, [ImpactVenue]>
extension SearchSavedVenues {

    public static var searchSavedVenues: Self {
        .init(method: .post)
    }
}

///
public typealias EmployeeLeaderboard = Request<UUID, VenueImpactSummary>
extension EmployeeLeaderboard {

    public static var employeeLeaderboard: Self {
        .init(method: .post)
    }
}

public struct NearbyEmptyStateResponse: Codable, Hashable, Equatable {

    // MARK: Clout
    public let userJoinRank: Int
    public let cloutLocationDescription: String?

    // MARK: Benchmark
    public let wantsBenchmarkNotifications: Bool
    public let nearbyUserCount: Int

    /// If none is saved for this then send the user's sign in email.
    public let defaultEmail: String

    // MARK: Forecast game
    /// Reminder for the date that was guessed.
    public let wantsCalendarReminder: Bool
    public let savedForecastDate: Date?
    public let actualDateOfBenchmark: Date?

    // MARK: ui setting preference
    public let hideFoundingMemberTile: Bool

    public init(
        userJoinRank: Int,
        wantsBenchmarkNotifications: Bool,
        nearbyUserCount: Int,
        wantsCalendarReminder: Bool,
        savedForecastDate: Date?,
        defaultEmail: String,
        cloutLocationDescription: String?,
        hideFoundingMemberTile: Bool,
        actualDateOfBenchmark: Date?
    ) {
        self.userJoinRank = userJoinRank
        self.wantsBenchmarkNotifications = wantsBenchmarkNotifications
        self.nearbyUserCount = nearbyUserCount
        self.wantsCalendarReminder = wantsCalendarReminder
        self.savedForecastDate = savedForecastDate
        self.defaultEmail = defaultEmail
        self.cloutLocationDescription = cloutLocationDescription
        self.hideFoundingMemberTile = hideFoundingMemberTile
        self.actualDateOfBenchmark = actualDateOfBenchmark
    }
}

public typealias NearbyEmptyStateEndpoint = Request<Empty, NearbyEmptyStateResponse>
extension NearbyEmptyStateEndpoint {

    /// When a user signed up to an area with few users, we can send some details as part
    /// of a pitch to convince  them to stay engaged in anticipation.
    public static var nearbyEmptyStateDetails: Self {
        .init(method: .get)
    }
}


public struct NearbyEmptyStateSubmitPayload: Codable, Hashable, Equatable {

    // MARK: Notify for Benchmarks.
    public let email: String
    public let notifyForLocalBenchmarks: Bool

    // MARK: Forecast game
    public let forecastDate: Date?
    public let wantsCalendarReminder: Bool
    public let forecastLocationHash: String

    // MARK: offload work on client.
    public let locationDescription: String

    // MARK: ui setting preference
    public let hideFoundingMemberTile: Bool

    public let targetBenchMark: Int

    public init(
        email: String,
        notifyForLocalBenchmarks: Bool,
        forecastDate: Date?,
        forecastLocationHash: String,
        hideFoundingMemberTile: Bool,
        wantsCalendarReminder: Bool,
        locationDescription: String,
        targetBenchMark: Int
    ) {
        self.email = email
        self.notifyForLocalBenchmarks = notifyForLocalBenchmarks
        self.forecastDate = forecastDate
        self.hideFoundingMemberTile = hideFoundingMemberTile
        self.wantsCalendarReminder = wantsCalendarReminder
        self.locationDescription = locationDescription
        self.forecastLocationHash = forecastLocationHash
        self.targetBenchMark = targetBenchMark
    }
}

public typealias NotifyUserCountProgressEndpoint = Request<NearbyEmptyStateSubmitPayload, StandardPostResponse>

extension NotifyUserCountProgressEndpoint {

    /// This endpoint is designed to receive user information to maintain ongoing engagement when there aren't many users
    /// yet.  This is to attempt to solve the chicken and the egg problem.
    public static var submitBenchmarkNotificationPreferences: Self {
        .init(method: .post)
    }
}

/// POST /forgot-password
/// Client submits this to start the password reset flow.
/// Server replies with success regardless of whether the email exists.
public typealias ForgotPasswordEndpoint = Request<String, StandardPostResponse>

extension ForgotPasswordEndpoint {

    /// Request sent from the client to initiate a password reset email.
    /// The user provides only their email. If the account exists,
    /// a one-time reset link is emailed to them.
    ///
    /// This route is anonymous (no login required).
    public static var forgotPassword: Self {
        .init(method: .post)
    }

    /// Registers a new user
    public static var resendVerification: Self {
        .init(method: .post)
    }
}



public typealias NewPasswordEndpoint = Request<String, StandardPostResponse>

extension NewPasswordEndpoint {
    public static var newPasswordEndpoint: Self {
        .init(method: .post)
    }
}

/// Request sent from the client after the user clicks the reset link.
/// This contains the token (from the email) and the new password they want to set.
///
/// The token is verified, the password is updated, and the token is invalidated.
public struct ResetPasswordRequest: Codable {

    public let token: String
    public let newPassword: String

    public init(token: String, newPassword: String) {
        self.token = token
        self.newPassword = newPassword
    }
}

/// POST /reset-password
/// Sent after the user has clicked the link and entered a new password.
/// If the token is valid and not expired, the server resets their password.
public typealias ResetPasswordEndpoint = Request<ResetPasswordRequest, StandardPostResponse>

extension ResetPasswordEndpoint {
    public static var resetPassword: Self {
        .init(method: .post)
    }
}

// MARK: - Terms Acceptance Logging Payload

public struct AcceptTermsRequest: Codable, Equatable, Hashable {
    public let termsVersion: String
    public let acceptedAt: Date
    public let deviceInfo: String?
    public let source: String? // "ios", "android", "web"

    public init(
        termsVersion: String,
        acceptedAt: Date,
        deviceInfo: String?,
        source: String?
    ) {
        self.termsVersion = termsVersion
        self.acceptedAt = acceptedAt
        self.deviceInfo = deviceInfo
        self.source = source
    }
}

public typealias TermsRequest = Request<Empty, TermsOfService>
extension TermsRequest {
    /// Gets the terms and conditions of using the app
    public static var latestTerms: Self {
        .init(method: .get)
    }
}

public typealias AcceptTermsRequestType = Request<AcceptTermsRequest, StandardPostResponse>

extension AcceptTermsRequestType {
    /// Post a new acceptance of the current Terms version
    public static var acceptTerms: Self {
        .init(method: .post)
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
    public var continueWithoutToken: Bool
    public var userID: UUID
    public var otherUserID: UUID
    public var contextRaw: String
    public var greetingMethod: Greet.Method
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

public enum ModerationContentType: String, Codable {
    case question
    case response
    case imageMetaData
}

public struct SubmitFlagRequest: Codable {
    public let contentType: ModerationContentType
    public let contentID: UUID
    public let flagExplanation: FlagExplanation

    public init(
        contentType: ModerationContentType,
        contentID: UUID,
        flagExplanation: FlagExplanation
    ) {
        self.contentType = contentType
        self.contentID = contentID
        self.flagExplanation = flagExplanation
    }
}

public typealias ReportFlagRequest = Request<SubmitFlagRequest, StandardPostResponse>

extension ReportFlagRequest {

    public static var reportFlags: Self {
        .init(method: .post)
    }
}

public struct UpdateFlagTreatment: Codable {
    public let treatment: ModerationTreatment
    public let flag: ReportFlag

    public init(treatment: ModerationTreatment, flag: ReportFlag) {
        self.treatment = treatment
        self.flag = flag
    }
}

public typealias UpdateFlagTreatmentRequest = Request<UpdateFlagTreatment, StandardPostResponse>

extension UpdateFlagTreatmentRequest {

    public static var updateFlagTreatment: Self {
        .init(method: .put)
    }
}

public typealias GetFlagTreatmentRequest = Request<Empty, [ReportFlag: ModerationTreatment]>

extension GetFlagTreatmentRequest {

    public static var getFlagTreatmentSettings: Self {
        .init(method: .get)
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
public typealias AddQuestion = Request<Question, Question>

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
public typealias AddQuestions = Request<[Question], [Question]>

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

public enum HideOption: Codable, Hashable, Equatable {
    case automatic
    case manual
}

public struct HideUpdatePayload: Codable, Hashable, Equatable {
    public let hideMe: Bool
    public let hideOption: HideOption

    public init(hideMe: Bool, hideOption: HideOption) {
        self.hideMe = hideMe
        self.hideOption = hideOption
    }
}

public typealias HideFromNearByListRequest = Request<HideUpdatePayload, StandardPostResponse>
extension HideFromNearByListRequest {
    /// Disables greet. Makes it so that this user doesn't show up as a greet
    /// option when there are more than one potential meetup options.
    public static var hideUpdate: Self {
        .init(method: .post)
    }
}

public typealias RegisterPushKitDeviceTokenRequest = Request<DeviceTokenPayload, StandardPostResponse>
extension RegisterPushKitDeviceTokenRequest {
    /// Registers push kit device token.
    public static var registerPushKitDeviceToken: Self {
        .init(method: .post)
    }
}

public struct RelationUpdatePayload: Codable, Hashable, Equatable {
    public var otherUserID: UUID
    public var relationUpdate: RelationUpdate

    public init(otherUserID: UUID, relationUpdate: RelationUpdate) {
        self.otherUserID = otherUserID
        self.relationUpdate = relationUpdate
    }
}

public enum RelationUpdate: Codable, Hashable, Equatable {
    case automatic(NotificationFrequency)
    case manual(NotificationFrequency)
    case blocked(Bool)
}

public typealias UpdateUserRelationPreferenceRequest = Request<RelationUpdatePayload, StandardPostResponse>
extension UpdateUserRelationPreferenceRequest {
    /// Blocks a user from being considered for meetups with this user.
    public static var updateUserRelation: Self {
        .init(method: .patch)
    }
}

// pages
public typealias GetBlockedUsersRequest = Request<Int, [GreetedUser]>
extension GetBlockedUsersRequest {
    /// Returns a list of users that are blocked by this user.
    public static var getBlockedUsers: Self {
        .init(method: .post) //  in mobile apps for paginated queries with input.
    }
}

// pages
public typealias GetGreetedUsersRequest = Request<Int, [ClientGreetingSettings]>
extension GetGreetedUsersRequest {
    /// Returns a list of users that are blocked by this user.
    public static var getGreetedUsers: Self {
        .init(method: .post) //  in mobile apps for paginated queries with input.
    }
}

public typealias AddResponseRequest = Request<Question.Response, Question.Response>

extension AddResponseRequest {
    /// To deprecate `add(response: Question.Response, questionID: String)`
    /// Add a Response to a question.
    public static var addResponse: Self {
        .init(method: .post)
    }
}

public struct AddResponsePayload: Codable {
    public let questionText: String
    public let responses: [Question.Response]

    public init(questionText: String, responses: [Question.Response]) {
        self.questionText = questionText
        self.responses = responses
    }
}

public typealias AddResponsesRequest = Request<AddResponsePayload, [Question.Response]>

extension AddResponsesRequest {
    /// To deprecate `add(response: Question.Response, questionID: String)`
    /// Add a Response to a question.
    public static var addResponses: Self {
        .init(method: .post)
    }
}

public struct NearbyUserRequest: Codable, Hashable, Equatable {
    public let coordinates: Coordinates
    public let page: Int
    public let limit: Int

    public init(coordinates: Coordinates, page: Int, limit: Int) {
        self.coordinates = coordinates
        self.page = page
        self.limit = limit
    }
}

public struct NearbyUserResponse: Codable, Hashable, Equatable {
    public let nearbyMembers: [Greet.User]
    public let hideStatusAutomatic: Bool
    public let hideStatusManual: Bool

    public init(nearbyMembers: [Greet.User], hideStatusAutomatic: Bool, hideStatusManual: Bool) {
        self.nearbyMembers = nearbyMembers
        self.hideStatusAutomatic = hideStatusAutomatic
        self.hideStatusManual = hideStatusManual
    }
}

public typealias NearbyUsersRequest = Request<NearbyUserRequest, NearbyUserResponse>

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

public struct GetQuestionsRequestPayload: Codable {
    public let specs: [QuestionsSpecifications]
    public let isFirst: Bool
    public let page: Int
    public let limit: Int

    public init(
        specs: [QuestionsSpecifications] = [],
        isFirst: Bool = false,
        page: Int = 1,
        limit: Int = 20
    ) {
        self.specs = specs
        self.isFirst = isFirst
        self.page = page
        self.limit = limit
    }
}



public typealias GetQuestionsRequest = Request<GetQuestionsRequestPayload, [Question]>
extension GetQuestionsRequest {
    /// Gets questions for the matchmaking questionnaire.
    public static var getQuestions: Self {
        .init(method: .post)
    }
}

public struct GetQuestionPayload: Codable {
    public let questionID: UUID
    public let responseID: UUID?

    public init(questionID: UUID, responseID: UUID?) {
        self.questionID = questionID
        self.responseID = responseID
    }
}

public typealias GetQuestionRequest = Request<GetQuestionPayload, Question>
extension GetQuestionRequest {

    /// Gets questions for the matchmaking questionnaire.
    public static var getQuestion: Self {
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

/// This is provided from the client side before the cloudflare image id is available, that is why there
///  is also ImageInfo for when the cloudflareurl is available.
public struct ImageMetadata: Codable, Hashable, Equatable {
    public let width: Double
    public let height: Double
    public let format: String
    public let assessment: ModerationAssessment
    public let id: UUID

    public init(
        width: Double,
        height: Double,
        format: String,
        assessment: ModerationAssessment,
        id: UUID
    ) {
        self.width = width
        self.height = height
        self.format = format
        self.assessment = assessment
        self.id = id
    }
}

/// The ImageMetadata is provided from the client side before the cloudflare image id is available, that is why there
///  is also ImageInfo for when the cloudflareurl is available.
public struct ImageInfo: Codable, Hashable, Equatable {
    ///  When saving image metaData this will be the Upload url.
    ///  When provided in a greet process, this will be the Get url.
    public let imageStorageURL: String
    public let metaData: ImageMetadata

    public init(path: String, metaData: ImageMetadata) {
        self.imageStorageURL = path
        self.metaData = metaData
    }
}

/// The server starts the communication with cloudflare endpoints directly and gets a url that is sent to the client to use.
public struct CloudflareImageURLS: Codable {

    /// The upload url that our server gets from pinging cloudflare.
    public let uploadURL: String

    /// The download url that our server configures using the cloudflare image id.
    /// It  won't work until you use the upload url to upload the image.
    public let downloadURL: String

    public init(uploadURL: String, downloadURL: String) {
        self.uploadURL = uploadURL
        self.downloadURL = downloadURL
    }
}

public typealias SaveImageMetaDataRequest = Request<ImageMetadata, CloudflareImageURLS>
extension SaveImageMetaDataRequest {

    public static var saveImageMetaData: Self {
        .init(method: .post)
    }
}

/// String should be the cloudflareurl at which the image can be accessed.
public typealias ModeratePicRequest = Request<String, StandardPostResponse>
extension ModeratePicRequest {

    public static var moderatePic: Self {
        .init(method: .post)
    }
}

public typealias UpdateGreetRequest = Request<PayloadWithEvent<Greet>, Greet>
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

public typealias UpdateMidGreetSettings = Request<PayloadWithEvent<Greet.Settings>, StandardPostResponse>
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

public struct LocationPayload: Codable, Hashable, Equatable {
    public var coordinates: Coordinates
    public var cityName: String
    public let timeZoneIdentifier: String
    public let localeIdentifier: String
    public let regionCode: String
    public let languageCode: String?
    public let uses24HourClock: Bool?
    public let calendarIdentifier: String?

    public init(
        coordinates: Coordinates,
        cityName: String,
        timeZoneIdentifier: String,
        localeIdentifier: String,
        regionCode: String,
        languageCode: String?,
        uses24HourClock: Bool?,
        calendarIdentifier: String?
    ) {
        self.coordinates = coordinates
        self.cityName = cityName
        self.timeZoneIdentifier = timeZoneIdentifier
        self.localeIdentifier = localeIdentifier
        self.regionCode = regionCode
        self.languageCode = languageCode
        self.uses24HourClock = uses24HourClock
        self.calendarIdentifier = calendarIdentifier
    }
}

public typealias UpdateUserLocationRequest = Request<LocationPayload, StandardPostResponse>
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

public typealias SendAppleTokenRequest = Request<AppleAuthorization, LoginResponse>
extension SendAppleTokenRequest {
    /// Add a display image.
    public static var sendAppleAuthID: Self {
        .init(method: .post)
    }
}
