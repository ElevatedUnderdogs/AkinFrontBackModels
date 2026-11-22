//
//  MemberProfileSummaryWireProbe.swift
//

import Foundation

/// The count keys of an encoded `MemberProfileSummary`, read back by their wire names.
///
/// `followerCount` is here so a test can show that the old spelling is never on the wire.
struct MemberProfileSummaryWireProbe: Decodable {

    /// The value under `subscriber_count`.
    let subscriberCount: Int?

    /// The value under `follower_count`, which must always be absent.
    let followerCount: Int?

    enum CodingKeys: String, CodingKey {
        case subscriberCount = "subscriber_count"
        case followerCount = "follower_count"
    }
}
