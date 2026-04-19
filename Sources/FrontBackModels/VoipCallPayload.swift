//
//  VoipCallPayload.swift
//  AkinFrontBackModels
//
//  Created by Scott Lydon + claude on 4/19/26.
//
//  The minimum-size Codable contract delivered through a PushKit
//  (Voice over Internet Protocol) push when the server rings the
//  recipient's phone for a greet-related call.  Keeping this payload
//  small is load-bearing: Apple Push Notification service rejects VoIP
//  pushes over 5120 bytes with status 413 PayloadTooLarge.
//
//  This type intentionally lives APART from `Greet.Notification` so
//  that a future developer cannot accidentally ship a full `Greet`
//  (with its unbounded `events` array, full `NearbyUser`, full
//  `Venue`, `openers`, and `compatibility`) through the VoIP pipe.
//  The client resolves `greetID` to a full `Greet` after the call is
//  answered by calling `Request.getGreetByID`.
//

import Foundation

/// The Codable shape shipped via a PushKit VoIP push when the server
/// is asking a recipient's phone to ring.  Carries only what CallKit
/// requires to display the incoming-call UI plus the identifiers the
/// client needs to resolve the surrounding `Greet` after answer.
public struct VoipCallPayload: Codable, Equatable, Hashable, Sendable {

	/// Stable identifier of the greet this call belongs to.  The client
	/// resolves this to a full `Greet` by calling `Request.getGreetByID`
	/// after the recipient answers the call.
	public let greetID: UUID

	/// CallKit's unique identifier for this call leg.  Distinct from
	/// `greetID` so a single greet can host multiple independent calls
	/// (e.g. a `ringToVoipEnroute` that follows a completed
	/// `ringToVoipAfterOtherUserNotViewed`).  CallKit uses this UUID
	/// to correlate answer, end, and hold actions.
	public let callUUID: UUID

	/// The semantic purpose of this call.  The client uses this to
	/// decide what the green and red buttons mean (see
	/// `CallType.opensLiveVoipConversation` and
	/// `CallType.redButtonClosesGreet`).
	public let callType: CallType

	/// The user id of the person initiating the call.  Used by the
	/// client for logging, deduplication against a duplicate delivery
	/// of the same push, and to prefetch a profile image if desired.
	public let callerUserID: UUID

	/// The on-screen name CallKit renders on the lock screen and call
	/// UI.  Must be short enough to fit the CallKit label.  If the
	/// recipient already has the caller in their contacts, iOS will
	/// override this with the contact's display name.
	public let callerDisplayName: String

	/// The handle value CallKit records in the native recents log and
	/// passes back to the app when the user taps the entry later.
	/// Using the caller's display name (matching `callerDisplayName`)
	/// keeps the recents list human readable.
	public let callerHandleValue: String

	/// Whether the CallKit UI should offer a video option.  Currently
	/// always `false` for MapMates since the provider configuration
	/// declares `supportsVideo = false`, but kept here so the payload
	/// shape is ready when audio and video calls become available.
	public let hasVideo: Bool

	/// Server assigned send time in unix seconds.  The client uses it
	/// to drop stale deliveries (for example, if APNs retries a push
	/// after the call has already been answered on another device).
	public let serverUnixTimestampSeconds: Int

	/// A unique identifier for this particular push.  Used by the
	/// client for idempotency against duplicate deliveries of the
	/// same logical call.  Distinct from `callUUID` because the same
	/// CallKit call may be rung more than once if the first push
	/// fails to deliver.
	public let messageID: UUID

	public init(
		greetID: UUID,
		callUUID: UUID,
		callType: CallType,
		callerUserID: UUID,
		callerDisplayName: String,
		callerHandleValue: String,
		hasVideo: Bool = false,
		serverUnixTimestampSeconds: Int,
		messageID: UUID = UUID()
	) {
		self.greetID = greetID
		self.callUUID = callUUID
		self.callType = callType
		self.callerUserID = callerUserID
		self.callerDisplayName = callerDisplayName
		self.callerHandleValue = callerHandleValue
		self.hasVideo = hasVideo
		self.serverUnixTimestampSeconds = serverUnixTimestampSeconds
		self.messageID = messageID
	}
}
