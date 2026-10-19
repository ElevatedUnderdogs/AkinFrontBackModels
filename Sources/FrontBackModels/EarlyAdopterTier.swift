//
//  EarlyAdopterTier.swift
//  FrontBackModels
//
//  TestFlight feedback note B17-15: "I want the early adopter emojis to show on the profile
//  pictures of different users."
//

import Foundation

/// How early a member joined, as a BAND rather than as a position.
///
/// ## Why a tier and not the rank
///
/// Until this type existed, a join rank reached exactly one screen, the member's OWN early
/// adopter row, and it reached it as an `Int` that the client banded into a medal at the point of
/// drawing. B17-15 asks for the medal on OTHER members' photographs, which makes the fact public
/// to everybody standing nearby, so what crosses the wire is the band and never the ordinal.
///
/// That is a deliberate narrowing, and there are two reasons for it. An ordinal is strictly more
/// disclosure than the note asks for: "show the emoji" does not require telling a stranger that
/// the person across the room was the fourth member to join. And a number invites a ranking
/// nobody designed, where a band does not, because a band says only which of four glyphs to draw
/// and two people in the same band are not ordered against each other.
///
/// ## The boundaries
///
/// The four bands are the ones the app has always drawn, now stated once here rather than
/// inferred from `Int` comparisons on the client. `from(joinRank:)` is the only way a rank
/// becomes a tier, so the server bands it and the ordinal stops at the server.
public enum EarlyAdopterTier: String, Codable, Hashable, Sendable, CaseIterable {

    /// The first ten members.
    case diamond

    /// Ranks 11 to 100.
    case gold

    /// Ranks 101 to 1000.
    case silver

    /// Ranks 1001 to 10000.
    case bronze

    /// The badge glyph.
    ///
    /// The same four emoji the viewer's own row has always drawn, so a member who has seen their
    /// own badge recognises somebody else's.
    public var medalEmoji: String {
        switch self {
        case .diamond: return "\u{1F48E}"
        case .gold: return "\u{1F947}"
        case .silver: return "\u{1F948}"
        case .bronze: return "\u{1F949}"
        }
    }

    /// The word that goes with the glyph, for the accessibility label and for any copy that
    /// names the band.
    public var name: String {
        switch self {
        case .diamond: return "Diamond"
        case .gold: return "Gold"
        case .silver: return "Silver"
        case .bronze: return "Bronze"
        }
    }

    /// The highest rank that still falls inside this band, 1 based.
    public var highestRank: Int {
        switch self {
        case .diamond: return 10
        case .gold: return 100
        case .silver: return 1_000
        case .bronze: return 10_000
        }
    }

    /// The band a 1 based join rank falls in, or nil for a member outside the ranked window.
    ///
    /// Nil is the ordinary answer for most members and is NOT an error. It is also the answer for
    /// a nonsense rank: a join rank is 1 based, so zero or a negative is a not-set sentinel
    /// arriving where a value was expected, and banding it would award the top badge to a member
    /// who has no rank at all. That exact coercion has already shipped once in this product, in
    /// the client's own `medalDescription`, where `-1 <= 10` read as Diamond.
    public static func from(joinRank: Int?) -> EarlyAdopterTier? {
        guard let joinRank, joinRank > 0 else { return nil }
        return allCases.first { joinRank <= $0.highestRank }
    }
}
