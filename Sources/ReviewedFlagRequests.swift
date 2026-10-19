//
//  ReviewedFlagRequests.swift
//  AkinFrontBackModels
//
//  GOAL_LOOP34 items 0.F3a to 0.F3d and DR3. The GL29 feature flags, resolved by the server.
//

import Foundation
import StrongContractClient

/// One GL29 feature flag, with every value that went into deciding it.
///
/// WHY THE WHOLE CHAIN TRAVELS AND NOT JUST THE ANSWER. DR3 makes a flag three values deep: the
/// member's own override, then the value this server carries, then the default the build shipped
/// with. A response that carried only `resolved` would be impossible to debug from the device:
/// "want to meet is off" would not say whether somebody switched it off for this member, switched
/// it off for everybody, or whether the build simply never had it. The debug screen draws all
/// three lines because all three are different problems with different fixes.
public struct ResolvedFlag: Codable, Hashable, Equatable, Sendable, Identifiable {

    /// The flag's property name, which is also its identity on the wire.
    ///
    /// The PROPERTY NAME rather than a new enum, so a flag cannot exist on one side of the wire
    /// under a name the other side does not know. `ReviewedFeatureFlag.Feature.propertyName`
    /// already produces it and the debug screen already shows it.
    public let flag: String

    /// What the installed build would use with nothing else set.
    public let shippedDefault: Bool

    /// What this server says, for everybody, or nil when it says nothing.
    public let serverValue: Bool?

    /// What this server says for this member in particular, or nil when it says nothing.
    public let userOverride: Bool?

    /// The answer, which is `userOverride ?? serverValue ?? shippedDefault`.
    ///
    /// SENT RATHER THAN RECOMPUTED, so the client and the server cannot disagree about the order.
    /// A client that applied the three values itself would be a second implementation of DR3, and
    /// the two would drift the first time one of them changed.
    public let resolved: Bool

    public var id: String { flag }

    public init(
        flag: String,
        shippedDefault: Bool,
        serverValue: Bool?,
        userOverride: Bool?,
        resolved: Bool
    ) {
        self.flag = flag
        self.shippedDefault = shippedDefault
        self.serverValue = serverValue
        self.userOverride = userOverride
        self.resolved = resolved
    }
}

/// Setting, or clearing, one flag at one scope.
///
/// `value` is OPTIONAL and nil means CLEAR, which is a different act from setting false. Clearing
/// an override hands the decision back to the next level down; setting false says this level has
/// decided. Without the distinction there is no way to undo an override at all, and the debug
/// screen's "clear" control would have to send `false` and lie about what it did.
public struct FeatureFlagSettingPayload: Codable, Hashable, Equatable, Sendable {

    public let flag: String
    public let value: Bool?

    public init(flag: String, value: Bool?) {
        self.flag = flag
        self.value = value
    }
}

/// Every GL29 flag as it resolves for the signed in member.
public typealias ResolvedFeatureFlagsRequest = Request<Empty, [ResolvedFlag]>

extension ResolvedFeatureFlagsRequest {

    /// Read the resolved flags for the caller. Any signed in member may read their own.
    public static var resolvedFeatureFlags: Self {
        .init(method: .post)
    }
}

/// Set or clear the caller's OWN override.
public typealias SetFeatureFlagOverrideRequest = Request<FeatureFlagSettingPayload, [ResolvedFlag]>

extension SetFeatureFlagOverrideRequest {

    /// Set or clear one flag for the caller alone.
    ///
    /// Any signed in member may change their own, because it only ever affects what they see, and
    /// that is what makes 0.F3c checkable: one generated account sets an override and a second one
    /// is unaffected.
    public static var setFeatureFlagOverride: Self {
        .init(method: .post)
    }
}

/// Set or clear the value this SERVER carries, for everybody.
public typealias SetServerFeatureFlagRequest = Request<FeatureFlagSettingPayload, [ResolvedFlag]>

extension SetServerFeatureFlagRequest {

    /// Set or clear one flag for every member on this server.
    ///
    /// Allowed only for accounts the server marks as debug capable. A route that changes what
    /// every member sees cannot be open to every member, and the authorization is checked on the
    /// server rather than hidden behind a client that does not draw the control: a client is not
    /// a permission.
    public static var setServerFeatureFlag: Self {
        .init(method: .post)
    }
}
