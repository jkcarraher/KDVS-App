//
//  LargeRemindView.swift
//  KDVS
//
//  Created by John Carraher on 6/10/26.
//

import SwiftUI

struct LargeRemindView: View {
    @Binding var show: Show
    @Binding var label: String
    @Binding var scheduleGrid: [Show]

    let notificationService = NotificationService(apiService: KDVSAPIService())

    @State private var isLoaded = false
    @State private var isSubscribed = false
    @State private var isLoadingSubscription = true
    @State private var isPerformingNotificationAction = false

    @State private var dates: Set<DateComponents> = []
    
        
    var body: some View {
        VStack {
            if ((show.name != "")) {
                HStack {
                    AsyncImage(url: show.playlistImageURL) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .clipped()
                            .frame(width: 60, height: 60, alignment: .center)
                            .cornerRadius(10)
                    } placeholder: {
                        Rectangle()
                            .fill(Color("RemindLoading"))
                            .cornerRadius(10)
                        .frame(width: 60, height:60)
                    }.frame(width: 60, height: 60)
                    
                    VStack(alignment: .leading, spacing: 0){
                        Text(show.name)
                            .font(.system(size: 17, weight: .bold))
                            .environment(\.colorScheme, .dark)
                            .lineLimit(1)
                        Text(show.djName)
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
                    Text(label)
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
                if(!isLoaded){
                    ProgressView()
                        .frame(width: 325, height: 300, alignment: .center)
                }else{
                    if(!show.dates.isEmpty){
                        MultiDatePicker(
                            "Show Dates",
                            selection: $dates,
                            in: show.firstShowDate...
                        ).frame(width: 325, height: 330, alignment: .center)
                            .tint(show.color.brightened(by: 1))
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
                        await toggleRemindButton()
                    }
                } label: {
                    if isLoadingSubscription || isPerformingNotificationAction {
                        ProgressView()
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
                .frame(width: 350, height: 50)
                .background(Color("NotiButtonColor2"))
                .cornerRadius(10)
                .padding([.top, .bottom], 20)
                .disabled(!isLoaded)
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
            findShowWithName(scheduleGrid, showName: show.name) { foundShow in
                guard let foundShow else {
                    return
                }

                show = foundShow
                dates = getShowDates(for: show)

                Task {
                    await loadSubscriptionStatus()
                    isLoaded = true
                }
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

func findShowWithName(_ shows: [Show], showName: String, completion: @escaping (Show?) -> Void) {
    let matchingShow = shows.first { $0.name == showName }
    completion(matchingShow)
}
