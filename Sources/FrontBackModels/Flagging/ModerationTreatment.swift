//
//  File.swift
//  AkinFrontBackModels
//
//  Created by Scott Lydon on 6/24/25.
//

import Foundation

/// Recommended moderation action to take on content.
public enum ModerationTreatment: String, CaseIterable, Codable, Identifiable, Comparable {

    /// Applied to Illegal or harmful content; hidden from all users (shadow banned), and whatever a user sets for their settings. 
    case shadowBan

    /// Potentially inappropriate; content is blurred or filtered unless user opts in.
    case blur

    /// Warns the user before posting, optionally requiring confirmation.
    case areYouSureMessage

    /// Content is allowed but shown less prominently (e.g., ranked lower).
    case deprioritize

    /// Content is allowed with no action.
    case allow

    // MARK: - Display & Behavior

    public var id: String { rawValue }

    public var displayText: String {
        switch self {
        case .shadowBan: return "🕳️ Don't show me"
        case .blur: return "🌫️ Blur"
        case .areYouSureMessage: return "⚠️ Are You Sure?"
        case .deprioritize: return "⬇️ Deprioritize"
        case .allow: return "✅ Show me"
        }
    }

    public var shortLabel: String {
        switch self {
        case .shadowBan: return "Omit"
        case .blur: return "Blur"
        case .areYouSureMessage: return "Warn"
        case .deprioritize: return "Deprioritize"
        case .allow: return "No Action"
        }
    }

    public var symbol: String {
        switch self {
        case .shadowBan: return "🕳️"
        case .blur: return "🌫️"
        case .areYouSureMessage: return "⚠️"
        case .deprioritize: return "⬇️"
        case .allow: return "🚫"
        }
    }

    /// Used to control sorting or severity comparison.
    public var rank: Int {
        switch self {
        case .shadowBan: return 0
        case .blur: return 1
        case .deprioritize: return 2
        case .areYouSureMessage: return 3
        case .allow: return 4
        }
    }

    public static func < (lhs: ModerationTreatment, rhs: ModerationTreatment) -> Bool {
        lhs.rank < rhs.rank
    }
}
