//
//  VenueLookupRoutes.swift
//  AkinFrontBackModels
//
//  The server proxies Google Places so the key never leaves it. Both answer with Google's JSON
//  verbatim, so the response is `Data` the caller decodes with Google's schema.
//

import Foundation
import StrongContractClient

/// What the app sends to search venues by name.
public struct VenueAutocompleteRequest: Codable, Hashable, Sendable {
    public let input: String
    /// Google bills an autocomplete session as one unit only when this travels with every request.
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

public typealias VenueDetailsContract = Request<Empty, Data>
extension VenueDetailsContract {
    /// GET. Google's Place Details for one place.
    public static var venueDetails: Self {
        .init(path: "api/venues/:placeID", method: .get, assertHasAccessToken: false)
    }
}

public typealias VenueAutocompleteContract = Request<VenueAutocompleteRequest, Data>
extension VenueAutocompleteContract {
    /// POST. Google's autocomplete suggestions for what the member typed.
    public static var venueAutocomplete: Self {
        .init(path: "api/venues/autocomplete", method: .post, assertHasAccessToken: false)
    }
}
