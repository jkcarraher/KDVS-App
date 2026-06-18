//
//  LargeRemindViewModel.swift
//  KDVS
//
//  Created by John Carraher on 6/17/26.
//

import Foundation
import UIKit

@MainActor
final class LargeRemindViewModel: ObservableObject {
    @Published var show: Show
    @Published var showImage: UIImage?
    @Published var showDates: Set<DateComponents> = []
    
    @Published var isDatesLoading = true
    @Published var isSubscribed = false
    @Published var isLoadingSubscription = true
    @Published var isPerformingNotificationAction = false
    @Published var errorMessage: String?

    private let notificationService: NotificationService

    init(show: Show, notificationService: NotificationService) {
        self.show = show
        self.notificationService = notificationService
    }
    
    func loadImage() async {
        if let url = show.playlistImageURL {
            self.showImage = await ImageCacheService.shared.loadImage(from: url)
        } else {
            self.showImage = nil
        }
    }
    
    func loadDates() {
        isDatesLoading = true
        self.showDates = Set(show.dates.map {
            Calendar.current.dateComponents([.year, .month, .day], from: $0)
        })
        isDatesLoading = false
    }

    func loadSubscriptionStatus() async {
        isLoadingSubscription = true

        defer {
            isLoadingSubscription = false
        }

        do {
            isSubscribed = try await notificationService.isSubscribed(
                showId: show.id
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
            if isSubscribed {
                try await notificationService.unsubscribe(
                    showId: show.id
                )
                
                isSubscribed = false
            } else {
                try await notificationService.subscribe(
                    showId: show.id
                )
                
                isSubscribed = true
            }
        } catch {
            print("Notification action failed:", error)
        }
    }

}
