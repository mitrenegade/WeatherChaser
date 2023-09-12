//
//  Weather.swift
//  ChaseWeather
//
//  Created by Bobby Ren on 9/11/23.
//

import Foundation

struct WeatherDetail: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct Wind: Codable {
    let speed: Double
    let deg: Double
}

struct Location: Codable {
    let lat: Double
    let lon: Double
}

struct TemperaturePressure: Codable {
    let temp: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let pressure: Double
    let humidity: Double
}

struct System: Codable {
    let id: Int?
    let country: String
    let sunrise: TimeInterval
    let sunset: TimeInterval
}

struct Weather: Codable {

    // MARK: - Top level properties
    let name: String
    let id: Int
    let timezone: Int
    let cod: Int
    let visibility: Int

    // MARK: - Top level objects
    let coord: Location
    let weather: [WeatherDetail]
    let wind: Wind
    let main: TemperaturePressure
    let sys: System?

    // MARK: - Calculated variables
    var sunriseString: String? {
        guard let sunrise = sys?.sunrise else {
            return nil
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let time = Date(timeIntervalSince1970: sunrise)
        return formatter.string(from: time)
    }

    var sunsetString: String? {
        guard let sunset = sys?.sunset else {
            return nil
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let time = Date(timeIntervalSince1970: sunset)
        return formatter.string(from: time)
    }
}

extension Weather: CustomStringConvertible {
    var description: String {
        var string = """
        The weather in \(name) is \(weather.first?.description ?? "unknown").
        High: \(main.tempMax) Low: \(main.tempMin) Feels like: \(main.feelsLike)
        """
        if let sunriseString,
           let sunsetString {
            string = string + """
            \nSunrise -> Sunset: \(sunriseString) to \(sunsetString)
            """
        }
        return string
    }
}
