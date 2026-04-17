//
//  VoipSignal.swift
//  AkinFrontBackModels
//
//  Created by Scott Lydon + claude on 4/16/26.
//
//  Strong-contract types used to ferry WebRTC (Web Real Time
//  Communication) signalling messages between two Greet
//  participants.  A caller and callee exchange an Session
//  Description Protocol (SDP) "offer" and "answer", followed
//  by Interactive Connectivity Establishment (ICE) candidates.
//
//  The server acts as a pure relay: it receives one of these
//  payloads over a REST (`Request.relayVoipSignal`) or WebSocket
//  (`SocketPayload.voipSignal`) channel and forwards it to the
//  other participant in the Greet via the `WebSocketHub`.
//

import Foundation

/// A single Web Real Time Communication (WebRTC) signalling
/// message ferried between two participants in a Greet.
public enum VoipSignal: Codable, Equatable, Hashable, Sendable {

	/// A Session Description Protocol (SDP) offer generated
	/// by the caller.
	/// - Parameter sdp: The full SDP blob.
	case offer(sdp: String)

	/// A Session Description Protocol (SDP) answer generated
	/// by the callee.
	/// - Parameter sdp: The full SDP blob.
	case answer(sdp: String)

	/// An Interactive Connectivity Establishment (ICE)
	/// candidate emitted by either participant.  All three
	/// fields are required so the receiving side can
	/// reconstruct the candidate exactly.
	case iceCandidate(
		sdp: String,
		sdpMLineIndex: Int32,
		sdpMid: String?
	)

	// MARK: - Codable

	private enum CaseType: String, Codable {
		case offer
		case answer
		case iceCandidate
	}

	private enum CodingKeys: String, CodingKey {
		case caseType
		case sdp
		case sdpMLineIndex
		case sdpMid
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		switch self {
		case .offer(let sdp):
			try container.encode(CaseType.offer, forKey: .caseType)
			try container.encode(sdp, forKey: .sdp)
		case .answer(let sdp):
			try container.encode(CaseType.answer, forKey: .caseType)
			try container.encode(sdp, forKey: .sdp)
		case .iceCandidate(let sdp, let sdpMLineIndex, let sdpMid):
			try container.encode(CaseType.iceCandidate, forKey: .caseType)
			try container.encode(sdp, forKey: .sdp)
			try container.encode(sdpMLineIndex, forKey: .sdpMLineIndex)
			try container.encodeIfPresent(sdpMid, forKey: .sdpMid)
		}
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let caseType: CaseType = try container.decode(CaseType.self, forKey: .caseType)
		switch caseType {
		case .offer:
			let sdp: String = try container.decode(String.self, forKey: .sdp)
			self = .offer(sdp: sdp)
		case .answer:
			let sdp: String = try container.decode(String.self, forKey: .sdp)
			self = .answer(sdp: sdp)
		case .iceCandidate:
			let sdp: String = try container.decode(String.self, forKey: .sdp)
			let sdpMLineIndex: Int32 = try container.decode(Int32.self, forKey: .sdpMLineIndex)
			let sdpMid: String? = try container.decodeIfPresent(String.self, forKey: .sdpMid)
			self = .iceCandidate(sdp: sdp, sdpMLineIndex: sdpMLineIndex, sdpMid: sdpMid)
		}
	}
}

/// Strong-contract payload for a single Web Real Time
/// Communication (WebRTC) signalling message.  The server
/// relays the entire payload unchanged to the other
/// participant in the Greet.
public struct VoipSignalPayload: Codable, Equatable, Hashable, Sendable {

	/// Identifies the Greet session this signalling message
	/// belongs to.  The server uses this to look up the
	/// participants and route the message to the non-sender.
	public let greetID: UUID

	/// The ``CallType`` the signalling message is associated
	/// with.  Included for completeness / client routing; the
	/// server does not branch on it.
	public let callType: CallType

	/// The actual signalling payload (Session Description
	/// Protocol offer/answer, or an Interactive Connectivity
	/// Establishment candidate).
	public let signal: VoipSignal

	/// Creates a new signalling payload.
	/// - Parameters:
	///   - greetID: The Greet this signalling message belongs to.
	///   - callType: The ``CallType`` that triggered the call.
	///   - signal: The signalling message itself.
	public init(
		greetID: UUID,
		callType: CallType,
		signal: VoipSignal
	) {
		self.greetID = greetID
		self.callType = callType
		self.signal = signal
	}
}
