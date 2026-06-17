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
    
    func request<T: Decodable>(
        _ path: String,
        queryItems: [URLQueryItem]? = nil
    ) async throws -> T {

        var components = URLComponents(
            url: baseURL.appending(path: path),
            resolvingAgainstBaseURL: false
        )!

        components.queryItems = queryItems

        guard let url = components.url else {
            throw APIError.invalidResponse
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw APIError.invalidResponse
        }

        return try decoder.decode(T.self, from: data)
    }
    
    func requestOptional<T: Decodable>(
        _ path: String,
        queryItems: [URLQueryItem]? = nil
    ) async throws -> T? {

        var components = URLComponents(
            url: baseURL.appending(path: path),
            resolvingAgainstBaseURL: false
        )!

        components.queryItems = queryItems

        guard let url = components.url else {
            throw APIError.invalidResponse
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw APIError.invalidResponse
        }

        if data.isEmpty {
            return nil
        }

        return try decoder.decode(T.self, from: data)
    }
    
    func fetchShows() async throws -> [Show] {
        let timeslots: [TimeslotDTO] = try await request("timeslots")
        return timeslots.compactMap { $0.toShow() }
    }
    
    func fetchCurrentShow() async throws -> Show? {
        let timeslot: TimeslotDTO? = try await requestOptional("timeslots/current")
        
        if timeslot == nil {
            return nil
        }
        
        return timeslot!.toShow()
    }
    
}

enum APIError: Error {
    case invalidResponse
    case invalidStatusCode(Int)
    case decodingFailed
}

extension KDVSAPIService {
    func post<T: Decodable, B: Encodable>(
        _ path: String,
        body: B
    ) async throws -> T {
        let url = baseURL.appending(path: path)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw APIError.invalidResponse
        }

        return try decoder.decode(T.self, from: data)
    }

    func delete<T: Decodable>(
        _ path: String,
        queryItems: [URLQueryItem]? = nil
    ) async throws -> T {

        var components = URLComponents(
            url: baseURL.appending(path: path),
            resolvingAgainstBaseURL: false
        )!

        components.queryItems = queryItems

        guard let url = components.url else {
            throw APIError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw APIError.invalidResponse
        }

        return try decoder.decode(T.self, from: data)
    }
}
