//
//  TemperatureGenieApp.swift
//  TemperatureGenie
//
//  Created by Andrew Donnelly on 25/03/2025.
//

import SwiftUI

let apiPath = Bundle.main.infoDictionary!["APIPATH"] as? String ?? "https://demo-api.barcodegenie.co.uk"

enum APIError: Error {
    case errorDescription(String)
    case unknown
}

@main
struct TemperatureGenieApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
