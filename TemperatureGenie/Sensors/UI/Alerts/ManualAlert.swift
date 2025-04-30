//
//  ManualAlert.swift
//  TemperatureGenie
//
//  Created by Andrew Donnelly on 15/04/2025.
//

import SwiftUI

struct ManualAlert: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authenticationHelper: AuthenticationHelper
    var sensor: UserSensorResponse
    @StateObject var viewModel: SensorListViewModel
    
    var body: some View {
        ZStack {
            Color(Color("GenieBoxBackground")).ignoresSafeArea(.all)
            VStack {
                VStack {
                    HStack {
                        Text("Temperature Reading").font(.custom("poppins_medium", size: 12)).foregroundColor(Color("GenieBlue"))
                        Spacer()
                    }
                    ValidationTextField(placeHolderText: "Enter temperature reading", promptText: viewModel.tempPrompt, fieldValue: $viewModel.manualTempReading)
                }.padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
                VStack {
                    HStack {
                        Text("Product type probed").font(.custom("poppins_medium", size: 12)).foregroundColor(Color("GenieBlue"))
                        Spacer()
                    }
                    ValidationTextField(placeHolderText: "Enter product type probed", promptText: viewModel.probePrompt, fieldValue: $viewModel.probeLocation)
                }.padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
                VStack {
                    HStack {
                        Text("Notes").font(.custom("poppins_medium", size: 12)).foregroundColor(Color("GenieBlue"))
                        Spacer()
                    }
                    ValidationTextField(placeHolderText: "Enter any notes", promptText: viewModel.notesPrompt, fieldValue: $viewModel.notes)
                }.padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
                Button {
                    viewModel.submitManualReading(sensor: sensor, tempReading: viewModel.manualTempReading, probedLocation: viewModel.probeLocation, readingNotes: viewModel.notes, token: authenticationHelper.getAccessToken())
                    print("Submit reading")
                } label: {
                    Text("Submit alert reading").font(.custom("poppins_medium", size: 17))
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(Color("GenieLightBlue"))
                        .cornerRadius(8)
                        .foregroundColor(Color.white)
                }.disabled(!viewModel.isManualEntryValid)
                .opacity(viewModel.isManualEntryValid ? 1.0 : 0.5)
                .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
                Spacer()
                    .alert(viewModel.manualAlertMessageTitle, isPresented: $viewModel.showManualAlert) {
                        Button("OK") {
                            viewModel.showAlert = false
                            presentationMode.wrappedValue.dismiss()
                        }
                    } message: {
                        Text(viewModel.manualAlertMessage)
                    }
            }
        }
        .navigationTitle("Alert action for \(sensor.description)").foregroundStyle(Color.white)
        .font(.custom("poppins_medium", size: 17))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color("GenieLightBlue"), for: .navigationBar)
        Spacer()
    }
}

#Preview {
    ManualAlert(sensor: UserSensorResponse(sensorId: 0, description: "Hot Cabinet 1",serialNumber: "ZS300_DLJ230202572", physicalId: "ABC!234", batteryLevelPercentage: 67, storeName: "ANDYS", departmentName: "Department 1", active: true, inAlarmState: false, lastTemperatureReading: "10.4", lastTemperatureReadingTimestamp: "", manualReadsEnabled: true, alertPauseEndDateTime: ""), viewModel: SensorListViewModel())
}
