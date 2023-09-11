//
//  ImageService.swift
//  ChaseWeather
//
//  Created by Bobby Ren on 9/11/23.
//

import Foundation
import UIKit

class ImageService {

    private var currentImageTask: Task<UIImage, Error>?

    private var imageCache = [String: UIImage]()

    enum ImageServiceError: Error {
        case invalidURL
        case invalidImageData
    }

    private let baseURL: String = "https://openweathermap.org/img/wn"

    func icon(for weather: WeatherDetail) async throws -> UIImage {
        let task = Task {
            try await fetchImage(name: weather.icon)
        }
        currentImageTask?.cancel()
        currentImageTask = task
        return try await task.value
    }

    private func fetchImage(name: String) async throws -> UIImage {
        let imagePath =  "\(name)@2x.png"
        guard let url = URL(string: baseURL)?.appending(path: imagePath) else {
            throw ImageServiceError.invalidURL
        }

        if let image = imageCache[imagePath] {
            return image
        }

        let request = URLRequest(url: url)

        let (data, _) = try await URLSession.shared.data(for: request)

        guard let image = UIImage(data: data) else {
            throw ImageServiceError.invalidImageData
        }
        imageCache[imagePath] = image

        return image
    }
}
