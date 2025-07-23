//
//  File.swift
//
//
//  Created by Scott Lydon on 4/3/24.
//

import Foundation
import Callable

extension String {

    static let moderationPromptFormatIntro = """
    You are a strict and thorough content moderation assistant.

    You will analyze user-generated content for violations across multiple categories of inappropriate or problematic content. You MUST detect **every applicable flag** — it is unacceptable to miss any.

    Each violation should be labeled using the predefined categories below. You must return your result as a **JSON string** that conforms exactly to the Swift structure shown.

    ## REQUIRED BEHAVIOR:
    - Return one `entry` for **every single applicable flag**. Multiple violations are common.
    - Do NOT stop after the first flag.
    - It is BETTER to return extra flags than to miss one. **Missing a flag is a critical error.**
    - The `explanation` should be 1–2 sentences explaining why that flag applies.
    - The `source` must always be `"\(FlagSource.autoServerOpenAI.rawValue)"`.

    ## ALLOWED FLAGS (use these exactly):
        \(ReportFlag.gptModerationCommaSeparatedList)
    
    Note: There is a 

    ## EXAMPLE OUTPUT (you must match this format — but DO NOT wrap it in ```json or any Markdown code block):
    ```json
    \(ModerationAssessment.exampleJSONString)
    ```
    
    Return only the raw JSON. Do not include backticks, do not wrap in a code block, and do not say "Here is your result" or anything else. Only the JSON.
    """

    public static let questionMisunderstanding: String =
    """
        ✳️ For questions:

        Use this flag when a user submits a question that may be grammatically valid, but doesn’t align with the purpose of the platform — such as matchmaking or compatibility filtering.
        Example:

        ❌ “How are you?” — While this is a valid question, it lacks the depth or relevance expected from a matchmaking prompt designed to reveal preferences, values, or personality traits.
    """

    public static let responseMisunderstanding: String =
    """
    ✳️ For responses:

    Use this flag when a user submits a response that is unrelated to the original question — for example when the response is itself a separate, unrelated question.
    Example:

       Question: “What is the best way to skin a cat?”
    ❌ Response: “What is your favorite color?” — This is not a valid answer; it’s an unrelated topic that indicates the user didn’t understand the assignment when they submitted the response.
    """

    public func misunderstandingAssignmentPromptNote(middleContent: String = .questionMisunderstanding) -> String {
    """
    🔧 misunderstandingAssignment — Moderation Note
    This flag is used when a user attempts to contribute content (either a question or a response) but misunderstands the intended purpose or structure of the interaction.
    
    \(middleContent)
    
    ✅ Goal of this flag:
    
    Identify content that appears sincere or non-malicious but fails to fulfill the intended content structure, likely due to confusion or unfamiliarity with how the platform works.
    """
    }

    public static let accountNotVerifed: String = "This account's email hasn't been verified yet.  Would you like us to resend a link?"

    static var generateBoundaryString: String {
        "Boundary-\(NSUUID().uuidString)"
    }

    public var scaped: String? {
        addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }

    // For apns primarily
    static var environmentString: String {
        #if DEBUG
            return "DEBUG"
        #elseif ADHOC
            return "ADHOC"
        #else
            return "PRODUCTION"
        #endif
    }

    var int: Int? {
        Int(self)
    }

    /// Generates a moderation prompt based on label, question, and user response.
    public static func verifyUserAction(
        flagged flagLabel: ReportFlag,
        question: String,
        response: String
    ) -> String {
        verifyUserAction(flagged: flagLabel, forContent: "Question: \(question)\nResponse: \(response)")
    }

    /// Builds a system prompt for moderation (question only).
    public static func verifyUserAction(
        flagged flagLabel: ReportFlag,
        question: String
    ) -> String {
        verifyUserAction(flagged: flagLabel, forContent: "Question: \(question)")
    }

    private static func verifyUserAction(
        flagged flagLabel: ReportFlag,
        forContent content: String
    ) -> String {
        """
        \(moderationPromptFormatIntro)

        A user has flagged a piece of content under the category "\(flagLabel.rawValue)".

        Review this content:

        \"\"\"
        \(content)
        \"\"\"

        Return only the JSON. Do not include extra commentary.
        """
    }

    public static func moderationPrompt(forContent content: String) -> String {
        """
        \(moderationPromptFormatIntro)

        Analyze the following content:

        \"\"\"
        \(content)
        \"\"\"

        Return only the JSON. Do not include extra text or formatting.
        """
    }
}

extension String {
    /// Attempts to decode a moderation assessment from the string, assuming it's the LLM's JSON response.
    /// Returns an empty assessment if decoding fails.
    public func moderationAssessment() throws -> ModerationAssessment {
        guard let data = self.data(using: .utf8) else {
            throw GenericError(text: "Couldn't convert the llm output into a valid ModerationAssessment instance.  -->\(self)")
        }
        return try JSONDecoder().decode(ModerationAssessment.self, from: data)
    }
}


import Foundation

public extension ModerationAssessment {
    static var exampleJSONString: String {
        let example = ModerationAssessment(entries: [
            FlagExplanation(
                flag: .threatensPhysicalHarm,
                explanation: "The content contains a direct threat of physical harm.",
                source: .autoServerOpenAI
            ),
            FlagExplanation(
                flag: .sexual,
                explanation: "The content contains a breast.",
                source: .autoServerOpenAI
            ),
            FlagExplanation(
                flag: .childSexualAbuseMaterial,
                explanation: "There is a naked child getting flogged.",
                source: .autoServerOpenAI
            )
        ])

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        guard let data = try? encoder.encode(example),
              let jsonString = String(data: data, encoding: .utf8) else {
            return "// Failed to encode example JSON"
        }

        return jsonString
    }
}
