//
//  ToastView.swift
//  KDVS
//
//  Created by John Carraher on 5/18/26.
//

import SwiftUI

struct ToastView: View {
    let message: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color.black.opacity(0.7))
                .frame(width: 100, height: 40)
            Text(message)
                .foregroundColor(.white)
                .fontWeight(.bold)
        }
    }
}
