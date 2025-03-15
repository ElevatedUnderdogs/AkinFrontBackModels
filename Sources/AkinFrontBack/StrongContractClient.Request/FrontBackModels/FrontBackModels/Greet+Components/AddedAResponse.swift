//
//  File.swift
//  AkinFrontBack
//
//  Created by Scott Lydon on 3/10/25.
//

import Foundation

public struct AddedAResponse: Codable {
    public var question: AkinFrontBack.Question
    public var response: UUID
}
