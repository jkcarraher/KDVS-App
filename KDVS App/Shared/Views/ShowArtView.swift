//
//  ShowArtView.swift
//  KDVS
//
//  Created by John Carraher on 5/18/26.
//

import SwiftUI

struct ShowArt : View {
    var show : Show
    
    var body: some View {
        ZStack(alignment: .bottom, content: {
            AsyncImage(url: show.playlistImageURL) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .frame(width: 290, height: 290, alignment: .center)
            } placeholder: {
                ProgressView()
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("\(show.startTime.formattedTime(endTime: show.endTime))")
                        .foregroundColor(.white)
                        .font(.system(size: 15, weight: .bold))
                        .padding(.all, 5)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(5)
                }
            }
            .padding(.all, 10)
        })
        .frame(width: 290, height: 290, alignment: .top)
        .background(Color.white)
        .cornerRadius(5)
    }
}

