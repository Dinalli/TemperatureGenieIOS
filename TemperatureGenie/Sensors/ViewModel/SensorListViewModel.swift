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
    @Published var lastTemperatureSample: Int16 = -999
    @Published var isLoading: Bool = false
    @Published var alertMessageTitle = ""
    @Published var alertMessage = ""
    @Published var showAlert = false
    
    //MARK: - Sensor Discovery
    
    private var discoveryList: [BLEDeviceData] = []
    private var discoveredUserSensors: [UserSensorResponse] = []
    private var temperatureSamples: [Int16] = []
    
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
        if AuthenticationHelper().isAlertModeOnly() {
            filteredSensors = discoveredUserSensors
            return
        }
        let foundDeviceNames = Set(discoveryList.map { $0.peripheral.name })
        filteredSensors = discoveredUserSensors.filter { foundDeviceNames.contains($0.serialNumber)}
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
    
    
    
    //MARK: Pause Entry
    @Published var reasonForPause: String = ""
    @Published var actionedBy: String = ""
    @Published var duration: String = ""
    
    @Published var pauseAlertMessageTitle = ""
    @Published var pauseAlertMessage = ""
    @Published var showPauseAlert = false
    
    var isPauseEntryValid: Bool {
        return isDurationValid() && !actionedBy.isEmpty && !reasonForPause.isEmpty
    }
    
    var durationPrompt: String {
        if isDurationValid() {
            return ""
        } else {
            return "Please enter a value for pause duration 0-12 hours"
        }
    }
    
    private func isDurationValid() -> Bool {
        guard let intDuration = Int(duration) else {
            return false
        }
        let durationTest = NSPredicate(format: "SELF MATCHES %@",
                                    "^([0-9]|1[0-2])$")
        return durationTest.evaluate(with: duration)
    }
    
    var reasonPrompt: String {
        if reasonForPause.isEmpty {
            return "Enter the reason for pausing the alert."
        }
        return ""
    }
    
    var actionedPrompt: String {
        if actionedBy.isEmpty {
            return "Enter who this was actioned by"
        }
        return ""
    }
    
    func submitPauseAlert(sensor: UserSensorResponse, tempReading: String, probedLocation: String, readingNotes: String, token: String) {
        guard let intDuration: Int = Int(duration) else {
            DispatchQueue.main.async {
                self.pauseAlertMessageTitle = "Submission error"
                self.pauseAlertMessage = "Please enter a value for pause duration 0-12 hours"
                self.showPauseAlert = true
            }
            return
        }
        let pauseSubmission = PauseAlarmSubmission(sensorId: String("\(sensor.sensorId)"), reason: reasonForPause, actionedBy: actionedBy, pauseHours: intDuration)
        self.service.submitPauseForSenson(token: token, pauseSubmission: pauseSubmission, session: URLSession.shared)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .sink { res  in
                switch res {
                    case .failure(let error):
                    DispatchQueue.main.async {
                        self.pauseAlertMessageTitle = "Submission error"
                        self.pauseAlertMessage = error.localizedDescription
                        self.showPauseAlert = true
                    }
                    case .finished:
                        break
                }
            } receiveValue: { response in
                //DispatchQueue.main.async {
                    self.pauseAlertMessageTitle = "Submission Complete"
                    self.pauseAlertMessage = "Submission has been successful"
                    self.showPauseAlert = true
                //}
            }
            .store(in: &cancellables)
    }
    
    func getLastTempReadingForSensors(sensor: UserSensorResponse) async {
        // Get the actual live sensor from the discovery List.
        guard let liveSensor = getBLEDEviceSensorForUserResponseSensor(sensor: sensor) else { print("Could not find sensor");  return }
        //Task {
            do {
                temperatureSamples = try await ZebraSdkUtilities.readSamplesOffline(peripheral: liveSensor.peripheral, size: 100, offset: 0)
                await MainActor.run {
                    guard let lastSample = temperatureSamples.last else { return }
                    lastTemperatureSample = lastSample / 100
                }
            } catch let error as ZebraIllegalArgumentException {
                print("Error fetching samples \(error.localizedDescription)")
            } catch let error as ZebraBluetoothLeException {
                print("Error fetching samples Bluetooth exception \(error.localizedDescription)")
            } catch {
                print("Error fetching samples \(error.localizedDescription)")
            }
        //}
    }
    
    func getDeviceStatus(sensor: UserSensorResponse)-> String {
        guard let liveSensor = getBLEDEviceSensorForUserResponseSensor(sensor: sensor) else { print("Could not find sensor");  return "" }
        switch liveSensor.peripheral.state {
        case .connected:
            return "Connected"
        case .disconnected:
            return "Disconnected"
        default:
            return "Unknown"
        }
    }
    
    func getAdvertismentData(advertisementData: [String : Any]) -> String {
        guard let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data else {
            print("Could not find advertismentData");  return ""
        }
        do {
            // Initialize AdvertisingInfo with the manufacturer data
            let advertisingInfo = try ZebraSdkUtilities.getAdvertisingInfo(data: manufacturerData)
            return advertisingInfo.description
        } catch let error as ZebraIllegalArgumentException {
            print("Error fetching advertisment Data \(error.localizedDescription)")
        } catch {
            print("Error fetching advertisment Data \(error.localizedDescription)")
        }
        return ""
    }
    
    func getBLEDEviceSensorForUserResponseSensor(sensor: UserSensorResponse) -> BLEDeviceData? {
        return discoveryList.filter { $0.peripheral.name == sensor.serialNumber }.first
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
            let advertisingData = getAdvertismentData(advertisementData: advertisementData)
            let discovery = BLEDeviceData(peripheral: peripheral, advertisementData: advertisingData)
            if !discoveryList.contains(where: { item in
                return item.peripheral.identifier == peripheral.identifier
            }) {
                print("Peripheral Data \(discovery.peripheral)")
                print("Advertisement Data \(discovery.advertisementData)")
                discoveryList.append(discovery)
            }
            updateFilteredSensors()
        }
    }
}

