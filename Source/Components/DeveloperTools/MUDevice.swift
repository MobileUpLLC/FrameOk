//
//  MUDevice.swift
//  FrameOk
//
//  Created by Denis Sushkov on 23.12.2020.
//

import Foundation
import DeviceKit

// MARK: - MUDevice

public enum MUDevice {
    
    case iPodTouch5
    case iPodTouch6
    case iPodTouch7
    case iPhone4
    case iPhone4s
    case iPhone5
    case iPhone5c
    case iPhone5s
    case iPhone6
    case iPhone6Plus
    case iPhone6s
    case iPhone6sPlus
    case iPhone7
    case iPhone7Plus
    case iPhoneSE
    case iPhone8
    case iPhone8Plus
    case iPhoneX
    case iPhoneXS
    case iPhoneXSMax
    case iPhoneXR
    case iPhone11
    case iPhone11Pro
    case iPhone11ProMax
    case iPhoneSE2
    case iPhone12
    case iPhone12Mini
    case iPhone12Pro
    case iPhone12ProMax
    case iPad2
    case iPad3
    case iPad4
    case iPadAir
    case iPadAir2
    case iPad5
    case iPad6
    case iPadAir3
    case iPad7
    case iPad8
    case iPadAir4
    case iPadMini
    case iPadMini2
    case iPadMini3
    case iPadMini4
    case iPadMini5
    case iPadPro9Inch
    case iPadPro12Inch
    case iPadPro12Inch2
    case iPadPro10Inch
    case iPadPro11Inch
    case iPadPro12Inch3
    case iPadPro11Inch2
    case iPadPro12Inch4
    
    indirect case simulator(Device)
    
    case unknown(String)
    
    // MARK: - Public Properties
    
    static var currentDevice: MUDevice { getCurrentDevice() }
    
    var realDevice: MUDevice { getRealDevice(self) }
    
    var isSimulator: Bool { checkIfSimulator(self) }
    
    var modelName: String { getModelName(self) }
    
    var fullName: String { getFullName(self) }
    
    var isIphone: Bool { checkIfIphone(self) }
    
    var isIpad: Bool { checkIfIpad(self) }
    
    var osVersion: String { getOsVersion(self) }
    
    var osName: String { getOsName(self) }
    
    var screenDiagonalInInches: Double { getScreenDiagonal(self) }
    
    var screenOrientation: MUDeviceOrientation { getScreenOrientation(self) }
    
    var screenRatio: (Double, Double) { getScreenRatio(self) }
    
    var screenBrightness: Int { getScreenBrightness(self) }
    
    var batteryLevel: Int { getBatteryLevel(self) }
    
    var hasBiometry: Bool { checkBiometry(self) }
    
    var hasTouchId: Bool { checkTouchId(self) }
    
    var hasFaceId: Bool { checkFaceId(self) }
    
    var hasCamera: Bool { checkCamera(self) }
    
    var hasLidar: Bool { checkLidar(self) }
    
    var hasWirelessCharging: Bool { checkWirelessCharging(self) }
    
    var hasPencilSupport: Bool { checkPencilSupport(self) }
    
    // MARK: - Private Methods
    
    private static func getCurrentDevice() -> MUDevice {
        
        return Device.convertToMUDevice(Device.current)
    }
    
    private func getRealDevice(_ device: MUDevice) -> MUDevice {
        
        let realDevice = MUDevice.convertToDevice(device)
        
        let resultDevice = Device.realDevice(from: realDevice)
        
        return Device.convertToMUDevice(resultDevice)
    }
    
    private func checkIfSimulator(_ device: MUDevice) -> Bool {

        return MUDevice.convertToDevice(device).isSimulator
    }
    
    private func getModelName(_ device: MUDevice) -> String {
        
        return MUDevice.convertToDevice(device).model ?? "Not Found"
    }
    
    private func getFullName(_ device: MUDevice) -> String {
        
        return MUDevice.convertToDevice(device).name ?? "Not Found"
    }
    
    private func checkIfIphone(_ device: MUDevice) -> Bool {
        
        return MUDevice.convertToDevice(device).isPhone
    }
    
    private func checkIfIpad(_ device: MUDevice) -> Bool {
        
        return MUDevice.convertToDevice(device).isPad
    }
    
    private func getOsVersion(_ device: MUDevice) -> String {
        
        return MUDevice.convertToDevice(device).systemVersion ?? "Not Found"
    }
    
    private func getOsName(_ device: MUDevice) -> String {
        
        return MUDevice.convertToDevice(device).systemName ?? "Not Found"
    }
    
    private func getScreenDiagonal(_ device: MUDevice) -> Double {
        
        return MUDevice.convertToDevice(device).diagonal
    }
    
    private func getScreenOrientation(_ device: MUDevice) -> MUDeviceOrientation {
        
        if MUDevice.convertToDevice(device).orientation == .landscape {
            
            return .landscape
            
        } else {
            
            return .portrait
        }
    }
    
    private func getScreenRatio(_ device: MUDevice) -> (Double, Double) {
        
        return MUDevice.convertToDevice(device).screenRatio
    }
    
    private func getScreenBrightness(_ device: MUDevice) -> Int {
        
        return MUDevice.convertToDevice(device).screenBrightness
    }
    
    private func getBatteryLevel(_ device: MUDevice) -> Int {
        
        return MUDevice.convertToDevice(device).batteryLevel ?? 0
    }
    
    private func checkBiometry(_ device: MUDevice) -> Bool {
        
        return MUDevice.convertToDevice(device).hasBiometricSensor
    }
    
    private func checkTouchId(_ device: MUDevice) -> Bool {
        
        return MUDevice.convertToDevice(device).isTouchIDCapable
    }
    
    private func checkFaceId(_ device: MUDevice) -> Bool {
        
        return MUDevice.convertToDevice(device).isFaceIDCapable
    }
    
    private func checkCamera(_ device: MUDevice) -> Bool {
        
        return MUDevice.convertToDevice(device).hasCamera
    }
    
    private func checkLidar(_ device: MUDevice) -> Bool {
        
        return MUDevice.convertToDevice(device).hasLidarSensor
    }
    
    private func checkWirelessCharging(_ device: MUDevice) -> Bool {
        
        return MUDevice.convertToDevice(device).supportsWirelessCharging
    }
    
    private func checkPencilSupport(_ device: MUDevice) -> Bool {
        
        let convertedDevice = MUDevice.convertToDevice(device)
        
        return Device.allApplePencilCapableDevices.contains(convertedDevice)
    }
    
    private static func convertToDevice(_ device: MUDevice) -> Device {
        
        switch device {
        
        case iPodTouch5            : return Device.iPodTouch5;
        case iPodTouch6            : return Device.iPodTouch6;
        case iPodTouch7            : return Device.iPodTouch7;
        case iPhone4               : return Device.iPhone4;
        case iPhone4s              : return Device.iPhone4s;
        case iPhone5               : return Device.iPhone5;
        case iPhone5c              : return Device.iPhone5c;
        case iPhone5s              : return Device.iPhone5s;
        case iPhone6               : return Device.iPhone6;
        case iPhone6Plus           : return Device.iPhone6Plus;
        case iPhone6s              : return Device.iPhone6s;
        case iPhone6sPlus          : return Device.iPhone6sPlus;
        case iPhone7               : return Device.iPhone7;
        case iPhone7Plus           : return Device.iPhone7Plus;
        case iPhoneSE              : return Device.iPhoneSE;
        case iPhone8               : return Device.iPhone8;
        case iPhone8Plus           : return Device.iPhone8Plus;
        case iPhoneX               : return Device.iPhoneX;
        case iPhoneXS              : return Device.iPhoneXS;
        case iPhoneXSMax           : return Device.iPhoneXSMax;
        case iPhoneXR              : return Device.iPhoneXR;
        case iPhone11              : return Device.iPhone11;
        case iPhone11Pro           : return Device.iPhone11Pro;
        case iPhone11ProMax        : return Device.iPhone11ProMax;
        case iPhoneSE2             : return Device.iPhoneSE2;
        case iPhone12              : return Device.iPhone12;
        case iPhone12Mini          : return Device.iPhone12Mini;
        case iPhone12Pro           : return Device.iPhone12Pro;
        case iPhone12ProMax        : return Device.iPhone12ProMax;
            
        case iPad2                 : return Device.iPad2;
        case iPad3                 : return Device.iPad3;
        case iPad4                 : return Device.iPad4;
        case iPadAir               : return Device.iPadAir;
        case iPadAir2              : return Device.iPadAir2;
        case iPad5                 : return Device.iPad5;
        case iPad6                 : return Device.iPad6;
        case iPadAir3              : return Device.iPadAir3;
        case iPad7                 : return Device.iPad7;
        case iPad8                 : return Device.iPad8;
        case iPadAir4              : return Device.iPadAir4;
        case iPadMini              : return Device.iPadMini;
        case iPadMini2             : return Device.iPadMini2;
        case iPadMini3             : return Device.iPadMini3;
        case iPadMini4             : return Device.iPadMini4;
        case iPadMini5             : return Device.iPadMini5;
        case iPadPro9Inch          : return Device.iPadPro9Inch;
        case iPadPro12Inch         : return Device.iPadPro12Inch;
        case iPadPro12Inch2        : return Device.iPadPro12Inch2;
        case iPadPro10Inch         : return Device.iPadPro10Inch;
        case iPadPro11Inch         : return Device.iPadPro11Inch;
        case iPadPro12Inch3        : return Device.iPadPro12Inch3;
        case iPadPro11Inch2        : return Device.iPadPro11Inch2;
        case iPadPro12Inch4        : return Device.iPadPro12Inch4;
            
        case .simulator(let model) : return Device.simulator(model)
            
        default                    : return Device.unknown("Unknown device")
        }
    }
}

// MARK: - Device Orientation

public enum MUDeviceOrientation {
    
    case portrait
    case landscape
}

// MARK: - Device

extension Device {
    
    // MARK: - Public Methods
    
    static func convertToMUDevice(_ device: Device) -> MUDevice {
        
        switch device {
        
        case iPodTouch5            : return MUDevice.iPodTouch5;
        case iPodTouch6            : return MUDevice.iPodTouch6;
        case iPodTouch7            : return MUDevice.iPodTouch7;
        case iPhone4               : return MUDevice.iPhone4;
        case iPhone4s              : return MUDevice.iPhone4s;
        case iPhone5               : return MUDevice.iPhone5;
        case iPhone5c              : return MUDevice.iPhone5c;
        case iPhone5s              : return MUDevice.iPhone5s;
        case iPhone6               : return MUDevice.iPhone6;
        case iPhone6Plus           : return MUDevice.iPhone6Plus;
        case iPhone6s              : return MUDevice.iPhone6s;
        case iPhone6sPlus          : return MUDevice.iPhone6sPlus;
        case iPhone7               : return MUDevice.iPhone7;
        case iPhone7Plus           : return MUDevice.iPhone7Plus;
        case iPhoneSE              : return MUDevice.iPhoneSE;
        case iPhone8               : return MUDevice.iPhone8;
        case iPhone8Plus           : return MUDevice.iPhone8Plus;
        case iPhoneX               : return MUDevice.iPhoneX;
        case iPhoneXS              : return MUDevice.iPhoneXS;
        case iPhoneXSMax           : return MUDevice.iPhoneXSMax;
        case iPhoneXR              : return MUDevice.iPhoneXR;
        case iPhone11              : return MUDevice.iPhone11;
        case iPhone11Pro           : return MUDevice.iPhone11Pro;
        case iPhone11ProMax        : return MUDevice.iPhone11ProMax;
        case iPhoneSE2             : return MUDevice.iPhoneSE2;
        case iPhone12              : return MUDevice.iPhone12;
        case iPhone12Mini          : return MUDevice.iPhone12Mini;
        case iPhone12Pro           : return MUDevice.iPhone12Pro;
        case iPhone12ProMax        : return MUDevice.iPhone12ProMax;
            
        case iPad2                 : return MUDevice.iPad2;
        case iPad3                 : return MUDevice.iPad3;
        case iPad4                 : return MUDevice.iPad4;
        case iPadAir               : return MUDevice.iPadAir;
        case iPadAir2              : return MUDevice.iPadAir2;
        case iPad5                 : return MUDevice.iPad5;
        case iPad6                 : return MUDevice.iPad6;
        case iPadAir3              : return MUDevice.iPadAir3;
        case iPad7                 : return MUDevice.iPad7;
        case iPad8                 : return MUDevice.iPad8;
        case iPadAir4              : return MUDevice.iPadAir4;
        case iPadMini              : return MUDevice.iPadMini;
        case iPadMini2             : return MUDevice.iPadMini2;
        case iPadMini3             : return MUDevice.iPadMini3;
        case iPadMini4             : return MUDevice.iPadMini4;
        case iPadMini5             : return MUDevice.iPadMini5;
        case iPadPro9Inch          : return MUDevice.iPadPro9Inch;
        case iPadPro12Inch         : return MUDevice.iPadPro12Inch;
        case iPadPro12Inch2        : return MUDevice.iPadPro12Inch2;
        case iPadPro10Inch         : return MUDevice.iPadPro10Inch;
        case iPadPro11Inch         : return MUDevice.iPadPro11Inch;
        case iPadPro12Inch3        : return MUDevice.iPadPro12Inch3;
        case iPadPro11Inch2        : return MUDevice.iPadPro11Inch2;
        case iPadPro12Inch4        : return MUDevice.iPadPro12Inch4;
            
        case .simulator(let model) : return MUDevice.simulator(model)
            
        default                    : return MUDevice.unknown("Unknown device")
        }
    }
}

