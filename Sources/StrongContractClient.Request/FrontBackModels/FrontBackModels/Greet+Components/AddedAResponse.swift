//
//  File.swift
//  AkinFrontBackModels
//
//  Created by Scott Lydon on 3/10/25.
//

import Foundation

public struct AddedAResponse: Codable {
    public var question: AkinFrontBackModels.Question
    public var response: UUID
}
