//
//  Requirement.swift
//  akin
//
//  Created by Scott Lydon on 8/4/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//

public typealias RequirementAction = (Requirement) -> Void

public enum Requirement: Equatable, Codable {

    case birthday,
         location(Location),
         profilePic,
         pushNotification(PushNotification)

    public enum Location: Codable {
        case regular, requiresDeeplinkToSettings, shouldUpgradeToAlways
    }

    public enum PushNotification: Codable {
        case requiresDeeplinkToSettings, regular
    }

    // MARK - inits
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
