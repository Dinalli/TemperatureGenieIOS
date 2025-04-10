//
//  Sensor.swift
//  TemperatureGenie
//
//  Created by Andrew Donnelly on 27/03/2025.
//

import SwiftUI

struct SensorList: View {
    @EnvironmentObject var authenticationHelper: AuthenticationHelper
    @StateObject var viewModel: SensorListViewModel = SensorListViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.filteredSensors, id: \.sensorId) { sensor in
                    DiscoveredSensorRow(sensor: sensor, viewModel: viewModel)
                        .listRowInsets(.init(top: 10, leading: 10, bottom: 0, trailing: 10))
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                }.listRowBackground(Color("mainBackground"))
                .listRowSeparator(.hidden)
            }.listStyle(.plain)
                .refreshable {
                    viewModel.getUserSensors(token: authenticationHelper.getAccessToken())
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
        }
    }
}

#Preview {
    SensorList()
}
