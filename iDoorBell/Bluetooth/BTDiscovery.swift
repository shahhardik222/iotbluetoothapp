import Foundation
import CoreBluetooth

let btDiscoverySharedInstance = BTDiscovery();

class BTDiscovery: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
  
  fileprivate var centralManager: CBCentralManager?
  fileprivate var peripheralBLE: CBPeripheral?
  var positionCharacteristic: CBCharacteristic?
    
  override init() {
    super.init()
    
    centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
  }
  
  func startScanning() {
    if let central = centralManager {
        
        let options = [
            CBCentralManagerScanOptionAllowDuplicatesKey : Int(false)
        ]
      central.scanForPeripherals(withServices: nil, options: nil)
    }
  }
  
  var bleService: BTService? {
    didSet {
      if let service = self.bleService {
        service.startDiscoveringServices()
      }
    }
  }
  
  // MARK: - CBCentralManagerDelegate
  
  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    // Be sure to retain the peripheral or it will fail during connection.
    
    
    print(peripheral)
    print(advertisementData)
    print(RSSI)
    // Validate peripheral information
    if ((peripheral.name == nil) || (peripheral.name == "")) {
      return
    }
    
    // If not already connected to a peripheral, then connect to this one
    if ((self.peripheralBLE == nil) || (self.peripheralBLE?.state == CBPeripheralState.disconnected)) {
      // Retain the peripheral before trying to connect
      self.peripheralBLE = peripheral
      self.peripheralBLE?.delegate = self
      // Reset service
      self.bleService = nil
      
      // Connect to peripheral
      central.connect(peripheral, options: nil)
    }
  }
  
  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    
    // Create new service class
    if (peripheral == self.peripheralBLE) {
      self.bleService = BTService(initWithPeripheral: peripheral)
    }
    
    // Stop scanning for new devices
    central.stopScan()
  }
  
  func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
    
    // See if it was our peripheral that disconnected
    if (peripheral == self.peripheralBLE) {
      self.bleService = nil;
      self.peripheralBLE = nil;
    }
    
    // Start scanning for new devices
    self.startScanning()
  }
  
  // MARK: - Private
  
  func clearDevices() {
    self.bleService = nil
    self.peripheralBLE = nil
  }
    
    func openTheDoor() {
        self.bleService?.openTheDoor()
//        let bytes : [UInt8] = [ 0x00, 0x33]
//        let data = NSData(bytes: bytes, length: bytes.count)
//        peripheralBLE?.writeValue(data as Data, for: positionCharacteristic!, type: .withResponse)
    }
    
    func closeTheDoor() {
        self.bleService?.closeTheDoor()
////        let textToSend = ""
////        let data : Data = textToSend.dataWithHexString(hex: "0x0044")
//        let bytes : [UInt8] = [ 0x00, 0x44]
//        let data = NSData(bytes: bytes, length: bytes.count)
//        peripheralBLE?.writeValue(data as Data, for: positionCharacteristic!, type: .withResponse)
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
        print("%@",characteristic)
    }
  
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    switch (central.state) {
    case .poweredOff:
      self.clearDevices()
      
    case .unauthorized:
      // Indicate to user that the iOS device does not support BLE.
      break
      
    case .unknown:
      // Wait for another event
      break
      
    case .poweredOn:
      self.startScanning()
      
    case .resetting:
      self.clearDevices()
      
    case .unsupported:
      break
    }
  }

}


extension String {
    
    /// Create `Data` from hexadecimal string representation
    ///
    /// This takes a hexadecimal representation and creates a `Data` object. Note, if the string has any spaces or non-hex characters (e.g. starts with '<' and with a '>'), those are ignored and only hex characters are processed.
    ///
    /// - returns: Data represented by this hexadecimal string.
    
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
    
    
    func dataWithHexString(hex: String) -> Data {
        var hex = hex
        var data = Data()
        while(hex.characters.count > 0) {
            let c: String = hex.substring(to: hex.index(hex.startIndex, offsetBy: 2))
            hex = hex.substring(from: hex.index(hex.startIndex, offsetBy: 2))
            var ch: UInt32 = 0
            Scanner(string: c).scanHexInt32(&ch)
            var char = UInt8(ch)
            data.append(&char, count: 1)
        }
        return data
    }
}
