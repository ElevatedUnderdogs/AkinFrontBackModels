//
//  File.swift
//  AkinFrontBackModels
//
//  Created by Scott Lydon on 9/11/25.
//

import Foundation

public struct InstructionCellContents: Equatable {
    public let venueNaeme: String
    public let targetMeetTime: Date

    public init(venueNaeme: String, targetMeetTime: Date) {
        self.venueNaeme = venueNaeme
        self.targetMeetTime = targetMeetTime
    }

    public static func == (
        left: InstructionCellContents,
        right: InstructionCellContents
    ) -> Bool {
        guard left.venueNaeme == right.venueNaeme else {
            return false
        }

        let timeDifferenceInSeconds = abs(
            left.targetMeetTime.timeIntervalSince1970
            - right.targetMeetTime.timeIntervalSince1970
        )

        return timeDifferenceInSeconds <= 1.0
    }
}


public enum MeetTimeState {
    case show
    case rejectedHidden
    case waiting
}

public struct MeetDecisionCellContents: Equatable {
    public let venueName: String
    public let proposalState: TimeNegotiationContents

    public init(venueName: String, proposalState: TimeNegotiationContents) {
        self.venueName = venueName
        self.proposalState = proposalState
    }

    public enum TimeNegotiationContents: Equatable, Hashable {
        /// The other user proposed meeting in x: Int minutes. Show this when the other user proposed in 30 and this user hasn't rejected it.
        case alternateProposal(AlternateRequestCellModel)
        /// Current build does not allow for now to be rejected, only rejecting the whole greet altogether.
        case select(now: MeetTimeState, in30: MeetTimeState)
    }

}

public enum GreetViewContents: Equatable {
    case negotiation(StartViewContents) // if no one has rejected in any form, not confirmed met, this user hasn't agreed to any.
    case enroute(EnrouteContents)
    case rejected(RejectedContents)
    /// Go to the rating screen.
    case giveRating

    /// If the client asks what should be displayed and the greet is finito. 
    case showInHistory
}

public struct StartViewContents: Equatable {
    public let profilePicURL: String
    public let openers: [String]
    public let meetDecisionContents: MeetDecisionCellContents

    public init(profilePicURL: String, openers: [String], meetDecisionContents: MeetDecisionCellContents) {
        self.profilePicURL = profilePicURL
        self.openers = openers
        self.meetDecisionContents = meetDecisionContents
    }
}

public struct AlternateRequestCellModel: Equatable, Hashable {

    public enum GeneralStyle: Equatable, Hashable {
        case minutes(Int)
        case theySaidTheyMet(String)
        case youAreClose(String)
    }

     public var title: String
     public var message: String
     public var leftButtonTitle: String?
     public var rightButtonTitle: String
     public var style: GeneralStyle

    public init(title: String, message: String, leftButtonTitle: String? = nil, rightButtonTitle: String, style: GeneralStyle) {
        self.title = title
        self.message = message
        self.leftButtonTitle = leftButtonTitle
        self.rightButtonTitle = rightButtonTitle
        self.style = style
    }

    static func theyProposed(minutes: Int) -> AlternateRequestCellModel {
        AlternateRequestCellModel(title: "Meet in \(String(minutes)) minutes?",
            message: "They want to meet you!  Would in \(String(minutes)) minutes be okay?",
            leftButtonTitle: "I can't",
            rightButtonTitle: "Sure!",
            style: .minutes(minutes))
    }

    static func youAreClose(otherName: String) -> AlternateRequestCellModel {
        AlternateRequestCellModel(
            title: "You seem pretty close",
            message: "Did you meet \(otherName) yet?",
            leftButtonTitle: nil,
            rightButtonTitle: "Yes",
            style: .youAreClose(otherName))
    }

    static func theySaidTheyMet(otherName: String) -> AlternateRequestCellModel {
        AlternateRequestCellModel(title: "\(otherName) said you met.",
            message: "Did you meet \(otherName) yet?",
            leftButtonTitle: nil,
            rightButtonTitle: "Yes",
            style: .theySaidTheyMet(otherName))
    }
}

// The user goes to the rating screen based on tapping the yes we met which sends an event and navigates to the rating screen,
// I suppose if there is
public struct EnrouteContents: Equatable {
    public let profilePicURL: String
    public let openers: [String]
    public let address: String
    public let percentTravelled: Double
    public let instructionContents: InstructionCellContents
    // map cell details are personal to the viewing user,
    // not related to the greet/relation
    public let otherContents: OtherUserContents
    /// Set to true if the other user and this user are within 5 minutes of each other and the venue.
    /// So we can show the check if you met ui. 
    ///let checkIfMet: Bool
    public let alternateRequestCellModel: AlternateRequestCellModel?

    public init(profilePicURL: String, openers: [String], address: String, percentTravelled: Double, instructionContents: InstructionCellContents, otherContents: OtherUserContents, alternateRequestCellModel: AlternateRequestCellModel?) {
        self.profilePicURL = profilePicURL
        self.openers = openers
        self.address = address
        self.percentTravelled = percentTravelled
        self.instructionContents = instructionContents
        self.otherContents = otherContents
        self.alternateRequestCellModel = alternateRequestCellModel
    }
}

public struct ConfirmedMetContents: Equatable {
    public var profilePicURL: String
    public let address: String
    public let percentTravelled: Double
    public let openers: [String]
    public let instructionContents: InstructionCellContents

    // map cell details are personal to the viewing user,
    // not related to the greet/relation
    public let otherContents: OtherUserContents

    public init(profilePicURL: String, address: String, percentTravelled: Double, openers: [String], instructionContents: InstructionCellContents, otherContents: OtherUserContents) {
        self.profilePicURL = profilePicURL
        self.address = address
        self.percentTravelled = percentTravelled
        self.openers = openers
        self.instructionContents = instructionContents
        self.otherContents = otherContents
    }
}

public struct RejectedContents: Equatable {
    public let title: String
    public let body: String
    // Probably says something like okay, or lets go!
    public let confirmText: String

    public init(title: String, body: String, confirmText: String) {
        self.title = title
        self.body = body
        self.confirmText = confirmText
    }

    public static var thisUserDismissed: RejectedContents {
        .init(title: "Don't worry we closed it for both you and them", body: "", confirmText: "")
    }

    public static var otherUserDismissed: RejectedContents {
        .init(title: "There are more fish in the sea.", body: "", confirmText: "")
    }

    public static func theyWrongWay(travelTime: Int) -> RejectedContents {
        .init(
            title: "Wrong way.",
            body: "It looks like they are going the wrong way.  It would take them \(travelTime) minutes to get to the meeting point.  We closed it to save you the hassle.",
            confirmText: "There are more fish in the sea."
        )
    }

    public static func thisWrongWay(travelTime: Int) -> RejectedContents {
        .init(
            title: "Wrong way.",
            body: "It looks like you are going the wrong way.  It would take you \(travelTime) minutes to get to the meeting point.",
            confirmText: "There are more fish in the sea."
        )
    }

    public static func theySlowProgress(travelTime: Int) -> RejectedContents {
        .init(
            title: "No progress",
            body: "It looks like they weren’t making progress toward the meeting point. They were still about \(travelTime) minutes away, so we closed the greet to save you the wait.",
            confirmText: "There are more fish in the sea."
        )
    }

    public static func thisSlowProgress(travelTime: Int) -> RejectedContents {
        .init(
            title: "No progress",
            body: "It looks like you weren’t making progress toward the meeting point and were still about \(travelTime) minutes away. We closed the greet to keep things moving.",
            confirmText: "There are more fish in the sea."
        )
    }
}

public struct OtherUserContents: Equatable {
    public let otherUserName: String
    public let greetingMethod: String
    // Get it from greet.otherUserTravelStatusText
    public let travelStatusText: String

    public init(otherUserName: String, greetingMethod: String, travelStatusText: String) {
        self.otherUserName = otherUserName
        self.greetingMethod = greetingMethod
        self.travelStatusText = travelStatusText
    }
}



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
