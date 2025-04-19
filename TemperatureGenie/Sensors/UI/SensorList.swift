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
        NavigationView {
            ZStack {
                VStack {
                    List {
                        ForEach(viewModel.filteredSensors, id: \.sensorId) { sensor in
                            DiscoveredSensorRow(sensor: sensor, viewModel: viewModel)
                                .listRowInsets(.init(top: 10, leading: 10, bottom: 10, trailing: 10))
                                .overlay(
                                    NavigationLink(destination: ManualAlert(sensor: sensor, viewModel: viewModel)) {
                                        EmptyView()
                                    }.opacity(0)
                                )
                        }.listRowBackground(
                            RoundedRectangle(cornerRadius: 5)
                                .background(.clear)
                                .foregroundColor(.clear)
                        )
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                    .refreshable {
                        viewModel.getUserSensors(token: authenticationHelper.getAccessToken())
                    }
                }
                .toolbarBackground(.orange, for: .navigationBar, .tabBar)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Image("TempGenieLogo").resizable().frame(width: 232, height: 30, alignment: .center)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            authenticationHelper.logout()
                        } label: {
                            Text("Logout").padding().font(.custom("poppins_medium", size: 12))
                                .foregroundColor(Color.white)
                        }
                        .frame(maxWidth: 100, minHeight: 44)
                        .background(Color("GenieLightBlue"))
                        .cornerRadius(8)
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        LiveIndicator(fillColor: .constant(.red))
                    }
                }
            }
            .background(Color("GenieBoxBackground"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(false)
            .navigationTitle("Sensors").foregroundStyle(Color.white)
            .font(.custom("poppins_medium", size: 17))
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.white, for: .navigationBar)
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

