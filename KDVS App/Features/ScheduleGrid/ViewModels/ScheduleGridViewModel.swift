//
//  ScheduleGridViewModel.swift
//  KDVS
//
//  Created by John Carraher on 6/5/26.
//

import Foundation

@MainActor
final class ScheduleGridViewModel: ObservableObject {
    @Published var shows: [Show] = []
    @Published var searchText: String = ""
    @Published var selectedShow: Show?
    @Published var selectedDay: DayOfWeek? = nil
    
    @Published var isShowingSheet = false
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private let showService: ShowService

    init(showService: ShowService) {
        self.showService = showService
    }
    
    var filteredShows: [Show] {
        var result = shows

        if let selectedDay {
            result = result.filter { $0.DOTW == selectedDay.displayName }
        }

        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result
    }
    
    func load() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            shows = try await showService.getAllActiveShows()
        } catch {
            errorMessage = error.localizedDescription
            print("Failed to load shows:", error)
        }
    }
}
