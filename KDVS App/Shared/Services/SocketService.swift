//
//  SocketService.swift
//  KDVS
//
//  Created by John Carraher on 5/10/26.
//

import SocketIO
import Foundation

final class SocketService {

    static let shared = SocketService()

    private let manager = SocketManager(
        socketURL: Socket.server!,
        config: [
            .log(true),
            .compress
        ]
    )

    private lazy var socket = manager.defaultSocket

    private init() {
        setupHandlers()
    }

    func connect() {
        socket.connect()
    }

    func disconnect() {
        socket.disconnect()
    }

    func startListening() {
        socket.emit("startListening")
    }

    func stopListening() {
        socket.emit("stopListening")
    }

    private func setupHandlers() {

        socket.on(clientEvent: .connect) { data, ack in
            print("Socket connected")
        }

        socket.on(clientEvent: .disconnect) { data, ack in
            print("Socket disconnected")
        }

        socket.on("listenerCount") { data, ack in
            guard
                let payload = data.first as? [String: Any],
                let count = payload["count"] as? Int
            else {
                return
            }

            print("Current listeners: \(count)")
        }
    }
}
