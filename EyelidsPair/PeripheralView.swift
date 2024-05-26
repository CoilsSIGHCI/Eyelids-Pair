//
//  PeripheralView.swift
//  EyelidsPair
//
//  Created by 砚渤 on 2024/3/28.
//

import SwiftUI
import CoreBluetooth

struct PeripheralView: View {
    var peripheral: CBPeripheral
    var viewController: BluetoothViewController
    
    @ObservedObject var viewModel: BluetoothViewModel
    
    @State var animationControlValue: String?
    @State var gesture: GestureEvent?
    
    var body: some View {
        VStack {
            Text("Current animation: " + (animationControlValue ?? "No animation state"))
                .onAppear {
                    viewController.centralManager.connect(peripheral)
                    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                        fetchValues()
                    }
                }
            Spacer()
            RealtimeGestureView(gesture: $gesture)
            Spacer()
            HStack {
                if let characteristic = viewModel.animationControlcharacteristic {
                    Button("Send Strobe") {
                        viewModel.connectedPeripheral?.writeValue(Data("STROBE".utf8), for: characteristic, type: .withResponse)
                    }
                    .buttonStyle(BorderedButtonStyle())
                    Button("Send HMove Right") {
                        viewModel.connectedPeripheral?.writeValue(Data("SLIDE_RIGHT".utf8), for: characteristic, type: .withResponse)
                    }
                    Button("Send HMove Left") {
                        viewModel.connectedPeripheral?.writeValue(Data("SLIDE_LEFT".utf8), for: characteristic, type: .withResponse)
                    }
                    .buttonStyle(BorderedButtonStyle())
                }
            }
            Spacer()
        }
        .navigationTitle((peripheral.name ?? "Unknown peripheral") + (viewModel.connectedPeripheral != nil ? " 🟢" : " 🔴"))
    }
    
    private func fetchValues() {
        // Fetch gesture from peripheral
        viewModel.connectedPeripheral!.discoverServices(BluetoothViewModel.serviceUUIDs)
        if let service = viewModel.connectedPeripheral!.services?.first {
            viewModel.eyelidsService = service
            viewModel.connectedPeripheral!.discoverCharacteristics([BluetoothViewModel.gestureUUID, BluetoothViewModel.animationControlUUID], for: service)
            if let validCharacteristic = viewModel.eyelidsService?.characteristics?.first(where: { $0.uuid == BluetoothViewModel.gestureUUID}) {
                viewModel.gestureCharacteristic = validCharacteristic
                viewModel.connectedPeripheral?.readValue(for: validCharacteristic)
                if let value = validCharacteristic.value {
                    if let jsonString = try? JSONSerialization.jsonObject(with: value, options: []) as? [String: Any] {
                        gesture = .init(json: jsonString)
                    } else {
                        print("Gesture cancelled")
                        gesture = nil
                    }
                }
            }
            if let validCharacteristic = viewModel.eyelidsService?.characteristics?.first(where: { $0.uuid == BluetoothViewModel.animationControlUUID}) {
                viewModel.animationControlcharacteristic = validCharacteristic
                viewModel.connectedPeripheral?.readValue(for: validCharacteristic)
                if let value = validCharacteristic.value {
                    animationControlValue = String(data: value, encoding: .utf8)
                }
            }
        }
    }
}
