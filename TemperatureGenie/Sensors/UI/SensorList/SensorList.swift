//
//  Sensor.swift
//  TemperatureGenie
//
//  Created by Andrew Donnelly on 27/03/2025.
//

import SwiftUI

struct SensorList: View {
    @EnvironmentObject var authenticationHelper: AuthenticationHelper
    @EnvironmentObject var locationHelper: LocationHelper
    @StateObject var viewModel: SensorListViewModel = SensorListViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    ScrollView(.vertical) {
                        ForEach(viewModel.filteredSensors) { sensor in
                            DiscoveredSensorRow(sensor: sensor, viewModel: viewModel)
                        }
                        .padding()
                    }
                    .refreshable {
                        viewModel.getUserSensors(token: authenticationHelper.getAccessToken())
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color("GenieBoxBackground"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(false)
            .navigationTitle("Sensors")
            .font(.custom("poppins_medium", size: 17))
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.white, for: .navigationBar)
            .navigationDestination(for: Route.self) { route in
                switch route {
                case let .liveSensor(sensor):
                    LiveSensorDetail(sensor: sensor, viewModel: viewModel)
                case let .manualSensor(sensor):
                    ManualAlert(sensor: sensor, viewModel: viewModel)
                case let .pauseSensor(sensor):
                    PauseAlert(sensor: sensor, viewModel: viewModel)
                case let .alertSensor(sensor):
                    AlarmAlert(sensor: sensor, viewModel: viewModel)
                }
            }
            .toolbarBackground(Color("GenieLightBlue"), for: .navigationBar, .tabBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Sensors")
                        .font(.custom("poppins_medium", size: 17))
                        .foregroundStyle(Color("GenieBoxBackground"))
                }
            }
        }
        .alert(viewModel.alertMessageTitle, isPresented: $viewModel.showAlert) {
            Button("OK") {
                viewModel.showAlert = false
            }
        } message: {
            Text(viewModel.alertMessage)
        }
        .onAppear()
        {
            viewModel.filteredSensors.removeAll()
            viewModel.setUpManager()
            viewModel.getDiscoveredSensors()
            viewModel.getUserSensors(token: authenticationHelper.getAccessToken())
            locationHelper.checkLocationState()
        }
    }
}

#Preview {
    SensorList()
}

