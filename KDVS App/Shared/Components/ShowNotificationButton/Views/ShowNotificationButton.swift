//
//  ShowNotificationButton.swift
//  KDVS
//
//  Created by John Carraher on 6/24/26.
//

import SwiftUI

struct ShowNotificationButton: View {
    @StateObject private var vm: ShowNotificationButtonVM
    
    init(showId: String, notificationService: NotificationService) {
        self._vm = StateObject(
            wrappedValue: ShowNotificationButtonVM(
                showId: showId,
                notificationService: notificationService
            )
        )
    }
    
    var body: some View {
        Button {
            Task {
                await vm.toggleRemindButton()
            }
        } label: {
            ZStack {
                Color("NotiButtonColor2")

                if vm.isLoading || vm.isPerformingNotificationAction {
                    ProgressView()
                } else {
                    Text(vm.isSubscribed ? "Turn off Notifications" : "Notify Me!")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .frame(height: 50)
            .cornerRadius(10)
        }
        .onAppear {
            Task { await vm.loadSubscriptionStatus() }
        }
        .disabled(vm.isLoading || vm.isPerformingNotificationAction)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}
