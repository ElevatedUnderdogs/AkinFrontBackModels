//
//  String+Tokens.swift
//  akin
//
//  Created by Scott Lydon on 8/7/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//

import Foundation

struct EnvConfig {
    // This is private because the use of 'appConfiguration' is preferred.
    private static let isTestFlight = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
    
    // This can be used to add debug statements.
    static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    static var fromAppStore: Bool {
        return !isDebug && !isTestFlight
    }
    
    static var appConfiguration: AppConfiguration {
        if isDebug {
            return .Debug
        } else if isTestFlight {
            return .TestFlight
        } else {
            return .AppStore
        }
    }
}
