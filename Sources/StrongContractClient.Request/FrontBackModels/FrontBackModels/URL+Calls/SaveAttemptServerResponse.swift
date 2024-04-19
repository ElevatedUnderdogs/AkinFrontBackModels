//
//  SaveQuestionResponse.swift
//  akin
//
//  Created by Scott Lydon on 8/5/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//

import Foundation

extension Question {
    
    public enum SaveAttemptServerResponse {
        
        case error(ServerError)
        case question(Question)
    }
}
