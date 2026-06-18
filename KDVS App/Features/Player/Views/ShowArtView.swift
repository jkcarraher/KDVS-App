//
//  ShowArtView.swift
//  KDVS
//
//  Created by John Carraher on 5/18/26.
//

import SwiftUI

struct ShowArtView : View {
    var show : Show?
    var showImage: UIImage?
    var errorMessage: String?

    
    var body: some View {
        ZStack(alignment: .bottom, content: {
            Group {
                if let errorMessage {
                    VStack(spacing: 20){
                        Image("Cloud_error_icon")
                            .scaleEffect(1.2)
                        Text(errorMessage)
                            .font(Font.custom(
                                "Silkscreen-Regular",
                                size: 10))
                    }
                } else if let showImage {
                    Image(uiImage: showImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    VStack(spacing: 20){
                        Image("Unavailable_icon")
                            .scaleEffect(1.2)
                        Text("Error: Unscheduled Programming")
                            .font(Font.custom(
                                "Silkscreen-Regular",
                                size: 10))
                    }
                }
            }
            .frame(width: 290, height: 290)
            if show != nil {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text((show!.startTime.to12HourString()+" - "+show!.endTime.to12HourString()))
                            .foregroundColor(.white)
                            .font(.system(size: 15, weight: .bold))
                            .padding(.all, 5)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(5)
                    }
                }
                .padding(.all, 10)
            }
        })
        .frame(width: 290, height: 290, alignment: .top)
        .background(Color.white)
        .cornerRadius(5)
    }
}

