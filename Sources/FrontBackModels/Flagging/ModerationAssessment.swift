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
            return .blurOrFilter
        } else if entries.contains(where: \.flag.isCommunityIssue) {
            return .deprioritize
        }
        return .allow
    }
}

public struct FlagExplanation: Codable, Hashable, Equatable {
    public let flag: ReportFlag
    public let explanation: String

    public init(flag: ReportFlag, explanation: String) {
        self.flag = flag
        self.explanation = explanation
    }
}
