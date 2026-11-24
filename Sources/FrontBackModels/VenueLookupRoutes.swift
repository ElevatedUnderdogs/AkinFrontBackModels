//
//  VenueLookupRoutes.swift
//  AkinFrontBackModels
//
//  The server asks Google Places for the app so the key never leaves the server.
//  The responses are the subset of Google's fields the server's field masks request.
//

import Foundation
import StrongContractClient

// MARK: - Details

/// - Parameter placeId: Google's place identifier, without the `places/` prefix.
public struct VenueDetailsPayload: Codable, Hashable, Sendable {
    public let placeId: String

    public init(placeId: String) {
        self.placeId = placeId
    }
}

/// One place, as Google's Place Details returns it.
public struct VenueDetailsResponse: Codable, Hashable, Sendable {

    /// Google's `LocalizedText`.
    public struct DisplayName: Codable, Hashable, Sendable {
        public let text: String?

        public init(text: String?) {
            self.text = text
        }
    }

    /// One photo. `name` is shaped `places/<id>/photos/<id>`.
    public struct Photo: Codable, Hashable, Sendable {
        public let name: String

        public init(name: String) {
            self.name = name
        }
    }

    public struct Location: Codable, Hashable, Sendable {
        public let latitude: Double
        public let longitude: Double

        public init(latitude: Double, longitude: Double) {
            self.latitude = latitude
            self.longitude = longitude
        }
    }

    public let id: String?
    public let displayName: DisplayName?
    public let formattedAddress: String?
    public let location: Location?
    public let googleMapsUri: String?
    public let types: [String]?
    public let photos: [Photo]?

    public init(
        id: String?,
        displayName: DisplayName?,
        formattedAddress: String?,
        location: Location?,
        googleMapsUri: String?,
        types: [String]?,
        photos: [Photo]?
    ) {
        self.id = id
        self.displayName = displayName
        self.formattedAddress = formattedAddress
        self.location = location
        self.googleMapsUri = googleMapsUri
        self.types = types
        self.photos = photos
    }
}

/// POST because the place identifier travels in the body.
public typealias VenueDetailsRequest = Request<VenueDetailsPayload, VenueDetailsResponse>
extension VenueDetailsRequest {
    public static var venueDetails: Self { .init(method: .post, assertHasAccessToken: false) }
}

// MARK: - Autocomplete

/// - Parameters:
///   - input: What the member typed.
///   - sessionToken: Google bills an autocomplete session as one unit only when this travels
///     with every request of the session.
///   - locationBias: Google's `locationBias`, for example a `rectangle` with `low` and `high`.
///   - includedPrimaryTypes: Google place types to restrict the suggestions to.
public struct VenueAutocompletePayload: Codable, Hashable, Sendable {
    public let input: String
    public let sessionToken: String?
    public let locationBias: [String: [String: [String: Double]]]?
    public let includedPrimaryTypes: [String]?

    public init(
        input: String,
        sessionToken: String? = nil,
        locationBias: [String: [String: [String: Double]]]? = nil,
        includedPrimaryTypes: [String]? = nil
    ) {
        self.input = input
        self.sessionToken = sessionToken
        self.locationBias = locationBias
        self.includedPrimaryTypes = includedPrimaryTypes
    }
}

/// Google's autocomplete answer. Google leaves `suggestions` out when there are none.
public struct VenueAutocompleteResponse: Codable, Hashable, Sendable {

    public struct TextBlock: Codable, Hashable, Sendable {
        public let text: String

        public init(text: String) {
            self.text = text
        }
    }

    public struct StructuredFormat: Codable, Hashable, Sendable {
        public let mainText: TextBlock
        public let secondaryText: TextBlock?

        public init(mainText: TextBlock, secondaryText: TextBlock?) {
            self.mainText = mainText
            self.secondaryText = secondaryText
        }
    }

    public struct PlacePrediction: Codable, Hashable, Sendable {
        public let placeId: String
        public let structuredFormat: StructuredFormat

        public init(placeId: String, structuredFormat: StructuredFormat) {
            self.placeId = placeId
            self.structuredFormat = structuredFormat
        }
    }

    public struct Suggestion: Codable, Hashable, Sendable {
        public let placePrediction: PlacePrediction?

        public init(placePrediction: PlacePrediction?) {
            self.placePrediction = placePrediction
        }
    }

    public let suggestions: [Suggestion]?

    public init(suggestions: [Suggestion]?) {
        self.suggestions = suggestions
    }
}

public typealias VenueAutocompleteRequest = Request<VenueAutocompletePayload, VenueAutocompleteResponse>
extension VenueAutocompleteRequest {
    public static var venueAutocomplete: Self { .init(method: .post, assertHasAccessToken: false) }
}

// MARK: - Photo address

/// - Parameters:
///   - placeId: Google's place identifier, without the `places/` prefix.
///   - photoId: The last part of a photo `name` (`places/<placeId>/photos/<photoId>`).
///   - maxWidthPx: The width to ask Google for; the server clamps it, and nil uses its default.
public struct VenuePhotoAddressPayload: Codable, Hashable, Sendable {
    public let placeId: String
    public let photoId: String
    public let maxWidthPx: Int?

    public init(placeId: String, photoId: String, maxWidthPx: Int? = nil) {
        self.placeId = placeId
        self.photoId = photoId
        self.maxWidthPx = maxWidthPx
    }
}

/// - Parameter photoUri: Google's short-lived image address; it carries no API key.
public struct VenuePhotoAddressResponse: Codable, Hashable, Sendable {
    public let photoUri: String

    public init(photoUri: String) {
        self.photoUri = photoUri
    }
}

/// The server asks Google for the image address so the key stays on the server.
public typealias VenuePhotoAddressRequest = Request<VenuePhotoAddressPayload, VenuePhotoAddressResponse>
extension VenuePhotoAddressRequest {
    public static var venuePhotoAddress: Self { .init(method: .post, assertHasAccessToken: false) }
}
