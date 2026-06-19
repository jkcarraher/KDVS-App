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
            Circle()
                .fill(Color("ButtonBackground"))
                .frame(width: 80, height: 80)

            Button(action: action) {
                ZStack {
                    Circle()
                        .fill(Color("BoxColor"))

                    Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color(UIColor.label))
                        .environment(\.colorScheme, .dark)
                        .background(Color.clear)
                        .frame(width: 30, height: 30)
                        .offset(x: isPlaying ? 0 : 4)
                }
                .frame(width: 70, height: 70)
                .contentShape(Circle())
            }
        }
        .padding()
    }
}
