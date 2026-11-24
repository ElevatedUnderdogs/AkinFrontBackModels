import Foundation
import StrongContractClient

/// The oldest app version the server still supports. Older apps ask the member to update.
public struct AppVersionRequirement: Codable, Hashable, Sendable {

    /// Oldest supported iOS `CFBundleShortVersionString`, e.g. "2.4.0". Nil blocks nobody.
    public let minimumIOSVersion: String?

    public init(minimumIOSVersion: String?) {
        self.minimumIOSVersion = minimumIOSVersion
    }

    /// Whether `version` is older than the minimum. Compares numerically, part by part.
    /// - Parameter version: The app's `CFBundleShortVersionString`.
    /// - Returns: True only when a minimum is set and `version` is below it.
    public func requiresUpdate(from version: String) -> Bool {
        guard let minimumIOSVersion else { return false }
        return version.compare(minimumIOSVersion, options: .numeric) == .orderedAscending
    }
}

public typealias AppVersionCheck = Request<Empty, AppVersionRequirement>
extension AppVersionCheck {

    /// Unauthenticated, so it can be checked at launch before sign-in.
    public static var appVersionRequirement: Self {
        .init(method: .get, assertHasAccessToken: false)
    }
}
