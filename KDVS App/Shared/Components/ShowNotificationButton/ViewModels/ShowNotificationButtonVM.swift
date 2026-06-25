//
//  ShowNotificationButtonVM.swift
//  KDVS
//
//  Created by John Carraher on 6/24/26.
//

import Foundation
import UIKit

@MainActor
final class ShowNotificationButtonVM: ObservableObject {
    let showId: String
    @Published var isSubscribed = false
    
    @Published var isLoading = false
    @Published var isPerformingNotificationAction = false

    private let notificationService: NotificationService
    
    init(showId: String, notificationService: NotificationService) {
        self.showId = showId
        self.notificationService = notificationService
    }
    
    func loadSubscriptionStatus() async {
        isLoading = true

        defer {
            isLoading = false
        }

        do {
            isSubscribed = try await notificationService.isSubscribed(
                showId: showId
            )
        } catch {
            print("Failed to load subscription status:", error)
            isSubscribed = false
        }
    }

    func toggleRemindButton() async {
        guard !isPerformingNotificationAction else {
            return
        }
        
        isPerformingNotificationAction = true
        
        defer {
            isPerformingNotificationAction = false
        }
        
        do {
            let newValue = !isSubscribed

            if newValue {
                try await notificationService.subscribe(showId: showId)
            } else {
                try await notificationService.unsubscribe(showId: showId)
            }

            isSubscribed = newValue
        } catch {
            print("Notification action failed:", error)
        }
    }

}
