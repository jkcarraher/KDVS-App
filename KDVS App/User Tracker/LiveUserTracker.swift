//
//  LiveUserTracking.swift
//  KDVS
//
//  Created by John Carraher on 5/31/23.
//

import Foundation
import AVKit
import SocketIO

let socketManager = SocketManager(socketURL: URL(string: "https://acute-scientific-corleggy.glitch.me")!,
                                  config: [.connectParams(["appKey": "your-app-key"]), .log(true), .compress])

let socket = socketManager.defaultSocket

func connectToSocket(){
    print("Connecting to Socket")
    socket.connect()
}

func disconnectToSocket(){
    print("Disconnecting from Socket")
    socket.disconnect()
}

