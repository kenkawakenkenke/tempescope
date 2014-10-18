Tempescope is an open-source physical display that visualizes the weather inside your room.

The system is composed of three parts:
Tempescope- the box itself
Tempescope Remote- a wireless controller for your tempescope
(optionally) your pc- to control your tempescope through the tempscope remote, and send updates of the current weather forecast etc.

For more information, see the website at: http://tempescope.com for details.

CONTENTS OF DISTRIBUTION:
tempescope:  contains source code for the tempescope and the tempescope remote
pc: contains the java source that runs on your PC for controlling your Tempescope
hardware: contains the schematics, CAD data etc for the hardware

INSTALLATION:
- tempescope/Tempescope
  runs inside your Arduino in your tempescope

- tempescope/Tempescope/TempescopeRemote
  runs inside your Arduino in your tempescope remote controller

- pc/TempescopeController
  runs on your PC to control your tempescope through the remote
  (1) import the project into your favorite IDE (eclipse, etc)
  (2) download the required libraries (json-simple, RXTXcomm) and put on your class path
  (3) run com.tempescope.app.SimpleTest

Detailed instructions will follow…

LIBRARIES
Tempescope uses the following libraries:
VirtualWire.h
json-simple
RXTXcomm

Ken Kawamoto
ken@kawamoto.co.uk
