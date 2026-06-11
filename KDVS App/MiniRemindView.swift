//
//  MiniRemindView.swift
//  KDVS
//
//  Created by John Carraher on 6/10/26.
//

import SwiftUI

struct MiniRemindView: View {
    @Binding var show : ShowDTO
    @Binding var label : String

    @State private var isPerformingNotificationAction = false
    
    @State private var image: UIImage?
    
    @State private var selectedDate = Date()
    @State private var dates: Set<DateComponents> = []
    
    
    var body: some View {
        VStack {
            HStack {
                //Display Rectangle with music note icon and a 30x30 rectangle with a background
                ZStack {
                    Rectangle()
//                        .fill(show.color)
                    Image(systemName: "music.note") // Outlined bell icon
                        .font(.system(size: 15))
                        .foregroundColor(Color(.white))
                }
                .frame(width: 30, height: 30)
                .cornerRadius(5)
                .padding([.leading], 12)

                
                Text(show.name)
                    .font(.system(size: 15, weight: .bold))
                    .environment(\.colorScheme, .dark)
                    .frame(alignment: .leading)
                    .padding([.leading], 8)
                Spacer()
            }.frame(width: 350)
            .padding([.leading, .trailing], 15)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
        
    }
}
