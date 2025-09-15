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
    case pushSent(channel: GreetActionChannel, providerMessageID: UUID?) // consider deprecating
    case pushProviderAccepted(providerMessageID: UUID)
    case pushFailed(channel: GreetActionChannel)

    case webSocketSent
    case webSocketFailed

    case deliveryConfirmed(channel: GreetActionChannel, providerMessageID: UUID?)
    case fallbackTriggered(to: GreetActionChannel)

    case rateLimited

    // Received on device (client-ack style)
    case pushNotifReceived(providerMessageID: UUID) // APNS
    case voipReceived(providerMessageID: UUID)      // VoIP

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
    case exceededRange(currentMeters: Double, allowedMeters: Double)

    // App/system state
    case userClosedApp
    case greetCreated
    case greetCanceled
    case greetExpired
    case settingsUpdated

    /// Maps to the persisted action type as a typed enum.
    /// NOTE: You must ensure GreetActionType has corresponding cases for the new events below.
    public var action: GreetActionType {
        switch self {
        // Delivery lifecycle
        case .pushQueued:                    return .pushQueued
        case .pushSent:                      return .pushSent
        case .pushProviderAccepted:          return .pushProviderAccepted
        case .pushFailed:                    return .pushFailed
        case .webSocketSent:                 return .webSocketSent
        case .webSocketFailed:               return .webSocketFailed
        case .deliveryConfirmed:             return .deliveryConfirmed
        case .fallbackTriggered:             return .fallbackTriggered
        case .rateLimited:                   return .rateLimited

        // Received on device
        case .pushNotifReceived:             return .pushNotifReceived
        case .voipReceived:                  return .voipReceived

        // User intent (existing)
        case .userTappedMeet:                return .userTappedMeet
        case .userTappedCancel:              return .userTappedCancel
        case .userTappedDismiss:             return .userTappedDismiss
        case .userSelectedLater30m:          return .userSelectedLater30m
        case .userAgreedLater30m:            return .userAgreedLater30m
        case .userRejectedLater30m:          return .userRejectedLater30m

        // User intent (new)
        case .userViewed:                    return .userViewed
        case .userAgreedNow:                 return .userAgreedNow
        case .userAgreedToUnplannedTime:     return .userAgreedToUnplannedTime
        case .userRejectNow:                 return .userRejectNow
        case .userRejectToUnplannedTime:     return .userRejectToUnplannedTime
        case .tappedRedRejectButton:         return .tappedRedRejectButton
        case .tappedRedVoipReject:           return .tappedRedVoipReject

        // Motion/geo
        case .distanceTravelledChanged:      return .distanceTravelledChanged
        case .exceededRange:                 return .exceededRange

        // App/system state
        case .userClosedApp:                 return .userClosedApp
        case .greetCreated:                  return .greetCreated
        case .greetCanceled:                 return .greetCanceled
        case .greetExpired:                  return .greetExpired
        case .settingsUpdated:               return .settingsUpdated
        }
    }

    /// Channel to persist (if any).
    public var channel: GreetActionChannel {
        switch self {
        case .pushQueued(let ch, _), .pushSent(let ch, _), .pushFailed(let ch):
            return ch
        case .deliveryConfirmed(let ch, _):
            return ch
        case .fallbackTriggered(let to):
            return to

        // Received on device – set explicit channels
        case .pushNotifReceived:
            return .applePush
        case .voipReceived:
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
             .pushProviderAccepted:
            return .notApplicable
        }
    }

    /// Provider message identifier (e.g., APNS `apns-id` or VoIP ID) if applicable.
    public var providerMessageID: UUID? {
        switch self {
        case .pushQueued(_, let id), .pushSent(_, let id):
            return id
        case .pushProviderAccepted(let id):
            return id
        case .deliveryConfirmed(_, let id):
            return id
        case .pushNotifReceived(let id):
            return id
        case .voipReceived(let id):
            return id

        case .pushFailed,
             .webSocketSent, .webSocketFailed,
             .fallbackTriggered, .rateLimited,
             .userTappedMeet, .userTappedCancel, .userTappedDismiss,
             .userSelectedLater30m, .userAgreedLater30m, .userRejectedLater30m,
             .userViewed, .userAgreedNow, .userAgreedToUnplannedTime,
             .userRejectNow, .userRejectToUnplannedTime, .tappedRedRejectButton,
             .tappedRedVoipReject, .distanceTravelledChanged, .exceededRange,
             .userClosedApp, .greetCreated, .greetCanceled, .greetExpired, .settingsUpdated:
            return nil
        }
    }

    /// Default actor kind to record for this event.
    public var actorKindDefault: GreetActionActorKind {
        switch self {
        // Delivery lifecycle (server-initiated)
        case .pushQueued, .pushSent, .pushProviderAccepted, .pushFailed,
             .webSocketSent, .webSocketFailed, .fallbackTriggered, .rateLimited,
             .greetCreated, .greetCanceled, .settingsUpdated:
            return .server

        // Device acknowledged receipt; treat as system by default.
        case .pushNotifReceived, .voipReceived, .deliveryConfirmed, .greetExpired:
            return .system

        // Explicit user intents
        case .userTappedMeet, .userTappedCancel, .userTappedDismiss,
             .userSelectedLater30m, .userAgreedLater30m, .userRejectedLater30m,
             .userViewed, .userAgreedNow, .userAgreedToUnplannedTime,
             .userRejectNow, .userRejectToUnplannedTime,
             .tappedRedRejectButton, .tappedRedVoipReject, .distanceTravelledChanged,
             .exceededRange, .userClosedApp:
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
public enum GreetActionChannel: String, Codable, CaseIterable, RawRepresentable {
    case websocket
    case applePush = "apple_push"   /// Apple Push Notification service (APNs)
    case voicePush  = "voice_push"  /// Voice-over-Internet push
    case notApplicable = "not_applicable"
}

// MARK: - Action Type (typed in Swift, stored as String)
public enum GreetActionType: Equatable, Hashable, Sendable {
    // Delivery lifecycle
    case pushQueued
    case pushSent
    case pushProviderAccepted
    case pushFailed
    case webSocketSent
    case webSocketFailed
    case deliveryConfirmed
    case fallbackTriggered
    case rateLimited

    // Received on device
    case pushNotifReceived
    case voipReceived

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
    case userAgreedToUnplannedTime
    case userRejectNow
    case userRejectToUnplannedTime
    case tappedRedRejectButton
    case tappedRedVoipReject

    // Motion/geo
    case distanceTravelledChanged
    case exceededRange

    // App/system state
    case userClosedApp
    case greetCreated
    case greetCanceled
    case greetExpired
    case settingsUpdated

    // Forward-compat: holds unknown/new strings without migrations
    case other(String)

    /// String used in the database.
    public var rawValue: String {
        switch self {
        // Delivery lifecycle
        case .pushQueued:                  return "push_queued"
        case .pushSent:                    return "push_sent"
        case .pushProviderAccepted:        return "push_provider_accepted"
        case .pushFailed:                  return "push_failed"
        case .webSocketSent:               return "websocket_sent"
        case .webSocketFailed:             return "websocket_failed"
        case .deliveryConfirmed:           return "delivery_confirmed"
        case .fallbackTriggered:           return "fallback_triggered"
        case .rateLimited:                 return "rate_limited"

        // Received on device
        case .pushNotifReceived:           return "push_notif_received"
        case .voipReceived:                return "voip_received"

        // User intent (existing)
        case .userTappedMeet:              return "user_tapped_meet"
        case .userTappedCancel:            return "user_tapped_cancel"
        case .userTappedDismiss:           return "user_tapped_dismiss"
        case .userSelectedLater30m:        return "user_selected_later_30m"
        case .userAgreedLater30m:          return "user_agreed_later_30m"
        case .userRejectedLater30m:        return "user_rejected_later_30m"

        // User intent (new)
        case .userViewed:                  return "user_viewed"
        case .userAgreedNow:               return "user_agreed_now"
        case .userAgreedToUnplannedTime:   return "user_agreed_to_unplanned_time"
        case .userRejectNow:               return "user_reject_now"
        case .userRejectToUnplannedTime:   return "user_reject_to_unplanned_time"
        case .tappedRedRejectButton:       return "tapped_red_reject_button"
        case .tappedRedVoipReject:         return "tapped_red_voip_reject"

        // Motion/geo
        case .distanceTravelledChanged:    return "distance_travelled_changed"
        case .exceededRange:               return "exceeded_range"

        // App/system state
        case .userClosedApp:               return "user_closed_app"
        case .greetCreated:                return "greet_created"
        case .greetCanceled:               return "greet_canceled"
        case .greetExpired:                return "greet_expired"
        case .settingsUpdated:             return "settings_updated"

        case .other(let value):            return value
        }
    }

    /// Construct from a database string; unknown values map to `.other(...)`.
    public init(rawValue: String) {
        switch rawValue {
        // Delivery lifecycle
        case "push_queued":                 self = .pushQueued
        case "push_sent":                   self = .pushSent
        case "push_provider_accepted":      self = .pushProviderAccepted
        case "push_failed":                 self = .pushFailed
        case "websocket_sent":              self = .webSocketSent
        case "websocket_failed":            self = .webSocketFailed
        case "delivery_confirmed":          self = .deliveryConfirmed
        case "fallback_triggered":          self = .fallbackTriggered
        case "rate_limited":                self = .rateLimited

        // Received on device
        case "push_notif_received":         self = .pushNotifReceived
        case "voip_received":               self = .voipReceived

        // User intent (existing)
        case "user_tapped_meet":            self = .userTappedMeet
        case "user_tapped_cancel":          self = .userTappedCancel
        case "user_tapped_dismiss":         self = .userTappedDismiss
        case "user_selected_later_30m":     self = .userSelectedLater30m
        case "user_agreed_later_30m":       self = .userAgreedLater30m
        case "user_rejected_later_30m":     self = .userRejectedLater30m

        // User intent (new)
        case "user_viewed":                 self = .userViewed
        case "user_agreed_now":             self = .userAgreedNow
        case "user_agreed_to_unplanned_time": self = .userAgreedToUnplannedTime
        case "user_reject_now":             self = .userRejectNow
        case "user_reject_to_unplanned_time": self = .userRejectToUnplannedTime
        case "tapped_red_reject_button":    self = .tappedRedRejectButton
        case "tapped_red_voip_reject":      self = .tappedRedVoipReject

        // Motion/geo
        case "distance_travelled_changed":  self = .distanceTravelledChanged
        case "exceeded_range":              self = .exceededRange

        // App/system state
        case "user_closed_app":             self = .userClosedApp
        case "greet_created":               self = .greetCreated
        case "greet_canceled":              self = .greetCanceled
        case "greet_expired":               self = .greetExpired
        case "settings_updated":            self = .settingsUpdated

        default:                            self = .other(rawValue)
        }
    }
}

// Optional: make it Codable as a single string for APIs
extension GreetActionType: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value: String = try container.decode(String.self)
        self = .init(rawValue: value)
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}
