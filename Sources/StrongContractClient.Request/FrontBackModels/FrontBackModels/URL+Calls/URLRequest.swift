//
//  URLRequest.swift
//  akin
//
//  Created by Scott Lydon on 8/7/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//

import Foundation
import StrongContractClient


public typealias DictionaryAction = ([String: Any]) -> Void
public typealias HTTPStatusAction = (HTTPURLResponse.HTTPStatus?) -> Void

extension URLRequest {
    
    public var post: Self {
        var buffer = self
        buffer.httpMethod = "POST"
        return buffer
    }
    
    /// Might not need to pass this user id if the user is signed in and passing access tokens etc.
    static func addDisplay(img: Data, thisUserID: UUID) -> URLRequest? {
        NSMutableURLRequest(
            img: img,
            url: URL.addDisplay(),
            thisUserID: thisUserID
        )?.urlRequest
    }
    
    /// Initializes a URLRequest configured for a specified HTTP method with a JSON body from a Codable object.
    ///Sources/EncryptDecryptKey/DataCrypto.swift
    /// Using a generic type `T` constrained to `Codable` allows the Swift compiler to know the specific type
    /// of the `Codable` object being passed in. This is crucial because the encoding process needs to know
    /// the exact type to correctly use its `encode(to:)` method. Directly using `Codable` as a parameter type
    /// would not work for encoding, as `Codable` is a protocol that many types can conform to, and just passing
    /// a `Codable` would not provide the `JSONEncoder` with enough information about which specific type's
    /// encoding logic to use. Hence, a generic type `T` ensures that the specific type information is preserved,
    /// enabling `JSONEncoder` to correctly and safely encode the object.
    ///
    /// - Parameters:
    ///   - url: The URL for the request.
    ///   - method: The HTTP method (e.g., "POST", "PUT") as a `String`.
    ///   - codable: The Codable object to encode and use as the request body. It uses a generic type `T` to
    ///             maintain the type information necessary for encoding.
    ///   - contentType: The content type to set for the request. Defaults to "application/octet-stream".
    private init?<T: Codable>(
        path: String,
        method: HTTPMethod,
        payload: T,
        contentType: String = "application/octet-stream"
    ) {
        self.init(url: URLComponents.baseURLComponents.with(path: path).url!)
        
        httpMethod = method.rawValue
        addValue(contentType, forHTTPHeaderField: "Content-Type")
        
        let codable: TokenAndPayload<T> = .init(payload: payload)
        do {
            let encoder = JSONEncoder()
            httpBody = try encoder.encode(codable)
            print("Original data size: \(String(describing: httpBody?.count)) bytes")
        } catch {
            print("Error encoding codable to JSON: \(error)")
            return nil
        }
    }
    
    public var method: HTTPMethod? {
        httpMethod.flatMap { HTTPMethod(rawValue: $0) }
    }
}

/// A struct to make the naming convention a bit more explicit for this simple type.
public typealias Row = Int

///
public struct TokenAndPayload<Payload: Codable>: Codable {
    public var accessToken: URLQueryItem = .access_token_and_user_id
    public var payload: Payload
}

public struct TwoIDs: Codable {
    public var firstId: UUID
    public var otherID: UUID
}

public struct PayloadResponse {

   // var path:
}

extension URL {

    static func reportFlags(_ flags: [Int], question id: Int) -> URL? {
        URLComponents.baseURLComponents
            .with(path: "reportFlags")
            .with(queryItems: .access_token_and_user_id, .reportFlag(int: flags), .question_id(String(id)))
            .url
    }

    static func reportFlags(
        _ flags: [Int],
        response responseID: Int,
        for questionID: Int
    ) -> URL? {
        URLComponents.baseURLComponents
            .with(path: "reportFlags")
            .with(queryItems: .access_token_and_user_id, .reportFlag(int: flags), .question_id(String(questionID)), .responseID(String(responseID)))
            .url
    }

    static func reportFlags(_ flags: [Int], picURL: String, userID: Int) -> URL? {
        URLComponents.baseURLComponents
            .with(path: "reportFlag")
            .with(queryItems: .access_token_and_user_id, .reportFlag(int: flags), .urlAddress(picURL))
            .url
    }

    static var getUserInformation: URL? {
        URLComponents.baseURLComponents
            .with(path: "getUserInformation")
            .with(queryItems: .access_token_and_user_id)
            .url
    }

    static func rate(greetid: String, otherUser otherid: Int, rating: Double) -> URL? {
        URLComponents.baseURLComponents
            .with(path: "rateGreet")
            .with(queryItems: .access_token_and_user_id, .other_id(otherid), .greet_id(greetid), .rating(rating))
            .url
    }

    static var updateSchedule: URL? {
        URLComponents.baseURLComponents
            .with(path: "updateSchedule")
            .with(queryItems: .access_token_and_user_id)
            .url
    }

    static var updateGreet: URL {
        URLComponents.baseURLComponents
            .with(path: "updateGreet")
            .with(queryItems: .access_token_and_user_id)
            .url!
    }

    static var updateGreetSettings: URL {
        URLComponents.baseURLComponents
            .with(path: "updateGreetSettings")
            .with(queryItems: .access_token_and_user_id)
            .url!
    }

    /// New vapor backend url for location update service.
    /// - Parameter userId: User's id who's location needs to be updated.
    /// - Parameter contextId: Current context id.
    /// - Returns: `URL` to the location update service.
    static func updateUserLocation(userId: UUID, contextId: String) -> URL {
        URLComponents.baseURLComponents.with(path: "user/\(userId)/location/context/\(contextId)/")
            .url!
    }

    static func silentPushLocationUpdates(alwaysOn: Bool) -> URL {
        URLComponents.baseURLComponents
            .with(path: "shouldUpdateLocation")
            .with(queryItems: .access_token_and_user_id, .alwaysInUse(alwaysOn))
            .url!
    }

    static func updateLocation(
        token: String?/* = Keychain.accessToken*/,
        userID: String?/* = Keychain.thisUserID*/,
        lat: String/* = CLLocationCoordinate2D.thisLocation?.latitude.string ?? "1.01"*/,
        lon: String/* = CLLocationCoordinate2D.thisLocation?.longitude.string ?? "1.1"*/
    ) -> URL {
            URLComponents.baseURLComponents
                .with(path: "updateUserLocation")
                .with(queryItems: .access_token_and_user_id,
                    .lat(lat),
                    .lon(lon),
                    .context("")
                )
            .url!
    }

    static func assert(
        _ assertion: Bool = false,
        message: String,
        file: String = #file,
        line: Int = #line
    ) -> URL {
       // Swift.assert(false, message)
        URLComponents.baseURLComponents
            .with(path: "assert")
            .with(queryItems: .assert(message))
        .url!
    }

    static func update(importance: Question.Importance, for context: Context, questionID: Int) -> URL {
        URLComponents.baseURLComponents
            .with(path: "updateImportance")
            .with(queryItems: .context(context.rawValue),
                .importance(importance),
                .question_id(String(questionID)),
                .access_token_and_user_id)
            .url!
    }

    static var terms: URL {
        URLComponents.baseURLComponents.with(path: "getTerms")
            .url!
    }

    static func track(events: [Int: String]) -> URL {
        URLComponents.baseURLComponents
            .with(path: "trackEvents")
            .with(array: [.access_token_and_user_id, .date()] + URLQueryItem.tracking(events: events))
            .url!
    }

    static func updateEmail(new: String, password: String) -> URL {
        URLComponents.baseURLComponents
            .with(path: "updateEmail")
            .with(queryItems: .access_token_and_user_id,
                .email(new),
                .password(password))
            .url!
    }

    static func updateCourtesyCallSetting(allows: Bool) -> URL {
        URLComponents.baseURLComponents
            .with(path: "allowsCourtesyCall")
            .with(queryItems: .access_token_and_user_id, .allows(allows))
            .url!
    }

    static func update(oldPassword: String, newPassword: String, savedEmail: String?) -> URL? {
        guard let email = savedEmail else { return nil }
        return URLComponents.baseURLComponents
            .with(path: "updatePassByOldPass")
            .with(queryItems: .oldPassword(oldPassword),
                .new_password(newPassword),
                .primary_email(email))
            .url!
    }

    static func sendMake(deviceString: String) -> URL {
        URLComponents.baseURLComponents
            .with(path: "make")
            .with(queryItems: .access_token_and_user_id, .make(deviceString: deviceString))
            .url!
    }

    static func add(question: Question) -> URL {
        URLComponents.baseURLComponents
            .with(path: "addQuestion")
            .with(queryItems: .access_token_and_user_id,
                .question(text: question.text),
                .date())
            .url!
    }

    static func manualGreet(otherID: Int) -> URL {
        URLComponents.baseURLComponents.with(path: "manualGreet")
            .with(queryItems: .access_token_and_user_id,
                .other_id(String(otherID)))
            .url!
    }

    static func resetPassword(email: String) -> URL {
        URLComponents.baseURLComponents
            .with(path: "resetPassword")
            .with(queryItems: .reset(email: email))
            .url!
    }

    static func change(email: String, to new: String) -> URL {
        URLComponents.baseURLComponents
            .with(path: "changeEmail")
            .with(queryItems: .primary_email(email), .email(new))
            .url!
    }

    static func registerDeviceToken(error: String) -> URL {
        URLComponents.baseURLComponents
            .with(path: "registerDeviceTokenError")
            .with(queryItems: .access_token_and_user_id,
                .environment(),
                .error(error))
        .url!
    }

    /// User id shoudl be set before using this.
    static func register(deviceToken: String) -> URL {
        URLComponents.baseURLComponents
            .with(path: "registerDeviceToken")
            .with(queryItems: .device(token: deviceToken),
                .access_token_and_user_id,
                .environment(.environmentString))
            .url!
    }

    // MARK - pending product update
    static func hide(me hide: Bool) -> URL {
        URLComponents.baseURLComponents
            .with(path: "HideFromNearByList")
            .with(queryItems: .access_token_and_user_id, .hide(me: hide))
            .url!
    }

    // MARK - pending product update
    /// User id shoudl be set before using this.
    static func register(pushKitDeviceToken: String) -> URL {
        URLComponents.baseURLComponents
            .with(path: "registerPushKitDeviceToken")
            .with(queryItems: .pushKitDevice(token: pushKitDeviceToken),
                .access_token_and_user_id,
                .environment(.environmentString))
            .url!
    }

    // MARK - pending product update
    static func block(user otherUser: Int) -> URL {
        URLComponents.baseURLComponents
            .with(path: "blockUser")
            .with(queryItems: .access_token_and_user_id, .other_id("\(otherUser)"))
            .url!
    }

    // MARK - pending product update
    static func block(otherID: Int, shouldBlock: Bool) -> URL {
        URLComponents.baseURLComponents
            .with(path: "blockUser")
            .with(queryItems: .access_token_and_user_id, .other_id(String(otherID)))
            .url!
    }

    // MARK - pending product update
    static var blockedUsers: URL {
        URLComponents.baseURLComponents
            .with(path: "getBlockedUsersLIst")
            .with(queryItems: .access_token_and_user_id)
            .url!
    }


    static func login(email: String, password: String) -> URL {
        URLComponents.baseURLComponents
            .with(path: "login")
            .with(queryItems: .primary_email(email), .password(password))
            .url!
    }


    static func add(response: Question.Response, questionID: String) -> URL {
        URLComponents.baseURLComponents
            .with(path: "addOption")
            .with(queryItems: .access_token_and_user_id, .question_id(questionID), .response(response.text))
            .url!
    }

    static func make(
        my: Question.Response.Selections.MyTheir.Choice?,
        their: Question.Response.Selections.MyTheir.Choice?,
        for responseID: Int,
        for questionID: Int,
        forContext: Context
    ) -> URL {
        URLComponents.baseURLComponents
            .with(path: "addUserResponse")
            .with(
                queryItems: .access_token_and_user_id, .context(forContext.rawValue), .question_id(String(questionID)), .responseID(String(responseID)),
                    .my(my?.weightMultiplier),
                    .their(their?.weightMultiplier)
            )
            .url!
    }

    static func questions(
        search text: String? = nil,
        type: Question.Category,
        page: Int? = nil,
        context: Context,
        required: Bool = false
        ) -> URL {
            URLComponents.baseURLComponents
                .with(path: "getQuestions")
                .with(queryItems: .access_token_and_user_id, .search(text: text), .flag(int: required.int), .type(type.rawValue), .PageNo(page), .context(context.rawValue))
            .url!
    }

    static var logout: URL {
        URLComponents.baseURLComponents
            .with(path: "logout")
            .with(queryItems: .access_token_and_user_id)
            .url!
    }


    static func addDisplay() -> URL {
        URLComponents.baseURLComponents.with(path: "addDisplayPicture")
            .with(queryItems: .access_token_and_user_id)
            .url!
    }

    static var uploadPic: URL {
        URLComponents.baseURLComponents
            .with(path: "addDisplayPicture")
            .with(queryItems: .access_token_and_user_id)
            .url!
    }

    static func yelpBusiness(latitude: Double, longitude: Double) -> URL? {
        URL(string: "https://api.yelp.com/v3/businesses/search?latitude=\(latitude)&longitude=\(longitude)")
    }
}
