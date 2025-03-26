//
//  File.swift
//  
//
//  Created by Scott Lydon on 4/3/24.
//

import Foundation

extension String {
    static var generateBoundaryString: String {
        "Boundary-\(NSUUID().uuidString)"
    }

    public var scaped: String? {
        addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }

//    static var baseUrlToUse: String {
//        // http://api.greetr.co/hifivedev/webservice/
//       // "http://akin.mydemo.co/hifivedev/webservice/"
//        vaporBaseUrlToUse
//    }
//
//    /// New vapor backend
//    static var vaporBaseUrlToUse: String {
//        EnvConfig.isDebug ? "http://127.0.0.1:8080/api/" : "https://akindev/api/"
//    }

    // For apns primarily
    static var environmentString: String {
        #if DEBUG
            return "DEBUG"
        #elseif ADHOC
            return "ADHOC"
        #else
            return "PRODUCTION"
        #endif
    }

    var int: Int? {
        Int(self)
    }
}
