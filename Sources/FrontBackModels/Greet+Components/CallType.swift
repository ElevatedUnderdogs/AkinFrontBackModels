//
//  CallType.swift
//  AkinFrontBackModels
//
//  Created by Scott Lydon on 4/9/26.
//

import Foundation

/// Distinguishes the purpose of a VoIP (Voice over Internet Protocol) call within a greet.
///
/// Each case carries enough context for the client to route the green/red
/// buttons to the correct behaviour.
public enum CallType: String, Codable, Sendable, Hashable, Equatable, CaseIterable {

	/// The current (legacy) behaviour: the PushKit ring is purely a nudge.
	/// Green button navigates to the greet/meetup negotiation screen.
	/// Red button dismisses the greet prompt.
	case ringToGreet

	/// Offered when the other user has not viewed the greet screen after
	/// a configurable delay (default two minutes).
	/// Green button opens a live VoIP conversation.
	/// Red button dismisses the greet prompt (same as ringToGreet red).
	case ringToVoipAfterOtherUserNotViewed

	/// Available after both users have agreed to meet, for coordination
	/// while en route to the venue.
	/// Green button opens a live VoIP conversation.
	/// Red button ends the ringing call and returns both users to
	/// GreetViewController (does not close the greet).
	case ringToVoipEnroute

	// MARK: - Helpers

	/// Whether the green button should open a live VoIP conversation
	/// rather than navigating to the greet flow.
	public var opensLiveVoipConversation: Bool {
		switch self {
		case .ringToGreet:
			return false
		case .ringToVoipAfterOtherUserNotViewed, .ringToVoipEnroute:
			return true
		}
	}

	/// Whether tapping the red (decline) button on the CallKit UI should
	/// close the greet entirely for the recipient.  Only `ringToVoipEnroute`
	/// keeps the greet open and returns the user to GreetViewController
	/// after the call ends.
	public var redButtonClosesGreet: Bool {
		switch self {
		case .ringToGreet, .ringToVoipAfterOtherUserNotViewed:
			return true
		case .ringToVoipEnroute:
			return false
		}
	}
}
