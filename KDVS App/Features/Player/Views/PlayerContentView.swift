//
//  PlayerContentView.swift
//  KDVS
//
//  Created by John Carraher on 5/10/26.
//

import SwiftUI

struct PlayerContentView: View {
    let show: Show?
    let showImage: UIImage?
    let errorMessage: String?
    let isPlaying: Bool
    let onPlayPause: () -> Void
    let onOpenReminder: () -> Void
    
    var body: some View {
        VStack {
            if show != nil {
                
            }
            ShowArtView(show: show, showImage: showImage, errorMessage: errorMessage)
            HStack (alignment: .top){
                VStack (alignment: .leading, spacing: 0) {
                    ScrollViewReader { scrollViewProxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            Text(show?.name ?? "")
                                .font(.system(size: 20, weight: .medium))
                                .environment(\.colorScheme, .dark)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    ScrollView(.horizontal, showsIndicators: false) {
                        Text(show?.djName ?? "")
                            .font(.system(size: 15, weight: .medium))
                            .lineLimit(1)
                            .environment(\.colorScheme, .dark)
                            .foregroundColor(Color("SecondaryText"))
                    }
                    
                }
                .frame(width: 230, alignment: .leading)
                .padding([.top, .trailing], 5)
                
                RemindButton(action: onOpenReminder)
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
        PausePlayButton( isPlaying: isPlaying, action: onPlayPause )
    }
}
