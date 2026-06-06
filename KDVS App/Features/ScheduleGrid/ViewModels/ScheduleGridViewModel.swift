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
    
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let api = KDVSAPIService()

    func load() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            shows = try await api.fetchShows()
        } catch {
            errorMessage = error.localizedDescription
            print("Failed to load shows:", error)
        }
    }
}
