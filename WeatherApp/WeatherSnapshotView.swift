//
//  WeatherSnapshotView.swift
//  WeatherApp
//
//  Created by Lincoln Takudzwa Nyarambi on 11/17/24.
//

import SwiftUI
import MapKit

struct WeatherSnapshotView: View {
    @EnvironmentObject var viewModel: WeatherViewModel
        let snapshot: WeatherSnapshot

        @State private var region: MKCoordinateRegion

        init(snapshot: WeatherSnapshot) {
            self.snapshot = snapshot
            let coordinate = CLLocationCoordinate2D(latitude: snapshot.location.latitude, longitude: snapshot.location.longitude)
            _region = State(initialValue: MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)))
        }

        var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    // Location Name
                    Text(snapshot.location.display_name)
                        .font(.title)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding(.top)

                    // Map View
                    Map(coordinateRegion: $region, annotationItems: [snapshot.location]) { location in
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
                            Text("Weather Snapshot")
                                .font(.headline)
                                .padding(.bottom, 5)

                            HStack {
                                Image(systemName: "thermometer")
                                    .foregroundColor(.accentColor)
                                Text("Temperature:")
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("\(snapshot.weatherInfo.hourly.temperature[index], specifier: "%.1f") \(snapshot.weatherInfo.hourly_units.temperature)")
                            }
                            HStack {
                                Image(systemName: "cloud.rain")
                                    .foregroundColor(.accentColor)
                                Text("Precipitation Probability:")
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("\(snapshot.weatherInfo.hourly.precipitation_probability[index])%")
                            }
                            HStack {
                                Image(systemName: "drop.fill")
                                    .foregroundColor(.accentColor)
                                Text("Precipitation:")
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("\(snapshot.weatherInfo.hourly.precipitation[index], specifier: "%.1f") \(snapshot.weatherInfo.hourly_units.precipitation)")
                            }
                        } else {
                            Text("Weather data not available for the snapshot time")
                                .foregroundColor(.red)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    .padding(.horizontal)

                    // Timestamp
                    Text("Snapshot taken on \(snapshot.weatherInfo.timestamp, formatter: dateFormatter)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)

                    // Delete Button
                    Button(action: {
                        viewModel.removeSnapshot(snapshot)
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Snapshot")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .background(Color.backgroundColor.edgesIgnoringSafeArea(.all))
            .navigationTitle("Weather Snapshot")
        }

    var currentWeatherIndex: Int? {
        let timestamp = snapshot.weatherInfo.timestamp
        let calendar = Calendar.current
        if let index = snapshot.weatherInfo.hourly.time.firstIndex(where: {
            calendar.isDate($0, equalTo: timestamp, toGranularity: .hour)
        }) {
            return index
        } else {
            return nil
        }
    }
}
