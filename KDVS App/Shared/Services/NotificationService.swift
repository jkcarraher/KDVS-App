//
//  NotificationService.swift
//  KDVS
//
//  Created by John Carraher on 6/10/26.
//

import Foundation

final class NotificationService {
    private let apiService: KDVSAPIService

    init(apiService: KDVSAPIService) {
        self.apiService = apiService
    }

    func subscribe(showId: String) async throws {
        let deviceToken = try getDeviceToken()

        let body = SubscribeRequest(
            deviceToken: deviceToken,
            showId: showId
        )

        let _: SuccessResponse = try await apiService.post(
            "notifications/subscribe",
            body: body
        )
    }

    func unsubscribe(showId: String) async throws {
        let deviceToken = try getDeviceToken()

        let _: SuccessResponse = try await apiService.delete(
            "notifications/subscribe/\(showId)",
            queryItems: [
                URLQueryItem(name: "deviceToken", value: deviceToken)
            ]
        )
    }

    func isSubscribed(showId: String) async throws -> Bool {
        let deviceToken = try getDeviceToken()

        let response: SubscriptionStatusResponse = try await apiService.request(
            "notifications/subscribe/\(showId)",
            queryItems: [
                URLQueryItem(name: "deviceToken", value: deviceToken)
            ]
        )

        return response.subscribed
    }
    
    func fetchShowSubscriptions() async throws -> [ShowDTO] {
        let deviceToken = try getDeviceToken()

        return try await apiService.request(
            "notifications/subscriptions",
            queryItems: [
                URLQueryItem(
                    name: "deviceToken",
                    value: deviceToken
                )
            ]
        )
    }

    private func getDeviceToken() throws -> String {
        guard let token = DeviceTokenStore.shared.get(),
              !token.isEmpty else {
            throw NotificationServiceError.missingDeviceToken
        }
        return token
    }
}
enum NotificationServiceError: Error {
    case missingDeviceToken
}

struct SubscriptionStatusResponse: Decodable {
    let subscribed: Bool
}

struct SubscribeRequest: Encodable {
    let deviceToken: String
    let showId: String
}

struct SuccessResponse: Decodable {
    let success: Bool
}
