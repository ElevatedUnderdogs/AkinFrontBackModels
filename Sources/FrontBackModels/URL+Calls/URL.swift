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

    static func cloudflareImageURL(imageID: String, variant: String = "public") -> URL {
        let deliveryID = "zhbimJ0OE5fdkDM6_OkY1A" // safe to hardcode
        return URL(string: "https://imagedelivery.net/\(deliveryID)/\(imageID)/\(variant)")!
    }
}
