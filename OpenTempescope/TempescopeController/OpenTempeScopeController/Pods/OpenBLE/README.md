### OpenBLE ###
 
===========================================================================
DESCRIPTION:
 
A simple iOS iPhone application that demonstrates how to use the CoreBluetooth Framework to connect to a Bluetooth LE 'spp' peripheral to read, write. Based on the Apple 1.0 Temperature Sensor example code https://developer.apple.com/library/IOS/samplecode/TemperatureSensor/Introduction/Intro.html 

Currently supports the Seeed Studio Xadow BLE device http://www.seeedstudio.com/depot/xadow-ble-slave-p-1546.html and whoever else uses that part. Should support many other devices with few changes. You can edit the LeDataService files to work for your device, particularly the characteristic UUIDs . I accept pull requests of new LeDataService classes for other devices, or if you want to ship my your device I might be able to get to it.

Important:
This project requires a Bluetooth LE Capable Device (iPhone 4s and later; iPad 3 and later; iPod Touch 5; iPad mini) and will not work on the simulator.
 
===========================================================================
BUILD REQUIREMENTS:
 
- Xcode 5 or greater
- iOS 7 SDK or greater
 
===========================================================================
RUNTIME REQUIREMENTS:
 
iOS 6 or later
Bluetooth LE Capable Device
Bluetooth LE Sensor/s
