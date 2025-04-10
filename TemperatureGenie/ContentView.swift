//
//  ContentView.swift
//  TemperatureGenie
//
//  Created by Andrew Donnelly on 25/03/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject var authenticationHelper = AuthenticationHelper()
    
    @State var showSplash = true
    
    var body: some View {
        ZStack{
            if showSplash {
                Splash().onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        showSplash = false
                    }
                }
            } else if !authenticationHelper.isAuthenticated {
                NavigationView {
                    GeometryReader { geo in
                        ScrollView {
                            VStack {
                                Spacer()
                                VStack {
                                    Spacer()
                                    HStack {
                                        Image("TempGenieLogo").resizable().frame(width: 232, height: 30, alignment: .center)
                                    }
                                    HStack {
                                        LoginView().frame(height: 350, alignment: .center)
                                            .environmentObject(authenticationHelper)
                                    }
                                    Spacer()
                                    HStack{
                                        Text("v\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "-")")
                                            .foregroundColor(Color("GenieLightBlue"))
                                            .font(.custom("poppins-medium", size: 12))
                                    }
                                }
                            }.frame(height: geo.size.height).padding()
                        }.background(Color("GenieBackground"))
                    }
                }.navigationViewStyle(.stack)
            } else {
                VStack {
                    SensorList().frame(maxWidth: .infinity).onAppear {
                        /// Request Push Authorization
                        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
                        UNUserNotificationCenter.current().requestAuthorization(
                            options: authOptions,
                            completionHandler: {_, _ in })
                        UIApplication.shared.registerForRemoteNotifications()
                        UIApplication.shared.applicationIconBadgeNumber = 0
                    }
                }
            }
        }
        .environmentObject(authenticationHelper)
    }
}

#Preview {
    ContentView()
}

