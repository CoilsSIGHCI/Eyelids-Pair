import SwiftUI
import CoreBluetooth

struct BluetoothManagerView: UIViewControllerRepresentable {
    @ObservedObject var viewModel: BluetoothViewModel
    
    var setController: (BluetoothViewController) -> Void = { _ in }

    func makeUIViewController(context: Context) -> BluetoothViewController {
        let viewController = BluetoothViewController()
        viewController.viewModel = viewModel
        setController(viewController)
        return viewController
    }

    func updateUIViewController(_ uiViewController: BluetoothViewController, context: Context) {
        // No updates needed
    }
}

class BluetoothViewModel: ObservableObject {
    @Published var bluetoothState: CBManagerState = .unknown
    @Published var discoveredPeripherals: [CBPeripheral] = []
    @Published var connectedPeripheral: CBPeripheral?
    @Published var eyelidsService: CBService?
    @Published var animationControlcharacteristic: CBCharacteristic?
    
    static let serviceUUIDs = [CBUUID(string: "D57D86F6-E6F3-4BE4-A3D1-A71119D27AD3")]
    
    func updateBluetoothState(_ newState: CBManagerState) {
        self.objectWillChange.send()
        self.bluetoothState = newState
    }
    
    func initializeCoreBluetoothManager() {
        // Create an instance of BluetoothViewController
        let viewController = BluetoothViewController()
        viewController.viewModel = self

        // Initialize the CBCentralManager in the BluetoothViewController
        viewController.viewDidLoad()
    }
    
    func startScanning(viewController: BluetoothViewController, serviceUUIDs: [CBUUID]? = BluetoothViewModel.serviceUUIDs) {
        viewController.centralManager.scanForPeripherals(withServices: serviceUUIDs)
    }
    
    func stopScanning(viewController: BluetoothViewController) {
        viewController.centralManager.stopScan()
    }
}
