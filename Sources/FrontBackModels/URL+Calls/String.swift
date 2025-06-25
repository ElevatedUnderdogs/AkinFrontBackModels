//
//  File.swift
//
//
//  Created by Scott Lydon on 4/3/24.
//

import Foundation

extension String {

    private static let moderationPromptFormatIntro = """
    You are a content moderation assistant. Analyze the following user-generated content and assess whether it falls into any of the predefined categories of inappropriate or problematic content.

    You must return your answer as a JSON string that can be parsed into the following Swift structure:

    {
      "entries": [
        {
          "flag": "ReportFlag", // One of: \(ReportFlag.commaSeparatedList)
          "explanation": "Short explanation (1–2 sentences) describing why this flag was applied"
        }
        // ... you may include more than one entry
      ]
    }

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
    public static func user(flagged flagLabel: ReportFlag, question: String, response: String) -> String {
        user(flagged: flagLabel, forContent: "Question: \(question)\nResponse: \(response)")
    }

    /// Builds a system prompt for moderation (question only).
    public static func user(flagged flagLabel: ReportFlag, question: String) -> String {
        user(flagged: flagLabel, forContent: "Question: \(question)")
    }

    private static func user(flagged flagLabel: ReportFlag, forContent content: String) -> String {
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
