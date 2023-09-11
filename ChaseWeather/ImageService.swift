//
//  ImageService.swift
//  ChaseWeather
//
//  Created by Bobby Ren on 9/11/23.
//

import Foundation
import UIKit

class ImageService {

    enum ImageServiceError: Error {
        case invalidURL
        case invalidImageData
    }

    private let baseURL: String = "https://openweathermap.org/img/wn"

    private func request(for name: String) throws -> URLRequest {
        let imagePath =  "\(name)@2x.png"
        guard let url = URL(string: baseURL)?.appending(path: imagePath) else {
            throw ImageServiceError.invalidURL
        }
        return URLRequest(url: url)
    }

    func icon(for weather: WeatherDetail) async throws -> UIImage {
        let request = try request(for: weather.icon)

        let (data, _) = try await URLSession.shared.data(for: request)

        guard let image = UIImage(data: data) else {
            throw ImageServiceError.invalidImageData
        }
        return image
    }
}
