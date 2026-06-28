//
//  ShareShowButton.swift
//  KDVS
//
//  Created by John Carraher on 6/27/26.
//

import SwiftUI

struct ShareShowButton: View {
    @StateObject private var vm: ShareShowButtonVM

    init(show: Show) {
        _vm = StateObject(
            wrappedValue: ShareShowButtonVM(show: show)
        )
    }

    var body: some View {
        Button {
            Task {
                await vm.shareShow()
            }
        } label: {
            ZStack {
                Color("NotiButtonColor2")

                if vm.isSharing {
                    ProgressView()
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .foregroundColor(.white)
                }
            }
            .frame(width: 50, height: 50)
            .cornerRadius(10)
        }
        .disabled(vm.isSharing)
    }
}
