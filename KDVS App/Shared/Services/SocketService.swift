//
//  SocketService.swift
//  KDVS
//
//  Created by John Carraher on 5/10/26.
//

import SocketIO
import Foundation

final class SocketService: ObservableObject {
    
    private let manager = SocketManager (
        socketURL: URL(string: "https://acute-scientific-corleggy.glitch.me")!
    )
    
    // Make this lazy connection after we create a socketService (after self exists)
    private lazy var socket = manager.defaultSocket

    func connect(){
        socket.connect()
    }

    func disconnect(){
        socket.disconnect()
    }

}
