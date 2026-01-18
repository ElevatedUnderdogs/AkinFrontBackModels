//
//  File.swift
//  AkinFrontBackModels
//
//  Created by Scott Lydon on 9/11/25.
//

import Foundation

public struct FullGreetEventLedger: Codable, Sendable {

    public let greetID: UUID
    public let participantUserIDs: [UUID]
    public let events: [GreetEvent]

    public var latestServerSequenceNumber: Int {
        events.last?.serverSequenceNumber ?? 0
    }
}

public struct GreetEvent: Codable, Sendable, Hashable {

    /// Stable identity for this event (idempotency, debugging).
    public let eventID: UUID

    /// Monotonic ordering number assigned by the server, scoped to greetID.
    public let serverSequenceNumber: Int

    /// The user who authored the action.
    public let actorUserID: UUID

    /// Server-side timestamp.
    public let serverDate: Date

    /// Client Date

    /// Domain action.
    public let action: GreetAction
}

// MARK: - Event enum (top-level) with helpers
public enum GreetAction: Codable, Sendable, Hashable, Equatable {

    /// When a user taps or swipes on another user to try to meet them now.
    ///  **UI Effect:**
    /// It can affect the alert text, instead of "We think you may want to meet", "They'd like to meet you".
    case manualGreetInitiated

    /// The associated value represents a time from the agreement to meet that they would like to leave.
    ///  For example, if both agree to meet in 30 minutes at 5:00PM, then both users should aim to start traveling no later than
    ///  5:30PM
    ///  **UI Effect:** May prompt a user asking if they would like to meet at an alternative time.
    case agreedToMeet(Int)

    /// The current verbiage in the app ui is "dismiss" which is essentially rejecting the meetup with the other person
    /// altogether.
    ///  **UI Effect:** Should navigate to a "sorry it didn't work out screen"
    case dismissGreet

    /// In the negotiation
    case rejectTime(Int)

    /// A rejection of the other user.
    case closeApp

    /// Associated value in minutes.
    case travelTimeToVenueUpdate(start: Int, current: Int)

    ///
    case confirmedMet

    case rated(Int, outOf: Int)

    /// If you are moving in a way that the travel time is growing past a certain point/allowance,
    ///  then the greet may auto close.  When current > (start + allowance), then auto-close.
    /// - starting travel time.
    /// - allowance
    /// - current travel time.
    case exceededTravelTimeAllowance(start: Int, allowance: Int, current: Int)

    case tappedRedVoipReject
}

// MARK: - Event enum (top-level) with helpers
public enum GreetLogEvent: Codable {

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

        // MARK: - Shared greet actions (wrapped)
        case .greetAction(let greetAction):
            switch greetAction {

            case .manualGreetInitiated:
                return "manual_greet_initiated"

            case .agreedToMeet:
                return "agreed_to_meet"

            case .dismissGreet:
                return "dismiss_greet"

            case .rejectTime:
                return "reject_time"

            case .closeApp:
                return "close_app"

            case .travelTimeToVenueUpdate:
                return "travel_time_to_venue_update"

            case .confirmedMet:
                return "confirmed_met"

            case .rated:
                return "rated"

            case .exceededTravelTimeAllowance:
                return "exceeded_travel_time_allowance"

            case .tappedRedVoipReject:
                return "tapped_red_voip_reject"
            }

        // MARK: - Delivery lifecycle
        case .pushQueued:
            return "push_queued"

        case .pushSent:
            return "push_sent"

        case .pushProviderAccepted:
            return "push_provider_accepted"

        case .pushFailed:
            return "push_failed"

        case .webSocketSent:
            return "websocket_sent"

        case .webSocketFailed:
            return "websocket_failed"

        case .deliveryConfirmed:
            return "delivery_confirmed"

        case .fallbackTriggered:
            return "fallback_triggered"

        case .rateLimited:
            return "rate_limited"

        // MARK: - Received on device
        case .pushNotifReceived:
            return "push_notif_received"

        case .voipReceived:
            return "voip_received"

        // MARK: - User / app state
        case .userViewed:
            return "user_viewed"

        case .greetCreated:
            return "greet_created"

        case .greetExpired:
            return "greet_expired"

        case .settingsUpdated:
            return "settings_updated"

        case .rejectedViaAnotherCall:
            return "rejected_via_another_call"

        // MARK: - Error reporting
        case .serverFound:
            return "server_found_error"

        case .clientFound:
            return "client_found_error"
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
            if case let .travelTimeToVenueUpdate(start, current) = action {
                return ((start - current).double/start.double).string
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
