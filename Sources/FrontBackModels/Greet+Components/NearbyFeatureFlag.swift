//
//  NearbyFeatureFlag.swift
//  AkinFrontBackModels
//
//  Created by Scott Lydon on 8/10/26.
//

import Foundation

/// Client-controlled feature flags for the nearby list's meet up dispatch
/// features: freeze, availability pause, reservations, choose for me, and the
/// multi column layout.
///
/// Shaped after ``CallKitFeatureFlag`` on purpose. Same idea, same ergonomics:
/// a master switch, one boolean per feature, and an `isEnabled(for:)` that
/// refuses everything while the master switch is down. Every code path that
/// renders or acts on one of these features checks its flag first, so any one of
/// them can be taken back out without a server round trip and without unpicking
/// the code that surrounds it.
///
/// The defaults below are the SHIPPING defaults. A feature that is not yet
/// proven in the field starts `false` and is switched on from the app delegate.
public enum NearbyFeatureFlag {

    // MARK: - Individual flags

    /// Master switch. While `false`, none of the features below render and none
    /// of their requests are sent, so the nearby list behaves exactly as it did
    /// before this work landed.
    public static var isNearbyDispatchEnabled: Bool = false

    /// The freeze control: a short exclusive hold that pins a member's place in
    /// the list and keeps other viewers from greeting them.
    public static var isFreezeEnabled: Bool = true

    /// The self applied availability pause, raised after a greet so new meet ups
    /// do not interrupt one already under way.
    public static var isAvailabilityPauseEnabled: Bool = true

    /// The reservation queue offered on a member who is not greetable now.
    public static var isReserveEnabled: Bool = true

    /// The button that picks a candidate on the user's behalf.
    public static var isChooseForMeEnabled: Bool = true

    /// The one, two, or three column layout choice for the nearby list.
    public static var isColumnLayoutEnabled: Bool = true

    /// Live availability updates arriving over the WebSocket. With this off the
    /// list still shows availability, it just will not change until the next
    /// fetch or refresh.
    public static var isLiveAvailabilityEnabled: Bool = true

    // MARK: - Feature identity

    public enum Feature: String, CaseIterable, Sendable {
        case freeze
        case availabilityPause
        case reserve
        case chooseForMe
        case columnLayout
        case liveAvailability
    }

    // MARK: - Convenience

    /// Whether a specific feature is live under the current configuration.
    /// - Parameter feature: The feature to evaluate.
    /// - Returns: `true` when the feature's own flag is on AND the master
    ///   switch is on.
    public static func isEnabled(for feature: Feature) -> Bool {
        guard isNearbyDispatchEnabled else { return false }
        switch feature {
        case .freeze: return isFreezeEnabled
        case .availabilityPause: return isAvailabilityPauseEnabled
        case .reserve: return isReserveEnabled
        case .chooseForMe: return isChooseForMeEnabled
        case .columnLayout: return isColumnLayoutEnabled
        case .liveAvailability: return isLiveAvailabilityEnabled
        }
    }

    /// Whether anything in this family is live. Used to decide whether the
    /// nearby list needs its live state plumbing at all.
    public static var isAnyNearbyDispatchFeatureEnabled: Bool {
        Feature.allCases.contains { isEnabled(for: $0) }
    }

    /// Restores every flag to its shipping default. Exists so a test can undo
    /// whatever it toggled without each test knowing the whole set.
    public static func resetToDefaults() {
        isNearbyDispatchEnabled = false
        isFreezeEnabled = true
        isAvailabilityPauseEnabled = true
        isReserveEnabled = true
        isChooseForMeEnabled = true
        isColumnLayoutEnabled = true
        isLiveAvailabilityEnabled = true
    }
}

/// Server owned limits and durations for the dispatch features.
///
/// These are values the product will want to retune (thirty seconds, three
/// freezes, one hour) and every one of them is quoted in user facing copy, so
/// they are named once here and read from the server's `NearbySelfStatus` at
/// runtime. The constants below are only the fallback for a client that has not
/// heard from the server yet.
public enum NearbyDispatchDefaults {

    /// Default freeze hold, in seconds. The product brief says "let's say
    /// thirty seconds as the default".
    public static let freezeSeconds: Int = 30

    /// Ceiling on a single freeze request, so a client cannot ask for an hour.
    public static let freezeMaximumSeconds: Int = 120

    /// Freezes one member may place per calendar day.
    public static let freezeAllowancePerDay: Int = 3

    /// Default availability pause, in seconds. The brief says "maybe an hour or
    /// something".
    public static let pauseSeconds: Int = 3600

    /// Ceiling on a single pause request.
    public static let pauseMaximumSeconds: Int = 60 * 60 * 8

    /// Reservations one member may hold at once. The brief says "maybe they can
    /// only have, like, two or three".
    public static let reservationAllowance: Int = 3

    /// How long a reservation survives without maturing before it is dropped.
    /// Without this, a queue accumulates people who left hours ago and the
    /// person at the front is a ghost.
    public static let reservationTimeToLiveSeconds: Int = 60 * 60 * 2

    /// Beyond this many metres a member is reported as out of range.
    public static let outOfRangeMeters: Double = 1_000
}
