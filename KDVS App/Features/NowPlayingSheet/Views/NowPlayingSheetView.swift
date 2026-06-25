//
//  NowPlayingSheetView.swift
//  KDVS
//
//  Created by John Carraher on 6/24/26.
//

import SwiftUI

struct NowPlayingSheetView: View {
    @Binding var show : Show?
    @State var remindLabel = "CURRENT SHOW"

    var body: some View {
        VStack{
            Spacer()
            Text("Now Playing")
                .font(.system(size: 30, weight: .bold))
                .environment(\.colorScheme, .dark)
                .foregroundColor(Color.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.horizontal, .top], 20)
            if let show {
                RemindView(
                    show: .constant(show),
                    label: $remindLabel
                )
            } else {
                Text("No show is currently scheduled.")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            NowPlayingView()
            Spacer()
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
