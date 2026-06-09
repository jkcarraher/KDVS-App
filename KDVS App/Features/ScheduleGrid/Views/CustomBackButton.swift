//
//  CustomBackButton.swift
//  KDVS
//
//  Created by John Carraher on 6/6/26.
//

import SwiftUI

struct CustomBackButton: View {
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.backward.circle.fill")
                .symbolRenderingMode(.hierarchical)
                .environment(\.colorScheme, .dark)
                .padding(.horizontal)
                .foregroundColor(.gray)

        }
    }
}
