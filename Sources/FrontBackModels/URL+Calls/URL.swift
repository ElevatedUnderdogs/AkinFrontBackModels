//
//  URL+factory.swift
//  akin
//
//  Created by Scott Lydon on 8/7/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//
//DOCUMENATION https://git.generalassemb.ly/Scottyblades/GreeterEndpoints

//import Foundation
//import StrongContractClient
//
//
//
//extension StrongContractClient.Request {
//
//    /*
//     static func register(basicInfo: User.SignUp) -> URLRequest! {
//         URLRequest(
//             path: "user/register",
//             method: .post,
//             payload: basicInfo
//         )
//     }
//     */
//    static var register: Request<User.SignUp, RegisterResponse> {
//        Request(path: "user/register", method: .post)
//    }
//}

import Foundation

public extension URL {

    /// Builds a Cloudflare Images delivery URL, the one place client and server construct it.
    ///
    /// The delivery identifier is passed in rather than hardcoded so callers read it from their
    /// own configuration (the server reads `CLOUDFLARE_IMAGES_DELIVERY_ID`). It is a public
    /// identifier that appears in every delivered image URL, not a secret.
    ///
    /// - Parameters:
    ///   - imageID: the Cloudflare image identifier.
    ///   - deliveryID: the account's Images delivery identifier.
    ///   - variant: the Cloudflare Images variant, defaulting to `public`.
    static func cloudflareImageURL(
        imageID: String,
        deliveryID: String,
        variant: String = "public"
    ) -> URL? {
        URL(string: "https://imagedelivery.net/\(deliveryID)/\(imageID)/\(variant)")
    }
}
