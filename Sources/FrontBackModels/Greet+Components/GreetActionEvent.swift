//
//  File.swift
//  AkinFrontBackModels
//
//  Created by Scott Lydon on 9/11/25.
//

import Foundation

// MARK: - Event enum (top-level) with helpers
public enum GreetActionEvent: Codable {

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

    // User intent (existing)
    case userTappedMeet
    case userTappedCancel
    case userTappedDismiss
    case userSelectedLater30m
    case userAgreedLater30m
    case userRejectedLater30m

    // User intent (new)
    case userViewed
    case userAgreedNow
    case userAgreedToUnplannedTime(chosenStart: Int)
    case userRejectNow
    case userRejectToUnplannedTime(proposedStart: Int)
    case tappedRedRejectButton
    case tappedRedVoipReject

    // Motion/geo
    case distanceTravelledChanged(totalMeters: Double)
    case percentTravelledChanged(percent: Double)
    case exceededRange(currentMeters: Double, allowedMeters: Double)

    // App/system state
    case userClosedApp
    case greetCreated
    case greetCanceled
    case greetExpired
    case settingsUpdated

    case serverFound(error: String)
    case clientFound(error: String)

    // MARK: Persisted action string

    /// Stable, database-friendly identifier for this event.
    /// Use this when persisting the "action" column.
    public var action: String {
        switch self {
        // Delivery lifecycle
        case .pushQueued:                      return "push_queued"
        case .pushSent:                        return "push_sent"
        case .pushProviderAccepted:            return "push_provider_accepted"
        case .pushFailed:                      return "push_failed"
        case .webSocketSent:                   return "websocket_sent"
        case .webSocketFailed:                 return "websocket_failed"
        case .deliveryConfirmed:               return "delivery_confirmed"
        case .fallbackTriggered:               return "fallback_triggered"
        case .rateLimited:                     return "rate_limited"

        // Received on device
        case .pushNotifReceived:               return "push_notif_received"
        case .voipReceived:                    return "voip_received"

        // User intent (existing)
        case .userTappedMeet:                  return "user_tapped_meet"
        case .userTappedCancel:                return "user_tapped_cancel"
        case .userTappedDismiss:               return "user_tapped_dismiss"
        case .userSelectedLater30m:            return "user_selected_later_30m"
        case .userAgreedLater30m:              return "user_agreed_later_30m"
        case .userRejectedLater30m:            return "user_rejected_later_30m"

        // User intent (new)
        case .userViewed:                      return "user_viewed"
        case .userAgreedNow:                   return "user_agreed_now"
        case .userAgreedToUnplannedTime:       return "user_agreed_to_unplanned_time"
        case .userRejectNow:                   return "user_reject_now"
        case .userRejectToUnplannedTime:       return "user_reject_to_unplanned_time"
        case .tappedRedRejectButton:           return "tapped_red_reject_button"
        case .tappedRedVoipReject:             return "tapped_red_voip_reject"

        // Motion/geo
        case .distanceTravelledChanged:        return "distance_travelled_changed"
        case .exceededRange:                   return "exceeded_range"

        // App/system state
        case .userClosedApp:                   return "user_closed_app"
        case .greetCreated:                    return "greet_created"
        case .greetCanceled:                   return "greet_canceled"
        case .greetExpired:                    return "greet_expired"
        case .settingsUpdated:                 return "settings_updated"

        case .rejectedViaAnotherCall:          return "rejected_via_another_call"
        case .serverFound:                     return "server_found_error"
        case .clientFound:                     return "client_found_error"
        case .percentTravelledChanged:      return "percent_travelled_changed"
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

        case .webSocketFailed, .rateLimited,
             .userTappedMeet, .userTappedCancel, .userTappedDismiss,
             .userSelectedLater30m, .userAgreedLater30m, .userRejectedLater30m,
             .userViewed, .userAgreedNow, .userAgreedToUnplannedTime,
             .userRejectNow, .userRejectToUnplannedTime, .tappedRedRejectButton,
             .tappedRedVoipReject, .distanceTravelledChanged, .exceededRange,
             .userClosedApp, .greetCreated, .greetCanceled, .greetExpired, .settingsUpdated,
             .pushProviderAccepted, .serverFound, .clientFound, .percentTravelledChanged:
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
             .fallbackTriggered, .rateLimited,
             .userTappedMeet, .userTappedCancel, .userTappedDismiss,
             .userSelectedLater30m, .userAgreedLater30m, .userRejectedLater30m,
             .userViewed, .userAgreedNow, .userAgreedToUnplannedTime,
             .userRejectNow, .userRejectToUnplannedTime, .tappedRedRejectButton,
             .tappedRedVoipReject, .distanceTravelledChanged, .exceededRange,
             .userClosedApp, .greetCreated, .greetCanceled, .greetExpired, .settingsUpdated,
             .rejectedViaAnotherCall:
            return nil
        case .percentTravelledChanged(percent: let percent):
            return percent.string
        }
    }

    /// Default actor kind to record for this event.
    public var actorKindDefault: GreetActionActorKind {
        switch self {
        // Delivery lifecycle (server-initiated)
        case .pushQueued, .pushSent, .pushProviderAccepted, .pushFailed,
             .webSocketSent, .webSocketFailed, .fallbackTriggered, .rateLimited,
             .greetCreated, .greetCanceled, .settingsUpdated, .serverFound:
            return .server

        // Device acknowledged receipt; treat as system by default.
        case .pushNotifReceived, .voipReceived, .deliveryConfirmed, .greetExpired, .clientFound:
            return .system

        // Explicit user intents
        case .userTappedMeet, .userTappedCancel, .userTappedDismiss,
             .userSelectedLater30m, .userAgreedLater30m, .userRejectedLater30m,
             .userViewed, .userAgreedNow, .userAgreedToUnplannedTime,
             .userRejectNow, .userRejectToUnplannedTime,
             .tappedRedRejectButton, .tappedRedVoipReject, .distanceTravelledChanged,
             .exceededRange, .userClosedApp, .rejectedViaAnotherCall, .percentTravelledChanged:
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
