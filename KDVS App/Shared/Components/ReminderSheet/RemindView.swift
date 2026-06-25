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
    @EnvironmentObject private var notificationService: NotificationService

    @Binding var show : Show
    @Binding var label : String
    
    @State private var showImage: UIImage?
    @State private var isLoaded = false
    @State private var isSubscribed = false
    @State private var isLoadingSubscription = true
    @State private var isPerformingNotificationAction = false
    
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
                    if let image = showImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .clipped()
                            .frame(width: 100, height: 100)
                            .cornerRadius(5)
                    } else {
                        ProgressView()
                            .frame(width: 100, height: 100)
                    }
                    
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
                ShowNotificationButton(showId: show.id, notificationService: notificationService)
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
                Task {
                    await loadImage()
                    isLoaded = true
                }
            }
    }
    @MainActor
    func loadImage() async {
        guard let url = show.playlistImageURL else {
            return
        }

        showImage = await ImageCacheService.shared.loadImage(from: url)
    }
}
