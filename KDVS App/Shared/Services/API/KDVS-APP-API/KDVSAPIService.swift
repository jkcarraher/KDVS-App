//
//  KDVSApiService.swift
//  KDVS
//
//  Created by John Carraher on 6/6/26.
//

import Foundation

final class KDVSAPIService {
    private let baseURL = URL(string: "https://kdvs-api.jkcarraher.com/v1")!
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
    
    func fetchTimeslots() async throws -> [TimeslotDTO] {
        try await request("timeslots")
    }
    
    func fetchShows() async throws -> [ShowDTO] {
        try await request("shows")
    }
    
    func fetchPersonas() async throws -> [PersonaDTO] {
        try await request("personas")
    }
    
    func fetchSeasons() async throws -> [SeasonDTO] {
        try await request("seasons")
    }
    
}

enum APIError: Error {
    case invalidResponse
    case invalidStatusCode(Int)
    case decodingFailed
}
