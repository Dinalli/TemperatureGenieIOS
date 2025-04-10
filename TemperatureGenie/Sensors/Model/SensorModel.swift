//
//  SensorModel.swift
//  TemperatureGenie
//
//  Created by Andrew Donnelly on 29/03/2025.
//
import Foundation
import CoreBluetooth

public struct UserSensorResponse: Codable {
    public let sensorId: Int
    public let description: String
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
