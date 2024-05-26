//
//  GATT.swift
//  EyelidsPair
//
//  Created by 砚渤 on 2024/3/26.
//

import Foundation
import CoreBluetooth
import UIKit

enum GestureDirectionType: String {
    case upward = "upward"
    case downward = "downward"
    case leftward = "leftward"
    case rightward = "rightward"
    case forward = "forward"
    case backward = "backward"
    case rotationalClockwise = "rotation_clockwise"
    case rotationalCounterclockwise = "rotation_counterclockwise"
    case zoomIn = "zoom_in"
    case zoomOut = "zoom_out"
    case nonDirectional = "non_directional"
}

struct GestureEvent: Equatable {
    var gesture: Int
    var direction: GestureDirectionType
    var confidence: Float
    
    // optional initializer for RAW JSON data
    init?(json: [String: Any]) {
        guard let gesture = json["gesture"] as? Int,
              let directionValue = json["direction"] as? String,
              let direction = GestureDirectionType(rawValue: directionValue),
              let confidence = json["confidence"] as? Float else {
            print("Failed to parse JSON into GestureEvent")
            return nil
        }
        
        self.gesture = gesture
        self.confidence = confidence
        self.direction = direction
    }
    
    // provide a default initializer
    init(gesture: Int, direction: GestureDirectionType, confidence: Float) {
        self.gesture = gesture
        self.direction = direction
        self.confidence = confidence
    }
    
    // override the Equatable protocol to leave out the confidence
    static func == (lhs: GestureEvent, rhs: GestureEvent) -> Bool {
        return lhs.gesture == rhs.gesture
    }
}


class BluetoothViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    var viewModel: BluetoothViewModel!
    var centralManager: CBCentralManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Bluetooth state updated to: \(central.state == .poweredOn ? "powered on" : "powered off")")
        DispatchQueue.main.async {
            self.viewModel.updateBluetoothState(central.state)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Discovered peripheral: \(peripheral)")
        print("Advertisement data: \(advertisementData)")
        
        if !self.viewModel.discoveredPeripherals.compactMap({ $0.identifier }).contains(peripheral.identifier) {
            let delegatedPerpheral = peripheral
            delegatedPerpheral.delegate = self
            self.viewModel.discoveredPeripherals.append(delegatedPerpheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to peripheral: \(peripheral)")
        self.viewModel.connectedPeripheral = peripheral
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        self.viewModel.connectedPeripheral = peripheral
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        self.viewModel.eyelidsService = service
    }
    
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        self.viewModel.connectedPeripheral = peripheral
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        if characteristic.uuid == BluetoothViewModel.animationControlUUID {
            self.viewModel.animationControlcharacteristic = characteristic
        }
        if characteristic.uuid == BluetoothViewModel.gestureUUID {
            self.viewModel.gestureCharacteristic = characteristic
        }
    }
}
