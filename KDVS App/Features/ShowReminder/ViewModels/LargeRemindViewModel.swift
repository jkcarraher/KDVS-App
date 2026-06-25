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
    
    private var showCalendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = show.timezone
        return cal
    }

    init(show: Show) {
        self.show = show
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
            showCalendar.dateComponents([.year, .month, .day], from: $0)
        })
        isDatesLoading = false
    }
}
