//
//  KDVS_AppApp.swift
//  KDVS App
//
//  Created by John Carraher on 2/17/23.
//

import SwiftUI

@main
struct KDVS_AppApp: App {
    
    let audioService = AudioPlayerService()
    let socketService = SocketService()
    let showService = ShowService()

    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


