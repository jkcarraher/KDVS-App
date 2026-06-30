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

    private let manager = SocketManager( socketURL: Socket.server! )

    private lazy var socket = manager.defaultSocket

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
}
