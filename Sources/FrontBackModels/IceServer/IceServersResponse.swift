//
//  IceServersResponse.swift
//  AkinFrontBackModels
//
//  Created by Scott Lydon + claude on 4/20/26.
//
//  Strong-contract Codable wrapping the list of Interactive Connectivity
//  Establishment (ICE) servers the server returns to the client.  The
//  shape mirrors Cloudflare's `{"iceServers": [ ... ]}` envelope so the
//  Vapor handler can forward the normalized payload without introducing
//  a one-off ad-hoc dictionary.
//

import Foundation

/// Response body for `GET /api/v1/ice-servers`.
///
/// Contains the full, ordered list of Session Traversal Utilities for
/// Network Address Translators (STUN) and Traversal Using Relays around
/// Network Address Translators (TURN) servers the client should feed
/// into its Web Real Time Communication (WebRTC) `RTCConfiguration`.
public struct IceServersResponse: Codable, Equatable, Hashable, Sendable {

	/// The full, ordered list of servers.  Callers should preserve the
	/// order so STUN is attempted before TURN relay, which keeps most
	/// calls off Cloudflare's paid TURN path when a direct peer-to-peer
	/// route is reachable.
	public let iceServers: [IceServer]

	/// Creates a new response envelope.
	///
	/// - Parameter iceServers: Ordered ICE servers to return.
	public init(iceServers: [IceServer]) {
		self.iceServers = iceServers
	}
}
