//
//  ManualAlert.swift
//  TemperatureGenie
//
//  Created by Andrew Donnelly on 15/04/2025.
//

import SwiftUI

struct ManualAlert: View {
    var sensor: UserSensorResponse
    var viewModel: SensorListViewModel
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    ManualAlert(sensor: UserSensorResponse(sensorId: 0, description: "Hot Cabinet 1", physicalId: "ABC!234", batteryLevelPercentage: 67, storeName: "ANDYS", departmentName: "Department 1", active: true, inAlarmState: false, lastTemperatureReading: "10.4", lastTemperatureReadingTimestamp: "", manualReadsEnabled: true, alertPauseEndDateTime: ""), viewModel: SensorListViewModel())
}
