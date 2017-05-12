//
//  BLERouter.swift
//  ios-app
//
//  Created by ishansaksena on 5/5/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import Foundation
import CoreBluetooth


final class BLERouter: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var centralManager: CBCentralManager!
    var obd2: CBPeripheral?
    var dataCharacteristic:CBCharacteristic?
    var peripherals = [CBPeripheral]()
    var readService:CBService?
    
    let obd2TagName = "OBDBLE"
    let obd2ServiceUUID = CBUUID(string: "B88BAB0E-3ABD-40F9-A816-7FB4FBE10E7E")
    
    let timerPauseInterval:TimeInterval = 10.0  // Duration in seconds of each "pause" between scans
    let timerScanInterval:TimeInterval = 5.0    // Duration in seconds of each scan
    var pauseScanTimer:Timer?
    var resumeScanTimer:Timer?
    
    var timer = Timer()
    let speedUpdateInterval:TimeInterval = 1.0  // Number of seconds between speed requests
    
    var tracking = false
    
    var totalDist = 0.0;
    var aggDist = 0.0;
    var tripSeconds = 0.0;
    
    var trips = [[String]]()
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // Disconnect from the OBD
    func disconnect() {
        // Verify we have a peripheral
        guard let peripheral = self.obd2 else {
            print("No peripheral available to disconnect.")
            return
        }
        
        // Don't do anything if we're not connected
        if peripheral.state != .connected {
            print("Peripheral is not connected.")
            self.obd2 = nil
            return
        }
        
        // Disconnect directly
        guard let services = peripheral.services else {
            centralManager.cancelPeripheralConnection(peripheral)
            return
        }
        
        // Iterate through services
        for service in services {
            // Iterate through characteristics
            if let characteristics = service.characteristics {
                for characteristic in characteristics {
                    // find the Transfer Characteristic we defined in our Device struct
                    if characteristic.uuid == CBUUID.init(string: "FFE1") {
                        // Turn off notifications
                        peripheral.setNotifyValue(false, for: characteristic)
                        return
                    }
                }
            }
        } 
        
        // Disconnect from peripheral
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        //var showAlert = true
        
        switch central.state {
        case .poweredOff:
            print("Bluetooth on this device is currently powered off.")
        case .unsupported:
            print("This device does not support Bluetooth Low Energy.")
        case .unauthorized:
            print("This app is not authorized to use Bluetooth Low Energy.")
        case .resetting:
            print("The BLE Manager is resetting; a state update is pending.")
        case .unknown:
            print("The state of the BLE Manager is unknown.")
        case .poweredOn:
            //showAlert = false
            print("Bluetooth LE is turned on and ready for communication.")
            scan()
        }
    }
    
    @objc func pauseScan() {
        print("*** Pausing Scanning")
        pauseScanTimer = Timer.scheduledTimer(timeInterval: timerPauseInterval, target: self, selector: #selector(scan), userInfo: nil, repeats: false)
        centralManager.stopScan()
    }
    
    @objc func scan() {
        print("*** Scanning")
        resumeScanTimer = Timer.scheduledTimer(timeInterval: timerScanInterval, target: self, selector: #selector(pauseScan), userInfo: nil, repeats: false)
        
        //centralManager.scanForPeripherals(withServices: [obd2UUID], options: nil)
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let peripheralName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            if peripheralName == obd2TagName {
                print("*** FOUND OBDBLE! Attempting to connect now!")
                self.obd2 = peripheral
                self.obd2!.delegate = self
                peripherals.append(peripheral)
                
                centralManager.connect(obd2!, options: nil)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("*** 🐔Successfully connected!🦄")
        centralManager.stopScan()
        pauseScanTimer?.invalidate()
        resumeScanTimer?.invalidate()
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?){
        print("*** Failed to Connect!")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("*** Disconnected from Peripheral: \(peripheral.name!)")
        
        if error != nil {
            print("*** DISCONNECTION DETAILS: \(error!.localizedDescription)")
        }
        
        self.obd2 = nil
        scan()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil {
            print("ERROR DISCOVERING SERVICES: \(String(describing: error?.localizedDescription))")
            return
        }
        
        if let services = peripheral.services {
            for service in services {
                print("Discovered service \(service)")
                if (service.uuid.uuidString == "FFE0") {
                    readService = service
                }
                
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            print("ERROR DISCOVERING CHARACTERISTICS: \(String(describing: error?.localizedDescription))")
            return
        }
        
        if (service.uuid.uuidString == "FFE0" && service.characteristics![0].uuid.uuidString == "FFE1") {
            // Found OBD-II input/output service & characteristic
            monitorMetric(metricCmd: "010D\n\r", bleServiceCharacteristic: service.characteristics![0])
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print("ERROR ON UPDATING VALUE FOR CHARACTERISTIC: \(characteristic) - \(String(describing: error?.localizedDescription))")
            return
        }
        
        var kph:Int?
        var mph:Double = 0.0
        var returnedBytes = [UInt8](characteristic.value!)
//        print(characteristic)
//        print(returnedBytes.map { String(UnicodeScalar($0)) }.joined())
        if (returnedBytes.count == 7) {
            kph = Int("\(String(UnicodeScalar(returnedBytes[returnedBytes.count - 3])))\(String(UnicodeScalar(returnedBytes[returnedBytes.count - 2])))", radix:16)
        }
        
        if (kph != nil) {
            mph = Double(kph!) / 1.609344
            print("\n\n Current speed: \(mph) mph\n\n")
            if (!tracking && mph > 0) {
                tracking = true
                totalDist = 0
                tripSeconds = 0.0
                recordSpeedUpdate(spd: mph)
            } else if (tracking && mph <= 0) {
                tracking = false
                stopTrip()
            } else if (tracking) {
                recordSpeedUpdate(spd: mph)
            }
        }
    }
    
    func monitorMetric(metricCmd: String, bleServiceCharacteristic: CBCharacteristic) {
        timer = Timer.scheduledTimer(timeInterval: speedUpdateInterval,
                                     target: self,
                                     selector: #selector(monitorMetricRequest),
                                     userInfo: ["cmd": metricCmd, "bleServiceCharacteristic": bleServiceCharacteristic],
                                     repeats: true)
    }
    
    func monitorMetricRequest(timer: Timer) {
        let userInfoDict = timer.userInfo as! Dictionary<String, Any>
        requestMetric(cmd: userInfoDict["cmd"] as! String, bleServiceCharacteristic: userInfoDict["bleServiceCharacteristic"] as! CBCharacteristic)
    }
    
    func requestMetric(cmd: String, bleServiceCharacteristic: CBCharacteristic) {
        let cmdBytes = cmd.hexadecimal()!
        obd2?.setNotifyValue(true, for: bleServiceCharacteristic)
        obd2?.writeValue(cmdBytes, for: bleServiceCharacteristic, type: .withResponse)
    }
    
    func recordSpeedUpdate(spd: Double) {
        totalDist += spd * (Double(speedUpdateInterval)/3600.0)
        tripSeconds += Double(speedUpdateInterval)
    }
    
    func stopTrip() {
        aggDist += totalDist
        
        let date = Date()
        let calendar = Calendar.current
        
//        let year = calendar.component(.year, from: date)
        let month = calendar.monthSymbols[calendar.component(.month, from: date) - 1]
        let day = calendar.component(.day, from: date)
//        let hour = calendar.component(.hour, from: date)
//        let minutes = calendar.component(.minute, from: date)
//        let seconds = calendar.component(.second, from: date)
        
        trips.append(["\(day)", "\(String(format: "%.1f", (tripSeconds/60.0))) min", "\(String(format: "%.1f", totalDist)) miles", "\(month)"])
    }
    
}

// Easy conversion of Hexadecimal data from OBD
extension String {
    func hexadecimal() -> Data? {
        var data = Data(capacity: characters.count / 2)
        
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, options: [], range: NSMakeRange(0, characters.count)) { match, flags, stop in
            let byteString = (self as NSString).substring(with: match!.range)
            var num = UInt8(byteString, radix: 16)!
            data.append(&num, count: 1)
        }
        
        guard data.count > 0 else {
            return nil
        }
        return data
    }
}


