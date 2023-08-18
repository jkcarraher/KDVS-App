//
//  PlayerView.swift
//  KDVS
//
//  Created by John Carraher on 4/18/23.
//

import SwiftUI
import AVKit
import MediaPlayer
import SwiftSoup

struct PlayerView : View {
    let streamURL = URL(string: "https://archives.kdvs.org/stream")!
    
    @Binding var openRemind: Bool
    @Binding var show : Show
    @Binding var audioPlayer: AVPlayer
    @Binding var isLoading: Bool
    @Binding var isPlaying: Bool


    @State private var isShowingRemindView = false
    @State private var audioSessionInterruptionObserver: NSObjectProtocol?
    
    var body: some View {
        VStack {
            if(isLoading){
                LoadingPlayerView()
            } else{
                VStack {
                    ShowArt(show: show)
                    HStack (alignment: .top){
                        VStack (alignment: .leading, spacing: 0) {
                            ScrollViewReader { scrollViewProxy in
                                ScrollView(.horizontal, showsIndicators: false) {
                                    Text(show.name)
                                        .font(.system(size: 20, weight: .medium))
                                        .environment(\.colorScheme, .dark)
                                        .lineLimit(1)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            ScrollView(.horizontal, showsIndicators: false) {
                                Text(show.djName!)
                                    .font(.system(size: 15, weight: .medium))
                                    .lineLimit(1)
                                    .environment(\.colorScheme, .dark)
                                    .foregroundColor(Color("SecondaryText"))
                            }
                            
                        }
                        .frame(width: 230, alignment: .leading)
                        .padding([.top, .trailing], 5)
                        
                        Button(action: {
                            openRemind = true
                        }, label: {
                            Image(systemName: "info.circle.fill")
                                .resizable()
                                .foregroundColor(Color("NotiPrimary"))
                                .environment(\.colorScheme, .dark)
                                .background(Color.clear)
                                .frame(width: 20, height: 20)
                            
                        }).frame(width: 40, height: 40, alignment: .center)
                            .background(Color("NotiButtonColor"))
                            .cornerRadius(10)
                            .padding([.top], 7)
                    }
                    .frame(width: 290, alignment: .leading)
                    .padding([.leading], 15)
                }
                .frame(width: 310, height: 360, alignment: .top)
                .padding([.top], 10)
                .background(Color("BoxBlack"))
                .cornerRadius(10)
                .shadow(color: Color("InnerShadow"), radius: 1, x: 0, y: 2)
                
                
                //PAUSE PLAY BUTTONS
                ZStack {
                    VStack{
                        Button(action: togglePlayPause, label: {
                            Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                                .resizable()
                                .foregroundColor(Color(UIColor.label))
                                .environment(\.colorScheme, .dark)
                                .background(Color.clear)
                                .frame(width: 30, height: 30)
                                .padding(isPlaying ? EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0) : EdgeInsets(top: 0, leading: 22, bottom: 0, trailing: 0))
                        }).frame(width: 70, height: 70, alignment: isPlaying ? .center : .leading)
                            .background(Color("BoxColor"))
                            .cornerRadius(35)
                    }.frame(width: 80, height: 80)
                        .background(Color("ButtonBackground"))
                        .cornerRadius(40)
                }.padding()
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
    
    private func togglePlayPause() {
        if isPlaying {
            audioPlayer.pause()
            isPlaying = false
            disconnectToSocket()
        } else {
            audioPlayer.play()
            isPlaying = true
            connectToSocket()
        }
    }
}


struct LoadingPlayerView : View {
    var body: some View {
        VStack {
            Rectangle()
                .fill(Color("DeadScreen"))
                .frame(width: 290, height: 290, alignment: .center)
                .cornerRadius(5)
                
            

            HStack (alignment: .top){
                VStack (alignment: .leading, spacing: 0) {
                    Rectangle().fill(Color("Loading"))
                        .frame(width: 230, height: 18)
                        .padding([.top], 3)
                    Rectangle().fill(Color("Loading"))
                        .frame(width: 100, height: 10)
                        .padding([.top], 7)

                
                }
                .frame(width: 230, alignment: .leading)
                .padding([.top, .trailing], 5)
                
                Button(action: toggleNothing, label: {
                    Image(systemName: "info.circle.fill")
                        .resizable()
                        .foregroundColor(Color("DisabledButton"))
                        .environment(\.colorScheme, .dark)
                        .background(Color.clear)
                        .frame(width: 20, height: 20)
                }).frame(width: 40, height: 40, alignment: .center)
                    .background(Color("NotiButtonColor"))
                    .cornerRadius(10)
                    .padding([.top], 7)
                    
            }
            .frame(width: 290, alignment: .leading)
            .padding([.leading], 15)
            
            
        }
        .frame(width: 310, height: 360, alignment: .top)
        .padding([.top], 10)
        .background(Color("BoxBlack"))
        .cornerRadius(10)
        .shadow(color: Color("InnerShadow"), radius: 1, x: 0, y: 2)
        
        
        //PAUSE PLAY BUTTONS
        ZStack {
            VStack{
                Button(action: toggleNothing, label: {
                    Image(systemName: "play.fill")
                        .resizable()
                        .foregroundColor(Color("DisabledButton"))
                        .environment(\.colorScheme, .dark)
                        .background(Color.clear)
                        .frame(width: 30, height: 30)
                        .padding(EdgeInsets(top: 0, leading: 22, bottom: 0, trailing: 0))
                }).frame(width: 70, height: 70, alignment: .leading)
                    .background(Color("BoxColor"))
                    .cornerRadius(35)
                    
            }.frame(width: 80, height: 80)
                .background(Color("ButtonBackground"))
                .cornerRadius(40)
        }.padding()
    }

    private func toggleNothing() {
        
    }
}

