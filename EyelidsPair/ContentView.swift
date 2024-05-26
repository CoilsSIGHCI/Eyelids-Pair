//
//  ContentView.swift
//  EyelidsPair
//
//  Created by 砚渤 on 2024/3/25.
//

import SwiftUI
import SwiftData
import CoreBluetooth

var underlyingController: BluetoothViewController?

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    @StateObject private var bluetoothViewModel = BluetoothViewModel()
    
    @State var bluetoothController: BluetoothViewController?
    
    
    var navigationTitle: String {
        switch bluetoothViewModel.bluetoothState {
        case .poweredOn:
            return "Bluetooth is powered on"
        case .poweredOff:
            return "Bluetooth is powered off"
        case .unauthorized:
            return "Bluetooth is unauthorized"
        default:
            return "Bluetooth state is unknown"
        }
    }
    
    var body: some View {
        ZStack {
            BluetoothManagerView(viewModel: bluetoothViewModel, setController: { controller in underlyingController = controller }).frame(height: 0).onAppear {
                bluetoothController = underlyingController
            }
            if let bluetoothController = bluetoothController {
                NavigationStack {
                    
                    List {
                        ForEach(bluetoothViewModel.discoveredPeripherals, id: \.identifier) { peripheral in
                            NavigationLink(value: peripheral) {
                                Text(peripheral.name ?? "Unknown")
                            }
                        }
                        if bluetoothViewModel.discoveredPeripherals.isEmpty {
                            Text("No peripherals found, pull to refresh")
                        }
                    }
                    .refreshable {
                        print("Scanning for peripherals")
                        bluetoothViewModel.startScanning(viewController: bluetoothController)
                        //                        wait till discovered
//                        var retries = 5
//                        while bluetoothViewModel.discoveredPeripherals.isEmpty && retries > 0 {
//                            sleep(1)
//                            retries -= 1
//                        }
//                        bluetoothViewModel.stopScanning(viewController: bluetoothController)
                    }
                    .navigationTitle(navigationTitle)
                    .navigationBarTitleDisplayMode(.inline)
                    
                    .navigationDestination(for: CBPeripheral.self) { peripheral in
                        PeripheralView(peripheral: peripheral, viewController: bluetoothController, viewModel: bluetoothViewModel)
                    }
                }
            } else {
                Text("Bluetooth controller not found")
            }
        }
    }
    
    
    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
