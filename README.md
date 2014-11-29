The tempescope is a physical display that can recreate various weather conditions (eg: rain, clouds, lightning) inside a box.
OpenTempescope is the open source version of tempescope.

The system is composed of three parts:
OpenTempescope- the box itself
Tempescope Demo App- an app that runs on your iOS device, and connects to OpenTempescope by BLE

For more information, see our website at: http://tempescope.com

CONTENTS OF DISTRIBUTION:
tempescope:  contains source code for the OpenTempescope and Tempescope Demo App
hardware: contains the schematics, CAD data etc for the hardware

INSTALLATION:
- OpenTempescope/OpenTempescope
  load this sketch onto an ATMega328p and insert into your OpenTempescope.

- OpenTempescope/TempescopeController/TempescopeDemo
  runs on an iOS device to control your OpenTempescope. The distributed version does not connect to a weather forecast service of any sort- this is left as an exercise for the reader.

Ken Kawamoto (ken@kawamoto.co.uk)
