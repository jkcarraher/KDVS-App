//
//  InstagramStoryService.swift
//  KDVS
//
//  Created by John Carraher on 6/27/26.
//

import UIKit

final class InstagramStoryService {

    static let shared = InstagramStoryService()

    private init() {}

    func share(show: Show) async throws {

        guard let url = URL(string: "instagram-stories://share"),
              await UIApplication.shared.canOpenURL(url)
        else {
            throw ShareError.instagramNotInstalled
        }

        let sticker = createSticker(for: show)

        let items: [String: Any] = [
            "com.instagram.sharedSticker.stickerImage": sticker
        ]

        UIPasteboard.general.setItems(
            [items],
            options: [
                .expirationDate: Date().addingTimeInterval(300)
            ]
        )

        await UIApplication.shared.open(url)
    }

    private func createSticker(for show: Show) -> UIImage {
        // Generate artwork here
        UIImage(named: "COTC_playlistImg1")!
    }
}

enum ShareError: Error {
    case instagramNotInstalled
}
