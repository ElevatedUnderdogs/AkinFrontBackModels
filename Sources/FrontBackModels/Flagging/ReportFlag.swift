//
//  ReportFlag.swift
//  akin
//
//  Created by Scott Lydon on 8/5/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//

import Foundation

/// Flags for reporting inappropriate content.
/// Each case maps to a content category, and may influence moderation behavior (e.g. shadow banning, blurring, or filtering).
public enum ReportFlag: String, Codable, CaseIterable, Hashable {

    // 🚫 Illegal or severely harmful content (triggers shadow ban)
    case childSexualAbuseMaterial
    case promotesTerrorism
    case threatensPhysicalHarm

    // ⚠️ Harmful or abusive content (blurred or hidden by default, adjustable in user settings)
    case hateSpeech
    case graphicViolence

    /// 1.1.4 Overtly sexual or pornographic material, defined by Webster’s Dictionary as “explicit descriptions or displays of sexual organs or activities intended to stimulate erotic rather than aesthetic or emotional feelings,” is not allowed on the App Store.
    case explicitSexualContent
    case sexual
    case selfHarmPromotion
    case harmfulMisinformation

    // TODO: profanity, vulgarity,

    // ⚙️ Community moderation (soft filter or deprioritized)
    case spam
    case copyrightViolation
    case personalAttack
    case unwantedContact
    case under18
    case profanity
    case vulgarity
    case nudity

    // User error
    /// This is for when a user doesn't understand the ui/ux For example, a user adds an
    /// unrelated question to a question Instead of a response.
    case misunderstandingAssignment
    case misstyping
    case missSpelling

    /// Human-readable string for display purposes (UI, emails, etc.)
    public var displayName: String {
        switch self {
        case .childSexualAbuseMaterial: return "Child Sexual Abuse Material"
        case .promotesTerrorism: return "Promotes Terrorism"
        case .threatensPhysicalHarm: return "Threatens Physical Harm"
        case .hateSpeech: return "Hate Speech"
        case .graphicViolence: return "Graphic Violence"
        case .explicitSexualContent: return "Explicit Sexual Content"
        case .sexual: return "Sexual Content"
        case .selfHarmPromotion: return "Self-Harm Promotion"
        case .harmfulMisinformation: return "Harmful Misinformation"
        case .spam: return "Spam or Misleading"
        case .copyrightViolation: return "Copyright Violation"
        case .personalAttack: return "Personal Attack"
        case .unwantedContact: return "Unwanted Contact"
        case .under18: return "Under 18"
        case .profanity: return "Profanity"
        case .vulgarity: return "Vulgarity"
        case .nudity: return "Nudity"
        case .misunderstandingAssignment: return "Misunderstanding Assignment"
        case .misstyping: return "Misstyping"
        case .missSpelling: return "Misspelling"
        }
    }

    /// Numeric ID for legacy support or analytics. Category order reflects severity from most at 0 to least.  .
    public var int: Int {
        switch self {
        case .childSexualAbuseMaterial: return 0
        case .promotesTerrorism: return 1
        case .threatensPhysicalHarm: return 2
        case .explicitSexualContent: return 3
        case .nudity: return 4
        case .graphicViolence: return 5
        case .hateSpeech: return 6
        case .selfHarmPromotion: return 7
        case .harmfulMisinformation: return 8
        case .copyrightViolation: return 9
        case .spam: return 10
        case .personalAttack: return 11
        case .unwantedContact: return 12
        case .under18: return 13
        case .sexual: return 14
        case .profanity: return 15
        case .vulgarity: return 16
        case .misunderstandingAssignment: return 17
        case .misstyping: return 18
        case .missSpelling: return 19
        }
    }

    public static var gptModerationCommaSeparatedList: String {
        allCases
            .filter { $0 != .childSexualAbuseMaterial }
            .map(\.rawValue)
            .joined(separator: ", ")
    }

    public static var permissableFlags: [ReportFlag] {
        allCases.filter { !$0.isSeverelyIllegal && !$0.isAppStoreNonCompliant }
    }

    public var isSeverelyIllegal: Bool {
        switch self {
        case .childSexualAbuseMaterial,
                .promotesTerrorism,
                .threatensPhysicalHarm,
                .selfHarmPromotion:
            return true
        default:
            return false
        }
    }

    public var isInappropriate: Bool {
        switch self {
        case .explicitSexualContent,
                .nudity,
                .graphicViolence,
                .hateSpeech,
                .harmfulMisinformation:
            return true
        default:
            return false
        }
    }

    public var isCommunityIssue: Bool {
        switch self {
        case .spam,
                .copyrightViolation,
                .personalAttack,
                .unwantedContact,
                .under18:
            return true
        default:
            return false
        }
    }

    public var isAppStoreNonCompliant: Bool {
        switch self {
        case .childSexualAbuseMaterial,
                .promotesTerrorism,
                .threatensPhysicalHarm,
                .selfHarmPromotion,
                .explicitSexualContent,
                .graphicViolence,
                .nudity:
            return true
        default:
            return false
        }
    }

    public static let hideFromNonCreator: Set<ReportFlag> = [
        .childSexualAbuseMaterial,
        .promotesTerrorism,
        .threatensPhysicalHarm,
        .selfHarmPromotion,
        .explicitSexualContent,
        .graphicViolence,
        .nudity
        // Note: under18 is NOT hidden by default
    ]

    public var moderationTreatment: ModerationTreatment {
        switch self {
        case .childSexualAbuseMaterial,
                .promotesTerrorism,
                .threatensPhysicalHarm:
            return .shadowBan
        case .explicitSexualContent,
                .nudity,
                .graphicViolence,
                .hateSpeech,
                .selfHarmPromotion,
                .harmfulMisinformation,
                .sexual,
                .profanity,
                .vulgarity:
            return .blur
        case .spam,
                .copyrightViolation,
                .personalAttack,
                .unwantedContact,
                .under18:
            return .deprioritize
        case .misunderstandingAssignment,
                .misstyping,
                .missSpelling:
            return .areYouSureMessage
        }
    }

    public var riskLevel: RiskLevel {
        switch self {
        case .childSexualAbuseMaterial,
                .promotesTerrorism,
                .threatensPhysicalHarm:
            return .critical
        case .selfHarmPromotion,
                .graphicViolence,
                .hateSpeech:
            return .high
        case .explicitSexualContent,
                .nudity,
                .sexual,
                .harmfulMisinformation,
                .copyrightViolation,
                .personalAttack,
                .unwantedContact,
                .profanity,
                .vulgarity:
            return .medium
        case .spam,
                .under18,
                .misunderstandingAssignment,
                .misstyping,
                .missSpelling:
            return .low
        }
    }
}

extension Array where Element == ReportFlag {
    public var ints: [Int] { map(\.int) }

    var isChildSexualHeuristic: Bool {
        self.contains(.childSexualAbuseMaterial) ||
        (
            self.contains(.under18) &&
            (
                self.contains(.sexual) ||
                self.contains(.explicitSexualContent) ||
                self.contains(.nudity) ||
                self.contains(.graphicViolence)
            )
        )
    }
}

