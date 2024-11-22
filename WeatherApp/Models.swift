//
//  Models.swift
//  WeatherApp
//
//  Created by Lincoln Takudzwa Nyarambi on 11/17/24.
//

import Foundation

struct Location: Identifiable, Codable {
    let place_id: Int?
    let lat: String
    let lon: String
    let display_name: String
    let address: Address?

    var id: String { "\(lat)_\(lon)" }

    var latitude: Double {
        guard let value = Double(lat) else {
            print("Invalid latitude value: \(lat)")
            return 0.0
        }
        return value
    }
    var longitude: Double {
        guard let value = Double(lon) else {
            print("Invalid longitude value: \(lon)")
            return 0.0
        }
        return value
    }

    // Add a static default location
    static let `default` = Location(place_id: nil, lat: "0", lon: "0", display_name: "Unknown Location", address: nil)
}

struct Address: Codable {
    let city: String?
    let county: String?
    let state: String?
    let country: String
    let country_code: String?
}

struct WeatherInfo: Codable, Identifiable {
    let id = UUID()
    let timestamp: Date
    let hourly_units: HourlyUnits
    let hourly: WeatherData

    enum CodingKeys: String, CodingKey {
        case hourly_units
        case hourly
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        timestamp = Date()
        hourly_units = try container.decode(HourlyUnits.self, forKey: .hourly_units)
        hourly = try container.decode(WeatherData.self, forKey: .hourly)
    }
}

struct HourlyUnits: Codable {
    let time: String
    let temperature: String
    let precipitation_probability: String
    let precipitation: String

    enum CodingKeys: String, CodingKey {
        case time
        case temperature = "temperature_2m"
        case precipitation_probability
        case precipitation
    }
}

struct WeatherData: Codable {
    let time: [Date]
    let temperature: [Double]
    let precipitation_probability: [Int]
    let precipitation: [Double]

    enum CodingKeys: String, CodingKey {
        case time
        case temperature = "temperature_2m"
        case precipitation_probability
        case precipitation
    }
}

struct WeatherSnapshot: Identifiable, Codable {
    let id = UUID()
    let location: Location
    let weatherInfo: WeatherInfo
}
