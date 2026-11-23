//
//  SchemaReadyEnumGoldens.swift
//  FrontBackModelsTests
//
//  The exact JSON every case of the changed enums produced BEFORE `CaseIterable` and the
//  hand-written `CodingKeys` were added. Captured on commit cb51359 (main before this change)
//  by encoding one value per case with a plain `JSONEncoder` and with `JSONEncoder.akinWire`,
//  both with sorted keys so the text is stable.
//
//  SchemaReadyEnumTests decodes each string with the new code and encodes it again. Getting the
//  same bytes back proves the change did not move the wire format, in either direction. Do not
//  regenerate these from the current code: that would only prove the code agrees with itself.
//
//  Long strings are split into pieces so no line passes 100 columns. The pieces are joined
//  back into one string with nothing between them.
//

struct WireGolden {
    /// The enum case this JSON holds, by its Swift name.
    let caseName: String
    /// What a plain `JSONEncoder` with sorted keys wrote.
    let plain: String
    /// What `JSONEncoder.akinWire` with sorted keys wrote: snake_case keys and ISO dates.
    let wire: String
}

enum SchemaReadyEnumGoldens {

    static let automaticGreetDebugAction: [WireGolden] = [
        WireGolden(
            caseName: "expireCooldownNow",
            plain: #"{"expireCooldownNow":{}}"#,
            wire: #"{"expire_cooldown_now":{}}"#
        ),
        WireGolden(
            caseName: "setLastGreet",
            plain: #"{"setLastGreet":{"secondsAgo":1.5}}"#,
            wire: #"{"set_last_greet":{"seconds_ago":1.5}}"#
        ),
        WireGolden(
            caseName: "clearPairHistory",
            plain: #"{"clearPairHistory":{}}"#,
            wire: #"{"clear_pair_history":{}}"#
        ),
    ]

    static let automaticGreetSuppression: [WireGolden] = [
        WireGolden(
            caseName: "pairCooldown",
            plain: #"{"pairCooldown":{"until":812692800.1229999}}"#,
            wire: #"{"pair_cooldown":{"until":"2026-10-03T04:00:00.123Z"}}"#
        ),
        WireGolden(
            caseName: "memberCapReached",
            plain: [
                #"{"memberCapReached":{"cap":7,"count":7,"isScanner":true,"until":8126"#,
                #"92800.1229999}}"#,
            ].joined(),
            wire: [
                #"{"member_cap_reached":{"cap":7,"count":7,"is_scanner":true,"until":""#,
                #"2026-10-03T04:00:00.123Z"}}"#,
            ].joined()
        ),
        WireGolden(
            caseName: "alreadyInAGreet",
            plain: #"{"alreadyInAGreet":{"isScanner":true}}"#,
            wire: #"{"already_in_a_greet":{"is_scanner":true}}"#
        ),
        WireGolden(
            caseName: "pendingGreetUnanswered",
            plain: #"{"pendingGreetUnanswered":{}}"#,
            wire: #"{"pending_greet_unanswered":{}}"#
        ),
        WireGolden(
            caseName: "alreadyMet",
            plain: #"{"alreadyMet":{"until":812692800.1229999}}"#,
            wire: #"{"already_met":{"until":"2026-10-03T04:00:00.123Z"}}"#
        ),
        WireGolden(
            caseName: "busy",
            plain: #"{"busy":{"isScanner":true,"until":812692800.1229999}}"#,
            wire: #"{"busy":{"is_scanner":true,"until":"2026-10-03T04:00:00.123Z"}}"#
        ),
        WireGolden(
            caseName: "automaticGreetsOff",
            plain: #"{"automaticGreetsOff":{"isScanner":true}}"#,
            wire: #"{"automatic_greets_off":{"is_scanner":true}}"#
        ),
        WireGolden(
            caseName: "hiddenFromNearby",
            plain: #"{"hiddenFromNearby":{"isScanner":true}}"#,
            wire: #"{"hidden_from_nearby":{"is_scanner":true}}"#
        ),
        WireGolden(
            caseName: "blocked",
            plain: #"{"blocked":{}}"#,
            wire: #"{"blocked":{}}"#
        ),
        WireGolden(
            caseName: "unreachable",
            plain: #"{"unreachable":{}}"#,
            wire: #"{"unreachable":{}}"#
        ),
        WireGolden(
            caseName: "unverified",
            plain: #"{"unverified":{"isScanner":true}}"#,
            wire: #"{"unverified":{"is_scanner":true}}"#
        ),
        WireGolden(
            caseName: "moderationFlagged",
            plain: #"{"moderationFlagged":{}}"#,
            wire: #"{"moderation_flagged":{}}"#
        ),
        WireGolden(
            caseName: "frozenByAnotherMember",
            plain: #"{"frozenByAnotherMember":{"until":812692800.1229999}}"#,
            wire: #"{"frozen_by_another_member":{"until":"2026-10-03T04:00:00.123Z"}}"#
        ),
        WireGolden(
            caseName: "outsideStatedAvailability",
            plain: #"{"outsideStatedAvailability":{"isScanner":true}}"#,
            wire: #"{"outside_stated_availability":{"is_scanner":true}}"#
        ),
        WireGolden(
            caseName: "noVenueBetweenThem",
            plain: #"{"noVenueBetweenThem":{}}"#,
            wire: #"{"no_venue_between_them":{}}"#
        ),
        WireGolden(
            caseName: "unavailableToYou",
            plain: #"{"unavailableToYou":{}}"#,
            wire: #"{"unavailable_to_you":{}}"#
        ),
    ]

    static let greetAction: [WireGolden] = [
        WireGolden(
            caseName: "manualGreetInitiated",
            plain: #"{"manualGreetInitiated":{}}"#,
            wire: #"{"manual_greet_initiated":{}}"#
        ),
        WireGolden(
            caseName: "agreedToMeet",
            plain: #"{"agreedToMeet":{"_0":7}}"#,
            wire: #"{"agreed_to_meet":{"_0":7}}"#
        ),
        WireGolden(
            caseName: "rejectTime",
            plain: #"{"rejectTime":{"_0":7}}"#,
            wire: #"{"reject_time":{"_0":7}}"#
        ),
        WireGolden(
            caseName: "travelTimeToVenue",
            plain: #"{"travelTimeToVenue":{"changedTo":7}}"#,
            wire: #"{"travel_time_to_venue":{"changed_to":7}}"#
        ),
        WireGolden(
            caseName: "travelDistanceToVenue",
            plain: #"{"travelDistanceToVenue":{"changedTo":1.5}}"#,
            wire: #"{"travel_distance_to_venue":{"changed_to":1.5}}"#
        ),
        WireGolden(
            caseName: "dismissGreet",
            plain: #"{"dismissGreet":{}}"#,
            wire: #"{"dismiss_greet":{}}"#
        ),
        WireGolden(
            caseName: "closeApp",
            plain: #"{"closeApp":{}}"#,
            wire: #"{"close_app":{}}"#
        ),
        WireGolden(
            caseName: "tappedRedVoipReject",
            plain: #"{"tappedRedVoipReject":{}}"#,
            wire: #"{"tapped_red_voip_reject":{}}"#
        ),
        WireGolden(
            caseName: "notGettingCloser",
            plain: #"{"notGettingCloser":{"allowance":7,"current":7,"start":7}}"#,
            wire: #"{"not_getting_closer":{"allowance":7,"current":7,"start":7}}"#
        ),
        WireGolden(
            caseName: "callInitiated",
            plain: #"{"callInitiated":{"_0":"ringToVoipEnroute"}}"#,
            wire: #"{"call_initiated":{"_0":"ringToVoipEnroute"}}"#
        ),
        WireGolden(
            caseName: "callAnswered",
            plain: #"{"callAnswered":{"_0":"ringToVoipEnroute"}}"#,
            wire: #"{"call_answered":{"_0":"ringToVoipEnroute"}}"#
        ),
        WireGolden(
            caseName: "callDeclined",
            plain: #"{"callDeclined":{"_0":"ringToVoipEnroute"}}"#,
            wire: #"{"call_declined":{"_0":"ringToVoipEnroute"}}"#
        ),
        WireGolden(
            caseName: "callEnded",
            plain: #"{"callEnded":{"_0":"ringToVoipEnroute"}}"#,
            wire: #"{"call_ended":{"_0":"ringToVoipEnroute"}}"#
        ),
        WireGolden(
            caseName: "viewedGreetScreen",
            plain: #"{"viewedGreetScreen":{}}"#,
            wire: #"{"viewed_greet_screen":{}}"#
        ),
        WireGolden(
            caseName: "confirmedMet",
            plain: #"{"confirmedMet":{}}"#,
            wire: #"{"confirmed_met":{}}"#
        ),
        WireGolden(
            caseName: "rated",
            plain: #"{"rated":{"_0":7,"outOf":7}}"#,
            wire: #"{"rated":{"_0":7,"out_of":7}}"#
        ),
    ]

    static let greetLogEvent: [WireGolden] = [
        WireGolden(
            caseName: "greetAction",
            plain: #"{"greetAction":{"_0":{"manualGreetInitiated":{}}}}"#,
            wire: #"{"greet_action":{"_0":{"manual_greet_initiated":{}}}}"#
        ),
        WireGolden(
            caseName: "pushQueued",
            plain: [
                #"{"pushQueued":{"channel":"apple_push","providerMessageID":"00000000-"#,
                #"0000-0000-0000-0000000000A1"}}"#,
            ].joined(),
            wire: [
                #"{"push_queued":{"channel":"apple_push","provider_message_id":"000000"#,
                #"00-0000-0000-0000-0000000000A1"}}"#,
            ].joined()
        ),
        WireGolden(
            caseName: "pushSent",
            plain: [
                #"{"pushSent":{"channel":"apple_push","providerMessageID":"00000000-00"#,
                #"00-0000-0000-0000000000A1"}}"#,
            ].joined(),
            wire: [
                #"{"push_sent":{"channel":"apple_push","provider_message_id":"00000000"#,
                #"-0000-0000-0000-0000000000A1"}}"#,
            ].joined()
        ),
        WireGolden(
            caseName: "pushProviderAccepted",
            plain: [
                #"{"pushProviderAccepted":{"providerMessageID":"00000000-0000-0000-000"#,
                #"0-0000000000A1"}}"#,
            ].joined(),
            wire: [
                #"{"push_provider_accepted":{"provider_message_id":"00000000-0000-0000"#,
                #"-0000-0000000000A1"}}"#,
            ].joined()
        ),
        WireGolden(
            caseName: "pushFailed",
            plain: #"{"pushFailed":{"channel":"apple_push"}}"#,
            wire: #"{"push_failed":{"channel":"apple_push"}}"#
        ),
        WireGolden(
            caseName: "webSocketSent",
            plain: #"{"webSocketSent":{}}"#,
            wire: #"{"web_socket_sent":{}}"#
        ),
        WireGolden(
            caseName: "webSocketFailed",
            plain: #"{"webSocketFailed":{}}"#,
            wire: #"{"web_socket_failed":{}}"#
        ),
        WireGolden(
            caseName: "deliveryConfirmed",
            plain: [
                #"{"deliveryConfirmed":{"channel":"apple_push","providerMessageID":"00"#,
                #"000000-0000-0000-0000-0000000000A1"}}"#,
            ].joined(),
            wire: [
                #"{"delivery_confirmed":{"channel":"apple_push","provider_message_id":"#,
                #""00000000-0000-0000-0000-0000000000A1"}}"#,
            ].joined()
        ),
        WireGolden(
            caseName: "fallbackTriggered",
            plain: #"{"fallbackTriggered":{"to":"apple_push"}}"#,
            wire: #"{"fallback_triggered":{"to":"apple_push"}}"#
        ),
        WireGolden(
            caseName: "rateLimited",
            plain: #"{"rateLimited":{}}"#,
            wire: #"{"rate_limited":{}}"#
        ),
        WireGolden(
            caseName: "pushNotifReceived",
            plain: [
                #"{"pushNotifReceived":{"providerMessageID":"00000000-0000-0000-0000-0"#,
                #"000000000A1"}}"#,
            ].joined(),
            wire: [
                #"{"push_notif_received":{"provider_message_id":"00000000-0000-0000-00"#,
                #"00-0000000000A1"}}"#,
            ].joined()
        ),
        WireGolden(
            caseName: "voipReceived",
            plain: [
                #"{"voipReceived":{"providerMessageID":"00000000-0000-0000-0000-000000"#,
                #"0000A1"}}"#,
            ].joined(),
            wire: [
                #"{"voip_received":{"provider_message_id":"00000000-0000-0000-0000-000"#,
                #"0000000A1"}}"#,
            ].joined()
        ),
        WireGolden(
            caseName: "rejectedViaAnotherCall",
            plain: #"{"rejectedViaAnotherCall":{}}"#,
            wire: #"{"rejected_via_another_call":{}}"#
        ),
        WireGolden(
            caseName: "userViewed",
            plain: #"{"userViewed":{}}"#,
            wire: #"{"user_viewed":{}}"#
        ),
        WireGolden(
            caseName: "greetCreated",
            plain: #"{"greetCreated":{}}"#,
            wire: #"{"greet_created":{}}"#
        ),
        WireGolden(
            caseName: "greetExpired",
            plain: #"{"greetExpired":{}}"#,
            wire: #"{"greet_expired":{}}"#
        ),
        WireGolden(
            caseName: "settingsUpdated",
            plain: #"{"settingsUpdated":{}}"#,
            wire: #"{"settings_updated":{}}"#
        ),
        WireGolden(
            caseName: "serverFound",
            plain: #"{"serverFound":{"error":"gl28"}}"#,
            wire: #"{"server_found":{"error":"gl28"}}"#
        ),
        WireGolden(
            caseName: "clientFound",
            plain: #"{"clientFound":{"error":"gl28"}}"#,
            wire: #"{"client_found":{"error":"gl28"}}"#
        ),
    ]

    static let greetedClientStatus: [WireGolden] = [
        WireGolden(
            caseName: "confirmedMet",
            plain: #"{"confirmedMet":{}}"#,
            wire: #"{"confirmed_met":{}}"#
        ),
        WireGolden(
            caseName: "exceededRange",
            plain: #"{"exceededRange":{}}"#,
            wire: #"{"exceeded_range":{}}"#
        ),
        WireGolden(
            caseName: "rejectedOther",
            plain: #"{"rejectedOther":{}}"#,
            wire: #"{"rejected_other":{}}"#
        ),
        WireGolden(
            caseName: "onGoing",
            plain: #"{"onGoing":{}}"#,
            wire: #"{"on_going":{}}"#
        ),
        WireGolden(
            caseName: "connectionLost",
            plain: #"{"connectionLost":{}}"#,
            wire: #"{"connection_lost":{}}"#
        ),
    ]

    static let hideOption: [WireGolden] = [
        WireGolden(
            caseName: "automatic",
            plain: #"{"automatic":{}}"#,
            wire: #"{"automatic":{}}"#
        ),
        WireGolden(
            caseName: "manual",
            plain: #"{"manual":{}}"#,
            wire: #"{"manual":{}}"#
        ),
    ]

    static let initiationMethod: [WireGolden] = [
        WireGolden(
            caseName: "manual",
            plain: #"{"manual":{"userID":"00000000-0000-0000-0000-0000000000A1"}}"#,
            wire: #"{"manual":{"user_id":"00000000-0000-0000-0000-0000000000A1"}}"#
        ),
        WireGolden(
            caseName: "automatic",
            plain: #"{"automatic":{"userID":"00000000-0000-0000-0000-0000000000A1"}}"#,
            wire: #"{"automatic":{"user_id":"00000000-0000-0000-0000-0000000000A1"}}"#
        ),
        WireGolden(
            caseName: "devForced",
            plain: #"{"devForced":{}}"#,
            wire: #"{"dev_forced":{}}"#
        ),
        WireGolden(
            caseName: "unknown",
            plain: #"{"unknown":{}}"#,
            wire: #"{"unknown":{}}"#
        ),
    ]

    static let manualGreetResponse: [WireGolden] = [
        WireGolden(
            caseName: "notification",
            plain: [
                #"{"notification":{"_0":{"notification":{"caseType":"silentLocationUpd"#,
                #"ate"},"status":"success"}}}"#,
            ].joined(),
            wire: [
                #"{"notification":{"_0":{"notification":{"case_type":"silentLocationUp"#,
                #"date"},"status":"success"}}}"#,
            ].joined()
        ),
        WireGolden(
            caseName: "otherUserIsInGreet",
            plain: #"{"otherUserIsInGreet":{}}"#,
            wire: #"{"other_user_is_in_greet":{}}"#
        ),
        WireGolden(
            caseName: "thisUserIsInGreet",
            plain: #"{"thisUserIsInGreet":{}}"#,
            wire: #"{"this_user_is_in_greet":{}}"#
        ),
        WireGolden(
            caseName: "thisAndOtherUserAlreadyInSameGreet",
            plain: #"{"thisAndOtherUserAlreadyInSameGreet":{}}"#,
            wire: #"{"this_and_other_user_already_in_same_greet":{}}"#
        ),
        WireGolden(
            caseName: "noNearbyVenuesOpen",
            plain: #"{"noNearbyVenuesOpen":{}}"#,
            wire: #"{"no_nearby_venues_open":{}}"#
        ),
    ]

    static let notificationSubject: [WireGolden] = [
        WireGolden(
            caseName: "question",
            plain: [
                #"{"question":{"id":"00000000-0000-0000-0000-0000000000A1","text":"gl2"#,
                #"8"}}"#,
            ].joined(),
            wire: [
                #"{"question":{"id":"00000000-0000-0000-0000-0000000000A1","text":"gl2"#,
                #"8"}}"#,
            ].joined()
        ),
        WireGolden(
            caseName: "response",
            plain: [
                #"{"response":{"id":"00000000-0000-0000-0000-0000000000A1","text":"gl2"#,
                #"8"}}"#,
            ].joined(),
            wire: [
                #"{"response":{"id":"00000000-0000-0000-0000-0000000000A1","text":"gl2"#,
                #"8"}}"#,
            ].joined()
        ),
        WireGolden(
            caseName: "questionnaire",
            plain: [
                #"{"questionnaire":{"id":"00000000-0000-0000-0000-0000000000A1","title"#,
                #"":"gl28"}}"#,
            ].joined(),
            wire: [
                #"{"questionnaire":{"id":"00000000-0000-0000-0000-0000000000A1","title"#,
                #"":"gl28"}}"#,
            ].joined()
        ),
    ]

    static let questionRequirement: [WireGolden] = [
        WireGolden(
            caseName: "mustHaveAnswered",
            plain: [
                #"{"mustHaveAnswered":{"questionID":"00000000-0000-0000-0000-000000000"#,
                #"0A1"}}"#,
            ].joined(),
            wire: [
                #"{"must_have_answered":{"question_id":"00000000-0000-0000-0000-000000"#,
                #"0000A1"}}"#,
            ].joined()
        ),
        WireGolden(
            caseName: "mustNotHaveChosen",
            plain: [
                #"{"mustNotHaveChosen":{"questionID":"00000000-0000-0000-0000-00000000"#,
                #"00A1","responseIDs":["00000000-0000-0000-0000-0000000000A1"]}}"#,
            ].joined(),
            wire: [
                #"{"must_not_have_chosen":{"question_id":"00000000-0000-0000-0000-0000"#,
                #"000000A1","response_i_ds":["00000000-0000-0000-0000-0000000000A1"]}}"#,
            ].joined()
        ),
        WireGolden(
            caseName: "mustHaveChosenOneOf",
            plain: [
                #"{"mustHaveChosenOneOf":{"questionID":"00000000-0000-0000-0000-000000"#,
                #"0000A1","responseIDs":["00000000-0000-0000-0000-0000000000A1"]}}"#,
            ].joined(),
            wire: [
                #"{"must_have_chosen_one_of":{"question_id":"00000000-0000-0000-0000-0"#,
                #"000000000A1","response_i_ds":["00000000-0000-0000-0000-0000000000A1""#,
                #"]}}"#,
            ].joined()
        ),
    ]

    static let questionnaireCreator: [WireGolden] = [
        WireGolden(
            caseName: "you",
            plain: #"{"you":{}}"#,
            wire: #"{"you":{}}"#
        ),
        WireGolden(
            caseName: "member",
            plain: [
                #"{"member":{"id":"00000000-0000-0000-0000-0000000000A1","name":"gl28""#,
                #"}}"#,
            ].joined(),
            wire: [
                #"{"member":{"id":"00000000-0000-0000-0000-0000000000A1","name":"gl28""#,
                #"}}"#,
            ].joined()
        ),
        WireGolden(
            caseName: "anonymous",
            plain: #"{"anonymous":{}}"#,
            wire: #"{"anonymous":{}}"#
        ),
    ]

    static let relationUpdate: [WireGolden] = [
        WireGolden(
            caseName: "automatic",
            plain: #"{"automatic":{"_0":"Daily"}}"#,
            wire: #"{"automatic":{"_0":"Daily"}}"#
        ),
        WireGolden(
            caseName: "manual",
            plain: #"{"manual":{"_0":"Daily"}}"#,
            wire: #"{"manual":{"_0":"Daily"}}"#
        ),
        WireGolden(
            caseName: "blocked",
            plain: #"{"blocked":{"_0":true}}"#,
            wire: #"{"blocked":{"_0":true}}"#
        ),
    ]

    static let requirement: [WireGolden] = [
        WireGolden(
            caseName: "birthday",
            plain: #"{"birthday":{}}"#,
            wire: #"{"birthday":{}}"#
        ),
        WireGolden(
            caseName: "location",
            plain: #"{"location":{"_0":{"shouldUpgradeToAlways":{}}}}"#,
            wire: #"{"location":{"_0":{"should_upgrade_to_always":{}}}}"#
        ),
        WireGolden(
            caseName: "profilePic",
            plain: #"{"profilePic":{}}"#,
            wire: #"{"profile_pic":{}}"#
        ),
        WireGolden(
            caseName: "pushNotification",
            plain: #"{"pushNotification":{"_0":{"regular":{}}}}"#,
            wire: #"{"push_notification":{"_0":{"regular":{}}}}"#
        ),
        WireGolden(
            caseName: "callKitConsent",
            plain: #"{"callKitConsent":{}}"#,
            wire: #"{"call_kit_consent":{}}"#
        ),
    ]

    static let socketPayload: [WireGolden] = [
        WireGolden(
            caseName: "greetUpdate",
            plain: #"{"greetUpdate":{"_0":{"caseType":"silentLocationUpdate"}}}"#,
            wire: #"{"greet_update":{"_0":{"case_type":"silentLocationUpdate"}}}"#
        ),
        WireGolden(
            caseName: "greetEvent",
            plain: [
                #"{"greetEvent":{"_0":{"action":{"manualGreetInitiated":{}},"actorUser"#,
                #"ID":"00000000-0000-0000-0000-0000000000A1","eventID":"00000000-0000-"#,
                #"0000-0000-0000000000A1","greetID":"00000000-0000-0000-0000-000000000"#,
                #"0A1","serverDate":812692800.1229999,"serverSequenceNumber":7}}}"#,
            ].joined(),
            wire: [
                #"{"greet_event":{"_0":{"action":{"manual_greet_initiated":{}},"actor_"#,
                #"user_id":"00000000-0000-0000-0000-0000000000A1","event_id":"00000000"#,
                #"-0000-0000-0000-0000000000A1","greet_id":"00000000-0000-0000-0000-00"#,
                #"00000000A1","server_date":"2026-10-03T04:00:00.123Z","server_sequenc"#,
                #"e_number":7}}}"#,
            ].joined()
        ),
        WireGolden(
            caseName: "nearbyUserUpdate",
            plain: #"{"nearbyUserUpdate":{}}"#,
            wire: #"{"nearby_user_update":{}}"#
        ),
        WireGolden(
            caseName: "pong",
            plain: #"{"pong":{}}"#,
            wire: #"{"pong":{}}"#
        ),
        WireGolden(
            caseName: "voipSignal",
            plain: [
                #"{"voipSignal":{"_0":{"callType":"ringToVoipEnroute","greetID":"00000"#,
                #"000-0000-0000-0000-0000000000A1","signal":{"caseType":"iceCandidate""#,
                #","sdp":"gl28","sdpMLineIndex":7,"sdpMid":"0"}}}}"#,
            ].joined(),
            wire: [
                #"{"voip_signal":{"_0":{"call_type":"ringToVoipEnroute","greet_id":"00"#,
                #"000000-0000-0000-0000-0000000000A1","signal":{"case_type":"iceCandid"#,
                #"ate","sdp":"gl28","sdp_m_line_index":7,"sdp_mid":"0"}}}}"#,
            ].joined()
        ),
        WireGolden(
            caseName: "nearbyStateUpdate",
            plain: [
                #"{"nearbyStateUpdate":{"_0":{"interaction":{"availability":"available"#,
                #"","distanceMeters":1.5,"frozenByViewer":true,"frozenUntil":812692800"#,
                #".1229999,"reservationQueueLength":7,"viewerReservationPosition":7},""#,
                #"observedAt":812692800.1229999,"userID":"00000000-0000-0000-0000-0000"#,
                #"000000A1"}}}"#,
            ].joined(),
            wire: [
                #"{"nearby_state_update":{"_0":{"interaction":{"availability":"availab"#,
                #"le","distance_meters":1.5,"frozen_by_viewer":true,"frozen_until":"20"#,
                #"26-10-03T04:00:00.123Z","reservation_queue_length":7,"viewer_reserva"#,
                #"tion_position":7},"observed_at":"2026-10-03T04:00:00.123Z","user_id""#,
                #":"00000000-0000-0000-0000-0000000000A1"}}}"#,
            ].joined()
        ),
        WireGolden(
            caseName: "reservationMatured",
            plain: [
                #"{"reservationMatured":{"_0":{"otherUserID":"00000000-0000-0000-0000-"#,
                #"0000000000A1","otherUserName":"gl28","recipientPlacedTheReservation""#,
                #":true}}}"#,
            ].joined(),
            wire: [
                #"{"reservation_matured":{"_0":{"other_user_id":"00000000-0000-0000-00"#,
                #"00-0000000000A1","other_user_name":"gl28","recipient_placed_the_rese"#,
                #"rvation":true}}}"#,
            ].joined()
        ),
    ]

    static let subscriptionTarget: [WireGolden] = [
        WireGolden(
            caseName: "questionnaire",
            plain: #"{"questionnaire":{"_0":"00000000-0000-0000-0000-0000000000A1"}}"#,
            wire: #"{"questionnaire":{"_0":"00000000-0000-0000-0000-0000000000A1"}}"#
        ),
        WireGolden(
            caseName: "member",
            plain: #"{"member":{"_0":"00000000-0000-0000-0000-0000000000A1"}}"#,
            wire: #"{"member":{"_0":"00000000-0000-0000-0000-0000000000A1"}}"#
        ),
    ]

    static let timingUpdate: [WireGolden] = [
        WireGolden(
            caseName: "agreed",
            plain: #"{"agreed":{"_0":7}}"#,
            wire: #"{"agreed":{"_0":7}}"#
        ),
        WireGolden(
            caseName: "rejected",
            plain: #"{"rejected":{"_0":7}}"#,
            wire: #"{"rejected":{"_0":7}}"#
        ),
    ]

    static let travelUpdate: [WireGolden] = [
        WireGolden(
            caseName: "percentTravelled",
            plain: #"{"percentTravelled":{"_0":1.5}}"#,
            wire: #"{"percent_travelled":{"_0":1.5}}"#
        ),
        WireGolden(
            caseName: "exceededRange",
            plain: #"{"exceededRange":{}}"#,
            wire: #"{"exceeded_range":{}}"#
        ),
    ]

    static let viewSetting: [WireGolden] = [
        WireGolden(
            caseName: "inGreet",
            plain: #"{"inGreet":{}}"#,
            wire: #"{"in_greet":{}}"#
        ),
        WireGolden(
            caseName: "inGreetConfirmedMet",
            plain: #"{"inGreetConfirmedMet":{"_0":"theyConfirmed"}}"#,
            wire: #"{"in_greet_confirmed_met":{"_0":"theyConfirmed"}}"#
        ),
        WireGolden(
            caseName: "otherAskedIfCanMeetLater",
            plain: #"{"otherAskedIfCanMeetLater":{"_0":7}}"#,
            wire: #"{"other_asked_if_can_meet_later":{"_0":7}}"#
        ),
        WireGolden(
            caseName: "rejected",
            plain: #"{"rejected":{}}"#,
            wire: #"{"rejected":{}}"#
        ),
        WireGolden(
            caseName: "start",
            plain: #"{"start":{}}"#,
            wire: #"{"start":{}}"#
        ),
        WireGolden(
            caseName: "thisUserAgreed",
            plain: #"{"thisUserAgreed":{}}"#,
            wire: #"{"this_user_agreed":{}}"#
        ),
    ]

    static let requirementLocation: [WireGolden] = [
        WireGolden(
            caseName: "regular",
            plain: #"{"regular":{}}"#,
            wire: #"{"regular":{}}"#
        ),
        WireGolden(
            caseName: "requiresDeeplinkToSettings",
            plain: #"{"requiresDeeplinkToSettings":{}}"#,
            wire: #"{"requires_deeplink_to_settings":{}}"#
        ),
        WireGolden(
            caseName: "shouldUpgradeToAlways",
            plain: #"{"shouldUpgradeToAlways":{}}"#,
            wire: #"{"should_upgrade_to_always":{}}"#
        ),
    ]

    static let requirementPushNotification: [WireGolden] = [
        WireGolden(
            caseName: "requiresDeeplinkToSettings",
            plain: #"{"requiresDeeplinkToSettings":{}}"#,
            wire: #"{"requires_deeplink_to_settings":{}}"#
        ),
        WireGolden(
            caseName: "regular",
            plain: #"{"regular":{}}"#,
            wire: #"{"regular":{}}"#
        ),
    ]

    static let greetNotification: [WireGolden] = [
        WireGolden(
            caseName: "getRating",
            plain: [
                #"{"associatedValue":{"greetID":"00000000-0000-0000-0000-0000000000B1""#,
                #","name":"Avery","notificationKey":"weClosedTheGreet","otherUserID":""#,
                #"00000000-0000-0000-0000-0000000000B2","profileURL":"https:\/\/exampl"#,
                #"e.invalid\/p.png","timeMet":"7:30 PM"},"caseType":"getRating"}"#,
            ].joined(),
            wire: [
                #"{"associated_value":{"greet_id":"00000000-0000-0000-0000-0000000000B"#,
                #"1","name":"Avery","notification_key":"weClosedTheGreet","other_user_"#,
                #"id":"00000000-0000-0000-0000-0000000000B2","profile_url":"https:\/\/"#,
                #"example.invalid\/p.png","time_met":"7:30 PM"},"case_type":"getRating"#,
                #""}"#,
            ].joined()
        ),
        WireGolden(
            caseName: "greet",
            plain: [
                #"{"associatedValue":{"compatitibility":{},"events":[],"greetID":"0000"#,
                #"0000-0000-0000-0000-0000000000C4","initiationMethod":{"manual":{"use"#,
                #"rID":"00000000-0000-0000-0000-0000000000C1"}},"matchMakingMethodVers"#,
                #"ion":1,"method":"wave","minutesAway":10,"openers":[],"otherMinutesAw"#,
                #"ay":15,"otherUser":{"hasGrantedCallKitConsent":false,"id":"00000000-"#,
                #"0000-0000-0000-0000000000C2","imageMetaData":{"assessment":{"entries"#,
                #"":[{"aiConfidence":0.5,"explanation":"x","flag":"spam","source":"man"#,
                #"ualOtherUser"}]},"format":"jpeg","height":20,"id":"00000000-0000-000"#,
                #"0-0000-0000000000C3","width":20},"interaction":{"availability":"avai"#,
                #"lable","frozenByViewer":false,"reservationQueueLength":0},"name":"Av"#,
                #"ery","profileImage":"profile.jpg","verified":true},"participantUserI"#,
                #"Ds":["00000000-0000-0000-0000-0000000000C1","00000000-0000-0000-0000"#,
                #"-0000000000C2"],"thisUserID":"00000000-0000-0000-0000-0000000000C1","#,
                #""travelMethod":"bike","venue":{"address":"1 Main St","latitude":37,""#,
                #"longitude":-122,"name":"Cafe","url":"https:\/\/example.com"}},"caseT"#,
                #"ype":"greet"}"#,
            ].joined(),
            wire: [
                #"{"associated_value":{"compatitibility":{},"events":[],"greet_id":"00"#,
                #"000000-0000-0000-0000-0000000000C4","initiation_method":{"manual":{""#,
                #"user_id":"00000000-0000-0000-0000-0000000000C1"}},"match_making_meth"#,
                #"od_version":1,"method":"wave","minutes_away":10,"openers":[],"other_"#,
                #"minutes_away":15,"other_user":{"has_granted_call_kit_consent":false,"#,
                #""id":"00000000-0000-0000-0000-0000000000C2","image_meta_data":{"asse"#,
                #"ssment":{"entries":[{"ai_confidence":0.5,"explanation":"x","flag":"s"#,
                #"pam","source":"manualOtherUser"}]},"format":"jpeg","height":20,"id":"#,
                #""00000000-0000-0000-0000-0000000000C3","width":20},"interaction":{"a"#,
                #"vailability":"available","frozen_by_viewer":false,"reservation_queue"#,
                #"_length":0},"name":"Avery","profile_image":"profile.jpg","verified":"#,
                #"true},"participant_user_i_ds":["00000000-0000-0000-0000-0000000000C1"#,
                #"","00000000-0000-0000-0000-0000000000C2"],"this_user_id":"00000000-0"#,
                #"000-0000-0000-0000000000C1","travel_method":"bike","venue":{"address"#,
                #"":"1 Main St","latitude":37,"longitude":-122,"name":"Cafe","url":"ht"#,
                #"tps:\/\/example.com"}},"case_type":"greet"}"#,
            ].joined()
        ),
        WireGolden(
            caseName: "silentLocationUpdate",
            plain: #"{"caseType":"silentLocationUpdate"}"#,
            wire: #"{"case_type":"silentLocationUpdate"}"#
        ),
    ]

    static let voipSignal: [WireGolden] = [
        WireGolden(
            caseName: "offer",
            plain: #"{"caseType":"offer","sdp":"v=0 offer"}"#,
            wire: #"{"case_type":"offer","sdp":"v=0 offer"}"#
        ),
        WireGolden(
            caseName: "answer",
            plain: #"{"caseType":"answer","sdp":"v=0 answer"}"#,
            wire: #"{"case_type":"answer","sdp":"v=0 answer"}"#
        ),
        WireGolden(
            caseName: "iceCandidate",
            plain: [
                #"{"caseType":"iceCandidate","sdp":"candidate:1","sdpMLineIndex":2,"sd"#,
                #"pMid":"0"}"#,
            ].joined(),
            wire: [
                #"{"case_type":"iceCandidate","sdp":"candidate:1","sdp_m_line_index":2"#,
                #","sdp_mid":"0"}"#,
            ].joined()
        ),
    ]
}
