//
//  ReportFlag.swift
//  akin
//
//  Created by Scott Lydon on 8/5/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//

import Foundation

public enum ReportFlag: String, Codable, CaseIterable {
    case childAbuse = "Child Abuse"
    case harmfulDangerousActs = "Harmful dangerous acts"
    case hatefulOrAbusive = "Hateful or abusive content"
    case infringesMyRights = "Infringes my rights"
    case promotesTerrorism = "Promotes terrorism"
    case sexualContent = "Sexual content"
    case spamOrMisleading = "Spam or misleading"
    case violentOrRepulsive = "Violent or repulsive content"
    
    public var int: Int {
        switch self {
        case .sexualContent: return 0
        case .violentOrRepulsive: return 1
        case .hatefulOrAbusive: return 2
        case .harmfulDangerousActs: return 3
        case .childAbuse: return 4
        case .infringesMyRights: return 5
        case .promotesTerrorism: return 6
        case .spamOrMisleading: return 7
        }
    }
}

extension Array where Element == ReportFlag {
    public var ints: [Int] { map { $0.int } }
}
