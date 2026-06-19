//
//  LargeRemindView.swift
//  KDVS
//
//  Created by John Carraher on 6/10/26.
//

import SwiftUI

struct LargeRemindView: View {
    @StateObject private var vm: LargeRemindViewModel
    
    init(show: Show) {
        _vm = StateObject(
            wrappedValue: LargeRemindViewModel(
                show: show,
                notificationService: NotificationService(
                    apiService: KDVSAPIService()
                )
            )
        )
    }
    
    var body: some View {
        VStack {
            if ((vm.show.name != "")) {
                HStack {
                    if let image = vm.showImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .clipped()
                            .frame(width: 60, height: 60)
                            .cornerRadius(10)
                    } else {
                        Rectangle()
                            .fill(Color("RemindLoading"))
                            .frame(width: 60, height: 60)
                            .cornerRadius(10)
                    }
                    
                    VStack(alignment: .leading, spacing: 0){
                        Text(vm.show.name)
                            .font(.system(size: 17, weight: .bold))
                            .environment(\.colorScheme, .dark)
                            .lineLimit(1)
                        Text(vm.show.djName)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color("SecondaryText"))
                            .environment(\.colorScheme, .dark)
                            .lineLimit(1)
                    }.padding([.leading], 5)
                    Spacer()
                }
                .padding([.top, .bottom, .leading, .trailing], 20)
                .frame(maxWidth: .infinity)
                .background(Color("RemindCompiment"))
                
                VStack(alignment: .leading) {
                    Text("UPCOMING SHOW DATES:")
                        .font(.system(size: 14, weight: .bold))
                        .environment(\.colorScheme, .dark)
                        .foregroundColor(Color("SecondaryText"))
                        .multilineTextAlignment(.leading)
                        .padding([.leading], 20)
                }
                .padding([.top], 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                // UICalendarView to display show.showDates
                if(vm.isDatesLoading){
                    ProgressView()
                        .frame(width: 325, height: 300, alignment: .center)
                }else{
                    if(!vm.showDates.isEmpty){
                        MultiDatePicker(
                            "Show Dates",
                            selection: $vm.showDates,
                            in: vm.show.firstShowDate...
                        ).frame(width: 325, height: 330, alignment: .center)
                            .tint(vm.show.color.brightened(by: 1))
                            .padding([.top], 7)
                    } else{
                        Spacer()
                        Text("No Upcoming Shows")
                            .font(.system(size: 16, weight: .semibold))
                            .environment(\.colorScheme, .dark)
                            .foregroundColor(Color.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.horizontal, 25)
                            .padding(.vertical, 15)
                        Spacer()
                    }
                }
                Spacer()
                Button {
                    Task {
                        await vm.toggleRemindButton()
                    }
                } label: {
                    ZStack {
                        Color("NotiButtonColor2")

                        if vm.isLoadingSubscription || vm.isPerformingNotificationAction {
                            ProgressView()
                        } else {
                            Text(vm.isSubscribed ? "Turn off Notifications" : "Notify Me!")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(width: 350, height: 50)
                    .cornerRadius(10)
                }
                .disabled(vm.isLoadingSubscription || vm.isPerformingNotificationAction)
            } else {
                Spacer()
                HStack {
                    Text("No Scheduled Programming")
                        .font(.system(size: 16, weight: .semibold))
                        .environment(\.colorScheme, .dark)
                        .foregroundColor(Color.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal, 25)
                        .padding(.vertical, 15)
                }.frame(alignment: .center)
                Spacer()
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("RemindBackground"))
        .onAppear {
            Task {
                await vm.loadImage()
                await vm.loadSubscriptionStatus()
                vm.loadDates()
            }
        }
    }
}
