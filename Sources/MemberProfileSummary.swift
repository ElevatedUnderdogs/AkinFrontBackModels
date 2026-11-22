//
//  MemberProfileSummary.swift
//

import Foundation
import StrongContractClient

/// What a member profile shows about a member beyond what the chip that opened it knew.
///
/// Build 27, B27-16: "It should show folllower count." A chip carries an ``AuthorSummary``, which
/// is a name, a face and an id, and nothing about the member's standing. The count is a fact only
/// the server holds, so the profile asks for it rather than deriving it, and a profile opened from
/// a chip and one opened from greet history ask the same question and get the same answer.
///
/// THE COUNT IS THE SUBJECT'S, NOT THE VIEWER'S, and it is public. It says how many members
/// subscribe to the member being looked at. It says nothing about who they are, which would be
/// a different disclosure, and nothing about whether the viewer is among them, which the
/// subscribe control already knows.
///
/// The property and the wire key are both `subscriberCount` / `subscriber_count`. This endpoint
/// never shipped under the old `followerCount` name, so there is no in-the-field spelling to
/// keep. Say subscribe, never follow, in all new code and wording.
public struct MemberProfileSummary: Codable, Hashable, Equatable, Sendable {

    /// The member this is about.
    public let memberId: UUID

    /// How many members subscribe to them.
    ///
    /// Not optional. A profile that cannot say the number draws no count at all, which is the
    /// request failing, and a request that succeeded with no number would be a second way to
    /// express the same absence.
    public let subscriberCount: Int

    public init(memberId: UUID, subscriberCount: Int) {
        self.memberId = memberId
        self.subscriberCount = subscriberCount
    }
}
