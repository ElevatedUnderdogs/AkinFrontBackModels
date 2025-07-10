//
//  File.swift
//  AkinFrontBackModels
//
//  Created by Scott Lydon on 6/24/25.
//

import Foundation

/// JSON structure returned from a moderation prompt for GPT
public struct ModerationAssessment: Codable, Hashable, Equatable {

    public let entries: [FlagExplanation]

    public init(entries: [FlagExplanation]) {
        self.entries = entries
    }

    public var suggestedTreatment: ModerationTreatment {
        if entries.contains(where: \.flag.isSeverelyIllegal) {
            return .shadowBan
        } else if entries.contains(where: \.flag.isInappropriate) {
            return .blur
        } else if entries.contains(where: \.flag.isCommunityIssue) {
            return .deprioritize
        }
        return .allow
    }

    public var treatment: ModerationTreatment {
        entries.map(\.flag.moderationTreatment).min() ?? .allow
    }
}

public struct FlagExplanation: Codable, Hashable, Equatable {
    public let flag: ReportFlag
    public let explanation: String
    public let source: FlagSource

    public init(flag: ReportFlag, explanation: String, source: FlagSource) {
        self.flag = flag
        self.explanation = explanation
        self.source = source
    }
}

/// Represents the source that triggered the moderation flag.
/// Combines both manual user reports and automatic flagging (e.g. AI, heuristics)
/// This prevents creating two nearly identical moderation models and a combinatorial
/// explosion of join/audit logic.
public enum FlagSource: String, Codable {
    case appleIntelligence
    case autoServerOpenAI
    case manualOtherUser
}
