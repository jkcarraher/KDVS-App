//
//  ScheduleGridView.swift
//  KDVS
//
//  Created by John Carraher on 6/5/26.
//

import SwiftUI

struct ScheduleGridView: View {
    @StateObject private var viewModel = ScheduleGridViewModel()

    @State private var searchText = ""
    @State private var selectedDay: DayOfWeek? = nil
    @State private var selectedShow: Show = .empty
    @State private var showSheet = false

    var body: some View {
        NavigationStack {
            List(filteredShows, id: \.id) { show in
                Button {
                    selectedShow = show
                    showSheet = true
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
            .searchable(text: $searchText)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    CustomBackButton()
                }

                ToolbarItem(placement: .topBarTrailing) {
                    CustomFilterButton(selectedDay: $selectedDay)
                }
            }
            .sheet(isPresented: $showSheet) {
                LargeRemindView(
                    show: $selectedShow,
                    label: .constant("UPCOMING SHOW DATES"),
                    scheduleGrid: $viewModel.shows
                )
                .presentationDetents([.height(575), .large])
            }
            .task {
                await viewModel.load()
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func showTimeText(for show: Show) -> String {
        let base = "\(show.DOTW)s \(show.startTime.to12HourString())"

        return show.alternates
            ? "\(base) • Alternating"
            : "\(base) • Every week"
    }
    
    private var filteredShows: [Show] {
        var result = viewModel.shows

        if let selectedDay {
            result = result.filter {
                $0.DOTW == selectedDay.displayName
            }
        }

        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result
    }
}
