//
//  Untitled.swift
//  AkinFrontBackModels
//
//  Created by Scott Lydon on 4/3/25.
//


import Foundation

public enum ServerEnvironment: String, CaseIterable, Identifiable, Codable, Hashable, Equatable {
    case dev, debug, prod
    public var id: String { rawValue }
}
