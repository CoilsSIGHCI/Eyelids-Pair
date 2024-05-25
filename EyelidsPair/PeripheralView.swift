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
            Text(peripheral.name ?? "Unknown peripheral")
                .onAppear {
                    viewController.centralManager.connect(peripheral)
                }
            if viewModel.connectedPeripheral != nil {
                Text("Connected")
                    .onAppear {
                        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                            fetchAnimationControlValue()
                            fetchGesture()
                        }
                    }
            } else {
                Text("Not connected")
            }
            Text(animationControlValue ?? "No animation state")
            Button("Fetch animation control value") {
                fetchAnimationControlValue()
            }
            RealtimeGestureView(gesture: $gesture)
            if let characteristic = viewModel.animationControlcharacteristic {
                Button("Send Strobe") {
                    viewModel.connectedPeripheral?.writeValue(Data("STROBE".utf8), for: characteristic, type: .withResponse)
                }
                .buttonStyle(BorderedButtonStyle())
                Button("Send HMove") {
                    viewModel.connectedPeripheral?.writeValue(Data("SLIDE_RIGHT".utf8), for: characteristic, type: .withResponse)
                }
                .buttonStyle(BorderedButtonStyle())
            }
        }
        .navigationTitle(peripheral.name ?? "Unknown peripheral")
    }
    
    private func fetchAnimationControlValue() {
        // Fetch animation control value from peripheral
        viewModel.connectedPeripheral!.discoverServices(BluetoothViewModel.serviceUUIDs)
        if let service = viewModel.connectedPeripheral!.services?.first {
            viewModel.eyelidsService = service
            viewModel.connectedPeripheral!.discoverCharacteristics([.init(string: "4116f8d2-9f66-4f58-a53d-fc7440e7c14e")], for: service)
            if let validCharacteristic = viewModel.eyelidsService?.characteristics?.first {
                viewModel.animationControlcharacteristic = validCharacteristic
                viewModel.connectedPeripheral?.readValue(for: validCharacteristic)
                if validCharacteristic.value != nil {
                    animationControlValue = String(data: validCharacteristic.value!, encoding: .utf8)
                }
            }
        }
    }
    
    private func fetchGesture() {
        // Fetch gesture from peripheral
        viewModel.connectedPeripheral!.discoverServices(BluetoothViewModel.serviceUUIDs)
        if let service = viewModel.connectedPeripheral!.services?.first {
            viewModel.eyelidsService = service
            viewModel.connectedPeripheral!.discoverCharacteristics([.init(string: "49B0478D-C1B0-4255-BB55-1FD182638BBB")], for: service)
            if let validCharacteristic = viewModel.eyelidsService?.characteristics?.first {
                viewModel.animationControlcharacteristic = validCharacteristic
                viewModel.connectedPeripheral?.readValue(for: validCharacteristic)
                if validCharacteristic.value != nil {
                    if let jsonString = try? JSONSerialization.jsonObject(with: validCharacteristic.value!, options: []) as? [String: Any] {
                        gesture = .init(json: jsonString)
                    } else {
                        gesture = nil
                    }
                }
            }
        }
    }
}
