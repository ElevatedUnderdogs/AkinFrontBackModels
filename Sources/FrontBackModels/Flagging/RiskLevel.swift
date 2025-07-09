//
//  File.swift
//  AkinFrontBackModels
//
//  Created by Scott Lydon on 6/30/25.
//

import Foundation

/// Represents the severity level of a moderation flag.
/// Used to influence escalation thresholds and moderation urgency.
public enum RiskLevel: String, Codable {

    /// Minimal impact content.
    /// Example: spam, off-topic, irrelevant, or minor misuse.
    /// Often safe to ignore or deprioritize unless volume is high.
    case low

    /// Potentially offensive but typically not dangerous.
    /// Example: nudity, suggestive content, or mild hate speech.
    /// May warrant blurring or auto-moderation, but rarely urgent.
    case medium

    /// Content with a higher likelihood of harm.
    /// Example: graphic violence, threats, or self-harm mentions.
    /// Often triggers faster review or limited automatic action.
    case high

    /// Extremely serious and legally or ethically urgent content.
    /// Example: child exploitation, terrorism, or suicide promotion.
    /// Should be prioritized for immediate AI and human moderation.
    case critical
}
