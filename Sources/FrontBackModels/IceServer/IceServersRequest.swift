//
//  IceServersRequest.swift
//  AkinFrontBackModels
//
//  Created by Scott Lydon + claude on 4/20/26.
//
//  Strong-contract endpoint declaration for the Interactive Connectivity
//  Establishment (ICE) server credentials fetch.  The client calls this
//  endpoint right before it builds its `RTCPeerConnection` so the
//  connection has a fresh, short-lived Traversal Using Relays around
//  Network Address Translators (TURN) credential minted by Cloudflare.
//
//  The endpoint takes no payload — identity is supplied by the standard
//  access token header, which the server already requires on every
//  authenticated call (see `assertHasAccessToken` default in
//  `StrongContractClient`).
//

import Foundation
import StrongContractClient

/// `GET /api/v1/ice-servers` — returns the ordered list of STUN/TURN
/// servers the client should pass to its Web Real Time Communication
/// (WebRTC) peer connection configuration.
public typealias IceServersRequestType = Request<Empty, IceServersResponse>

extension IceServersRequestType {

	/// Fetches a fresh set of Interactive Connectivity Establishment
	/// (ICE) servers from the server.  The server talks to Cloudflare
	/// behind the scenes and returns a normalized `IceServersResponse`.
	public static var iceServers: Self {
		.init(method: .get)
	}
}
