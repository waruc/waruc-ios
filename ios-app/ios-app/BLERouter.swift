//
//  BLERouter.swift
//  ios-app
//
//  Created by ishansaksena on 5/5/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import Foundation
import CoreBluetooth

class BLERouter: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
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
    
    var speedUpdateTimer = Timer()
    let speedUpdateInterval:TimeInterval = 1.0  // Number of seconds between speed requests
    
    var tracking = false
    
    var totalDist = 0.0
    var aggDist = 0.0
    var tripSeconds = 0.0
    var connectionType:String?
    
    let connectionTypeNotification = Notification.Name("connectionTypeNotificationIdentifier")
    let connectionStrengthNotification = Notification.Name("connectionStrengthNotificationIdentifier")
    let colorUpdateNotification = Notification.Name("colorUpdateNotification")
    
    var res:[UInt8] = []
    
    // setupOutput is expected output from device after reset (no prior configuration)
    // partialsetupOutput is expected output from device without reset (device remained configured from previous run)
    let setupOutput = "ATE0\rOK\r\r>OK\r\r>OK\r\r>OK\r\r>OK\r\r>OK\r\r>"
    let partialsetupOutput = "OK\r\r>OK\r\r>OK\r\r>OK\r\r>OK\r\r>OK\r\r>"
    var setupComplete = false
    
    var vinNumber:String?
    
    var bleConnectionStrength:String?
    
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    static let sharedInstance = BLERouter()
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
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
        
        obd2?.readRSSI()
        
        centralManager.stopScan()
        pauseScanTimer?.invalidate()
        resumeScanTimer?.invalidate()
        peripheral.discoverServices(nil)
        
        // Update connection type
        connectionType = "Bluetooth Low Energy"
        NotificationCenter.default.post(name: connectionTypeNotification, object: nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        print("\nRSSI: \(RSSI)")
        switch Int(RSSI) {
        case -70 ... Int.max:
            bleConnectionStrength = "Strong connection"
            print("Strong connection")
        case Int.min ... -71:
            bleConnectionStrength = "Weak connection"
            print("Weak connection")
        default:
            bleConnectionStrength = "Error getting RSSI value."
            print("Error getting RSSI value.")
        }
        
        NotificationCenter.default.post(name: connectionStrengthNotification, object: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("*** Failed to Connect!")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("*** Disconnected from Peripheral: \(peripheral.name!)")
        
        if error != nil {
            print("*** DISCONNECTION DETAILS: \(error!.localizedDescription)")
        }
        
        if peripheral.name! == obd2TagName {
            if tracking {
                tracking = false
                NotificationCenter.default.post(name: colorUpdateNotification, object: nil)
                
                stopTrip()
            }
            
            self.obd2 = nil
            setupComplete = false
            vinNumber = nil
            res = []
            speedUpdateTimer.invalidate()
            
            // Update connection type
            connectionType = nil
            NotificationCenter.default.post(name: connectionTypeNotification, object: nil)
            
            scan()
        }
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
            dataCharacteristic = service.characteristics![0]
            
            obd2?.setNotifyValue(true, for: dataCharacteristic!)
            configureOBD()
            
            // Get VIN Number
            obd2?.writeValue(Data(bytes: Array("0902\r".utf8)), for: dataCharacteristic!, type: .withResponse)
            
            // Monitor speed
            monitorMetric(metricCmd: "010D\r", bleServiceCharacteristic: dataCharacteristic!)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print("ERROR ON UPDATING VALUE FOR CHARACTERISTIC: \(characteristic) - \(String(describing: error?.localizedDescription))")
            return
        }
        
        var returnedBytes = [UInt8](characteristic.value!)
        
        res += returnedBytes
        if (res.map { String(UnicodeScalar($0)) }).joined() == setupOutput || (res.map { String(UnicodeScalar($0)) }).joined() == partialsetupOutput {
            print("\nOBD-II Setup is complete")
            setupComplete = true
            res = []
        }
        
        if setupComplete {
            if vinNumber == nil {
                // Parse VIN Number response
                if (Array(res.suffix(3)).map { String(UnicodeScalar($0)) }.joined()) == "\r\r>" {
                    var vinString = ""
                    
                    var resultStrings = res.map { String(UnicodeScalar($0)) }.joined().components(separatedBy: "\r")
                    
                    // Ref: Pg 42 - https://www.elmelectronics.com/wp-content/uploads/2016/07/ELM327DS.pdf
                    let
                    line1 = resultStrings[1]
                    let index1 = line1.index(line1.startIndex, offsetBy: 8)
                    vinString += line1.substring(from: index1)
                    
                    let line2 = resultStrings[2]
                    let index2 = line2.index(line2.startIndex, offsetBy: 2)
                    vinString += line2.substring(from: index2)
                    
                    let line3 = resultStrings[3]
                    let index3 = line3.index(line3.startIndex, offsetBy: 2)
                    vinString += line3.substring(from: index3)
                    
                    let vinHexArray = Array(vinString.characters).splitBy(subSize: 2).map { String($0) }
                    let vinCharArray = vinHexArray.map { char -> Character in
                        let code = Int(strtoul(char, nil, 16))
                        return Character(UnicodeScalar(code)!)
                    }
                    
                    vinNumber = String(vinCharArray)
                    print("\nVIN Number: \(vinNumber!)")
                    
                    res = []
                    
                    DB.sharedInstance.createOrReturnVehicle(vin: vinNumber!)
                }
            } else {
                // Setup complete and VIN Number is set.. Proceed with normal data collection
                var kph:Int?
                var mph:Double = 0.0
                
                // 20 byte arrays are ones containing usable data
                if (returnedBytes.count == 20) {
                    kph = Int("\(String(UnicodeScalar(returnedBytes[returnedBytes.count - 2])))\(String(UnicodeScalar(returnedBytes[returnedBytes.count - 1])))", radix:16)
                }
                
                if (kph != nil) {
                    mph = Double(kph!) / 1.609344
                    print("\nCurrent speed: \(mph) mph")
                    if (!tracking && mph > 0) {
                        tracking = true
                        NotificationCenter.default.post(name: colorUpdateNotification, object: nil)
                        
                        totalDist = 0
                        tripSeconds = 0.0
                        recordSpeedUpdate(spd: mph)
                    } else if (tracking) {
                        recordSpeedUpdate(spd: mph)
                    }
                }
            }
        }
    }
    
    func configureOBD() {
        obd2?.writeValue(Data(bytes: Array("ATE0\r".utf8)), for: dataCharacteristic!, type: .withResponse)
        obd2?.writeValue(Data(bytes: Array("ATH0\r".utf8)), for: dataCharacteristic!, type: .withResponse)
        obd2?.writeValue(Data(bytes: Array("ATS0\r".utf8)), for: dataCharacteristic!, type: .withResponse)
        obd2?.writeValue(Data(bytes: Array("ATL0\r".utf8)), for: dataCharacteristic!, type: .withResponse)
        obd2?.writeValue(Data(bytes: Array("ATSP0\r".utf8)), for: dataCharacteristic!, type: .withResponse)
        obd2?.writeValue(Data(bytes: Array("ATSP7\r".utf8)), for: dataCharacteristic!, type: .withResponse)
    }
    
    func monitorMetric(metricCmd: String, bleServiceCharacteristic: CBCharacteristic) {
        speedUpdateTimer = Timer.scheduledTimer(timeInterval: speedUpdateInterval,
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
        obd2?.writeValue(Data(bytes: Array(cmd.utf8)), for: bleServiceCharacteristic, type: .withResponse)
    }
    
    func recordSpeedUpdate(spd: Double) {
        totalDist += spd * (Double(speedUpdateInterval)/3600.0)
        tripSeconds += Double(speedUpdateInterval)
    }
    
    func stopTrip() {
        aggDist += totalDist
        
        let date = Date()
        let ts = Int(date.timeIntervalSince1970.rounded())
        
        writeTrip(ts: ts, distance: totalDist, duration: tripSeconds, vehicleVIN: vinNumber!)
    }
    
}

extension Array {
    func splitBy(subSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: subSize).map { startIndex in
            if let endIndex = self.index(startIndex, offsetBy: subSize, limitedBy: self.count) {
                return Array(self[startIndex ..< endIndex])
            }
            return Array()
        }
    }
}
