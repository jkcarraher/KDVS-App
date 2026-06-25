//
//  KDVS_AppApp.swift
//  KDVS App
//
//  Created by John Carraher on 2/17/23.
//

import SwiftUI

@main
struct KDVS_AppApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate
    
    let audioService = AudioPlayerService()
    let socketService = SocketService()
    let apiService = KDVSAPIService()
    
    let notificationService: NotificationService
    let showService: ShowService

    init() {
        self.showService = ShowService(apiService: apiService)
        self.notificationService = NotificationService(apiService: apiService)
    }

    var body: some Scene {
        WindowGroup {
            ContentView(showService: showService)
                .environmentObject(showService)
                .environmentObject(notificationService)
                .environmentObject(audioService)
                .environmentObject(socketService)
                .task {
                    await registerForNotifications()
                }
        }
    }
}

private func registerForNotifications() async {
    do {
        let granted = try await UNUserNotificationCenter.current()
            .requestAuthorization(
                options: [.alert, .badge, .sound]
            )

        print("Notification permission granted:", granted)

        if granted {
            await MainActor.run {
                print("Registering for remote notifications...")
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    } catch {
        print("Notification permission error:", error)
    }
}
