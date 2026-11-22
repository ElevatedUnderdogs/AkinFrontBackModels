//
//  QuestionnaireDetailWireProbe.swift
//

import Foundation

/// The two creator keys of an encoded `QuestionnaireDetailDTO`, read back by their wire names.
///
/// A test decodes the encoded bytes into this rather than into a `[String: Any]`, so the wire
/// spelling it checks is written once, here, as a coding key.
struct QuestionnaireDetailWireProbe: Decodable {

    /// The value under `creator_image_url`.
    let creatorImageURL: String?

    /// The value under `creator_name`.
    let creatorName: String?

    enum CodingKeys: String, CodingKey {
        case creatorImageURL = "creator_image_url"
        case creatorName = "creator_name"
    }
}
