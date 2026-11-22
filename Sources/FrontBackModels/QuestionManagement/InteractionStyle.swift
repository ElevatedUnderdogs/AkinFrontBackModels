//
//  InteractionStyle.swift
//  akin
//
//  Created by Scott Lydon on 8/5/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//

import Foundation

extension Question {

    public enum InteractionStyle: String, Codable {
        case binary
        case none
        case normal
    }
}
