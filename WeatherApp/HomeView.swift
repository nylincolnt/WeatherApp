//
//  HomeView.swift
//  WeatherApp
//
//  Created by Lincoln Takudzwa Nyarambi on 11/17/24.
//

import SwiftUI
import CoreLocation

struct HomeView: View {
    @EnvironmentObject var viewModel: WeatherViewModel
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var selectedLocation: Location?
    @State private var errorMessage: String?

    @StateObject private var locationManager = LocationManager()
    @State private var isUsingCurrentLocation = false

    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationStack {
            VStack {
                // Header
                Text("WeatherApp")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryColor)
                    .padding(.top)

                // Search Field
                HStack {
                    TextField("Enter location", text: $searchText)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)

                    Button(action: {
                        searchLocation()
                    }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white)
                            .padding()
                            .background(searchText.isEmpty || isSearching ? Color(.gray) : Color.accentColor)
                            .cornerRadius(8)
                    }
                    .disabled(searchText.isEmpty || isSearching)
                    .padding(.trailing)
                }

                // Use Current Location Button
                Button(action: {
                    isUsingCurrentLocation = true
                    locationManager.requestLocation()
                }) {
                    HStack {
                        Image(systemName: "location.fill")
                        Text("Use Current Location")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(8)
                }
                .padding(.top)

                if isSearching {
                    ProgressView()
                        .padding()
                }
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                // Favorites and Snapshots List
                List {
                    if !viewModel.favoriteLocations.isEmpty {
                        Section(header: Text("Favorite Locations")) {
                            ForEach(viewModel.favoriteLocations) { location in
                                NavigationLink(destination: LocationDetailView(location: location).environmentObject(viewModel)) {
                                    Text(location.display_name)
                                        .foregroundColor(.primary)
                                }
                                .listRowBackground(Color(.systemGray6))
                            }
                        }
                    }

                    if !viewModel.savedSnapshots.isEmpty {
                        Section(header: Text("Saved Weather Snapshots")) {
                            ForEach(viewModel.savedSnapshots) { snapshot in
                                NavigationLink(destination: WeatherSnapshotView(snapshot: snapshot).environmentObject(viewModel)) {
                                    VStack(alignment: .leading) {
                                        Text(snapshot.location.display_name)
                                            .foregroundColor(.primary)
                                        Text("\(snapshot.weatherInfo.timestamp, formatter: dateFormatter)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .listRowBackground(Color(.systemGray6))
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .background(Color.backgroundColor)

                Spacer()
            }
            .background(Color.backgroundColor.edgesIgnoringSafeArea(.all))
            .onReceive(locationManager.$currentLocation) { coordinate in
                guard isUsingCurrentLocation else { return }
                guard let coordinate = coordinate else { return }
                fetchLocationName(from: coordinate) { locationName in
                    searchText = locationName
                    searchLocation()
                    isUsingCurrentLocation = false // Reset the flag
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .locationAccessDenied)) { _ in
                alertMessage = "Location access is denied. Please enable it in Settings."
                showAlert = true
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Location Access Denied"),
                    message: Text(alertMessage),
                    primaryButton: .default(Text("Open Settings"), action: {
                        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(appSettings)
                        }
                    }),
                    secondaryButton: .cancel()
                )
            }
            .background(
                NavigationLink(
                    destination: selectedLocation.map { LocationDetailView(location: $0).environmentObject(viewModel) },
                    isActive: Binding(
                        get: { selectedLocation != nil },
                        set: { if !$0 { selectedLocation = nil } }
                    )
                ) {
                    EmptyView()
                }
                .hidden()
            )
        }
    }

    // MARK: - Functions

    func searchLocation() {
        isSearching = true
        errorMessage = nil
        APIService.shared.getLocation(for: searchText) { result in
            DispatchQueue.main.async {
                isSearching = false
                switch result {
                case .success(let location):
                    if let location = location {
                        selectedLocation = location
                    } else {
                        errorMessage = "Location not found"
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    func fetchLocationName(from coordinate: CLLocationCoordinate2D, completion: @escaping (String) -> Void) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let placemark = placemarks?.first {
                let nameComponents = [placemark.locality, placemark.administrativeArea, placemark.country]
                let locationName = nameComponents.compactMap { $0 }.joined(separator: ", ")
                completion(locationName)
            } else if let error = error {
                print("Error reverse geocoding location: \(error.localizedDescription)")
                completion("Unknown Location")
            }
        }
    }
}
