//
//  AlarmAlert.swift
//  TemperatureGenie
//
//  Created by Andrew Donnelly on 30/04/2025.
//

import SwiftUI

struct AlarmAlert: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authenticationHelper: AuthenticationHelper
    var sensor: UserSensorResponse
    @StateObject var viewModel: SensorListViewModel
    
    var body: some View {
        Text("Alarm")
    }
}

#Preview {
    AlarmAlert(sensor: UserSensorResponse(sensorId: 0, description: "Hot Cabinet 1",serialNumber: "ZS300_DLJ230202572", physicalId: "ABC!234", batteryLevelPercentage: 67, storeName: "ANDYS", departmentName: "Department 1", active: true, inAlarmState: false, lastTemperatureReading: "10.4", lastTemperatureReadingTimestamp: "", manualReadsEnabled: true, alertPauseEndDateTime: ""), viewModel: SensorListViewModel())
}
