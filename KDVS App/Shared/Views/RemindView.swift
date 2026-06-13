//
//  RemindView.swift
//  KDVS
//
//  Created by John Carraher on 5/13/23.
//

import Foundation
import SwiftUI
import UserNotifications
import UIKit
import EventKit

struct RemindView: View {
    @Binding var show : Show
    @Binding var label : String
    
    @State private var isLoaded = false
    @State private var isSubscribed = false
    @State private var isLoadingSubscription = true
    @State private var isPerformingNotificationAction = false
    
    @State private var dates: Set<DateComponents> = []
    
    let notificationService = NotificationService(
        apiService: KDVSAPIService()
    )
    
    var bounds: Range<Date> {
        let start = Date()
        let end = show.lastShowDate
        return start ..< end
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text(label)
                    .font(.system(size: 14, weight: .bold))
                    .environment(\.colorScheme, .dark)
                    .foregroundColor(Color("SecondaryText"))
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            if(show.name != ""){
                HStack {
                    AsyncImage(url: show.playlistImageURL) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .clipped()
                            .frame(width: 100, height: 100, alignment: .center)
                            .cornerRadius(5)
                    } placeholder: {
                        ProgressView()
                    }.frame(width: 100, height: 100)
                    
                    VStack(alignment: .leading, spacing: 5){
                        Text(show.name)
                            .font(.system(size: 20, weight: .bold))
                            .environment(\.colorScheme, .dark)
                        Text(show.djName)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(Color("SecondaryText"))
                            .environment(\.colorScheme, .dark)
                        Text("\(Date().dayOfWeek())s from \(show.startTime.to12HourString()) - \(show.endTime.to12HourString())")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(Color("SecondaryText"))
                            .environment(\.colorScheme, .dark)
                    }.padding([.leading], 5)
                    Spacer()
                }.padding([.leading, .trailing], 20)
                
                Button {
                    Task {
                        await toggleRemindButton()
                    }
                } label: {
                    if isLoadingSubscription || isPerformingNotificationAction {
                        Spacer()
                        ProgressView()
                        Spacer()
                    } else if isSubscribed {
                        Text("Turn off Notifications")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Text("Notify Me!")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background(Color("NotiButtonColor2"))
                .cornerRadius(10)
                .padding(.horizontal, 20)
                .padding(.top, 5)
                .disabled(!isLoaded)
            }else {
                Spacer()
                HStack{
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
        }.frame(maxWidth: .infinity, maxHeight: 220)
            .background(Color("RemindBackground"))
            .onAppear {
                dates = getShowDates(for: show)
                
                Task {
                    await loadSubscriptionStatus()
                    isLoaded = true
                }
            }
    }
    @MainActor
    func loadSubscriptionStatus() async {
        isLoadingSubscription = true

        defer {
            isLoadingSubscription = false
        }

        do {
            isSubscribed = try await notificationService.isSubscribed(
                showId: show.id
            )
        } catch {
            print("Failed to load subscription status:", error)
            isSubscribed = false
        }
    }
    
    @MainActor
    func toggleRemindButton() async {
        guard !isPerformingNotificationAction else {
            return
        }

        isPerformingNotificationAction = true

        defer {
            isPerformingNotificationAction = false
        }

        do {
            if isSubscribed {
                try await notificationService.unsubscribe(
                    showId: show.id
                )

                isSubscribed = false
            } else {
                try await notificationService.subscribe(
                    showId: show.id
                )

                isSubscribed = true
            }
        } catch {
            print("Notification action failed:", error)
        }
    }
    
    
}
