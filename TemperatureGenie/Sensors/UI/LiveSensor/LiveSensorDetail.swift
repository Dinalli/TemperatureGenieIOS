//
//  LiveSensorDetail.swift
//  TemperatureGenie
//
//  Created by Andrew Donnelly on 21/04/2025.
//

import SwiftUI

struct LiveSensorDetail: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authenticationHelper: AuthenticationHelper
    var sensor: UserSensorResponse
    @StateObject var viewModel: SensorListViewModel
    
    @State var showManualEntry = false
    
    var body: some View {
        ZStack {
            Color(Color("GenieBoxBackground")).ignoresSafeArea(.all)
            VStack {
                VStack{
                    HStack(){
                        Text(sensor.departmentName)
                            .padding(EdgeInsets(
                                top: 0,
                                leading: 10,
                                bottom: 0,
                                trailing: 10
                            ))
                            .font(.custom("poppins_medium", size: 17))
                            .foregroundColor(Color.white)
                        Spacer()
                        Text("\(sensor.batteryLevelPercentage)%")
                            .padding(EdgeInsets(
                                top: 0,
                                leading: 10,
                                bottom: 0,
                                trailing: 10
                            ))
                            .font(.custom("poppins_medium", size: 17))
                            .foregroundColor(Color.white)
                    }.padding()
                    .background((Color("GenieBlue")))
                    HStack{
                        Text("Alarm status: ")
                            .font(.custom("poppins_medium", size: 17))
                            .foregroundColor(Color("GenieBlue"))
                        Text(sensor.active ? "ACTIVE" : "INACTIVE")
                            .font(.custom("poppins_medium", size: 17))
                            .foregroundColor(Color("GenieBlue"))
                        Spacer()
                    }.padding(EdgeInsets(
                        top: 5,
                        leading: 10,
                        bottom: 5,
                        trailing: 10
                    ))
                    HStack{
                        Text("Status: ")
                            .font(.custom("poppins_medium", size: 17))
                            .foregroundColor(Color("GenieBlue"))
                        Text(viewModel.getDeviceStatus(sensor: sensor))
                            .font(.custom("poppins_medium", size: 17))
                            .foregroundColor(Color("GenieBlue"))
                        Spacer()
                    }.padding(EdgeInsets(
                        top: 5,
                        leading: 10,
                        bottom: 5,
                        trailing: 10
                    ))
                    HStack{
                        Text("Last Temp: ")
                            .font(.custom("poppins_medium", size: 17))
                            .foregroundColor(Color("GenieBlue"))
                        Text("\(viewModel.lastTemperatureSample) c")
                            .font(.custom("poppins_medium", size: 17))
                            .foregroundColor(Color("GenieBlue"))
                        Spacer()
                    }.padding(EdgeInsets(
                        top: 5,
                        leading: 10,
                        bottom: 5,
                        trailing: 10
                    ))
                    HStack{
                        Text("Timestamp: ")
                            .font(.custom("poppins_medium", size: 17))
                            .foregroundColor(Color("GenieBlue"))
                        Text(sensor.active ? "ACTIVE" : "")
                            .font(.custom("poppins_medium", size: 17))
                            .foregroundColor(Color("GenieBlue"))
                        Spacer()
                    }.padding(EdgeInsets(
                        top: 5,
                        leading: 10,
                        bottom: 5,
                        trailing: 10
                    ))
                }
                Button {
                    
                } label: {
                    Text("Submit live reading").font(.custom("poppins_medium", size: 17))
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(Color("GenieLightBlue"))
                        .cornerRadius(8)
                        .foregroundColor(Color.white)
                }
                .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
                Button {
                    showManualEntry.toggle()
                } label: {
                    Text(showManualEntry ? "Hide Manual reading" : "Show Manual reading" ).font(.custom("poppins_medium", size: 17))
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(Color("GenieLightBlue"))
                        .cornerRadius(8)
                        .foregroundColor(Color.white)
                }
                .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
                if (showManualEntry){
                    ManualAlert(sensor: sensor, viewModel: viewModel)
                }
                Spacer()
            }
        }
        .onAppear {
            Task {
                await viewModel.getLastTempReadingForSensors(sensor: sensor)
            }
        }
    }
}

#Preview {
    LiveSensorDetail(sensor: UserSensorResponse(sensorId: 0, description: "Hot Cabinet 1",serialNumber: "ZS300_DLJ230202572", physicalId: "ABC!234", batteryLevelPercentage: 67, storeName: "ANDYS", departmentName: "Department 1", active: true, inAlarmState: false, lastTemperatureReading: "10.4", lastTemperatureReadingTimestamp: "", manualReadsEnabled: true, alertPauseEndDateTime: ""), viewModel: SensorListViewModel())
}
