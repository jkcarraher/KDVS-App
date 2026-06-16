//
//  ImageCacheService.swift
//  KDVS
//
//  Created by John Carraher on 6/16/26.
//

import Foundation
import UIKit

final class ImageCacheService {
    static let shared = ImageCacheService()

    private let cache = NSCache<NSURL, UIImage>()

    private init() {
        
    }
    
    func image(for url: URL) -> UIImage? {
        cache.object(forKey: url as NSURL)
    }

    func setImage(_ image: UIImage, for url: URL) {
        cache.setObject(image, forKey: url as NSURL)
    }
    
    func loadImage(from url: URL) async -> UIImage? {
        if let cached = image(for: url) {
            return cached
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            guard let image = UIImage(data: data) else { return nil }

            setImage(image, for: url)

            return image

        } catch {
            print("Image load failed:", error)
            return nil
        }
    }
}
