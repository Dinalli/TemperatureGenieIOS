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
                Text(sensor.departmentName)
            }
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
                    
                } label: {
                    Text("Pause")
                }

            }
        }
    }
}

#Preview {
    DiscoveredSensorRow(sensor: UserSensorResponse(sensorId: 0, description: "Test Sensor", physicalId: "ABC!234", batteryLevelPercentage: 67, storeName: "ANDYS", departmentName: "DEPT1", active: true, inAlarmState: false, lastTemperatureReading: "10.4", lastTemperatureReadingTimestamp: "", manualReadsEnabled: true, alertPauseEndDateTime: ""), viewModel: SensorListViewModel())
}
