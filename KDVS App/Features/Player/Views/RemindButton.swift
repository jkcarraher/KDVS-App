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
        Button(action: action, label: {
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
}
