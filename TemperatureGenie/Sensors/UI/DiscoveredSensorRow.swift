//
//  DiscoveredSensorRow.swift
//  TemperatureGenie
//
//  Created by Andrew Donnelly on 10/04/2025.
//

import SwiftUI

struct DiscoveredSensorRow: View {
    
    var sensor: UserSensorResponse
    var viewModel: SensorListViewModel
    
    var body: some View {
        HStack{
            VStack {
                Text(sensor.description)
                    .padding(EdgeInsets(
                        top: 0,
                        leading: 10,
                        bottom: 0,
                        trailing: 10
                    ))
                    .font(.custom("poppins_medium", size: 17))
                    .foregroundColor(Color.black)
                Text(sensor.departmentName)
                    .padding(EdgeInsets(
                        top: 0,
                        leading: 10,
                        bottom: 0,
                        trailing: 10
                    ))
                    .font(.custom("poppins_medium", size: 17))
                    .foregroundColor(Color.black)
            }
            Spacer()
            VStack {
                if sensor.inAlarmState {
                    Image("warning")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24, alignment: .center)
                } else if viewModel.isSensorInPausedState(sensor: sensor) {
                    Image("alarm")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24, alignment: .center)
                } else {
                    Image("tick")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24, alignment: .center)
                }
            }
            VStack {
                Button {
                    print("PAUSE TAPPED")
                } label: {
                    Text("Pause\n Alert").padding().font(.custom("poppins_medium", size: 12))
                        .foregroundColor(Color.white)
                }
                .frame(maxWidth: 100, minHeight: 44)
                .background(Color("GenieLightBlue"))
                .cornerRadius(8)
                .padding(
                    EdgeInsets(
                        top: 2,
                        leading: 10,
                        bottom: 2,
                        trailing: 10
                    )
                )
            }
        }.frame(maxWidth: .infinity, minHeight:100, alignment: .leading)
            .background(
                Rectangle()
                    .fill(Color("GenieBackground"))
            )
            .cornerRadius(8.0)
    }
}

#Preview {
    DiscoveredSensorRow(sensor: UserSensorResponse(sensorId: 0, description: "Hot Cabinet 1", physicalId: "ABC!234", batteryLevelPercentage: 67, storeName: "ANDYS", departmentName: "Department 1", active: true, inAlarmState: false, lastTemperatureReading: "10.4", lastTemperatureReadingTimestamp: "", manualReadsEnabled: true, alertPauseEndDateTime: ""), viewModel: SensorListViewModel())
}
