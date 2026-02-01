//
//  File.swift
//  AkinFrontBackModels
//
//  Created by Scott Lydon on 1/31/26.
//

import Foundation


// MARK: - Event enum (top-level) with helpers
public enum GreetLogEvent: Codable, ActionStringConvertible {

    case greetAction(GreetAction)

    // Delivery lifecycle
    case pushQueued(channel: GreetActionChannel, providerMessageID: UUID?)
    /// Consider deprecating; `pushProviderAccepted` is the more reliable provider acknowledgment.
    case pushSent(channel: GreetActionChannel, providerMessageID: UUID?)
    case pushProviderAccepted(providerMessageID: UUID)
    case pushFailed(channel: GreetActionChannel)

    case webSocketSent
    case webSocketFailed

    case deliveryConfirmed(channel: GreetActionChannel, providerMessageID: UUID?)
    case fallbackTriggered(to: GreetActionChannel)

    case rateLimited

    // Received on device (client-ack style)
    case pushNotifReceived(providerMessageID: UUID) // APNs
    case voipReceived(providerMessageID: UUID)      // VoIP

    case rejectedViaAnotherCall

    // User intent
    case userViewed

    // App/system state
    case greetCreated

    /// Nobody acted on it within a time frame.
    case greetExpired
    case settingsUpdated

    case serverFound(error: String)
    case clientFound(error: String)

    // MARK: Persisted action string

    /// Stable, database-friendly identifier for this event.
    /// Use this when persisting the "action" column.
    public var action: String {
        switch self {
        case .greetAction(let greetAction):
            return greetAction.actionString
        default:
            return actionString
        }
    }

    /// Delivery channel to persist (if any).
    public var channel: GreetActionChannel {
        switch self {
        case .pushQueued(let deliveryChannel, _),
             .pushSent(let deliveryChannel, _),
             .pushFailed(let deliveryChannel):
            return deliveryChannel

        case .deliveryConfirmed(let deliveryChannel, _):
            return deliveryChannel

        case .fallbackTriggered(let destinationChannel):
            return destinationChannel

        // Received on device – set explicit channels
        case .pushNotifReceived:
            return .applePush
        case .voipReceived, .rejectedViaAnotherCall:
            return .voicePush

        case .webSocketSent:
            return .websocket

        case .webSocketFailed, .rateLimited, .greetAction,
             .userViewed, .greetCreated, .greetExpired, .settingsUpdated,
             .pushProviderAccepted, .serverFound, .clientFound:
            return .notApplicable
        }
    }

    /// Provider or diagnostic message:
    /// - For pushes, this is the provider message identifier (e.g., APNs `apns-id` or VoIP UUID) as a string.
    /// - For `.serverFound` / `.clientFound`, this is the error message.
    /// - Otherwise, `nil`.
    public var message: String? {
        switch self {
        case .pushQueued(_, let providerMessageIdentifier),
             .pushSent(_, let providerMessageIdentifier):
            return providerMessageIdentifier?.uuidString

        case .pushProviderAccepted(let providerMessageIdentifier):
            return providerMessageIdentifier.uuidString

        case .deliveryConfirmed(_, let providerMessageIdentifier):
            return providerMessageIdentifier?.uuidString

        case .pushNotifReceived(let providerMessageIdentifier):
            return providerMessageIdentifier.uuidString

        case .voipReceived(let providerMessageIdentifier):
            return providerMessageIdentifier.uuidString

        case .serverFound(let errorMessage):
            return errorMessage

        case .clientFound(let errorMessage):
            return errorMessage

        case .pushFailed,
             .webSocketSent, .webSocketFailed,
             .fallbackTriggered, .rateLimited, .userViewed,
              .greetCreated, .greetExpired, .settingsUpdated,
             .rejectedViaAnotherCall:
            return nil
        case .greetAction(let action):
            if case let .travelTimeToVenue(changedTo: current) = action {
                return current.string
            }
            return nil
        }
    }

    /// Default actor kind to record for this event.
    public var actorKindDefault: GreetActionActorKind {
        switch self {
        // Delivery lifecycle (server-initiated)
        case .pushQueued, .pushSent, .pushProviderAccepted, .pushFailed,
             .webSocketSent, .webSocketFailed, .fallbackTriggered, .rateLimited,
             .greetCreated, .settingsUpdated, .serverFound:
            return .server

        // Device acknowledged receipt; treat as system by default.
        case .pushNotifReceived, .voipReceived, .deliveryConfirmed, .greetExpired, .clientFound:
            return .system

        // Explicit user intents
        case .greetAction,
             .userViewed, .rejectedViaAnotherCall:
            return .user
        }
    }
}

// MARK: - DB-backed enums (top-level, no nesting)
public enum GreetActionActorKind: String, Codable, CaseIterable {
    case user
    case server
    case system
}

/// Delivery channel when the action represents an outbound delivery.
/// Stored as "websocket" | "apple_push" | "voice_push".
public enum GreetActionChannel: String, Codable, CaseIterable {
    case websocket
    case applePush = "apple_push"   /// Apple Push Notification service (APNs)
    case voicePush  = "voice_push"  /// Voice-over-Internet push
    case notApplicable = "not_applicable"
}
