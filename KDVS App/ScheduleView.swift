//
//  ScheduleView.swift
//  KDVS
//
//  Created by John Carraher on 8/1/23.
//

import Foundation
import SwiftUI

struct ScheduleView: View {
    @Binding var shows: [Show]
    @State private var searchText: String = ""
    @State var filteredData: [Show] = []
    @State var selectedShow = Show(
        name: "",
        djName: " ",
        playlistImageURL: URL(string: "https://library.kdvs.org/static/core/images/kdvs-image-placeholder.jpg"),
        alternatingType: 0,
        startTime: Date(),
        endTime: Date(),
        showDates: [],
        seasonStartDate: Date(),
        seasonEndDate: Date())
    @State var isRemindSheetPresented = false
    @State var remindLabel = "SELECTED SHOW"
    
    var body: some View {
        VStack{
            // Once the data is fetched, display the ScheduleView
            List {
                ForEach(filteredShows, id: \.id) { show in
                    Button(action: {
                        selectedShow = show
                        isRemindSheetPresented = true
                    }) {
                        VStack(alignment: .leading) {
                            Text(show.name)
                                .font(.headline)
                            Text(showTimeText(for: show))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    
                }
            }.listStyle(InsetListStyle()) // Apply a scrollable list style
             .searchable(text: $searchText)
             .sheet(isPresented: $isRemindSheetPresented) {
                 LargeRemindView(show: $selectedShow, label: $remindLabel)
                     .presentationDetents([.large])
            }
        }.preferredColorScheme(.dark) // Set the dark color scheme for the entire view
        .navigationBarTitle("Schedule Grid", displayMode: .inline)
        .navigationBarBackButtonHidden(true) // Hide the default back button
        .navigationBarItems(leading: CustomBackButton()) // Use the custom back button as the leading item
    }
    
    private var filteredShows: [Show] {
        if searchText.isEmpty {
            return shows
        } else {
            return shows.filter { show in
                show.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private func showTimeText(for show: Show) -> String {
        if show.alternatingType! > 1 {
            // Handle different text for alternating shows
            return "\(show.DOTW!)s  \(show.startTime.formattedTime(endTime: show.endTime)) • Alternating #\(show.alternatingPos!)"
        } else {
            // Normal show text
            return "\(show.DOTW!)s  \(show.startTime.formattedTime(endTime: show.endTime)) •  Every week"
        }
    }
}

struct CustomBackButton: View {
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.backward.circle.fill")
                .symbolRenderingMode(.hierarchical)
                .environment(\.colorScheme, .dark)
                .padding(.horizontal)
                .foregroundColor(.gray)

        }
    }
}

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
