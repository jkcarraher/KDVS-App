//
//  RemindButton.swift
//  KDVS
//
//  Created by John Carraher on 5/10/26.
//

import SwiftUI

struct RemindButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color("NotiButtonColor"))

                Image(systemName: "info.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color("NotiPrimary"))
                    .environment(\.colorScheme, .dark)
            }
            .frame(width: 40, height: 40)
            .contentShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(.top, 7)
    }
}
