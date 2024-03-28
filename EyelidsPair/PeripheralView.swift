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
    
    var body: some View {
        VStack {
            Text(peripheral.name ?? "Unknown peripheral")
                .onAppear {
                    viewController.centralManager.connect(peripheral)
                }
            if viewModel.connectedPeripheral != nil {
                Text("Connected")
                    .onAppear {
                        fetchAnimationControlValue()
                    }
            } else {
                Text("Not connected")
            }
            Text(animationControlValue ?? "No animation state")
            Button("Fetch animation control value") {
                fetchAnimationControlValue()
            }
            if let characteristic = viewModel.animationControlcharacteristic {
                Button("Send Strobe") {
                    viewModel.connectedPeripheral?.writeValue(Data("STROBE".utf8), for: characteristic, type: .withResponse)
                }
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
}
