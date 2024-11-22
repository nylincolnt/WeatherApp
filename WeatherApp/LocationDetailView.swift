//
//  LocationDetailView.swift
//  WeatherApp
//
//  Created by Lincoln Takudzwa Nyarambi on 11/17/24.
//

import SwiftUI
import MapKit

struct LocationDetailView: View {
    @EnvironmentObject var viewModel: WeatherViewModel
    @State var location: Location
    @State private var currentWeatherInfo: WeatherInfo?
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var region: MKCoordinateRegion

    init(location: Location) {
        _location = State(initialValue: location)
        let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        _region = State(initialValue: MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if isLoading {
                    ProgressView()
                } else if let weatherInfo = currentWeatherInfo {
                    // Location Name
                    Text(location.display_name)
                        .font(.title)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding(.top)

                    // Map View
                    Map(coordinateRegion: $region, annotationItems: [location]) { location in
                        MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)) {
                            Image(systemName: "mappin.circle.fill")
                                .resizable()
                                .foregroundColor(.accentColor)
                                .frame(width: 30, height: 30)
                        }
                    }
                    .frame(height: 250)
                    .cornerRadius(15)
                    .padding(.horizontal)

                    // Weather Information
                    VStack(spacing: 10) {
                        if let index = currentWeatherIndex {
                            Text("Current Weather")
                                .font(.headline)
                                .padding(.bottom, 5)

                            HStack {
                                Image(systemName: "thermometer")
                                    .foregroundColor(.accentColor)
                                Text("Temperature:")
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("\(weatherInfo.hourly.temperature[index], specifier: "%.1f") \(weatherInfo.hourly_units.temperature)")
                            }
                            HStack {
                                Image(systemName: "cloud.rain")
                                    .foregroundColor(.accentColor)
                                Text("Precipitation Probability:")
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("\(weatherInfo.hourly.precipitation_probability[index])%")
                            }
                            HStack {
                                Image(systemName: "drop.fill")
                                    .foregroundColor(.accentColor)
                                Text("Precipitation:")
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("\(weatherInfo.hourly.precipitation[index], specifier: "%.1f") \(weatherInfo.hourly_units.precipitation)")
                            }
                        } else {
                            Text("Current weather data not available")
                                .foregroundColor(.red)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    .padding(.horizontal)

                    // Action Buttons
                    HStack(spacing: 20) {
                        Button(action: {
                            if viewModel.isFavorite(location) {
                                viewModel.removeFavoriteLocation(location)
                            } else {
                                viewModel.addFavoriteLocation(location)
                            }
                        }) {
                            HStack {
                                Image(systemName: viewModel.isFavorite(location) ? "heart.fill" : "heart")
                                Text(viewModel.isFavorite(location) ? "Unfavorite" : "Favorite")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.accentColor)
                            .cornerRadius(10)
                        }

                        Button(action: {
                            if let weatherInfo = currentWeatherInfo {
                                let snapshot = WeatherSnapshot(location: location, weatherInfo: weatherInfo)
                                viewModel.addSnapshot(snapshot)
                            }
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.down")
                                Text("Save Snapshot")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.primaryColor)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
            .padding(.bottom)
        }
        .background(Color.backgroundColor.edgesIgnoringSafeArea(.all))
        .onAppear {
            fetchWeather()
        }
        .navigationTitle("Weather Details")
    }

    func fetchWeather() {
        isLoading = true
        APIService.shared.getWeather(for: location) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let info):
                    self.currentWeatherInfo = info
                    print("Weather data fetched successfully")
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    print("Error fetching weather: \(error)")
                }
            }
        }
    }

    var currentWeatherIndex: Int? {
        guard let weatherInfo = currentWeatherInfo else { return nil }
        let currentDate = Date()
        let calendar = Calendar.current
        if let index = weatherInfo.hourly.time.firstIndex(where: {
            calendar.isDate($0, equalTo: currentDate, toGranularity: .hour)
        }) {
            return index
        } else {
            return nil
        }
    }
}
