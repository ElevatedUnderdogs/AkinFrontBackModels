//
//  File.swift
//  
//
//  Created by Scott Lydon on 4/3/24.
//

import Foundation
#if canImport(FoundationNetworking)
// Provided for `URL` related objects on Linux platforms.
import FoundationNetworking
#endif

extension NSMutableURLRequest {

    public var urlRequest: URLRequest {
        self as URLRequest
    }

    convenience init?(img: Data, url: URL, thisUserID: UUID) {
        self.init(url:url)
        httpMethod = "POST"
        let boundary: String = .generateBoundaryString
        setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        httpBody = Data(
            parameters: nil,
            filePathKey: "userfile",
            imageDataKey: img,
            boundary: boundary,
            thisUserID: thisUserID
        )
    }
}
