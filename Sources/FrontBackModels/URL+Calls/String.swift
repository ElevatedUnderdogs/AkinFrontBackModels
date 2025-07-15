//
//  File.swift
//
//
//  Created by Scott Lydon on 4/3/24.
//

import Foundation
import Callable

extension String {

    private static let moderationPromptFormatIntro = """
    You are a content moderation assistant. Analyze the following user-generated content and assess whether it falls into any of the predefined categories of inappropriate or problematic content.

    You must return your answer as a JSON string that can be parsed into the following Swift structure:
    
    // NOTES: 
    // ... you may include more than one entry 0 - n
    // The report flags will be drawn from these: \(ReportFlag.commaSeparatedList)
    // Include all flags that apply!
    //  explanation is (1–2 sentences) describing why each flag was applied
    // The source should always be "autoServerOpenAI".

    \(ModerationAssessment.exampleJSONString)

    Do not include any fields other than "entries". Do not include the computed field `suggestedTreatment` — the system will calculate that automatically.
    """

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
