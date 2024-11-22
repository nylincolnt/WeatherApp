//
//  WeatherAppApp.swift
//  WeatherApp
//
//  Created by Lincoln Takudzwa Nyarambi on 11/17/24.
//

import SwiftUI

@main
struct WeatherAppApp: App {
    @StateObject var viewModel = WeatherViewModel()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(viewModel)
                .accentColor(.accentColor)
        }
    }
}
