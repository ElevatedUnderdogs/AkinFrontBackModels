//
//  SaveQuestionError.swift
//  akin
//
//  Created by Scott Lydon on 8/8/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//

import Foundation

extension Question.SaveAttemptServerResponse {
    
    public enum ServerError: String, Error, Codable {
        case incorrectFormatServerError, repeatQuestion, unknownError
        
        public var explanation: String {
            switch self {
            case .incorrectFormatServerError:
                return "Either the json came in the wrong format, or it was parsed incorrectly."
            case .unknownError:
                return "There is an unknown error from the server."
            case .repeatQuestion:
                return "This question already exists verbatim."
            }
        }
    }
}
