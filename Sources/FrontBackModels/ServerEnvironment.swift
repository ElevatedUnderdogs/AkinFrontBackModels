//
//  File.swift
//  AkinFrontBackModels
//
//  Created by Scott Lydon on 4/3/25.
//

import Foundation

public enum ServerEnvironment: String, CaseIterable, Identifiable, Codable, Hashable, Equatable {
    /// A personal dev machine. For example, saving images to the local file structure.
    case dev

    /// A deployed Render staging instance. Images are stored in Cloudflare Images.
    case debug

    /// A deployed Render production instance. Images are stored in Cloudflare Images.
    case prod

    /// Used for conformance to identifiable
    public var id: String { rawValue }
}
