//
//  PlayerView.swift
//  KDVS
//
//  Created by John Carraher on 5/10/26.
//

import SwiftUI

struct PlayerView2: View {
    @StateObject private var vm: PlayerViewModel

    init(
        audioService: AudioPlayerService,
        socketService: SocketService
    ) {
        _vm = StateObject(
            wrappedValue: PlayerViewModel(
                playerService: audioService,
                socketService: socketService
            )
        )
    }
    
    var body: some View {
        VStack {
            if(vm.isLoading){
                LoadingPlayerView()
            } else{
                VStack {
                    ShowArt(show: vm.show)
                    HStack (alignment: .top){
                        VStack (alignment: .leading, spacing: 0) {
                            ScrollViewReader { scrollViewProxy in
                                ScrollView(.horizontal, showsIndicators: false) {
                                    Text(vm.show.name)
                                        .font(.system(size: 20, weight: .medium))
                                        .environment(\.colorScheme, .dark)
                                        .lineLimit(1)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            ScrollView(.horizontal, showsIndicators: false) {
                                Text(vm.show.djName)
                                    .font(.system(size: 15, weight: .medium))
                                    .lineLimit(1)
                                    .environment(\.colorScheme, .dark)
                                    .foregroundColor(Color("SecondaryText"))
                            }
                            
                        }
                        .frame(width: 230, alignment: .leading)
                        .padding([.top, .trailing], 5)
                        
                        RemindButton(action: vm.openReminderSheet)                    }
                    .frame(width: 290, alignment: .leading)
                    .padding([.leading], 15)
                }
                .frame(width: 310, height: 360, alignment: .top)
                .padding([.top], 10)
                .background(Color("BoxBlack"))
                .cornerRadius(10)
                .shadow(color: Color("InnerShadow"), radius: 1, x: 0, y: 2)
                
                
                //PAUSE PLAY BUTTONS
                PausePlayButton( isPlaying: vm.isPlaying, action: vm.togglePlayback )
            }
        }.frame(width: 330, height: 490, alignment: .top)
        .padding([.top], 10)
        .background(Color("BoxColor"))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color("OutlineColor"), lineWidth: 2)
        )
    }
    

    
    
}
