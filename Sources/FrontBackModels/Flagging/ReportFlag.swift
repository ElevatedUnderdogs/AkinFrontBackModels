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
    case childSexualAbuseMaterial = "Child Sexual Abuse Material"
    case promotesTerrorism = "Promotes Terrorism"
    case threatensPhysicalHarm = "Threatens Physical Harm"

    // ⚠️ Harmful or abusive content (blurred or hidden by default, adjustable in user settings)
    case hateSpeech = "Hate Speech"
    case graphicViolence = "Graphic Violence"
    case explicitSexualContent = "Explicit Sexual Content"
    case selfHarmPromotion = "Self-Harm Promotion"
    case harmfulMisinformation = "Harmful Misinformation"

    // ⚙️ Community moderation (soft filter or deprioritized)
    case spam = "Spam or Misleading"
    case copyrightViolation = "Copyright Violation"
    case personalAttack = "Personal Attack"
    case unwantedContact = "Unwanted Contact"

    // User error
    /// This is for when a user doesn't understand the ui/ux For example, a user adds an
    /// unrelated question to a question Instead of a response.
    case misunderstandingAssignment = "Misunderstanding Assignment"
    case misstyping = "Misstyping"
    case missSpelling = "Misspelling"

    /// Numeric ID for legacy support or analytics. Category order reflects severity.
    public var int: Int {
        switch self {
        case .explicitSexualContent: return 0
        case .graphicViolence: return 1
        case .hateSpeech: return 2
        case .selfHarmPromotion: return 3
        case .childSexualAbuseMaterial: return 4
        case .copyrightViolation: return 5
        case .promotesTerrorism: return 6
        case .spam: return 7
        case .harmfulMisinformation: return 8
        case .threatensPhysicalHarm: return 9
        case .personalAttack: return 10
        case .unwantedContact: return 11
        case .misunderstandingAssignment: return 12
        case .misstyping: return 13
        case .missSpelling: return 14
        }
    }

    /// For analytics/debug output.
    public static var commaSeparatedList: String {
        allCases.map(\.rawValue).joined(separator: ", ")
    }

    /// 🔒 Do not expose to anyone except content creator.
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

    /// 🚫 Should default to hidden/blurred unless explicitly allowed by user.
    public var isInappropriate: Bool {
        switch self {
        case .explicitSexualContent,
             .graphicViolence,
             .hateSpeech,
             .harmfulMisinformation:
            return true
        default:
            return false
        }
    }

    /// ⚙️ Soft-moderated community behavior issues.
    public var isCommunityIssue: Bool {
        switch self {
        case .spam,
             .copyrightViolation,
             .personalAttack,
             .unwantedContact:
            return true
        default:
            return false
        }
    }

    /// 🍏 App Store violations that must be treated with extreme caution to remain compliant.
    public var isAppStoreNonCompliant: Bool {
        switch self {
        case .childSexualAbuseMaterial,
             .promotesTerrorism,
             .threatensPhysicalHarm,
             .selfHarmPromotion,
             .explicitSexualContent,
             .graphicViolence:
            return true
        default:
            return false
        }
    }

    /// Unified list for enforcing server-side content hiding
    public static let hideFromNonCreator: Set<ReportFlag> = [
        .childSexualAbuseMaterial,
        .promotesTerrorism,
        .threatensPhysicalHarm,
        .selfHarmPromotion,
        // Optional: these two can be filtered based on user settings or App Store mode
        .explicitSexualContent,
        .graphicViolence
    ]

    public var moderationTreatment: ModerationTreatment {
        switch self {
        case .childSexualAbuseMaterial, .promotesTerrorism, .threatensPhysicalHarm:
            return .shadowBan
        case .explicitSexualContent, .graphicViolence, .hateSpeech, .selfHarmPromotion, .harmfulMisinformation:
            return .blurOrFilter
        case .spam, .copyrightViolation, .personalAttack, .unwantedContact:
            return .deprioritize
        case .misunderstandingAssignment, .misstyping, .missSpelling:
            return .areYouSureMessage
        }
    }


    /// 🚨 Risk level used to determine escalation thresholds and AI audit behavior.
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
             .harmfulMisinformation,
             .copyrightViolation,
             .personalAttack,
             .unwantedContact:
            return .medium
        case .spam,
             .misunderstandingAssignment,
             .misstyping,
             .missSpelling:
            return .low
        }
    }
}

extension Array where Element == ReportFlag {
    public var ints: [Int] { map(\.int) }
}
