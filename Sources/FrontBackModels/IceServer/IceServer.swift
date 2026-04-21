//
//  IceServer.swift
//  AkinFrontBackModels
//
//  Created by Scott Lydon + claude on 4/20/26.
//
//  Strong-contract Codable describing a single Interactive Connectivity
//  Establishment (ICE) server.  Used to decode the response the server
//  returns from `GET /api/v1/ice-servers`, which itself is a normalized
//  view of the credentials Cloudflare minted via
//  `https://rtc.live.cloudflare.com/v1/turn/keys/{TOKEN_ID}/credentials/generate`.
//
//  Lives in AkinFrontBackModels because it is consumed by both the iOS
//  client (to build `[RTCIceServer]` for the WebRTC peer connection) and
//  the Vapor server (to shape its response body).
//

import Foundation

/// A single Interactive Connectivity Establishment (ICE) server entry.
///
/// Matches the shape Cloudflare returns from its TURN credential
/// generation endpoint.  `urls` may contain any mix of `stun:`, `turn:`,
/// and `turns:` URIs.  `username` and `credential` are `nil` for pure
/// STUN entries (STUN is unauthenticated) and present for TURN/TURNS.
public struct IceServer: Codable, Equatable, Hashable, Sendable {

	/// The Uniform Resource Identifiers (URIs) the peer connection should
	/// try in order when gathering candidates.
	public let urls: [String]

	/// Short-lived TURN username minted by Cloudflare.  `nil` for STUN.
	public let username: String?

	/// Short-lived TURN credential minted by Cloudflare.  `nil` for STUN.
	public let credential: String?

	/// Creates a new `IceServer` description.
	///
	/// - Parameters:
	///   - urls: Ordered list of STUN/TURN Uniform Resource Identifiers.
	///   - username: TURN username, or `nil` for STUN-only entries.
	///   - credential: TURN credential, or `nil` for STUN-only entries.
	public init(
		urls: [String],
		username: String?,
		credential: String?
	) {
		self.urls = urls
		self.username = username
		self.credential = credential
	}
}
