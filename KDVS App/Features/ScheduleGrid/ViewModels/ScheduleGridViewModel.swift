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

    private let api = KDVSAPIService()

    func load() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            shows = try await api.fetchShows()
        } catch {
            print(error)
        }
    }
}
