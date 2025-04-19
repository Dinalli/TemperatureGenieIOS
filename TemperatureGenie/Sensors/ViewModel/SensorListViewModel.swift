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
    
    //MARK: - Sensor Discovery
    
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
    
    //MARK: Manual Entry
    @Published var manualTempReading: String = ""
    @Published var probeLocation: String = ""
    @Published var notes: String = ""
    
    @Published var manualAlertMessageTitle = ""
    @Published var manualAlertMessage = ""
    @Published var showManualAlert = false
    
    var isManualEntryValid: Bool {
        return isTempValid() && !probeLocation.isEmpty && !notes.isEmpty
    }
    var tempPrompt: String {
        if isTempValid() {
            return ""
        } else {
            return "Temperature is not valid. Must be between -150 and 150"
        }
    }
    
    private func isTempValid() -> Bool {
        guard let floatLevel = Float(String(format: "%.2f", manualTempReading)) else {
            return false
        }
        let levelTest = NSPredicate(format: "SELF MATCHES %@",
                                    "^(?:-([0-9]|[1-4][0-9]|50)|([0-9]|[1-9][0-9]|1[0-4][0-9]|150))$")
        return levelTest.evaluate(with: manualTempReading)
    }
    
    var probePrompt: String {
        if probeLocation.isEmpty {
            return "Please enter the location of the probe for the reading."
        }
        return ""
    }
    
    var notesPrompt: String {
        if notes.isEmpty {
            return "Please enter some notes for the reading."
        }
        return ""
    }
    
    func submitManualReading(sensor: UserSensorResponse, tempReading: String, probedLocation: String, readingNotes: String, token: String) {
        guard let floatTemp = Float(String(format: "%.2f", tempReading)) else {
            DispatchQueue.main.async {
                self.manualAlertMessageTitle = "Submission error"
                self.manualAlertMessage = "Temperature is not valid. Must be between -150 and 150 and a number"
                self.showManualAlert = true
            }
            return
        }
        let manualReadingSubmission = ManualReadingSubmission(sensorPhysicalId: sensor.physicalId, manualReadTemperature: floatTemp, manualReadDate: Date().toString(dateFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"), manualReadLocation: probedLocation, manualReadNote: readingNotes, manualReadLatitude: "", manualReadLongitude: "")
        self.service.submitManualAlertReading(token: token, manualReading: manualReadingSubmission, session: URLSession.shared)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .sink { res  in
                switch res {
                    case .failure(let error):
                    DispatchQueue.main.async {
                        self.manualAlertMessageTitle = "Submission error"
                        self.manualAlertMessage = error.localizedDescription
                        self.showManualAlert = true
                    }
                    case .finished:
                        break
                }
            } receiveValue: { response in
                //DispatchQueue.main.async {
                    self.manualAlertMessageTitle = "Submission Complete"
                    self.manualAlertMessage = "Submission has been successful"
                    self.showManualAlert = true
                //}
            }
            .store(in: &cancellables)
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

