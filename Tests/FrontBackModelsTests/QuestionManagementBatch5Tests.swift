import XCTest
import Foundation
@testable import AkinFrontBackModels

fileprivate func batch5RoundTrip<T: Codable>(_ value: T) throws -> T {
    let data = try JSONEncoder().encode(value)
    return try JSONDecoder().decode(T.self, from: data)
}

fileprivate func batch5Context(_ id: UUID = UUID(), case caseValue: Context.Case = .romance) -> Context {
    Context(id: id, case: caseValue)
}

fileprivate func batch5Response(
    text: String = "hello",
    timeStamp: Date = Date(timeIntervalSince1970: 0),
    id: UUID = UUID(),
    creator: UUID = UUID(),
    questionID: UUID = UUID(),
    myChoice: [ContextRawValue: Question.Response.Selections.MyTheir.Choice] = [:],
    theirChoices: [ContextRawValue: Question.Response.Selections.MyTheir.Choice] = [:],
    popularity: [ContextRawValue: PopularityScore] = [:],
    originalContextID: UUID = UUID(),
    assessment: ModerationAssessment = ModerationAssessment(entries: [])
) -> Question.Response {
    Question.Response(
        text: text,
        timeStamp: timeStamp,
        id: id,
        creator: creator,
        questionID: questionID,
        myChoice: myChoice,
        theirChoices: theirChoices,
        popularity: popularity,
        originalContextID: originalContextID,
        assessment: assessment
    )
}

fileprivate let batch5DisplayNames: [ReportFlag: String] = [
    .childSexualAbuseMaterial: "Child Sexual Abuse Material",
    .promotesTerrorism: "Promotes Terrorism",
    .threatensPhysicalHarm: "Threatens Physical Harm",
    .hateSpeech: "Hate Speech",
    .graphicViolence: "Graphic Violence",
    .explicitSexualContent: "Explicit Sexual Content",
    .sexual: "Sexual Content",
    .selfHarmPromotion: "Self-Harm Promotion",
    .harmfulMisinformation: "Harmful Misinformation",
    .spam: "Spam or Misleading",
    .copyrightViolation: "Copyright Violation",
    .personalAttack: "Personal Attack",
    .unwantedContact: "Unwanted Contact",
    .under18: "Under 18",
    .profanity: "Profanity",
    .vulgarity: "Vulgarity",
    .nudity: "Nudity",
    .misunderstandingAssignment: "Misunderstanding Assignment",
    .misstyping: "Misstyping",
    .missSpelling: "Misspelling",
]

fileprivate let batch5Ints: [ReportFlag: Int] = [
    .childSexualAbuseMaterial: 0,
    .promotesTerrorism: 1,
    .threatensPhysicalHarm: 2,
    .explicitSexualContent: 3,
    .nudity: 4,
    .graphicViolence: 5,
    .hateSpeech: 6,
    .selfHarmPromotion: 7,
    .harmfulMisinformation: 8,
    .copyrightViolation: 9,
    .spam: 10,
    .personalAttack: 11,
    .unwantedContact: 12,
    .under18: 13,
    .sexual: 14,
    .profanity: 15,
    .vulgarity: 16,
    .misunderstandingAssignment: 17,
    .misstyping: 18,
    .missSpelling: 19,
]

fileprivate let batch5DefaultTreatments: [ReportFlag: ModerationTreatment] = [
    .childSexualAbuseMaterial: .shadowBan,
    .promotesTerrorism: .shadowBan,
    .threatensPhysicalHarm: .shadowBan,
    .explicitSexualContent: .blur,
    .nudity: .blur,
    .graphicViolence: .blur,
    .hateSpeech: .blur,
    .selfHarmPromotion: .blur,
    .harmfulMisinformation: .blur,
    .sexual: .blur,
    .profanity: .blur,
    .vulgarity: .blur,
    .spam: .deprioritize,
    .copyrightViolation: .deprioritize,
    .personalAttack: .deprioritize,
    .unwantedContact: .deprioritize,
    .under18: .deprioritize,
    .misunderstandingAssignment: .allow,
    .misstyping: .allow,
    .missSpelling: .allow,
]

fileprivate let batch5RiskLevels: [ReportFlag: RiskLevel] = [
    .childSexualAbuseMaterial: .critical,
    .promotesTerrorism: .critical,
    .threatensPhysicalHarm: .critical,
    .selfHarmPromotion: .high,
    .graphicViolence: .high,
    .hateSpeech: .high,
    .explicitSexualContent: .medium,
    .nudity: .medium,
    .sexual: .medium,
    .harmfulMisinformation: .medium,
    .copyrightViolation: .medium,
    .personalAttack: .medium,
    .unwantedContact: .medium,
    .profanity: .medium,
    .vulgarity: .medium,
    .spam: .low,
    .under18: .low,
    .misunderstandingAssignment: .low,
    .misstyping: .low,
    .missSpelling: .low,
]

fileprivate let batch5SeverelyIllegal: Set<ReportFlag> = [
    .childSexualAbuseMaterial, .promotesTerrorism, .threatensPhysicalHarm, .selfHarmPromotion,
]

fileprivate let batch5Inappropriate: Set<ReportFlag> = [
    .explicitSexualContent, .nudity, .graphicViolence, .hateSpeech, .harmfulMisinformation,
]

fileprivate let batch5CommunityIssue: Set<ReportFlag> = [
    .spam, .copyrightViolation, .personalAttack, .unwantedContact, .under18,
]

fileprivate let batch5AppStoreNonCompliant: Set<ReportFlag> = [
    .childSexualAbuseMaterial, .promotesTerrorism, .threatensPhysicalHarm, .selfHarmPromotion,
    .explicitSexualContent, .graphicViolence, .nudity,
]

final class QuestionManagementBatch5Tests: XCTestCase {

    // MARK: - Choice

    func testChoiceWeightMultiplier() {
        let expectations: [(Question.Response.Selections.MyTheir.Choice, Int)] = [
            (.YES, 1),
            (.empty, 0),
            (.NEUTRAL, 0),
            (.NO, -1),
        ]
        for (choice, expected) in expectations {
            XCTAssertEqual(choice.weightMultiplier, expected, "\(choice)")
        }
    }

    func testChoiceRawValues() {
        XCTAssertEqual(Question.Response.Selections.MyTheir.Choice.YES.rawValue, "YES")
        XCTAssertEqual(Question.Response.Selections.MyTheir.Choice.NO.rawValue, "NO")
        XCTAssertEqual(Question.Response.Selections.MyTheir.Choice.empty.rawValue, " ")
        XCTAssertEqual(Question.Response.Selections.MyTheir.Choice.NEUTRAL.rawValue, "NEUTRAL")
    }

    func testChoiceCaseIterable() {
        XCTAssertEqual(Question.Response.Selections.MyTheir.Choice.allCases.count, 4)
        XCTAssertTrue(Question.Response.Selections.MyTheir.Choice.allCases.contains(.YES))
        XCTAssertTrue(Question.Response.Selections.MyTheir.Choice.allCases.contains(.NO))
        XCTAssertTrue(Question.Response.Selections.MyTheir.Choice.allCases.contains(.empty))
        XCTAssertTrue(Question.Response.Selections.MyTheir.Choice.allCases.contains(.NEUTRAL))
    }

    func testChoiceInitFromRawValue() {
        XCTAssertEqual(Question.Response.Selections.MyTheir.Choice(rawValue: "YES"), .YES)
        XCTAssertEqual(Question.Response.Selections.MyTheir.Choice(rawValue: "NO"), .NO)
        XCTAssertEqual(Question.Response.Selections.MyTheir.Choice(rawValue: " "), .empty)
        XCTAssertEqual(Question.Response.Selections.MyTheir.Choice(rawValue: "NEUTRAL"), .NEUTRAL)
        XCTAssertNil(Question.Response.Selections.MyTheir.Choice(rawValue: "nope"))
    }

    func testChoiceCodableRoundTrip() throws {
        for choice in Question.Response.Selections.MyTheir.Choice.allCases {
            let decoded = try batch5RoundTrip(choice)
            XCTAssertEqual(decoded, choice)
        }
    }

    // MARK: - ClientContext

    func testClientContextInit() {
        let id = UUID()
        let creatorID = UUID()
        let createdAt = Date(timeIntervalSince1970: 1000)
        let context = batch5Context()
        let clientContext = ClientContext(
            id: id,
            context: context,
            description: "a description",
            createdAt: createdAt,
            creatorID: creatorID
        )
        XCTAssertEqual(clientContext.id, id)
        XCTAssertEqual(clientContext.context, context)
        XCTAssertEqual(clientContext.description, "a description")
        XCTAssertEqual(clientContext.createdAt, createdAt)
        XCTAssertEqual(clientContext.creatorID, creatorID)
    }

    func testClientContextEquatableAndHashable() {
        let id = UUID()
        let creatorID = UUID()
        let createdAt = Date(timeIntervalSince1970: 500)
        let context = batch5Context()
        let a = ClientContext(id: id, context: context, description: "d", createdAt: createdAt, creatorID: creatorID)
        let b = ClientContext(id: id, context: context, description: "d", createdAt: createdAt, creatorID: creatorID)
        let differentDescription = ClientContext(id: id, context: context, description: "other", createdAt: createdAt, creatorID: creatorID)
        let differentID = ClientContext(id: UUID(), context: context, description: "d", createdAt: createdAt, creatorID: creatorID)

        XCTAssertEqual(a, b)
        XCTAssertEqual(a.hashValue, b.hashValue)
        XCTAssertNotEqual(a, differentDescription)
        XCTAssertNotEqual(a, differentID)
        XCTAssertEqual(Set([a, b]).count, 1)
    }

    func testClientContextCodableRoundTripWithDescription() throws {
        let clientContext = ClientContext(
            id: UUID(),
            context: batch5Context(case: .social),
            description: "hi",
            createdAt: Date(timeIntervalSince1970: 42),
            creatorID: UUID()
        )
        let decoded = try batch5RoundTrip(clientContext)
        XCTAssertEqual(decoded, clientContext)
    }

    func testClientContextCodableRoundTripWithNilDescription() throws {
        let clientContext = ClientContext(
            id: UUID(),
            context: batch5Context(case: .romance),
            description: nil,
            createdAt: Date(timeIntervalSince1970: 42),
            creatorID: UUID()
        )
        let decoded = try batch5RoundTrip(clientContext)
        XCTAssertEqual(decoded, clientContext)
        XCTAssertNil(decoded.description)
    }

    // MARK: - Context

    func testContextInitWithCaseComputesRawValue() {
        let romance = Context(id: .init(), case: .romance)
        let social = Context(id: .init(), case: .social)
        XCTAssertEqual(romance.rawValue, "romance")
        XCTAssertEqual(romance.case, .romance)
        XCTAssertEqual(social.rawValue, "social")
        XCTAssertEqual(social.case, .social)
    }

    func testContextFailableInitWithValidRawValue() {
        let id = UUID()
        let context = Context(id: id, rawValue: "romance")
        XCTAssertNotNil(context)
        XCTAssertEqual(context?.id, id)
        XCTAssertEqual(context?.case, .romance)
        XCTAssertEqual(context?.rawValue, "romance")
    }

    // Item 1.11 opened Context to member-created values: a raw value that was not a built-in case is
    // now a first-class context, not nil. The type accepts any string; name moderation is a separate,
    // higher layer (swath C), not this initializer's job.
    func testContextInitAcceptsMemberCreatedRawValue() {
        let created = Context(id: .init(), rawValue: "not-a-case")
        XCTAssertNotNil(created)
        XCTAssertEqual(created?.case, Context.Case(rawValue: "not-a-case"))
        XCTAssertEqual(created?.rawValue, "not-a-case")
        XCTAssertNotNil(Context(id: .init(), rawValue: ""))
    }

    func testContextEquatableAndHashable() {
        let id = UUID()
        let a = Context(id: id, case: .romance)
        let b = Context(id: id, case: .romance)
        let differentCase = Context(id: id, case: .social)
        let differentID = Context(id: .init(), case: .romance)

        XCTAssertEqual(a, b)
        XCTAssertEqual(a.hashValue, b.hashValue)
        XCTAssertNotEqual(a, differentCase)
        XCTAssertNotEqual(a, differentID)
        XCTAssertEqual(Set([a, b]).count, 1)
    }

    func testContextCodableRoundTrip() throws {
        let context = Context(id: UUID(), case: .social)
        let decoded = try batch5RoundTrip(context)
        XCTAssertEqual(decoded, context)
    }

    func testContextCaseIterable() {
        XCTAssertEqual(Context.Case.allCases.count, 2)
        XCTAssertTrue(Context.Case.allCases.contains(.romance))
        XCTAssertTrue(Context.Case.allCases.contains(.social))
    }

    func testContextCaseRawValues() {
        XCTAssertEqual(Context.Case.romance.rawValue, "romance")
        XCTAssertEqual(Context.Case.social.rawValue, "social")
    }

    func testContextCaseCodableRoundTrip() throws {
        for c in Context.Case.allCases {
            let decoded = try batch5RoundTrip(c)
            XCTAssertEqual(decoded, c)
        }
    }

    // MARK: - Creator

    func testCreatorInit() {
        let creator = Creator(profileImageURL: "url", displayName: "Scott", contextCompatibility: ["romance": 1.5])
        XCTAssertEqual(creator.profileImageURL, "url")
        XCTAssertEqual(creator.displayName, "Scott")
        XCTAssertEqual(creator.contextCompatibility, ["romance": 1.5])
    }

    func testCreatorPlaceholder() {
        let placeholder = Creator.placeholder
        XCTAssertEqual(placeholder.profileImageURL, "")
        XCTAssertEqual(placeholder.displayName, "")
        XCTAssertTrue(placeholder.contextCompatibility.isEmpty)
    }

    func testCreatorEquatableAndHashable() {
        let a = Creator(profileImageURL: "u", displayName: "n", contextCompatibility: ["romance": 2])
        let b = Creator(profileImageURL: "u", displayName: "n", contextCompatibility: ["romance": 2])
        let different = Creator(profileImageURL: "u2", displayName: "n", contextCompatibility: ["romance": 2])

        XCTAssertEqual(a, b)
        XCTAssertEqual(a.hashValue, b.hashValue)
        XCTAssertNotEqual(a, different)
        XCTAssertEqual(Set([a, b]).count, 1)
    }

    func testCreatorCodableRoundTrip() throws {
        let creator = Creator(profileImageURL: "url", displayName: "Scott", contextCompatibility: ["romance": 1.25, "social": 3])
        let decoded = try batch5RoundTrip(creator)
        XCTAssertEqual(decoded, creator)
    }

    func testCreatorCodableRoundTripWithEmptyCompatibility() throws {
        let decoded = try batch5RoundTrip(Creator.placeholder)
        XCTAssertEqual(decoded, Creator.placeholder)
    }

    // MARK: - Importance

    func testImportanceInitFromValidInt() {
        XCTAssertEqual(Question.Importance(1), .irrelevant)
        XCTAssertEqual(Question.Importance(3), .somewhat)
        XCTAssertEqual(Question.Importance(9), .very)
    }

    func testImportanceInitFromInvalidInt() {
        XCTAssertNil(Question.Importance(0))
        XCTAssertNil(Question.Importance(2))
        XCTAssertNil(Question.Importance(4))
        XCTAssertNil(Question.Importance(-1))
        XCTAssertNil(Question.Importance(100))
    }

    func testImportanceRawValues() {
        XCTAssertEqual(Question.Importance.irrelevant.rawValue, 1)
        XCTAssertEqual(Question.Importance.somewhat.rawValue, 3)
        XCTAssertEqual(Question.Importance.very.rawValue, 9)
    }

    func testImportanceHasSelectionsInitNoOldNoSelections() {
        XCTAssertNil(Question.Importance(false, nil))
    }

    func testImportanceHasSelectionsInitNoOldHasSelections() {
        XCTAssertEqual(Question.Importance(true, nil), .irrelevant)
    }

    func testImportanceHasSelectionsInitWithOldPassesThroughRegardlessOfSelections() {
        XCTAssertEqual(Question.Importance(true, .somewhat), .somewhat)
        XCTAssertEqual(Question.Importance(false, .somewhat), .somewhat)
        XCTAssertEqual(Question.Importance(true, .very), .very)
        XCTAssertEqual(Question.Importance(false, .very), .very)
        XCTAssertEqual(Question.Importance(true, .irrelevant), .irrelevant)
        XCTAssertEqual(Question.Importance(false, .irrelevant), .irrelevant)
    }

    func testImportanceCodableRoundTrip() throws {
        for importance: Question.Importance in [.irrelevant, .somewhat, .very] {
            let decoded = try batch5RoundTrip(importance)
            XCTAssertEqual(decoded, importance)
        }
    }

    func testImportanceHashable() {
        XCTAssertEqual(Set([Question.Importance.irrelevant, .irrelevant, .somewhat]).count, 2)
    }

    // MARK: - Response

    func testResponseInitDefaults() {
        let id = UUID()
        let response = Question.Response(
            text: "t",
            timeStamp: Date(timeIntervalSince1970: 0),
            id: id,
            creator: .init(),
            questionID: .init(),
            originalContextID: .init(),
            assessment: ModerationAssessment(entries: [])
        )
        XCTAssertTrue(response.myChoice.isEmpty)
        XCTAssertTrue(response.theirChoices.isEmpty)
        XCTAssertTrue(response.popularity.isEmpty)
        XCTAssertEqual(response.id, id)
    }

    func testResponseEqualityIsIDOnly() {
        let id = UUID()
        let a = batch5Response(text: "hello", id: id)
        let b = batch5Response(text: "totally different text", id: id)
        XCTAssertEqual(a, b)
    }

    func testResponseInequalityWithDifferentID() {
        let a = batch5Response(text: "same")
        let b = batch5Response(text: "same")
        XCTAssertNotEqual(a, b)
    }

    func testResponseDeepEqualsTrueForIdenticalValues() {
        let id = UUID()
        let creator = UUID()
        let questionID = UUID()
        let originalContextID = UUID()
        let timeStamp = Date(timeIntervalSince1970: 123)
        let a = batch5Response(
            text: "hi", timeStamp: timeStamp, id: id, creator: creator, questionID: questionID,
            myChoice: ["romance": .YES], theirChoices: ["romance": .NO], popularity: ["romance": 5],
            originalContextID: originalContextID
        )
        let b = batch5Response(
            text: "hi", timeStamp: timeStamp, id: id, creator: creator, questionID: questionID,
            myChoice: ["romance": .YES], theirChoices: ["romance": .NO], popularity: ["romance": 5],
            originalContextID: originalContextID
        )
        XCTAssertTrue(a.deepEquals(b))
    }

    func testResponseDeepEqualsFalseWhenFieldsDifferButIDsMatch() {
        let id = UUID()
        let a = batch5Response(text: "hello", id: id)
        let b = batch5Response(text: "different", id: id)
        XCTAssertEqual(a, b)
        XCTAssertFalse(a.deepEquals(b))
    }

    func testResponseHasForMy() {
        let context = batch5Context()
        var response = batch5Response()
        XCTAssertFalse(response.has(.my, for: context.rawValue))

        response.myChoice[context.rawValue] = .YES
        XCTAssertTrue(response.has(.my, for: context.rawValue))

        response.myChoice[context.rawValue] = .NO
        XCTAssertTrue(response.has(.my, for: context.rawValue))

        response.myChoice[context.rawValue] = .NEUTRAL
        XCTAssertFalse(response.has(.my, for: context.rawValue))

        response.myChoice[context.rawValue] = .empty
        XCTAssertFalse(response.has(.my, for: context.rawValue))
    }

    func testResponseHasForTheir() {
        let context = batch5Context()
        var response = batch5Response()
        XCTAssertFalse(response.has(.their, for: context.rawValue))

        response.theirChoices[context.rawValue] = .YES
        XCTAssertTrue(response.has(.their, for: context.rawValue))

        response.theirChoices[context.rawValue] = .NO
        XCTAssertTrue(response.has(.their, for: context.rawValue))

        response.theirChoices[context.rawValue] = .NEUTRAL
        XCTAssertFalse(response.has(.their, for: context.rawValue))
    }

    func testResponseSetMyUpdatesMyChoiceOnly() {
        let context = batch5Context()
        var response = batch5Response()
        response.set(.my, .YES, for: context)
        XCTAssertEqual(response.myChoice[context.rawValue], .YES)
        XCTAssertNil(response.theirChoices[context.rawValue])
    }

    func testResponseSetTheirUpdatesTheirChoicesOnly() {
        let context = batch5Context()
        var response = batch5Response()
        response.set(.their, .NO, for: context)
        XCTAssertEqual(response.theirChoices[context.rawValue], .NO)
        XCTAssertNil(response.myChoice[context.rawValue])
    }

    func testResponseChoiceForReturnsNilWhenMissing() {
        let context = batch5Context()
        let response = batch5Response()
        XCTAssertNil(response.choice(for: .my, context))
        XCTAssertNil(response.choice(for: .their, context))
    }

    func testResponseChoiceForReturnsSetValue() {
        let context = batch5Context()
        var response = batch5Response()
        response.set(.my, .YES, for: context)
        response.set(.their, .NEUTRAL, for: context)
        XCTAssertEqual(response.choice(for: .my, context), .YES)
        XCTAssertEqual(response.choice(for: .their, context), .NEUTRAL)
    }

    func testResponseCodableRoundTripPreservesAllFieldsViaDeepEquals() throws {
        let response = batch5Response(
            text: "full round trip",
            timeStamp: Date(timeIntervalSince1970: 777),
            myChoice: ["romance": .YES],
            theirChoices: ["social": .NO],
            popularity: ["romance": 10, "social": 2],
            assessment: ModerationAssessment(entries: [
                FlagExplanation(flag: .spam, explanation: "e", source: .autoServerOpenAI, aiConfidence: 0.5)
            ])
        )
        let decoded = try batch5RoundTrip(response)
        XCTAssertTrue(response.deepEquals(decoded))
        XCTAssertEqual(decoded.assessment, response.assessment)
    }

    // MARK: - ModerationAssessment

    func testModerationAssessmentSuggestedTreatmentEmptyEntriesIsAllow() {
        XCTAssertEqual(ModerationAssessment(entries: []).suggestedTreatment, .allow)
    }

    func testModerationAssessmentSuggestedTreatmentSeverelyIllegalWinsOverInappropriate() {
        let assessment = ModerationAssessment(entries: [
            FlagExplanation(flag: .childSexualAbuseMaterial, explanation: "e", source: .manualOtherUser, aiConfidence: nil),
            FlagExplanation(flag: .nudity, explanation: "e", source: .manualOtherUser, aiConfidence: nil),
        ])
        XCTAssertEqual(assessment.suggestedTreatment, .shadowBan)
    }

    func testModerationAssessmentSuggestedTreatmentInappropriateOnly() {
        let assessment = ModerationAssessment(entries: [
            FlagExplanation(flag: .nudity, explanation: "e", source: .appleIntelligence, aiConfidence: 0.9)
        ])
        XCTAssertEqual(assessment.suggestedTreatment, .blur)
    }

    func testModerationAssessmentSuggestedTreatmentCommunityIssueOnly() {
        let assessment = ModerationAssessment(entries: [
            FlagExplanation(flag: .spam, explanation: "e", source: .autoServerOpenAI, aiConfidence: nil)
        ])
        XCTAssertEqual(assessment.suggestedTreatment, .deprioritize)
    }

    func testModerationAssessmentSuggestedTreatmentNoneOfTheAboveIsAllow() {
        let assessment = ModerationAssessment(entries: [
            FlagExplanation(flag: .misstyping, explanation: "e", source: .manualOtherUser, aiConfidence: nil)
        ])
        XCTAssertEqual(assessment.suggestedTreatment, .allow)
    }

    func testModerationAssessmentDefaultTreatmentEmptyEntriesIsAllow() {
        XCTAssertEqual(ModerationAssessment(entries: []).defaultTreatment, .allow)
    }

    func testModerationAssessmentDefaultTreatmentPicksMostSevere() {
        let assessment = ModerationAssessment(entries: [
            FlagExplanation(flag: .misstyping, explanation: "e", source: .manualOtherUser, aiConfidence: nil),
            FlagExplanation(flag: .childSexualAbuseMaterial, explanation: "e", source: .manualOtherUser, aiConfidence: nil),
            FlagExplanation(flag: .spam, explanation: "e", source: .manualOtherUser, aiConfidence: nil),
        ])
        XCTAssertEqual(assessment.defaultTreatment, .shadowBan)
    }

    func testModerationAssessmentEquatableAndHashable() {
        let a = ModerationAssessment(entries: [FlagExplanation(flag: .spam, explanation: "e", source: .manualOtherUser, aiConfidence: nil)])
        let b = ModerationAssessment(entries: [FlagExplanation(flag: .spam, explanation: "e", source: .manualOtherUser, aiConfidence: nil)])
        let different = ModerationAssessment(entries: [])
        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, different)
        XCTAssertEqual(Set([a, b]).count, 1)
    }

    func testModerationAssessmentCodableRoundTrip() throws {
        let assessment = ModerationAssessment(entries: [
            FlagExplanation(flag: .hateSpeech, explanation: "e", source: .appleIntelligence, aiConfidence: 0.75),
            FlagExplanation(flag: .spam, explanation: "e2", source: .manualOtherUser, aiConfidence: nil),
        ])
        let decoded = try batch5RoundTrip(assessment)
        XCTAssertEqual(decoded, assessment)
    }

    func testFlagExplanationEquatableAndHashable() {
        let a = FlagExplanation(flag: .spam, explanation: "e", source: .manualOtherUser, aiConfidence: 0.1)
        let b = FlagExplanation(flag: .spam, explanation: "e", source: .manualOtherUser, aiConfidence: 0.1)
        let different = FlagExplanation(flag: .spam, explanation: "different", source: .manualOtherUser, aiConfidence: 0.1)
        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, different)
        XCTAssertEqual(Set([a, b]).count, 1)
    }

    func testFlagSourceCodableRoundTripAndRawValues() throws {
        XCTAssertEqual(FlagSource.appleIntelligence.rawValue, "appleIntelligence")
        XCTAssertEqual(FlagSource.autoServerOpenAI.rawValue, "autoServerOpenAI")
        XCTAssertEqual(FlagSource.manualOtherUser.rawValue, "manualOtherUser")
        for source: FlagSource in [.appleIntelligence, .autoServerOpenAI, .manualOtherUser] {
            let decoded = try batch5RoundTrip(source)
            XCTAssertEqual(decoded, source)
        }
    }

    // MARK: - ModerationTreatment

    func testModerationTreatmentID() {
        for treatment in ModerationTreatment.allCases {
            XCTAssertEqual(treatment.id, treatment.rawValue)
        }
    }

    func testModerationTreatmentDisplayText() {
        XCTAssertEqual(ModerationTreatment.shadowBan.displayText, "🕳️ Don't show me")
        XCTAssertEqual(ModerationTreatment.blur.displayText, "🌫️ Blur")
        XCTAssertEqual(ModerationTreatment.deprioritize.displayText, "⬇️ Deprioritize")
        XCTAssertEqual(ModerationTreatment.allow.displayText, "✅ Show me")
    }

    func testModerationTreatmentShortLabel() {
        XCTAssertEqual(ModerationTreatment.shadowBan.shortLabel, "Omit")
        XCTAssertEqual(ModerationTreatment.blur.shortLabel, "Blur")
        XCTAssertEqual(ModerationTreatment.deprioritize.shortLabel, "Deprioritize")
        XCTAssertEqual(ModerationTreatment.allow.shortLabel, "No Action")
    }

    func testModerationTreatmentSymbol() {
        XCTAssertEqual(ModerationTreatment.shadowBan.symbol, "🕳️")
        XCTAssertEqual(ModerationTreatment.blur.symbol, "🌫️")
        XCTAssertEqual(ModerationTreatment.deprioritize.symbol, "⬇️")
        XCTAssertEqual(ModerationTreatment.allow.symbol, "🚫")
    }

    func testModerationTreatmentRank() {
        XCTAssertEqual(ModerationTreatment.shadowBan.rank, 0)
        XCTAssertEqual(ModerationTreatment.blur.rank, 1)
        XCTAssertEqual(ModerationTreatment.deprioritize.rank, 2)
        XCTAssertEqual(ModerationTreatment.allow.rank, 3)
    }

    func testModerationTreatmentComparable() {
        XCTAssertLessThan(ModerationTreatment.shadowBan, .blur)
        XCTAssertLessThan(ModerationTreatment.blur, .deprioritize)
        XCTAssertLessThan(ModerationTreatment.deprioritize, .allow)
        XCTAssertEqual(
            [ModerationTreatment.allow, .shadowBan, .deprioritize, .blur].sorted(),
            [.shadowBan, .blur, .deprioritize, .allow]
        )
    }

    func testModerationTreatmentCaseIterable() {
        XCTAssertEqual(ModerationTreatment.allCases.count, 4)
        XCTAssertEqual(Set(ModerationTreatment.allCases), [.shadowBan, .blur, .deprioritize, .allow])
    }

    func testModerationTreatmentCodableRoundTrip() throws {
        for treatment in ModerationTreatment.allCases {
            let decoded = try batch5RoundTrip(treatment)
            XCTAssertEqual(decoded, treatment)
        }
    }

    // MARK: - ReportFlag

    func testReportFlagCaseCount() {
        XCTAssertEqual(ReportFlag.allCases.count, 20)
    }

    func testReportFlagDisplayNameForEveryCase() {
        for flag in ReportFlag.allCases {
            XCTAssertEqual(flag.displayName, batch5DisplayNames[flag], "\(flag)")
        }
    }

    func testReportFlagIntForEveryCase() {
        for flag in ReportFlag.allCases {
            XCTAssertEqual(flag.int, batch5Ints[flag], "\(flag)")
        }
        XCTAssertEqual(Set(ReportFlag.allCases.map(\.int)).count, ReportFlag.allCases.count)
    }

    func testReportFlagDefaultTreatmentForEveryCase() {
        for flag in ReportFlag.allCases {
            XCTAssertEqual(flag.defaultTreatment, batch5DefaultTreatments[flag], "\(flag)")
        }
    }

    func testReportFlagRiskLevelForEveryCase() {
        for flag in ReportFlag.allCases {
            XCTAssertEqual(flag.riskLevel, batch5RiskLevels[flag], "\(flag)")
        }
    }

    func testReportFlagIsSeverelyIllegalForEveryCase() {
        for flag in ReportFlag.allCases {
            XCTAssertEqual(flag.isSeverelyIllegal, batch5SeverelyIllegal.contains(flag), "\(flag)")
        }
    }

    func testReportFlagIsInappropriateForEveryCase() {
        for flag in ReportFlag.allCases {
            XCTAssertEqual(flag.isInappropriate, batch5Inappropriate.contains(flag), "\(flag)")
        }
    }

    func testReportFlagIsCommunityIssueForEveryCase() {
        for flag in ReportFlag.allCases {
            XCTAssertEqual(flag.isCommunityIssue, batch5CommunityIssue.contains(flag), "\(flag)")
        }
    }

    func testReportFlagIsAppStoreNonCompliantForEveryCase() {
        for flag in ReportFlag.allCases {
            XCTAssertEqual(flag.isAppStoreNonCompliant, batch5AppStoreNonCompliant.contains(flag), "\(flag)")
        }
    }

    func testReportFlagHideFromNonCreator() {
        XCTAssertEqual(ReportFlag.hideFromNonCreator, batch5AppStoreNonCompliant)
        XCTAssertFalse(ReportFlag.hideFromNonCreator.contains(.under18))
    }

    func testReportFlagGptModerationCommaSeparatedListExcludesOnlyCSAM() {
        let list = ReportFlag.gptModerationCommaSeparatedList
        XCTAssertFalse(list.contains("childSexualAbuseMaterial"))
        let components = list.components(separatedBy: ", ")
        XCTAssertEqual(components.count, 19)
        XCTAssertTrue(components.contains("promotesTerrorism"))
        XCTAssertTrue(components.contains("missSpelling"))
    }

    func testReportFlagPermissableFlagsExcludesSeverelyIllegalAndAppStoreNonCompliant() {
        let permissable = Set(ReportFlag.permissableFlags)
        XCTAssertEqual(permissable.count, 13)
        for flag in batch5AppStoreNonCompliant {
            XCTAssertFalse(permissable.contains(flag), "\(flag)")
        }
        for flag in batch5SeverelyIllegal {
            XCTAssertFalse(permissable.contains(flag), "\(flag)")
        }
        XCTAssertTrue(permissable.contains(.spam))
        XCTAssertTrue(permissable.contains(.under18))
        XCTAssertTrue(permissable.contains(.hateSpeech))
        XCTAssertTrue(permissable.contains(.missSpelling))
    }

    func testReportFlagCodableRoundTrip() throws {
        for flag in ReportFlag.allCases {
            let decoded = try batch5RoundTrip(flag)
            XCTAssertEqual(decoded, flag)
        }
    }

    func testReportFlagArrayIntsPreservesOrder() {
        let flags: [ReportFlag] = [.spam, .childSexualAbuseMaterial, .missSpelling]
        XCTAssertEqual(flags.ints, [10, 0, 19])
    }

    func testReportFlagArrayIsChildSexualHeuristicTrueForCSAMAlone() {
        XCTAssertTrue([ReportFlag.childSexualAbuseMaterial].isChildSexualHeuristic)
    }

    func testReportFlagArrayIsChildSexualHeuristicTrueForUnder18PlusSexualSignals() {
        XCTAssertTrue([ReportFlag.under18, .sexual].isChildSexualHeuristic)
        XCTAssertTrue([ReportFlag.under18, .explicitSexualContent].isChildSexualHeuristic)
        XCTAssertTrue([ReportFlag.under18, .nudity].isChildSexualHeuristic)
        XCTAssertTrue([ReportFlag.under18, .graphicViolence].isChildSexualHeuristic)
    }

    func testReportFlagArrayIsChildSexualHeuristicFalseForUnder18Alone() {
        XCTAssertFalse([ReportFlag.under18].isChildSexualHeuristic)
    }

    func testReportFlagArrayIsChildSexualHeuristicFalseForUnrelatedFlags() {
        XCTAssertFalse([ReportFlag]().isChildSexualHeuristic)
        XCTAssertFalse([ReportFlag.spam, .hateSpeech].isChildSexualHeuristic)
    }

    // MARK: - IceServer

    func testIceServerInit() {
        let server = IceServer(urls: ["stun:example.com:3478"], username: "user", credential: "cred")
        XCTAssertEqual(server.urls, ["stun:example.com:3478"])
        XCTAssertEqual(server.username, "user")
        XCTAssertEqual(server.credential, "cred")
    }

    func testIceServerEquatableAndHashable() {
        let a = IceServer(urls: ["stun:a"], username: "u", credential: "c")
        let b = IceServer(urls: ["stun:a"], username: "u", credential: "c")
        let different = IceServer(urls: ["stun:b"], username: "u", credential: "c")
        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, different)
        XCTAssertEqual(Set([a, b]).count, 1)
    }

    func testIceServerCodableRoundTripWithCredentials() throws {
        let server = IceServer(urls: ["turn:example.com:3478"], username: "user", credential: "cred")
        let decoded = try batch5RoundTrip(server)
        XCTAssertEqual(decoded, server)
    }

    func testIceServerCodableRoundTripStunOnlyNilCredentials() throws {
        let server = IceServer(urls: ["stun:example.com:3478"], username: nil, credential: nil)
        let decoded = try batch5RoundTrip(server)
        XCTAssertEqual(decoded, server)
        XCTAssertNil(decoded.username)
        XCTAssertNil(decoded.credential)
    }

    func testIceServerDecodesWhenOptionalKeysAreEntirelyMissing() throws {
        let json = """
        { "urls": ["stun:example.com:3478"] }
        """
        let decoded = try JSONDecoder().decode(IceServer.self, from: Data(json.utf8))
        XCTAssertEqual(decoded.urls, ["stun:example.com:3478"])
        XCTAssertNil(decoded.username)
        XCTAssertNil(decoded.credential)
    }

    // MARK: - IceServersResponse

    func testIceServersResponseInit() {
        let server = IceServer(urls: ["stun:a"], username: nil, credential: nil)
        let response = IceServersResponse(iceServers: [server])
        XCTAssertEqual(response.iceServers, [server])
    }

    func testIceServersResponseEquatableAndHashable() {
        let server = IceServer(urls: ["stun:a"], username: nil, credential: nil)
        let a = IceServersResponse(iceServers: [server])
        let b = IceServersResponse(iceServers: [server])
        let empty = IceServersResponse(iceServers: [])
        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, empty)
        XCTAssertEqual(Set([a, b]).count, 1)
    }

    func testIceServersResponseCodableRoundTripEmpty() throws {
        let response = IceServersResponse(iceServers: [])
        let decoded = try batch5RoundTrip(response)
        XCTAssertEqual(decoded, response)
        XCTAssertTrue(decoded.iceServers.isEmpty)
    }

    func testIceServersResponseCodableRoundTripPreservesOrder() throws {
        let stun = IceServer(urls: ["stun:example.com:3478"], username: nil, credential: nil)
        let turn = IceServer(urls: ["turn:example.com:3478"], username: "user", credential: "cred")
        let response = IceServersResponse(iceServers: [stun, turn])
        let decoded = try batch5RoundTrip(response)
        XCTAssertEqual(decoded, response)
        XCTAssertEqual(decoded.iceServers, [stun, turn])
    }
}
