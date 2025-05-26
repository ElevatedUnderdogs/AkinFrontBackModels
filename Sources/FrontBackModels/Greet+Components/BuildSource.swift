//
//  File.swift
//  AkinFrontBackModels
//
//  Created by Scott Lydon on 5/26/25.
//

import Foundation

public enum BuildSource: String, CaseIterable, Identifiable, Codable, Hashable, Equatable {
    /// Local development build run from Xcode (DEBUG)
    case xcode

    /// Beta version distributed via TestFlight
    case testflight

    /// Production version downloaded from App Store
    case appStore

    public var id: String { rawValue }
}
