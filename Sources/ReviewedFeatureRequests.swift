//
//  ReviewedFeatureRequests.swift
//  AkinFrontBackModels
//
//  The contracts for the four reviewed features: the unbounded context list,
//  following, questionnaire toggles, and want to meet.
//
//  WHY THIS FILE EXISTS. GOAL_LOOP31 first shipped these eleven endpoints as
//  stringly typed Vapor routes, `routes.get("api", "user", ":id", "contexts",
//  "catalog")`, with the client holding a hand written copy of each path. That
//  compiles on both sides and 404s in front of a member the first time a path
//  is reworded, because nothing connects the two spellings. Here there is one
//  spelling per endpoint and it is a Swift identifier: the path IS the static
//  property's own name, taken from `#function`, so renaming it moves client and
//  server together or neither compiles.
//
//  The caller is NOT a path parameter. Every one of these is authenticated, and
//  the server reads the member from the verified token with
//  `try await request.verifiedUser()`, the same way `Handler.myReservations`
//  does. A member id in the path was a second source of truth for who is
//  asking, and the old routes had to defend it with `requireCaller`.
//

import Foundation
import StrongContractClient

// MARK: - Contexts

/// Every context in the catalog, ordered by popularity.
public typealias ContextCatalogRequest = Request<Empty, [ContextCatalogEntry]>

extension ContextCatalogRequest {

    public static var contextCatalog: Self {
        .init(method: .post)
    }
}

/// The caller's own contexts, DERIVED from the questions they answered.
public typealias MyContextsRequest = Request<Empty, [MemberContextEntry]>

extension MyContextsRequest {

    public static var myContexts: Self {
        .init(method: .post)
    }
}

/// What a member types when they create a context.
public struct CreateMemberContextPayload: Codable, Hashable, Equatable, Sendable {

    /// The display name as typed. Normalisation and the deduplicating join both
    /// happen on the server, which is where uniqueness is enforced.
    public let name: String

    public init(name: String) {
        self.name = name
    }
}

/// Create a context, or join the existing one it normalises to.
///
/// Named `createMemberContext` rather than `createContext` on purpose: a
/// company created context and a member created one are different acts, and
/// `ApiController` already serves an older create route. Two endpoints whose
/// paths collide would be resolved by registration order, silently.
public typealias CreateMemberContextRequest = Request<CreateMemberContextPayload, ContextCatalogEntry>

extension CreateMemberContextRequest {

    public static var createMemberContext: Self {
        .init(method: .post)
    }
}

/// The questions the caller answered inside one context, which is the
/// destination behind a context row and the only route off a context.
public typealias ContextAnsweredQuestionsRequest = Request<UUID, [ContextAnsweredQuestion]>

extension ContextAnsweredQuestionsRequest {

    public static var contextAnsweredQuestions: Self {
        .init(method: .post)
    }
}

/// Turning one context on or off.
public struct ContextParticipationPayload: Codable, Hashable, Equatable, Sendable {

    public let contextID: UUID

    /// `true` to take part in the context, `false` to withdraw from it.
    public let isParticipating: Bool

    public init(contextID: UUID, isParticipating: Bool) {
        self.contextID = contextID
        self.isParticipating = isParticipating
    }
}

public typealias SetContextParticipationRequest = Request<ContextParticipationPayload, MemberContextEntry>

extension SetContextParticipationRequest {

    public static var setContextParticipation: Self {
        .init(method: .post)
    }
}

// MARK: - Want to meet

/// The three single target meet mark calls share one payload and one response,
/// so they share one concrete type and differ only by name, which is also their
/// path. The payload is the target's id; the caller comes from the token.
public typealias MeetMarkRequest = Request<UUID, MeetMarkState>

extension MeetMarkRequest {

    /// Mark privately that the caller wants to meet the target.
    public static var markWantToMeet: Self {
        .init(method: .post)
    }

    /// Withdraw that mark. Inside the concealed window this cancels silently,
    /// with no signal in either direction.
    public static var unmarkWantToMeet: Self {
        .init(method: .post)
    }

    /// What the caller may see about one target. A pending match and no match
    /// are deliberately indistinguishable here, in the body AND in timing.
    public static var meetMarkState: Self {
        .init(method: .post)
    }
}

/// Everyone the caller has marked. Private to the caller.
public typealias MyMeetMarksRequest = Request<Empty, [MeetMarkedMember]>

extension MyMeetMarksRequest {

    public static var myMeetMarks: Self {
        .init(method: .post)
    }
}

/// The mutual marks that have passed their concealed reveal window.
public typealias MyMeetRevealsRequest = Request<Empty, [MutualMeetReveal]>

extension MyMeetRevealsRequest {

    public static var myMeetReveals: Self {
        .init(method: .post)
    }
}

// MARK: - Questionnaires

/// Which questionnaire rows to list.
public struct QuestionnaireRowsPayload: Codable, Hashable, Equatable, Sendable {

    /// Optional on purpose. The preferences screen lists one context's
    /// questionnaires and the browse screen lists everything, so a nil context
    /// means EVERYTHING rather than nothing: the reading that cannot silently
    /// produce an empty screen.
    public let contextID: UUID?

    public init(contextID: UUID? = nil) {
        self.contextID = contextID
    }
}

public typealias QuestionnaireRowsRequest = Request<QuestionnaireRowsPayload, [QuestionnaireRowSummary]>

extension QuestionnaireRowsRequest {

    public static var questionnaireRows: Self {
        .init(method: .post)
    }
}

/// Which questionnaire, in which context. Both ids are needed because a
/// questionnaire can be enabled in one context and disabled in another, which is
/// the whole point of the per context switch.
public struct QuestionnaireContextPayload: Codable, Hashable, Equatable, Sendable {

    public let questionnaireID: UUID
    public let contextID: UUID

    public init(questionnaireID: UUID, contextID: UUID) {
        self.questionnaireID = questionnaireID
        self.contextID = contextID
    }
}

/// Reading the per context switch.
public typealias QuestionnaireContextParticipationRequest = Request<QuestionnaireContextPayload, QuestionnaireContextParticipation>

extension QuestionnaireContextParticipationRequest {

    public static var questionnaireContextParticipation: Self {
        .init(method: .post)
    }
}

/// Setting the per context switch.
public struct SetQuestionnaireContextPayload: Codable, Hashable, Equatable, Sendable {

    public let questionnaireID: UUID
    public let contextID: UUID
    public let isEnabled: Bool

    public init(questionnaireID: UUID, contextID: UUID, isEnabled: Bool) {
        self.questionnaireID = questionnaireID
        self.contextID = contextID
        self.isEnabled = isEnabled
    }
}

public typealias SetQuestionnaireContextParticipationRequest = Request<SetQuestionnaireContextPayload, QuestionnaireContextParticipation>

extension SetQuestionnaireContextParticipationRequest {

    public static var setQuestionnaireContextParticipation: Self {
        .init(method: .post)
    }
}
