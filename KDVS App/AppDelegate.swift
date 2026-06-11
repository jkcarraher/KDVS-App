//
//  AppDelegate.swift
//  KDVS
//
//  Created by John Carraher on 6/10/26.
//

import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {

    override init() {
        super.init()
        print("AppDelegate initialized")
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let token = deviceToken.map {
            String(format: "%02.2hhx", $0)
        }.joined()

        DeviceTokenStore.shared.save(token)

        print("APNS Token:", token)
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register for notifications:", error)
    }
}
