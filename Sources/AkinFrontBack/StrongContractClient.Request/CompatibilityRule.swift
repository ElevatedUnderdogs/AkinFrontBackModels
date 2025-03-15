//
//  File.swift
//  AkinFrontBack
//
//  Created by Scott Lydon on 3/6/25.
//

import Foundation

public enum CompatibilityRule: String, Codable, Hashable, Equatable {
    case mandatory, weighted
}

public let genderResponses = ["Male", "Female"]
public let socialText: String = "social"
public let romanceText: String = "romance"
public let ageQuestionText: String = "What is your age?"
public let genderQuestionText: String = "What is your gender?"



extension Array where Element == AkinFrontBack.Question {

    /**
     var questions = questions
     if let indexOfAgeQ = questions?.firstIndex(where: { $0.text == ageQuestionText }),
     let indexOfResponse = questions?[indexOfAgeQ].responses.firstIndex(where: { $0.text.int == birthday.age() }) {
     AkinFrontBack.Context.Case.allCases.forEach { aContext in
     questions?[indexOfAgeQ].responses[indexOfResponse].myChoice[aContext.rawValue] = .YES
     }
     }
     */
    public func ageQuestionAdjusted(birthday: Date?) -> [AkinFrontBack.Question] {
        guard let birthday else { return self }
        let currentAge = birthday.age()
        var adjustedQuestions = self
        if let indexOfAgeQ: Array<Question>.Index = adjustedQuestions.firstIndex(where: { $0.text == ageQuestionText }) {
            let responses: [Question.Response] = adjustedQuestions[indexOfAgeQ].responses
            if let indexOfResponse = responses.firstIndex(where: { $0.text.int == currentAge }) {
                AkinFrontBack.Context.Case.allCases.forEach { aContext in
                    adjustedQuestions[indexOfAgeQ].responses[indexOfResponse].myChoice[aContext.rawValue] = .YES
                }
            }
        }
        return adjustedQuestions
    }
}
