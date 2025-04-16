//
//  ManualAlert.swift
//  TemperatureGenie
//
//  Created by Andrew Donnelly on 15/04/2025.
//

import SwiftUI

struct ManualAlert: View {
    var sensor: UserSensorResponse
    @StateObject var viewModel: SensorListViewModel
    
    var body: some View {
        ZStack {
            Color(Color("GenieBoxBackground")).ignoresSafeArea(.all)
            VStack {
                Button {
                    //viewModel.submitAlert()
                } label: {
                    Text("Submit alert reading").font(.custom("poppins_medium", size: 17))
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(Color("GenieLightBlue"))
                        .cornerRadius(8)
                        .foregroundColor(Color.white)
                }
                .alert(viewModel.alertMessageTitle, isPresented: $viewModel.showAlert) {
                    Button("OK") {
                        viewModel.showAlert = false
                    }
                } message: {
                    Text(viewModel.alertMessage)
                }
            }.padding()
        }
        .navigationTitle("Alert action for \(sensor.description)").foregroundColor(Color.black)
        .font(.custom("poppins_medium", size: 17))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ManualAlert(sensor: UserSensorResponse(sensorId: 0, description: "Hot Cabinet 1",serialNumber: "ZS300_DLJ230202572", physicalId: "ABC!234", batteryLevelPercentage: 67, storeName: "ANDYS", departmentName: "Department 1", active: true, inAlarmState: false, lastTemperatureReading: "10.4", lastTemperatureReadingTimestamp: "", manualReadsEnabled: true, alertPauseEndDateTime: ""), viewModel: SensorListViewModel())
}
