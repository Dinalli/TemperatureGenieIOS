//
//  PauseAlert.swift
//  TemperatureGenie
//
//  Created by Andrew Donnelly on 19/04/2025.
//

import SwiftUI

struct PauseAlert: View {
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
                        Text("Reason for pause :").font(.custom("poppins_medium", size: 12)).foregroundColor(Color("GenieBlue"))
                        Spacer()
                    }
                    ValidationTextField(placeHolderText: "Enter the reason for pausing the alert", promptText: viewModel.reasonPrompt, fieldValue: $viewModel.reasonForPause)
                }.padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
                VStack {
                    HStack {
                        Text("Actioned by:").font(.custom("poppins_medium", size: 12)).foregroundColor(Color("GenieBlue"))
                        Spacer()
                    }
                    ValidationTextField(placeHolderText: "Enter who this was actioned by", promptText: viewModel.actionedPrompt, fieldValue: $viewModel.actionedBy)
                }.padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
                VStack {
                    HStack {
                        Text("Pause duration:").font(.custom("poppins_medium", size: 12)).foregroundColor(Color("GenieBlue"))
                        Spacer()
                    }
                    ValidationTextField(placeHolderText: "Please enter value for pause duration 0-12 hours", promptText: viewModel.durationPrompt, fieldValue: $viewModel.duration, isNumeric: true)
                }.padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
                Button {
                    viewModel.submitPauseAlert(sensor: sensor, tempReading: viewModel.manualTempReading, probedLocation: viewModel.probeLocation, readingNotes: viewModel.notes, token: authenticationHelper.getAccessToken())
                } label: {
                    Text("Submit pause alert").font(.custom("poppins_medium", size: 17))
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(Color("GenieLightBlue"))
                        .cornerRadius(8)
                        .foregroundColor(Color.white)
                }.disabled(!viewModel.isPauseEntryValid)
                .opacity(viewModel.isPauseEntryValid ? 1.0 : 0.5)
                .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
                Spacer()
                    .alert(viewModel.pauseAlertMessageTitle, isPresented: $viewModel.showPauseAlert) {
                        Button("OK") {
                            viewModel.showAlert = false
                            presentationMode.wrappedValue.dismiss()
                        }
                    } message: {
                        Text(viewModel.pauseAlertMessage)
                    }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color("GenieLightBlue"), for: .navigationBar, .tabBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Pause alert for sensor \(sensor.description)")
                    .font(.custom("poppins_medium", size: 17))
                    .foregroundStyle(Color("GenieBoxBackground"))
            }
        }
        Spacer()
    }
}

#Preview {
    PauseAlert(sensor: UserSensorResponse(sensorId: 0, description: "Hot Cabinet 1",serialNumber: "ZS300_DLJ230202572", physicalId: "ABC!234", batteryLevelPercentage: 67, storeName: "ANDYS", departmentName: "Department 1", active: true, inAlarmState: false, lastTemperatureReading: "10.4", lastTemperatureReadingTimestamp: "", manualReadsEnabled: true, alertPauseEndDateTime: ""), viewModel: SensorListViewModel())
}
