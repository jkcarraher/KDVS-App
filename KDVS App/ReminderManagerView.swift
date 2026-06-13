//
//  ReminderManagerView.swift
//  KDVS
//
//  Created by John Carraher on 6/10/26.
//

import SwiftUI

struct ReminderManagerView: View {
    let notificationService = NotificationService(apiService: KDVSAPIService())
    
    @State private var notificationEnabledShows: [ShowDTO] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 0){
            VStack(alignment: .leading) {
                Text("NOTIFICATIONS")
                    .font(.system(size: 14, weight: .bold))
                    .environment(\.colorScheme, .dark)
                    .foregroundColor(Color("SecondaryText"))
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if(!notificationEnabledShows.isEmpty){
                List{
                    ForEach(notificationEnabledShows, id: \.id) { show in
                        MiniRemindView(show: .constant(show), label: .constant("Existing Notifications"))
                            .listRowBackground(Color("ListBackground"))
                    }.onDelete(perform: deleteShow)
                }
                .background(Color("RemindBackground"))
                .scrollContentBackground(.hidden)
                .navigationBarTitle("Reminder Manager", displayMode: .inline)
                .listStyle(DefaultListStyle())
            } else {
                Spacer()
                HStack{
                    Text("No Reminders Scheduled :)")
                        .font(.system(size: 16, weight: .semibold))
                        .environment(\.colorScheme, .dark)
                        .foregroundColor(Color.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal, 25)
                        .padding(.vertical, 15)
                }.frame(alignment: .center)
                Spacer()
            }
        }.task {
            
            await loadNotificationEnabledShows()
        }
    }
    
    @MainActor
    private func loadNotificationEnabledShows() async {
        isLoading = true

        do {
            notificationEnabledShows =
                try await notificationService
                    .fetchShowSubscriptions()
        } catch {
            errorMessage = error.localizedDescription
            print(error)
        }

        isLoading = false
    }
    
    func deleteShow(at offsets: IndexSet) {
        let shows = offsets.map {
            notificationEnabledShows[$0]
        }

        Task {
            for show in shows {
                do {
                    try await notificationService.unsubscribe(
                        showId: show.id
                    )

                    await MainActor.run {
                        notificationEnabledShows.removeAll {
                            $0.id == show.id
                        }
                    }
                } catch {
                    print(
                        "Failed to unsubscribe from \(show.name): \(error)"
                    )
                }
            }
        }
    }
    
}

