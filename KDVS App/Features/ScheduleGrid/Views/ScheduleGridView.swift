//
//  ScheduleGridView.swift
//  KDVS
//
//  Created by John Carraher on 6/5/26.
//

import Foundation
import SwiftUI

struct ScheduleGridView: View {
    @StateObject private var viewModel = ScheduleGridViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    List(viewModel.shows, id: \.id) { show in
                        VStack(alignment: .leading) {
                            Text(show.name)
                                .font(.headline)

                            Text(show.djName)
                                .font(.subheadline)

                            Text(show.DOTW + " - " + (show.alternates ? "Alternates" : "Weekly"))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Shows")
            .task {
                await viewModel.load()
            }
        }
    }
}
