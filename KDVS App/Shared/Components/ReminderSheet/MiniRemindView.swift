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
    
    var body: some View {
        HStack {
            ZStack {
                Rectangle()
                    .fill(Color(hex: show.color) ?? .gray)

                Image(systemName: "music.note")
                    .font(.system(size: 15))
                    .foregroundColor(.white)
            }
            .frame(width: 30, height: 30)
            .cornerRadius(5)
            .padding(.leading, 12)

            Text(show.name)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
                .padding(.leading, 8)

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 15)
    }
}
