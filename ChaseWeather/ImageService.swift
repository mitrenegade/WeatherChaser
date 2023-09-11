//
//  ImageService.swift
//  ChaseWeather
//
//  Created by Bobby Ren on 9/11/23.
//

import Foundation
import UIKit

class ImageService {

    private let apiService: APIService

    init(apiService: APIService = APIService()) {
        self.apiService = apiService
    }

    func icon(for weather: WeatherDetail) async throws -> UIImage {
        // TODO: cache
        try await apiService.icon(for: weather.icon)
    }
}
