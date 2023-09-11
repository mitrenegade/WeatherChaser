//
//  Weather.swift
//  ChaseWeather
//
//  Created by Bobby Ren on 9/11/23.
//

import Foundation

struct CityWeather: Codable {

    // Custom coding keys
//    private enum CodingKeys: String, CodingKey {
//        case id
//        case name
//        case timezone
//        case cod
//        case visibility
//        case coord
//        case weather
//        case wind
//        case sys
//    }

//    private enum SysCodingKeys: String, CodingKey {
//        case id
//        case country
//        case sunrise
//        case sunset
//        case type
//    }

    // decode top level properties
    let name: String
    let id: Int
    let timezone: Int
    let cod: Int
    let visibility: Int

    // decode top level objects
    let coord: Location
    let weather: [Weather]
    let wind: Wind
    let main: TemperaturePressure

    // decode from `sys` block using a custom decoding strategy
    let sys: System
}

//extension CityWeather {
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//
//        if let sysBlock = try? container.nestedContainer(keyedBy: SysCodingKeys.self, forKey: .sys) {
//            country = try? sysBlock.decode(String.self, forKey: .country)
//            sunrise = try? sysBlock.decode(TimeInterval.self, forKey: .sunrise)
//            sunset = try? sysBlock.decode(TimeInterval.self, forKey: .sunset)
//        }
//
//        name = try container.decode(String.self, forKey: .name)
//        id = try container.decode(Int.self, forKey: .id)
//    }
//}

struct Weather: Codable {
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
    let id: Int
    let country: String
    let sunrise: TimeInterval
    let sunset: TimeInterval
}
