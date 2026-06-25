//
//  ShowService.swift
//  KDVS
//
//  Created by John Carraher on 5/18/26.
//

import Foundation

final class ShowService: ObservableObject {
    private let apiService: KDVSAPIService
    
    init (apiService: KDVSAPIService) {
        self.apiService = apiService
    }

    func getCurrentShow() async throws -> Show? {
        try await apiService.fetchCurrentShow()
    }
    
    func getAllActiveShows() async throws -> [Show] {
        try await apiService.fetchAllActiveShows()
    }
}

enum ShowServiceError: Error {
    case invalidBody
    case invalidHTML
}
