//
//  GATT.swift
//  EyelidsPair
//
//  Created by 砚渤 on 2024/3/26.
//

import Foundation
import CoreBluetooth
import UIKit

struct GestureEvent: Equatable {
    var x: Float
    var y: Float
    var gesture: Int
    var confidency: Float
    
    // optional initializer for RAW JSON data
    init?(json: [String: Any]) {
        guard let x = json["x"] as? Float,
              let y = json["y"] as? Float,
              let gesture = json["gesture"] as? Int,
              let confidency = json["confidency"] as? Float else {
            return nil
        }
        
        self.x = x
        self.y = y
        self.gesture = gesture
        self.confidency = confidency
    }
    
    // provide a default initializer
    init(x: Float, y: Float, gesture: Int, confidency: Float) {
        self.x = x
        self.y = y
        self.gesture = gesture
        self.confidency = confidency
    }
    
    // override the Equatable protocol to leave out the confidency
    static func == (lhs: GestureEvent, rhs: GestureEvent) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.gesture == rhs.gesture
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
    // Add other CBCentralManagerDelegate methods as needed
}
