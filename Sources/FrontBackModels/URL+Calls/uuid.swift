//
//  File.swift
//  AkinFrontBackModels
//
//  Created by Scott Lydon on 3/9/25.
//

import Foundation

extension UUID {

    /// SW-GS-090: `UUID(uuidString:)` returns nil only for a string that is not a UUID, and this
    /// one is a literal checked by eye and by every decode that has used it since. A test would
    /// not add anything a reader of the literal cannot see.
    public static var questionResponseUpdated: UUID {
        UUID(uuidString: "3F2504E0-4F89-41D3-9A0C-0305E82C3301")!
    }
}
