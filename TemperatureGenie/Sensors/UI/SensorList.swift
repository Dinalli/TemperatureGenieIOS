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
            VStack {
                List {
                    ForEach(viewModel.filteredSensors, id: \.sensorId) { sensor in
                        DiscoveredSensorRow(sensor: sensor, viewModel: viewModel)
                            .listRowInsets(.init(top: 10, leading: 10, bottom: 0, trailing: 10))
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                    }.listRowBackground(Color("GenieBackground"))
                        .listRowSeparator(.hidden)
                }.listStyle(.plain)
                    .refreshable {
                        viewModel.getUserSensors(token: authenticationHelper.getAccessToken())
                    }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image("TempGenieLogo").resizable().frame(width: 232, height: 30, alignment: .center)
                }
            }
            .background(Color("GenieBackground"))
            .navigationTitle("Sensors").foregroundColor(Color("GenieBlue"))
            .font(.custom("poppins_medium", size: 17))
            .navigationBarTitleDisplayMode(.inline)
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
