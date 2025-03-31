//
//  SensorListViewModel.swift
//  TemperatureGenie
//
//  Created by Andrew Donnelly on 29/03/2025.
//

import Foundation
import ats_envirovue_ios_sdk
import CoreBluetooth
import SwiftUICore

class SensorListViewModel: NSObject, ObservableObject {
    @Published var discoveryList: [BLEDeviceData] = []
    @Published var isLoading: Bool = false
    
    private var centralManager: CBCentralManager?
    
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
    
    func getUserSensors() -> [UserSensorResponse] {
        return []
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
                discoveryList.append(discovery)
            }
        }
    }
}

