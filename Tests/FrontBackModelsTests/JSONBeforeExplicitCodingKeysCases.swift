//
//  JSONBeforeExplicitCodingKeysCases.swift
//  FrontBackModelsTests
//
//  The exact JSON every case of the changed enums produced BEFORE `CaseIterable` and the
//  hand-written `CodingKeys` were added. Captured on commit cb51359 (main before they were added)
//  by encoding one value per case with a plain `JSONEncoder` and with `JSONEncoder.akinWire`,
//  both with sorted keys so the text is stable.
//
//  SchemaReadyEnumTests decodes each string with the new code and encodes it again. Getting the
//  same bytes back proves adding them did not change the JSON, in either direction. Do not
//  regenerate these from the current code: that would only prove the code agrees with itself.
//
//  Long strings are split into pieces so no line passes 100 columns. The pieces are joined
//  back into one string with nothing between them.
//

enum JSONBeforeExplicitCodingKeysCases {

    static let automaticGreetDebugAction: [JSONBeforeExplicitCodingKeys] = [
        JSONBeforeExplicitCodingKeys(
            caseName: "expireCooldownNow",
            plain: #"{"expireCooldownNow":{}}"#,
            akinWire: #"{"expire_cooldown_now":{}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "setLastGreet",
            plain: #"{"setLastGreet":{"secondsAgo":1.5}}"#,
            akinWire: #"{"set_last_greet":{"seconds_ago":1.5}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "clearPairHistory",
            plain: #"{"clearPairHistory":{}}"#,
            akinWire: #"{"clear_pair_history":{}}"#
        ),
    ]

    static let automaticGreetSuppression: [JSONBeforeExplicitCodingKeys] = [
        JSONBeforeExplicitCodingKeys(
            caseName: "pairCooldown",
            plain: #"{"pairCooldown":{"until":812692800.1229999}}"#,
            akinWire: #"{"pair_cooldown":{"until":"2026-10-03T04:00:00.123Z"}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "memberCapReached",
            plain: [
                #"{"memberCapReached":{"cap":7,"count":7,"isScanner":true,"until":8126"#,
                #"92800.1229999}}"#,
            ].joined(),
            akinWire: [
                #"{"member_cap_reached":{"cap":7,"count":7,"is_scanner":true,"until":""#,
                #"2026-10-03T04:00:00.123Z"}}"#,
            ].joined()
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "alreadyInAGreet",
            plain: #"{"alreadyInAGreet":{"isScanner":true}}"#,
            akinWire: #"{"already_in_a_greet":{"is_scanner":true}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "pendingGreetUnanswered",
            plain: #"{"pendingGreetUnanswered":{}}"#,
            akinWire: #"{"pending_greet_unanswered":{}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "alreadyMet",
            plain: #"{"alreadyMet":{"until":812692800.1229999}}"#,
            akinWire: #"{"already_met":{"until":"2026-10-03T04:00:00.123Z"}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "busy",
            plain: #"{"busy":{"isScanner":true,"until":812692800.1229999}}"#,
            akinWire: #"{"busy":{"is_scanner":true,"until":"2026-10-03T04:00:00.123Z"}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "automaticGreetsOff",
            plain: #"{"automaticGreetsOff":{"isScanner":true}}"#,
            akinWire: #"{"automatic_greets_off":{"is_scanner":true}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "hiddenFromNearby",
            plain: #"{"hiddenFromNearby":{"isScanner":true}}"#,
            akinWire: #"{"hidden_from_nearby":{"is_scanner":true}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "blocked",
            plain: #"{"blocked":{}}"#,
            akinWire: #"{"blocked":{}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "unreachable",
            plain: #"{"unreachable":{}}"#,
            akinWire: #"{"unreachable":{}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "unverified",
            plain: #"{"unverified":{"isScanner":true}}"#,
            akinWire: #"{"unverified":{"is_scanner":true}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "moderationFlagged",
            plain: #"{"moderationFlagged":{}}"#,
            akinWire: #"{"moderation_flagged":{}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "frozenByAnotherMember",
            plain: #"{"frozenByAnotherMember":{"until":812692800.1229999}}"#,
            akinWire: #"{"frozen_by_another_member":{"until":"2026-10-03T04:00:00.123Z"}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "outsideStatedAvailability",
            plain: #"{"outsideStatedAvailability":{"isScanner":true}}"#,
            akinWire: #"{"outside_stated_availability":{"is_scanner":true}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "noVenueBetweenThem",
            plain: #"{"noVenueBetweenThem":{}}"#,
            akinWire: #"{"no_venue_between_them":{}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "unavailableToYou",
            plain: #"{"unavailableToYou":{}}"#,
            akinWire: #"{"unavailable_to_you":{}}"#
        ),
    ]

    static let greetAction: [JSONBeforeExplicitCodingKeys] = [
        JSONBeforeExplicitCodingKeys(
            caseName: "manualGreetInitiated",
            plain: #"{"manualGreetInitiated":{}}"#,
            akinWire: #"{"manual_greet_initiated":{}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "agreedToMeet",
            plain: #"{"agreedToMeet":{"_0":7}}"#,
            akinWire: #"{"agreed_to_meet":{"_0":7}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "rejectTime",
            plain: #"{"rejectTime":{"_0":7}}"#,
            akinWire: #"{"reject_time":{"_0":7}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "travelTimeToVenue",
            plain: #"{"travelTimeToVenue":{"changedTo":7}}"#,
            akinWire: #"{"travel_time_to_venue":{"changed_to":7}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "travelDistanceToVenue",
            plain: #"{"travelDistanceToVenue":{"changedTo":1.5}}"#,
            akinWire: #"{"travel_distance_to_venue":{"changed_to":1.5}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "dismissGreet",
            plain: #"{"dismissGreet":{}}"#,
            akinWire: #"{"dismiss_greet":{}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "closeApp",
            plain: #"{"closeApp":{}}"#,
            akinWire: #"{"close_app":{}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "tappedRedVoipReject",
            plain: #"{"tappedRedVoipReject":{}}"#,
            akinWire: #"{"tapped_red_voip_reject":{}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "notGettingCloser",
            plain: #"{"notGettingCloser":{"allowance":7,"current":7,"start":7}}"#,
            akinWire: #"{"not_getting_closer":{"allowance":7,"current":7,"start":7}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "callInitiated",
            plain: #"{"callInitiated":{"_0":"ringToVoipEnroute"}}"#,
            akinWire: #"{"call_initiated":{"_0":"ringToVoipEnroute"}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "callAnswered",
            plain: #"{"callAnswered":{"_0":"ringToVoipEnroute"}}"#,
            akinWire: #"{"call_answered":{"_0":"ringToVoipEnroute"}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "callDeclined",
            plain: #"{"callDeclined":{"_0":"ringToVoipEnroute"}}"#,
            akinWire: #"{"call_declined":{"_0":"ringToVoipEnroute"}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "callEnded",
            plain: #"{"callEnded":{"_0":"ringToVoipEnroute"}}"#,
            akinWire: #"{"call_ended":{"_0":"ringToVoipEnroute"}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "viewedGreetScreen",
            plain: #"{"viewedGreetScreen":{}}"#,
            akinWire: #"{"viewed_greet_screen":{}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "confirmedMet",
            plain: #"{"confirmedMet":{}}"#,
            akinWire: #"{"confirmed_met":{}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "rated",
            plain: #"{"rated":{"_0":7,"outOf":7}}"#,
            akinWire: #"{"rated":{"_0":7,"out_of":7}}"#
        ),
    ]

    static let greetLogEvent: [JSONBeforeExplicitCodingKeys] = [
        JSONBeforeExplicitCodingKeys(
            caseName: "greetAction",
            plain: #"{"greetAction":{"_0":{"manualGreetInitiated":{}}}}"#,
            akinWire: #"{"greet_action":{"_0":{"manual_greet_initiated":{}}}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "pushQueued",
            plain: [
                #"{"pushQueued":{"channel":"apple_push","providerMessageID":"00000000-"#,
                #"0000-0000-0000-0000000000A1"}}"#,
            ].joined(),
            akinWire: [
                #"{"push_queued":{"channel":"apple_push","provider_message_id":"000000"#,
                #"00-0000-0000-0000-0000000000A1"}}"#,
            ].joined()
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "pushSent",
            plain: [
                #"{"pushSent":{"channel":"apple_push","providerMessageID":"00000000-00"#,
                #"00-0000-0000-0000000000A1"}}"#,
            ].joined(),
            akinWire: [
                #"{"push_sent":{"channel":"apple_push","provider_message_id":"00000000"#,
                #"-0000-0000-0000-0000000000A1"}}"#,
            ].joined()
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "pushProviderAccepted",
            plain: [
                #"{"pushProviderAccepted":{"providerMessageID":"00000000-0000-0000-000"#,
                #"0-0000000000A1"}}"#,
            ].joined(),
            akinWire: [
                #"{"push_provider_accepted":{"provider_message_id":"00000000-0000-0000"#,
                #"-0000-0000000000A1"}}"#,
            ].joined()
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "pushFailed",
            plain: #"{"pushFailed":{"channel":"apple_push"}}"#,
            akinWire: #"{"push_failed":{"channel":"apple_push"}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "webSocketSent",
            plain: #"{"webSocketSent":{}}"#,
            akinWire: #"{"web_socket_sent":{}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "webSocketFailed",
            plain: #"{"webSocketFailed":{}}"#,
            akinWire: #"{"web_socket_failed":{}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "deliveryConfirmed",
            plain: [
                #"{"deliveryConfirmed":{"channel":"apple_push","providerMessageID":"00"#,
                #"000000-0000-0000-0000-0000000000A1"}}"#,
            ].joined(),
            akinWire: [
                #"{"delivery_confirmed":{"channel":"apple_push","provider_message_id":"#,
                #""00000000-0000-0000-0000-0000000000A1"}}"#,
            ].joined()
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "fallbackTriggered",
            plain: #"{"fallbackTriggered":{"to":"apple_push"}}"#,
            akinWire: #"{"fallback_triggered":{"to":"apple_push"}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "rateLimited",
            plain: #"{"rateLimited":{}}"#,
            akinWire: #"{"rate_limited":{}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "pushNotifReceived",
            plain: [
                #"{"pushNotifReceived":{"providerMessageID":"00000000-0000-0000-0000-0"#,
                #"000000000A1"}}"#,
            ].joined(),
            akinWire: [
                #"{"push_notif_received":{"provider_message_id":"00000000-0000-0000-00"#,
                #"00-0000000000A1"}}"#,
            ].joined()
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "voipReceived",
            plain: [
                #"{"voipReceived":{"providerMessageID":"00000000-0000-0000-0000-000000"#,
                #"0000A1"}}"#,
            ].joined(),
            akinWire: [
                #"{"voip_received":{"provider_message_id":"00000000-0000-0000-0000-000"#,
                #"0000000A1"}}"#,
            ].joined()
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "rejectedViaAnotherCall",
            plain: #"{"rejectedViaAnotherCall":{}}"#,
            akinWire: #"{"rejected_via_another_call":{}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "userViewed",
            plain: #"{"userViewed":{}}"#,
            akinWire: #"{"user_viewed":{}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "greetCreated",
            plain: #"{"greetCreated":{}}"#,
            akinWire: #"{"greet_created":{}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "greetExpired",
            plain: #"{"greetExpired":{}}"#,
            akinWire: #"{"greet_expired":{}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "settingsUpdated",
            plain: #"{"settingsUpdated":{}}"#,
            akinWire: #"{"settings_updated":{}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "serverFound",
            plain: #"{"serverFound":{"error":"gl28"}}"#,
            akinWire: #"{"server_found":{"error":"gl28"}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "clientFound",
            plain: #"{"clientFound":{"error":"gl28"}}"#,
            akinWire: #"{"client_found":{"error":"gl28"}}"#
        ),
    ]

    static let greetedClientStatus: [JSONBeforeExplicitCodingKeys] = [
        JSONBeforeExplicitCodingKeys(
            caseName: "confirmedMet",
            plain: #"{"confirmedMet":{}}"#,
            akinWire: #"{"confirmed_met":{}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "exceededRange",
            plain: #"{"exceededRange":{}}"#,
            akinWire: #"{"exceeded_range":{}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "rejectedOther",
            plain: #"{"rejectedOther":{}}"#,
            akinWire: #"{"rejected_other":{}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "onGoing",
            plain: #"{"onGoing":{}}"#,
            akinWire: #"{"on_going":{}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "connectionLost",
            plain: #"{"connectionLost":{}}"#,
            akinWire: #"{"connection_lost":{}}"#
        ),
    ]

    static let hideOption: [JSONBeforeExplicitCodingKeys] = [
        JSONBeforeExplicitCodingKeys(
            caseName: "automatic",
            plain: #"{"automatic":{}}"#,
            akinWire: #"{"automatic":{}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "manual",
            plain: #"{"manual":{}}"#,
            akinWire: #"{"manual":{}}"#
        ),
    ]

    static let initiationMethod: [JSONBeforeExplicitCodingKeys] = [
        JSONBeforeExplicitCodingKeys(
            caseName: "manual",
            plain: #"{"manual":{"userID":"00000000-0000-0000-0000-0000000000A1"}}"#,
            akinWire: #"{"manual":{"user_id":"00000000-0000-0000-0000-0000000000A1"}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "automatic",
            plain: #"{"automatic":{"userID":"00000000-0000-0000-0000-0000000000A1"}}"#,
            akinWire: #"{"automatic":{"user_id":"00000000-0000-0000-0000-0000000000A1"}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "devForced",
            plain: #"{"devForced":{}}"#,
            akinWire: #"{"dev_forced":{}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "unknown",
            plain: #"{"unknown":{}}"#,
            akinWire: #"{"unknown":{}}"#
        ),
    ]

    static let manualGreetResponse: [JSONBeforeExplicitCodingKeys] = [
        JSONBeforeExplicitCodingKeys(
            caseName: "notification",
            plain: [
                #"{"notification":{"_0":{"notification":{"caseType":"silentLocationUpd"#,
                #"ate"},"status":"success"}}}"#,
            ].joined(),
            akinWire: [
                #"{"notification":{"_0":{"notification":{"case_type":"silentLocationUp"#,
                #"date"},"status":"success"}}}"#,
            ].joined()
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "otherUserIsInGreet",
            plain: #"{"otherUserIsInGreet":{}}"#,
            akinWire: #"{"other_user_is_in_greet":{}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "thisUserIsInGreet",
            plain: #"{"thisUserIsInGreet":{}}"#,
            akinWire: #"{"this_user_is_in_greet":{}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "thisAndOtherUserAlreadyInSameGreet",
            plain: #"{"thisAndOtherUserAlreadyInSameGreet":{}}"#,
            akinWire: #"{"this_and_other_user_already_in_same_greet":{}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "noNearbyVenuesOpen",
            plain: #"{"noNearbyVenuesOpen":{}}"#,
            akinWire: #"{"no_nearby_venues_open":{}}"#
        ),
    ]

    static let notificationSubject: [JSONBeforeExplicitCodingKeys] = [
        JSONBeforeExplicitCodingKeys(
            caseName: "question",
            plain: [
                #"{"question":{"id":"00000000-0000-0000-0000-0000000000A1","text":"gl2"#,
                #"8"}}"#,
            ].joined(),
            akinWire: [
                #"{"question":{"id":"00000000-0000-0000-0000-0000000000A1","text":"gl2"#,
                #"8"}}"#,
            ].joined()
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "response",
            plain: [
                #"{"response":{"id":"00000000-0000-0000-0000-0000000000A1","text":"gl2"#,
                #"8"}}"#,
            ].joined(),
            akinWire: [
                #"{"response":{"id":"00000000-0000-0000-0000-0000000000A1","text":"gl2"#,
                #"8"}}"#,
            ].joined()
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "questionnaire",
            plain: [
                #"{"questionnaire":{"id":"00000000-0000-0000-0000-0000000000A1","title"#,
                #"":"gl28"}}"#,
            ].joined(),
            akinWire: [
                #"{"questionnaire":{"id":"00000000-0000-0000-0000-0000000000A1","title"#,
                #"":"gl28"}}"#,
            ].joined()
        ),
    ]

    static let questionRequirement: [JSONBeforeExplicitCodingKeys] = [
        JSONBeforeExplicitCodingKeys(
            caseName: "mustHaveAnswered",
            plain: [
                #"{"mustHaveAnswered":{"questionID":"00000000-0000-0000-0000-000000000"#,
                #"0A1"}}"#,
            ].joined(),
            akinWire: [
                #"{"must_have_answered":{"question_id":"00000000-0000-0000-0000-000000"#,
                #"0000A1"}}"#,
            ].joined()
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "mustNotHaveChosen",
            plain: [
                #"{"mustNotHaveChosen":{"questionID":"00000000-0000-0000-0000-00000000"#,
                #"00A1","responseIDs":["00000000-0000-0000-0000-0000000000A1"]}}"#,
            ].joined(),
            akinWire: [
                #"{"must_not_have_chosen":{"question_id":"00000000-0000-0000-0000-0000"#,
                #"000000A1","response_i_ds":["00000000-0000-0000-0000-0000000000A1"]}}"#,
            ].joined()
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "mustHaveChosenOneOf",
            plain: [
                #"{"mustHaveChosenOneOf":{"questionID":"00000000-0000-0000-0000-000000"#,
                #"0000A1","responseIDs":["00000000-0000-0000-0000-0000000000A1"]}}"#,
            ].joined(),
            akinWire: [
                #"{"must_have_chosen_one_of":{"question_id":"00000000-0000-0000-0000-0"#,
                #"000000000A1","response_i_ds":["00000000-0000-0000-0000-0000000000A1""#,
                #"]}}"#,
            ].joined()
        ),
    ]

    static let questionnaireCreator: [JSONBeforeExplicitCodingKeys] = [
        JSONBeforeExplicitCodingKeys(
            caseName: "you",
            plain: #"{"you":{}}"#,
            akinWire: #"{"you":{}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "member",
            plain: [
                #"{"member":{"id":"00000000-0000-0000-0000-0000000000A1","name":"gl28""#,
                #"}}"#,
            ].joined(),
            akinWire: [
                #"{"member":{"id":"00000000-0000-0000-0000-0000000000A1","name":"gl28""#,
                #"}}"#,
            ].joined()
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "anonymous",
            plain: #"{"anonymous":{}}"#,
            akinWire: #"{"anonymous":{}}"#
        ),
    ]

    static let relationUpdate: [JSONBeforeExplicitCodingKeys] = [
        JSONBeforeExplicitCodingKeys(
            caseName: "automatic",
            plain: #"{"automatic":{"_0":"Daily"}}"#,
            akinWire: #"{"automatic":{"_0":"Daily"}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "manual",
            plain: #"{"manual":{"_0":"Daily"}}"#,
            akinWire: #"{"manual":{"_0":"Daily"}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "blocked",
            plain: #"{"blocked":{"_0":true}}"#,
            akinWire: #"{"blocked":{"_0":true}}"#
        ),
    ]

    static let requirement: [JSONBeforeExplicitCodingKeys] = [
        JSONBeforeExplicitCodingKeys(
            caseName: "birthday",
            plain: #"{"birthday":{}}"#,
            akinWire: #"{"birthday":{}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "location",
            plain: #"{"location":{"_0":{"shouldUpgradeToAlways":{}}}}"#,
            akinWire: #"{"location":{"_0":{"should_upgrade_to_always":{}}}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "profilePic",
            plain: #"{"profilePic":{}}"#,
            akinWire: #"{"profile_pic":{}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "pushNotification",
            plain: #"{"pushNotification":{"_0":{"regular":{}}}}"#,
            akinWire: #"{"push_notification":{"_0":{"regular":{}}}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "callKitConsent",
            plain: #"{"callKitConsent":{}}"#,
            akinWire: #"{"call_kit_consent":{}}"#
        ),
    ]

    static let socketPayload: [JSONBeforeExplicitCodingKeys] = [
        JSONBeforeExplicitCodingKeys(
            caseName: "greetUpdate",
            plain: #"{"greetUpdate":{"_0":{"caseType":"silentLocationUpdate"}}}"#,
            akinWire: #"{"greet_update":{"_0":{"case_type":"silentLocationUpdate"}}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "greetEvent",
            plain: [
                #"{"greetEvent":{"_0":{"action":{"manualGreetInitiated":{}},"actorUser"#,
                #"ID":"00000000-0000-0000-0000-0000000000A1","eventID":"00000000-0000-"#,
                #"0000-0000-0000000000A1","greetID":"00000000-0000-0000-0000-000000000"#,
                #"0A1","serverDate":812692800.1229999,"serverSequenceNumber":7}}}"#,
            ].joined(),
            akinWire: [
                #"{"greet_event":{"_0":{"action":{"manual_greet_initiated":{}},"actor_"#,
                #"user_id":"00000000-0000-0000-0000-0000000000A1","event_id":"00000000"#,
                #"-0000-0000-0000-0000000000A1","greet_id":"00000000-0000-0000-0000-00"#,
                #"00000000A1","server_date":"2026-10-03T04:00:00.123Z","server_sequenc"#,
                #"e_number":7}}}"#,
            ].joined()
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "nearbyUserUpdate",
            plain: #"{"nearbyUserUpdate":{}}"#,
            akinWire: #"{"nearby_user_update":{}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "pong",
            plain: #"{"pong":{}}"#,
            akinWire: #"{"pong":{}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "voipSignal",
            plain: [
                #"{"voipSignal":{"_0":{"callType":"ringToVoipEnroute","greetID":"00000"#,
                #"000-0000-0000-0000-0000000000A1","signal":{"caseType":"iceCandidate""#,
                #","sdp":"gl28","sdpMLineIndex":7,"sdpMid":"0"}}}}"#,
            ].joined(),
            akinWire: [
                #"{"voip_signal":{"_0":{"call_type":"ringToVoipEnroute","greet_id":"00"#,
                #"000000-0000-0000-0000-0000000000A1","signal":{"case_type":"iceCandid"#,
                #"ate","sdp":"gl28","sdp_m_line_index":7,"sdp_mid":"0"}}}}"#,
            ].joined()
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "nearbyStateUpdate",
            plain: [
                #"{"nearbyStateUpdate":{"_0":{"interaction":{"availability":"available"#,
                #"","distanceMeters":1.5,"frozenByViewer":true,"frozenUntil":812692800"#,
                #".1229999,"reservationQueueLength":7,"viewerReservationPosition":7},""#,
                #"observedAt":812692800.1229999,"userID":"00000000-0000-0000-0000-0000"#,
                #"000000A1"}}}"#,
            ].joined(),
            akinWire: [
                #"{"nearby_state_update":{"_0":{"interaction":{"availability":"availab"#,
                #"le","distance_meters":1.5,"frozen_by_viewer":true,"frozen_until":"20"#,
                #"26-10-03T04:00:00.123Z","reservation_queue_length":7,"viewer_reserva"#,
                #"tion_position":7},"observed_at":"2026-10-03T04:00:00.123Z","user_id""#,
                #":"00000000-0000-0000-0000-0000000000A1"}}}"#,
            ].joined()
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "reservationMatured",
            plain: [
                #"{"reservationMatured":{"_0":{"otherUserID":"00000000-0000-0000-0000-"#,
                #"0000000000A1","otherUserName":"gl28","recipientPlacedTheReservation""#,
                #":true}}}"#,
            ].joined(),
            akinWire: [
                #"{"reservation_matured":{"_0":{"other_user_id":"00000000-0000-0000-00"#,
                #"00-0000000000A1","other_user_name":"gl28","recipient_placed_the_rese"#,
                #"rvation":true}}}"#,
            ].joined()
        ),
    ]

    static let subscriptionTarget: [JSONBeforeExplicitCodingKeys] = [
        JSONBeforeExplicitCodingKeys(
            caseName: "questionnaire",
            plain: #"{"questionnaire":{"_0":"00000000-0000-0000-0000-0000000000A1"}}"#,
            akinWire: #"{"questionnaire":{"_0":"00000000-0000-0000-0000-0000000000A1"}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "member",
            plain: #"{"member":{"_0":"00000000-0000-0000-0000-0000000000A1"}}"#,
            akinWire: #"{"member":{"_0":"00000000-0000-0000-0000-0000000000A1"}}"#
        ),
    ]

    static let timingUpdate: [JSONBeforeExplicitCodingKeys] = [
        JSONBeforeExplicitCodingKeys(
            caseName: "agreed",
            plain: #"{"agreed":{"_0":7}}"#,
            akinWire: #"{"agreed":{"_0":7}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "rejected",
            plain: #"{"rejected":{"_0":7}}"#,
            akinWire: #"{"rejected":{"_0":7}}"#
        ),
    ]

    static let travelUpdate: [JSONBeforeExplicitCodingKeys] = [
        JSONBeforeExplicitCodingKeys(
            caseName: "percentTravelled",
            plain: #"{"percentTravelled":{"_0":1.5}}"#,
            akinWire: #"{"percent_travelled":{"_0":1.5}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "exceededRange",
            plain: #"{"exceededRange":{}}"#,
            akinWire: #"{"exceeded_range":{}}"#
        ),
    ]

    static let viewSetting: [JSONBeforeExplicitCodingKeys] = [
        JSONBeforeExplicitCodingKeys(
            caseName: "inGreet",
            plain: #"{"inGreet":{}}"#,
            akinWire: #"{"in_greet":{}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "inGreetConfirmedMet",
            plain: #"{"inGreetConfirmedMet":{"_0":"theyConfirmed"}}"#,
            akinWire: #"{"in_greet_confirmed_met":{"_0":"theyConfirmed"}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "otherAskedIfCanMeetLater",
            plain: #"{"otherAskedIfCanMeetLater":{"_0":7}}"#,
            akinWire: #"{"other_asked_if_can_meet_later":{"_0":7}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "rejected",
            plain: #"{"rejected":{}}"#,
            akinWire: #"{"rejected":{}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "start",
            plain: #"{"start":{}}"#,
            akinWire: #"{"start":{}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "thisUserAgreed",
            plain: #"{"thisUserAgreed":{}}"#,
            akinWire: #"{"this_user_agreed":{}}"#
        ),
    ]

    static let requirementLocation: [JSONBeforeExplicitCodingKeys] = [
        JSONBeforeExplicitCodingKeys(
            caseName: "regular",
            plain: #"{"regular":{}}"#,
            akinWire: #"{"regular":{}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "requiresDeeplinkToSettings",
            plain: #"{"requiresDeeplinkToSettings":{}}"#,
            akinWire: #"{"requires_deeplink_to_settings":{}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "shouldUpgradeToAlways",
            plain: #"{"shouldUpgradeToAlways":{}}"#,
            akinWire: #"{"should_upgrade_to_always":{}}"#
        ),
    ]

    static let requirementPushNotification: [JSONBeforeExplicitCodingKeys] = [
        JSONBeforeExplicitCodingKeys(
            caseName: "requiresDeeplinkToSettings",
            plain: #"{"requiresDeeplinkToSettings":{}}"#,
            akinWire: #"{"requires_deeplink_to_settings":{}}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "regular",
            plain: #"{"regular":{}}"#,
            akinWire: #"{"regular":{}}"#
        ),
    ]

    static let greetNotification: [JSONBeforeExplicitCodingKeys] = [
        JSONBeforeExplicitCodingKeys(
            caseName: "getRating",
            plain: [
                #"{"associatedValue":{"greetID":"00000000-0000-0000-0000-0000000000B1""#,
                #","name":"Avery","notificationKey":"weClosedTheGreet","otherUserID":""#,
                #"00000000-0000-0000-0000-0000000000B2","profileURL":"https:\/\/exampl"#,
                #"e.invalid\/p.png","timeMet":"7:30 PM"},"caseType":"getRating"}"#,
            ].joined(),
            akinWire: [
                #"{"associated_value":{"greet_id":"00000000-0000-0000-0000-0000000000B"#,
                #"1","name":"Avery","notification_key":"weClosedTheGreet","other_user_"#,
                #"id":"00000000-0000-0000-0000-0000000000B2","profile_url":"https:\/\/"#,
                #"example.invalid\/p.png","time_met":"7:30 PM"},"case_type":"getRating"#,
                #""}"#,
            ].joined()
        ),
        JSONBeforeExplicitCodingKeys(
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
            akinWire: [
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
        JSONBeforeExplicitCodingKeys(
            caseName: "silentLocationUpdate",
            plain: #"{"caseType":"silentLocationUpdate"}"#,
            akinWire: #"{"case_type":"silentLocationUpdate"}"#
        ),
    ]

    static let voipSignal: [JSONBeforeExplicitCodingKeys] = [
        JSONBeforeExplicitCodingKeys(
            caseName: "offer",
            plain: #"{"caseType":"offer","sdp":"v=0 offer"}"#,
            akinWire: #"{"case_type":"offer","sdp":"v=0 offer"}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "answer",
            plain: #"{"caseType":"answer","sdp":"v=0 answer"}"#,
            akinWire: #"{"case_type":"answer","sdp":"v=0 answer"}"#
        ),
        JSONBeforeExplicitCodingKeys(
            caseName: "iceCandidate",
            plain: [
                #"{"caseType":"iceCandidate","sdp":"candidate:1","sdpMLineIndex":2,"sd"#,
                #"pMid":"0"}"#,
            ].joined(),
            akinWire: [
                #"{"case_type":"iceCandidate","sdp":"candidate:1","sdp_m_line_index":2"#,
                #","sdp_mid":"0"}"#,
            ].joined()
        ),
    ]
}
