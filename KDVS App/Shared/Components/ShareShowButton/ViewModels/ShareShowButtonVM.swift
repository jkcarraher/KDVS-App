//
//  Show.swift
//  KDVS
//
//  Created by John Carraher on 6/27/26.
//

import Foundation
import SwiftUI

@MainActor
final class ShareShowButtonVM: ObservableObject {

    @Published var isSharing = false

    private let show: Show

    init(show: Show) {
        self.show = show
    }

    func shareShow() async {
        isSharing = true

        defer {
            isSharing = false
        }

        do {
            try await InstagramStoryService.shared.share(show: show)
        } catch {
            print("Failed to share show: \(error)")
        }
    }
}
