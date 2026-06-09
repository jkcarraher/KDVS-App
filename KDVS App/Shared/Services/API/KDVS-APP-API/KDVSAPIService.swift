//
//  KDVSApiService.swift
//  KDVS
//
//  Created by John Carraher on 6/6/26.
//

import Foundation

final class KDVSAPIService {
    private let baseURL = API.KDVS_App.v1
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        return decoder
    }()
    
    private func request<T: Decodable>(
        _ path: String
    ) async throws -> T {
        let url = baseURL.appending(path: path)
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw APIError.invalidResponse
        }
        
        return try decoder.decode(T.self, from: data)
    }
    
    func fetchShows() async throws -> [Show] {
        let timeslots: [TimeslotDTO] = try await request("timeslots")
        return timeslots.compactMap { $0.toShow() }
    }
    
    func fetchCurrentShow() async throws -> Show {
        let timeslot: TimeslotDTO = try await request("timeslots/current")
        return timeslot.toShow()
    }
    
}

enum APIError: Error {
    case invalidResponse
    case invalidStatusCode(Int)
    case decodingFailed
}
