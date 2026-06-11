//
//  DeviceTokenStore.swift
//  KDVS
//
//  Created by John Carraher on 6/10/26.
//

import Foundation

final class DeviceTokenStore {
    static let shared = DeviceTokenStore()

    private let key = "APNSDeviceToken"

    private init() {}

    func save(_ token: String) {
        UserDefaults.standard.set(token, forKey: key)
    }

    func get() -> String? {
        UserDefaults.standard.string(forKey: key)
    }
}
