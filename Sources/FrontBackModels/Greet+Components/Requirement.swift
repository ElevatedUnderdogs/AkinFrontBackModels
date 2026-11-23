//
//  Requirement.swift
//  akin
//
//  Created by Scott Lydon on 8/4/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//

public typealias RequirementAction = (Requirement) -> Void

public enum Requirement: Equatable, Codable {
    /// Why do we need explicit coding keys when they match what would be synthesized?
    /// In order to give them CaseIterable conformance for schema generators to list every case.
    /// Schema generator: https://github.com/ElevatedUnderdogs/DecodableSchema
    enum CodingKeys: String, CodingKey, CaseIterable {
        case birthday, location, profilePic, pushNotification, callKitConsent
    }

    case birthday,
         location(Location),
         profilePic,
         pushNotification(PushNotification),
         callKitConsent

    public enum Location: Codable, CaseIterable {
        case regular, requiresDeeplinkToSettings, shouldUpgradeToAlways
    }

    public enum PushNotification: Codable, CaseIterable {
        case requiresDeeplinkToSettings, regular
    }

    // MARK: - inits
    init?(from authorizationStatus: LocationAuthorizationStatus) {
        switch authorizationStatus {
        case .notDetermined:
            self = .location(.regular)
        case .restricted:
            self = .location(.requiresDeeplinkToSettings)
        case .denied: 
            self = .location(.requiresDeeplinkToSettings)
        case .authorizedAlways: 
            return nil
        case .authorizedWhenInUse:
            self = .location(.shouldUpgradeToAlways)
        }
    }

    @available(macOS 10.14, *)
    init?(from authStatus: NotificationAuthorizationStatus) {
        switch authStatus {
        case .notDetermined:
            self = .pushNotification(.regular)
        case .denied:
            self = .pushNotification(.requiresDeeplinkToSettings)
        case .authorized, .ephemeral:
            return nil
        case .provisional:
            self = .pushNotification(.requiresDeeplinkToSettings)
        }
    }

    init?(from profilePicString: String?) {
        if profilePicString == nil {
            self = .profilePic
        } else {
            return nil
        }
    }
}
