//
//  File.swift
//  
//
//  Created by Scott Lydon on 4/3/24.
//

import Foundation

extension Data {

    init?(
        parameters: [String: String]?,
        filePathKey: String?,
        imageDataKey: Data,
        boundary: String,
        thisUserID: UUID
    ) {
        self.init()
        if let parameters = parameters {
            for (key, value) in parameters {
                appendString(string: "--\(boundary)\r\n")
                appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                appendString(string: "\(value)\r\n")
            }
        }
        let filename = "123display_\(String(describing: thisUserID)).jpeg"
        let mimetype = "image/jpeg"
        appendString(string: "--\(boundary)\r\n")
        guard let fileKey = filePathKey else { return nil }
        appendString(string: "Content-Disposition: form-data; name=\"\(fileKey)\"; filename=\"\(filename)\"\r\n")
        appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
        append(imageDataKey as Data)
        appendString(string: "\r\n")
        appendString(string: "--\(boundary)--\r\n")
    }

    mutating func appendString(string: String) {
        guard let data = string.data(
            using: String.Encoding.utf8,
            allowLossyConversion: true) else { return }
        append(data)
    }
}
