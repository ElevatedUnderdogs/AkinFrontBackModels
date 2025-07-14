//
//  Greet.User.swift
//  akin
//
//  Created by Scott Lydon on 8/4/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//

import Foundation

extension Greet {

    public struct User: Codable, Equatable, Hashable {
        public var personal: NearbyUser
        /// **BACKEND perspective**Sending percent travelled of the updating user to the recipient user.
        /// **Client perspective** The other user's percent travelled for the *TravelProgressCell*
        public var percentTravelled: Double? = nil
        public var imageInfo: ImageInfo? = nil
        public var minutesFromPoint: Int? = nil
        public var settings: Greet.Settings? = nil
        public var id: UUID
        

        /// <#Description#>
        /// - Parameters:
        ///   - nearbyUser: <#nearbyUser description#>
        ///   - percentTravelled: <#percentTravelled description#>
        ///   - image: <#image description#>
        ///   - minutesFromPoint: Is this supposed to be minutes away from a central meeting location or minutes away from the other user.
        ///   I think this solves a problem I was having.  I was worried about people triangulating exact locations of people, however, if instead
        ///   of showing how near someone is to someone else, perhaps I can
        ///   - settings: <#settings description#>
        public init(
            nearbyUser: NearbyUser,
            percentTravelled: Double? = nil,
            imageInfo: ImageInfo? = nil,
            minutesFromPoint: Int? = nil,
            settings: Greet.Settings? = nil,
            id: UUID
        ) {
            self.personal = nearbyUser
            self.percentTravelled = percentTravelled
            self.imageInfo = imageInfo
            self.minutesFromPoint = minutesFromPoint
            self.settings = settings
            self.id = id
        }
    }
}

extension String {

    var imageIDFromString: String {
        if contains("/"), let imageID = components(separatedBy: "/").last {
            return imageID
        }
        return self
    }
}


public extension Greet.User {

    var cloudFlareImageStrings: [String] {
        personal.profileImages + [imageInfo?.imageStorageURL].compactMap { $0 }
    }

    var cloudFlareImageIds: Set<String> {
        Set(cloudFlareImageStrings.map(\.imageIDFromString))
    }

//    var cloudFlareURL: URL? {
//        print("final strings: \(cloudFlareImageIds)")
//        guard let cloudFlareImageID = cloudFlareImageIds.first else {
//            return nil
//        }
//        return URL.cloudflareImageURL(imageID: cloudFlareImageID)
//    }
}
