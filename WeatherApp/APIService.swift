//
//  APIService.swift
//  WeatherApp
//
//  Created by Lincoln Takudzwa Nyarambi on 11/17/24.
//

import Foundation

class APIService {
    static let shared = APIService()

    func getLocation(for query: String, completion: @escaping (Result<Location?, Error>) -> Void) {
        let urlString = "https://nominatim.openstreetmap.org/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&format=json&addressdetails=1"
        guard let url = URL(string: urlString) else {
            completion(.success(nil))
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.success(nil))
                return
            }
            do {
                let decoder = JSONDecoder()
                let locations = try decoder.decode([Location].self, from: data)
                completion(.success(locations.first))
            } catch {
                print("Error decoding location data: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }

    func getWeather(for location: Location, completion: @escaping (Result<WeatherInfo, Error>) -> Void) {
        let latitude = location.latitude
        let longitude = location.longitude
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&hourly=temperature_2m,precipitation_probability,precipitation&temperature_unit=fahrenheit&forecast_days=1"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1)))
                return
            }
            do {
                let decoder = JSONDecoder()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
                dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                let weatherInfo = try decoder.decode(WeatherInfo.self, from: data)
                completion(.success(weatherInfo))
            } catch {
                print("Error decoding weather data: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
}
