//
//  File.swift
//  AkinFrontBackModels
//
//  Created by Scott Lydon on 6/24/25.
//

import Foundation

/// Recommended moderation action to take on content.
public enum ModerationTreatment: String, Codable {
    /// Illegal or harmful content; hidden from all users (shadow banned).
    case shadowBan

    /// Potentially inappropriate; content is blurred or filtered unless the user opts in to view it.
    case blurOrFilter

    /// Content is allowed but shown less prominently (e.g., ranked lower in feeds or search).
    case deprioritize

    /// Prompts the user with an "Are you sure?" message before posting; typically used for likely accidental or inappropriate posts.
    case areYouSureMessage

    /// Safe content; no moderation action needed.
    case allow
}
