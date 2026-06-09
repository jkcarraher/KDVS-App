//
//  PlayerView.swift
//  KDVS
//
//  Created by John Carraher on 5/10/26.
//

import SwiftUI

struct PlayerView: View {
    @StateObject private var vm: PlayerViewModel

    init(
        audioService: AudioPlayerService,
        socketService: SocketService,
        showService: ShowService
    ) {
        _vm = StateObject(
            wrappedValue: PlayerViewModel(
                playerService: audioService,
                socketService: socketService,
                showService: showService,
            )
        )
    }
    
    var body: some View {
        VStack {
            if(vm.isLoading){
                LoadingPlayerView()
            } else {
                PlayerContentView(show: vm.show, isPlaying: vm.isPlaying, onPlayPause: vm.togglePlayback, onOpenReminder: vm.openReminderSheet)
            }
        }.frame(width: 330, height: 490, alignment: .top)
        .padding([.top], 10)
        .background(Color("BoxColor"))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color("OutlineColor"), lineWidth: 2)
        )
        .sheet(isPresented: $vm.showReminderSheet) {
            SheetView(show: $vm.show)
                .environment(\.colorScheme, .dark)
                .presentationDetents([.height(450), .large])
                .background(Color("RemindBackground"))
            
        }
        .task {
            await vm.loadCurrentShow()
        }
    }
    

    
    
}
