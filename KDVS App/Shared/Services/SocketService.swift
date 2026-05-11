//
//  SocketService.swift
//  KDVS
//
//  Created by John Carraher on 5/10/26.
//

import SocketIO
import Foundation

final class SocketService {
    
    private let manager = SocketManager (
        socketURL: URL(string: "https://acute-scientific-corleggy.glitch.me")!,
        config: [.connectParams(["appKey": "your-app-key"]), .log(true), .compress]
    )
    
    // Make this lazy connection after we create a socketService (after self exists)
    private lazy var socket = manager.defaultSocket

    func connect(){
        print("Connecting to Socket")
        socket.connect()
    }

    func disconnect(){
        print("Disconnecting from Socket")
        socket.disconnect()
    }

}
