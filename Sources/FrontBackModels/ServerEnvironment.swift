//
//  File.swift
//  AkinFrontBackModels
//
//  Created by Scott Lydon on 4/3/25.
//

import Foundation

public enum ServerEnvironment: String, CaseIterable, Identifiable, Codable, Hashable, Equatable {
    /// Used for when working on a personal dev machine.  For example, saving images to the local file structure.
    case dev

    /// Used for when working on a staging web service.  For example, working with s3, called from a
    /// deployed render staging instance.
    case debug

    /// Used for when working on a staging web service.  For example, working with s3, called from a
    ///  deployed render production instance.
    case prod

    /// Used for conformance to identifiable
    public var id: String { rawValue }
}
