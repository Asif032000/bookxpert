//
//  ImageService.swift
//  Bookxpert
//
//  Created by Asif Habib on 18/05/25.
//

import Foundation
import UIKit

class ImageService {
    static let shared = ImageService()

    func saveToDisk(_ image: UIImage) async throws {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }

        let filename = UUID().uuidString + ".jpg"
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)

        try data.write(to: url)
        print("Saved image to: \(url.path)")
    }
}
