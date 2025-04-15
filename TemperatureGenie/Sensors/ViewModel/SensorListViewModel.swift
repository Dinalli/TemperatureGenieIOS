//
//  SensorListViewModel.swift
//  TemperatureGenie
//
//  Created by Andrew Donnelly on 29/03/2025.
//

import Foundation
import AtsEnvirovueSdk
import CoreBluetooth
import SwiftUICore
import Combine

class SensorListViewModel: NSObject, ObservableObject {
    private var centralManager: CBCentralManager?
    private var service = SensorAPI()
    private var cancellables = Set<AnyCancellable>()
    
    @Published var filteredSensors: [UserSensorResponse] = []
    @Published var isLoading: Bool = false
    @Published var alertMessageTitle = ""
    @Published var alertMessage = ""
    @Published var showAlert = false
    
    private var discoveryList: [BLEDeviceData] = []
    private var discoveredUserSensors: [UserSensorResponse] = []
    
    func setUpManager()  {
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    private func startScan()  {
        if centralManager?.isScanning ?? false {
            stopScan()
        }
        isLoading = true
        centralManager?.scanForPeripherals(withServices: nil)
    }
    
    private func stopScan() {
        isLoading = false;
        centralManager?.stopScan()
    }
    
    func getDiscoveredSensors() {
        centralManager?.scanForPeripherals(withServices: nil)
        Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { timer in
            self.stopScan()
            timer.invalidate()
        }
    }
    
    func getUserSensors(token: String) {
        self.service.getSensorsForUser(token: token, session: URLSession.shared)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .sink { res  in
                switch res {
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.alertMessageTitle = "Get sensor error"
                        self.alertMessage = error.localizedDescription
                        self.showAlert = true
                    }
                case .finished:
                    break
                }
            } receiveValue: { userSensors in
                self.discoveredUserSensors = userSensors
                self.updateFilteredSensors()
            }
            .store(in: &cancellables)
    }
    
    private func updateFilteredSensors() {
       // val filteredSensors = discoveredSensors.flatMap { sensorId -> userSensors.filter { sensorId == it.physicalId }}
       // filteredSensors = discoveryList.flatMap { $0.sensorId -> discoveryList.filter { sensorId == $0.physicalId }}
        
    // Come back to this as filtered live sensors doesnt have info needed yet
        filteredSensors = discoveredUserSensors
    }
    
    func isSensorInPausedState(sensor: UserSensorResponse) -> Bool {
        if (sensor.alertPauseEndDateTime.isEmpty) {
            return false
        }
        guard let alertPauseDate = sensor.alertPauseEndDateTime.toDate(dateFormat: "dd MM yyyy HH:mm:ss") else { return false }
        if (alertPauseDate < Date()) {
            return true
        } else {
            return false
        }
    }
    
}

extension SensorListViewModel: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            //bluetoothError = false
            startScan()
        } else if central.state == .poweredOff{
            isLoading = false
//            bluetoothError = true
//            scanTimer?.invalidate()
            centralManager?.stopScan()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if (peripheral.name ?? "Unknown Device").contains("ZS300") {
            let discovery = BLEDeviceData(peripheral: peripheral, advertisementData: BLEAdvertisementData(from: advertisementData))
            if !discoveryList.contains(where: { item in
                return item.peripheral.identifier == peripheral.identifier
            }) {
                print("Peripheral Data \(discovery.peripheral)")
                print("Advertisement Data \(discovery.advertisementData)")
                discoveryList.append(discovery)
            }
        }
        updateFilteredSensors()
    }
}

