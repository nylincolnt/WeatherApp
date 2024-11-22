//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Lincoln Takudzwa Nyarambi on 11/17/24.
//

import Foundation
import SwiftUI

class WeatherViewModel: ObservableObject {
    @Published var favoriteLocations: [Location] = []
    @Published var savedSnapshots: [WeatherSnapshot] = []

    // Using UserDefaults for favoriteLocations
    @AppStorage("favoriteLocations") private var favoriteLocationsData: Data = Data()

    // Using FileManager to save snapshots
    let snapshotsFileURL: URL

    init() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        snapshotsFileURL = documentsDirectory.appendingPathComponent("weather_snapshots.json")
        loadFavoriteLocations()
        loadSavedSnapshots()
    }

    func loadFavoriteLocations() {
        if let locations = try? JSONDecoder().decode([Location].self, from: favoriteLocationsData) {
            self.favoriteLocations = locations
        }
    }

    func saveFavoriteLocations() {
        if let data = try? JSONEncoder().encode(favoriteLocations) {
            favoriteLocationsData = data
        }
    }

    func addFavoriteLocation(_ location: Location) {
        if !favoriteLocations.contains(where: { $0.id == location.id }) {
            favoriteLocations.append(location)
            saveFavoriteLocations()
        }
    }

    func removeFavoriteLocation(_ location: Location) {
        favoriteLocations.removeAll { $0.id == location.id }
        saveFavoriteLocations()
    }

    func isFavorite(_ location: Location) -> Bool {
        favoriteLocations.contains(where: { $0.id == location.id })
    }

    func loadSavedSnapshots() {
        if let data = try? Data(contentsOf: snapshotsFileURL),
           let snapshots = try? JSONDecoder().decode([WeatherSnapshot].self, from: data) {
            savedSnapshots = snapshots
        }
    }

    func saveSnapshots() {
        if let data = try? JSONEncoder().encode(savedSnapshots) {
            try? data.write(to: snapshotsFileURL)
        }
    }

    func addSnapshot(_ snapshot: WeatherSnapshot) {
        savedSnapshots.append(snapshot)
        saveSnapshots()
    }

    func removeSnapshot(_ snapshot: WeatherSnapshot) {
        savedSnapshots.removeAll { $0.id == snapshot.id }
        saveSnapshots()
    }
}
