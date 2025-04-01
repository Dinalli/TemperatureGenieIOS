//
//  TemperatureGenieApp.swift
//  TemperatureGenie
//
//  Created by Andrew Donnelly on 25/03/2025.
//

import SwiftUI
import FirebaseCore

let apiPath = Bundle.main.infoDictionary!["APIPATH"] as? String ?? "https://demo-api.barcodegenie.co.uk"

enum APIError: Error {
    case errorDescription(String)
    case unknown
}



class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}


@main
struct TemperatureGenieApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
