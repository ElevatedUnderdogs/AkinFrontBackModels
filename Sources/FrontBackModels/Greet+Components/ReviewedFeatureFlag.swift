//
//  ReviewedFeatureFlag.swift
//  AkinFrontBackModels
//
//  GOAL_LOOP31 items 1.1 and 1.2. The four feature areas GOAL_LOOP29 designed, GOAL_LOOP30
//  revised, and GOAL_LOOP31 built, each behind its own switch.
//

import Foundation

/// Client controlled feature flags for the four reviewed feature areas: contexts, following,
/// questionnaire preferences, and want to meet.
///
/// Shaped after ``CallKitFeatureFlag`` and ``NearbyFeatureFlag`` on purpose. Same idea, same
/// ergonomics: a master switch, one boolean per feature, and an `isEnabled(for:)` that refuses
/// everything while the master switch is down. A second set of ergonomics for the same job is a
/// second thing to learn, and the two that ship already work.
///
/// One difference from its two siblings, and it is deliberate. `NearbyFeatureFlag` ships with its
/// master switch down and every individual flag UP, so turning the master on turns the whole
/// family on at once. Every flag here ships DOWN, including the individual ones, because these
/// features are reviewed designs rather than proven behaviour: the operator turns them on one at
/// a time, from the debug view, and judges each on its own.
///
/// How many there are is ``Feature/allCases``, and it is deliberately not written out here: a
/// number in a comment is wrong the day a flag is added, and this file is where that happens.
///
/// What a flag being down means, exactly. Nothing behind it renders, and nothing behind it sends a
/// request. Not hidden, withdrawn. A screen that draws a disabled control, or a view model that
/// fetches and then declines to show the result, has leaked the feature: the member can see that
/// something is there, and the server can see the traffic.
public enum ReviewedFeatureFlag {

    // MARK: - Individual flags

    /// Master switch. While `false` none of the individual features below render and none of
    /// their requests are sent, so the app behaves exactly as it did before GOAL_LOOP31 landed.
    public static var isReviewedFeaturesEnabled: Bool = false

    /// More than two contexts, with the replacement selector above a question.
    ///
    /// The shipping control is a two segment pill, which worked because there were two. With this
    /// off the pill is drawn unchanged; with it on the selector handles any number.
    public static var isUnboundedContextsEnabled: Bool = false

    /// A member may create a context, and the global catalog is searchable.
    public static var isMemberCreatedContextsEnabled: Bool = false

    /// The per context participation switch, which withdraws the member from a context rather
    /// than hiding it from their own screens.
    public static var isPerContextParticipationEnabled: Bool = false

    /// Following a member, so their new questions reach you.
    public static var isFollowingMembersEnabled: Bool = false

    /// Following a questionnaire, so you are told when it gains a question.
    public static var isFollowingQuestionnairesEnabled: Bool = false

    /// Turning a questionnaire on or off per context, which withdraws its answers from
    /// compatibility in the contexts it is off in.
    public static var isQuestionnairePreferencesEnabled: Bool = false

    /// Marking a member you would like to meet, privately, with the double blind mutual reveal.
    public static var isWantToMeetEnabled: Bool = false

    // MARK: - Feature identity

    /// One case per flag, including the master switch.
    ///
    /// The master switch is a case rather than an exception to the set, because the debug view
    /// lists switches and a master switch the view has to special case is a master switch that
    /// gets forgotten when a ninth flag is added.
    public enum Feature: String, CaseIterable, Sendable {

        /// ``isReviewedFeaturesEnabled``.
        case master

        /// ``isUnboundedContextsEnabled``.
        case unboundedContexts

        /// ``isMemberCreatedContextsEnabled``.
        case memberCreatedContexts

        /// ``isPerContextParticipationEnabled``.
        case perContextParticipation

        /// ``isFollowingMembersEnabled``.
        case followingMembers

        /// ``isFollowingQuestionnairesEnabled``.
        case followingQuestionnaires

        /// ``isQuestionnairePreferencesEnabled``.
        case questionnairePreferences

        /// ``isWantToMeetEnabled``.
        case wantToMeet

        /// The name of the static property this case switches, so evidence and a debug row can
        /// name the flag the same way the source does.
        public var propertyName: String {
            switch self {
            case .master: return "isReviewedFeaturesEnabled"
            case .unboundedContexts: return "isUnboundedContextsEnabled"
            case .memberCreatedContexts: return "isMemberCreatedContextsEnabled"
            case .perContextParticipation: return "isPerContextParticipationEnabled"
            case .followingMembers: return "isFollowingMembersEnabled"
            case .followingQuestionnaires: return "isFollowingQuestionnairesEnabled"
            case .questionnairePreferences: return "isQuestionnairePreferencesEnabled"
            case .wantToMeet: return "isWantToMeetEnabled"
            }
        }

        /// A short label for the switch, in the member's words rather than the code's.
        public var title: String {
            switch self {
            case .master: return "All reviewed features"
            case .unboundedContexts: return "More than two contexts"
            case .memberCreatedContexts: return "Members can make contexts"
            case .perContextParticipation: return "Context on and off switch"
            case .followingMembers: return "Follow a member"
            case .followingQuestionnaires: return "Follow a questionnaire"
            case .questionnairePreferences: return "Questionnaire on and off switch"
            case .wantToMeet: return "Want to meet"
            }
        }

        /// What turning the switch on actually does, said the way it would be said to a member.
        ///
        /// A debug row that reads "isWantToMeetEnabled" tells the operator the name of a variable
        /// and nothing about what flipping it will do to the screen in front of them.
        public var memberDescription: String {
            switch self {
            case .master:
                return "The switch above all the others. With it off, none of the features below "
                    + "appear and none of them talk to the server."
            case .unboundedContexts:
                return "Answer a question in any of your contexts, not just two. The selector "
                    + "above a question scrolls, and the count opens a search."
            case .memberCreatedContexts:
                return "Add a context in your own words. Everyone can then find it and join it."
            case .perContextParticipation:
                return "Switch a context off and you leave it: nobody finds you there and its "
                    + "questionnaires leave your feed."
            case .followingMembers:
                return "Follow a member and you hear about the questions they write."
            case .followingQuestionnaires:
                return "Follow a questionnaire and you hear when it gains a question."
            case .questionnairePreferences:
                return "Switch a questionnaire off in a context and your answers to it stop "
                    + "counting there. Switch it back on and they count again."
            case .wantToMeet:
                return "Mark somebody you would like to meet. They are told only if they mark "
                    + "you too."
            }
        }

        /// The feature area the flag belongs to, for grouping the debug rows.
        public var area: String {
            switch self {
            case .master: return "Master"
            case .unboundedContexts, .memberCreatedContexts, .perContextParticipation:
                return "Contexts"
            case .followingMembers, .followingQuestionnaires: return "Following"
            case .questionnairePreferences: return "Questionnaires"
            case .wantToMeet: return "Want to meet"
            }
        }
    }

    // MARK: - Reading and writing

    /// Whether a specific feature is live under the current configuration.
    ///
    /// - Parameter feature: the feature to evaluate.
    /// - Returns: `true` when the feature's own flag is on AND the master switch is on. Asked
    ///   about the master switch itself, the master switch's own value.
    public static func isEnabled(for feature: Feature) -> Bool {
        guard isReviewedFeaturesEnabled else { return false }
        switch feature {
        case .master: return isReviewedFeaturesEnabled
        case .unboundedContexts: return isUnboundedContextsEnabled
        case .memberCreatedContexts: return isMemberCreatedContextsEnabled
        case .perContextParticipation: return isPerContextParticipationEnabled
        case .followingMembers: return isFollowingMembersEnabled
        case .followingQuestionnaires: return isFollowingQuestionnairesEnabled
        case .questionnairePreferences: return isQuestionnairePreferencesEnabled
        case .wantToMeet: return isWantToMeetEnabled
        }
    }

    /// The flag's own stored value, ignoring the master switch.
    ///
    /// This is what a switch in the debug view shows and sets. ``isEnabled(for:)`` is what a
    /// feature's code path asks. Keeping the two apart is what lets the operator leave the
    /// individual switches on, drop the master, and find them all still on when they raise it
    /// again, rather than having to set them a second time.
    public static func storedValue(for feature: Feature) -> Bool {
        switch feature {
        case .master: return isReviewedFeaturesEnabled
        case .unboundedContexts: return isUnboundedContextsEnabled
        case .memberCreatedContexts: return isMemberCreatedContextsEnabled
        case .perContextParticipation: return isPerContextParticipationEnabled
        case .followingMembers: return isFollowingMembersEnabled
        case .followingQuestionnaires: return isFollowingQuestionnairesEnabled
        case .questionnairePreferences: return isQuestionnairePreferencesEnabled
        case .wantToMeet: return isWantToMeetEnabled
        }
    }

    /// Set one flag's stored value.
    ///
    /// - Parameters:
    ///   - value: the new value.
    ///   - feature: which flag to set.
    public static func setStoredValue(_ value: Bool, for feature: Feature) {
        switch feature {
        case .master: isReviewedFeaturesEnabled = value
        case .unboundedContexts: isUnboundedContextsEnabled = value
        case .memberCreatedContexts: isMemberCreatedContextsEnabled = value
        case .perContextParticipation: isPerContextParticipationEnabled = value
        case .followingMembers: isFollowingMembersEnabled = value
        case .followingQuestionnaires: isFollowingQuestionnairesEnabled = value
        case .questionnairePreferences: isQuestionnairePreferencesEnabled = value
        case .wantToMeet: isWantToMeetEnabled = value
        }
    }

    /// Whether anything in this family is live.
    ///
    /// Used where a decision is about the family rather than about one feature, such as whether
    /// the context plumbing needs to run at all.
    public static var isAnyReviewedFeatureEnabled: Bool {
        Feature.allCases.contains { $0 != .master && isEnabled(for: $0) }
    }

    /// The SHIPPING default for every flag, which is `false` for all of them.
    ///
    /// Named rather than written out at each site so that a ninth flag cannot be given a
    /// different default by accident.
    public static let shippingDefault: Bool = false

    /// Restores every flag to its shipping default.
    ///
    /// Exists so a test can undo whatever it toggled without each test knowing the whole set,
    /// which is the same reason ``NearbyFeatureFlag/resetToDefaults()`` exists.
    public static func resetToDefaults() {
        for feature in Feature.allCases {
            setStoredValue(shippingDefault, for: feature)
        }
    }
}
