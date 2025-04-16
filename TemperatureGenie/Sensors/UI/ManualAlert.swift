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
    
    @State private var tempReading: String = ""
    @State private var productType: String = ""
    @State private var notes: String = ""
    
    var body: some View {
        ZStack {
            Color(Color("GenieBoxBackground")).ignoresSafeArea(.all)
            VStack {
                VStack {
                    HStack {
                        Text("Temperature Reading").font(.custom("poppins_medium", size: 12)).foregroundColor(Color("GenieBlue"))
                        Spacer()
                    }
                    TextField("Enter temperature reading", text: $tempReading).autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/).font(.custom("poppins_medium", size: 17)).foregroundColor(Color("GenieBlue"))
                        .padding()
                        .background(Color.white)
                        .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color("GeniePurple"), lineWidth: 1)
                    )
                }
                VStack {
                    HStack {
                        Text("Product type probed").font(.custom("poppins_medium", size: 12)).foregroundColor(Color("GenieBlue"))
                        Spacer()
                    }
                    TextField("Enter product type probed", text: $productType).autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/).font(.custom("poppins_medium", size: 17)).foregroundColor(Color("GenieBlue"))
                        .padding()
                        .background(Color.white)
                        .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color("GeniePurple"), lineWidth: 1)
                    )
                }
                VStack {
                    HStack {
                        Text("Notes").font(.custom("poppins_medium", size: 12)).foregroundColor(Color("GenieBlue"))
                        Spacer()
                    }
                    TextField("Enter notes", text: $notes).autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/).font(.custom("poppins_medium", size: 17)).foregroundColor(Color("GenieBlue"))
                        .padding()
                        .background(Color.white)
                        .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color("GeniePurple"), lineWidth: 1)
                    )
                }
                Button {
                    //viewModel.submitAlert()
                    print("Submit reading")
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
        .navigationTitle("Alert action for \(sensor.description)").foregroundStyle(Color.white)
        .font(.custom("poppins_medium", size: 17))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color("GenieLightBlue"), for: .navigationBar)
    }
}

#Preview {
    ManualAlert(sensor: UserSensorResponse(sensorId: 0, description: "Hot Cabinet 1",serialNumber: "ZS300_DLJ230202572", physicalId: "ABC!234", batteryLevelPercentage: 67, storeName: "ANDYS", departmentName: "Department 1", active: true, inAlarmState: false, lastTemperatureReading: "10.4", lastTemperatureReadingTimestamp: "", manualReadsEnabled: true, alertPauseEndDateTime: ""), viewModel: SensorListViewModel())
}
