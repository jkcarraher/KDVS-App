//
//  ScheduleGridView.swift
//  KDVS
//
//  Created by John Carraher on 6/5/26.
//

import SwiftUI

struct ScheduleGridView: View {
    @EnvironmentObject private var notificationService: NotificationService
    @StateObject private var vm = ScheduleGridViewModel()
    
    
    var body: some View {
        List(vm.filteredShows, id: \.id) { show in
            Button {
                vm.selectedShow = show
                vm.isShowingSheet = true
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text(show.name)
                        .font(.headline)

                    Text(showTimeText(for: show))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .listStyle(.inset)
        .navigationTitle("Schedule Grid")
        .navigationBarBackButtonHidden(true)
        .searchable(text: $vm.searchText)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                CustomBackButton()
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                CustomFilterButton(selectedDay: $vm.selectedDay)
            }
        }
        .sheet(item: $vm.selectedShow) { show in
            LargeRemindView(show: show)
                .environmentObject(notificationService)
        }
        .task {
            await vm.load()
        }
        .preferredColorScheme(.dark)
    }
    
    private func showTimeText(for show: Show) -> String {
        let base = "\(show.DOTW)s \(show.startTime.to12HourString())"

        return show.alternates
            ? "\(base) • Alternating"
            : "\(base) • Weekly"
    }
}
