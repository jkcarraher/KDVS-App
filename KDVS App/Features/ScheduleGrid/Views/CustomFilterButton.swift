//
//  CustomFilterButton.swift
//  KDVS
//
//  Created by John Carraher on 6/6/26.
//

import SwiftUI

struct CustomFilterButton: View {
    @Binding var selectedDay: DayOfWeek?

    var body: some View {
        Menu {
            Button("All") {
                selectedDay = nil
            }

            Divider()

            ForEach(DayOfWeek.allCases, id: \.self) { day in
                Button {
                    selectedDay = day
                } label: {
                    Text(day.displayName)
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                .symbolRenderingMode(.hierarchical)
                .foregroundColor(.gray)
                .padding(.horizontal)
        }
        .menuStyle(BorderlessButtonMenuStyle())
    }
}
