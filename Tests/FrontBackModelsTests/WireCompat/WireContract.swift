//
//  WireContract.swift
//  FrontBackModelsTests
//
//  One contract's payload and response types, erased so samples can be checked in a loop.
//

import Foundation
import StrongContractClient
@testable import AkinFrontBackModels

struct WireContract {
    /// The route path; samples are matched to contracts by it.
    let path: String
    let label: String
    let decodePayload: (Data) throws -> Void
    let decodeResponse: (Data) throws -> Void

    init<P: Codable, R: Codable>(_ request: Request<P, R>) {
        path = request.path
        label = "\(P.self) -> \(R.self)"
        decodePayload = { _ = try JSONDecoder().decode(P.self, from: $0) }
        decodeResponse = { _ = try JSONDecoder().decode(R.self, from: $0) }
    }
}
