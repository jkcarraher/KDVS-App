//
//  SettingsView.swift
//  KDVS
//
//  Created by John Carraher on 6/19/26.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        Spacer()
        Text("Settings")
            .font(.system(size: 30, weight: .bold))
            .environment(\.colorScheme, .dark)
            .foregroundColor(Color.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 25)
            .padding(.vertical, 15)
        ReminderManagerView()
        CreditView()
        Spacer()
    }
}
