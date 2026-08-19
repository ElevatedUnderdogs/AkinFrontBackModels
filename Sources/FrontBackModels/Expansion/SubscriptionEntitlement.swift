import Foundation

// Swath S contracts (item 1.7): subscription tiers and what each unlocks. Capabilities are the single
// vocabulary the whole system gates on, and tiers nest: a higher tier is a superset of a lower one.

/// One thing a paid tier can unlock. The gate everywhere reads a Capability, never a tier name, so a
/// repricing changes only the tier-to-capability map below, not every call site.
public enum Capability: String, Codable, CaseIterable, Hashable {
    case createContext
    case chooseVenues
    case blacklistVenues
    case negotiateVenues
    case unlimitedFreezes
    case unlimitedNearbyMeetups
    case reservations
    case compatibilityVisibility
    case algorithmChoice
    case additionalContexts
    case requiredQuestions
}

/// A member's unlocked capabilities.
public typealias Entitlement = Set<Capability>

/// The three tiers and their monthly price in United States dollars. Price here is the contract the
/// UI displays; the store and server remain the authority on billing.
public enum SubscriptionTier: String, Codable, CaseIterable, Hashable {
    case free
    case plus
    case pro

    public var priceUSD: Double {
        switch self {
        case .free: return 0
        case .plus: return 4.99
        case .pro:  return 9.99
        }
    }

    /// What this tier unlocks. Deliberately nested: `plus` includes everything `free` has, and `pro`
    /// includes everything `plus` has, so `pro.capabilities.isSuperset(of: plus.capabilities)` holds.
    public var capabilities: Entitlement {
        switch self {
        case .free:
            return []
        case .plus:
            return [
                .createContext, .chooseVenues, .blacklistVenues, .unlimitedFreezes,
                .unlimitedNearbyMeetups, .additionalContexts, .compatibilityVisibility,
            ]
        case .pro:
            return SubscriptionTier.plus.capabilities.union([
                .negotiateVenues, .reservations, .algorithmChoice, .requiredQuestions,
            ])
        }
    }
}
