//
//  SensorModel.swift
//  TemperatureGenie
//
//  Created by Andrew Donnelly on 29/03/2025.
//
import Foundation
import CoreBluetooth

public struct BasicResponseObject: Codable {
    public let success: Bool
    public let errorMessage: String?
}

public struct ManualEntryErrorResponseObject: Codable {
    public let  type: String?
    public let  title: String?
    public let  status: Int?
    public let  traceId: String?
    public let  errors: listOfErrors
}

public struct UserSensorResponse: Codable {
    public let sensorId: Int
    public let description: String
    public let serialNumber: String
    public let physicalId: String
    public let batteryLevelPercentage: Int
    public let storeName: String
    public let departmentName: String
    public let active: Bool
    public let inAlarmState: Bool
    public let lastTemperatureReading: String
    public let lastTemperatureReadingTimestamp: String
    public let manualReadsEnabled: Bool
    public let alertPauseEndDateTime: String
}

public struct ManualReadingSubmission: Codable {
    public let sensorPhysicalId: String
    public let manualReadTemperature: Float
    public let manualReadDate: String
    public let manualReadLocation: String
    public let manualReadNote: String
    public let manualReadLatitude: String
    public let manualReadLongitude: String
}

public struct  AlertAlarmReadingSubmission: Codable {
    public let  sensorId: String
    public let  temperatureReading: Float
    public let  temperatureReadingLocation: String
    public let  temperatureReadingNotes: String
    public let  temperatureReadingDate: String
    public let  manualReadLatitude: String
    public let  manualReadLongitude: String
}

public struct  PauseAlarmSubmission: Codable {
    public let  sensorId: String
    public let  reason: String
    public let  actionedBy: String
    public let  pauseHours: Int
}

struct BLEDeviceData : Hashable {
    var _id = UUID();
    let peripheral: CBPeripheral;
    let advertisementData: BLEAdvertisementData;
}

struct BLEAdvertisementData : Hashable {
    let localName: String?
    let manufacturerData: Data?
    let serviceUUIDs: [UUID]?
    let txPowerLevel: Int?
}

extension BLEAdvertisementData {
    init(from advertisementData: [String: Any]) {
        self.localName = advertisementData[CBAdvertisementDataLocalNameKey] as? String
        self.manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data
        if let serviceUUIDs = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] {
            self.serviceUUIDs = serviceUUIDs.map { UUID(uuidString: $0.uuidString)! }
        } else {
            self.serviceUUIDs = nil
        }
        self.txPowerLevel = advertisementData[CBAdvertisementDataTxPowerLevelKey] as? Int
    }
}
