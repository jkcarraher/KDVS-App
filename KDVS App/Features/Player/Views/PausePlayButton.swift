//
//  PausePlayButton.swift
//  KDVS
//
//  Created by John Carraher on 5/10/26.
//

import SwiftUI

struct PausePlayButton: View {
    let isPlaying: Bool
    let action: () -> Void
    
    var body: some View {
        ZStack {
            VStack{
                Button(action: action, label: {
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
}
