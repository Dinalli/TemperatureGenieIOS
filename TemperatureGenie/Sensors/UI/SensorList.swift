//
//  Sensor.swift
//  TemperatureGenie
//
//  Created by Andrew Donnelly on 27/03/2025.
//

import SwiftUI

struct SensorList: View {
    @StateObject var viewModel: SensorListViewModel = SensorListViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.discoveryList,id: \._id) { data in
                VStack(alignment:.leading) {
                    Text(data.peripheral.name!)
                }
            }
        }
        .onAppear()
        {
            viewModel.discoveryList.removeAll()
            viewModel.setUpManager()
            viewModel.getDiscoveredSensors()
        }
    }
}

#Preview {
    SensorList()
}
