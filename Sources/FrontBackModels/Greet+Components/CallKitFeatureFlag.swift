//
//  CallKitFeatureFlag.swift
//  AkinFrontBackModels
//
//  Created by Scott Lydon on 4/9/26.
//

import Foundation

/// Client-controlled feature flags for CallKit functionality.
///
/// Toggle these booleans to enable or disable specific call
/// behaviours without a server round-trip. Every call-related
/// code path should check the relevant flag before executing.
public enum CallKitFeatureFlag {

	// MARK: - Individual flags

	/// Master switch: when `false`, all CallKit functionality is disabled
	/// and no call-related user interface (UI) is shown.
	public static var isCallKitEnabled: Bool = false

	/// Enables the legacy ring-to-greet behaviour where a PushKit
	/// notification nudges the user into the greet flow.
	public static var isRingToGreetEnabled: Bool = true

	/// Enables offering a VoIP call when the other user has not
	/// viewed the greet screen after the configured delay.
	public static var isRingToVoipAfterNoResponseEnabled: Bool = false

	/// Enables a VoIP call button while both users are en route
	/// to the venue, for coordination.
	public static var isRingToVoipEnrouteEnabled: Bool = false

	// MARK: - Convenience

	/// Whether any VoIP calling feature is currently active.
	public static var isAnyVoipCallEnabled: Bool {
		isCallKitEnabled && (isRingToVoipAfterNoResponseEnabled || isRingToVoipEnrouteEnabled)
	}

	/// Checks whether a specific `CallType` is allowed under the
	/// current flag configuration.
	/// - Parameter callType: The call type to evaluate.
	/// - Returns: `true` when the call type's flag is on **and** the
	///   master switch is on.
	public static func isEnabled(for callType: CallType) -> Bool {
		guard isCallKitEnabled else { return false }
		switch callType {
		case .ringToGreet:
			return isRingToGreetEnabled
		case .ringToVoipAfterNoResponse:
			return isRingToVoipAfterNoResponseEnabled
		case .ringToVoipEnroute:
			return isRingToVoipEnrouteEnabled
		}
	}
}
