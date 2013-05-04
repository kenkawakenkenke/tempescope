package arduino.common;
import gnu.io.CommPortIdentifier;
import gnu.io.SerialPort;

import java.io.InputStream;
import java.io.OutputStream;
import java.util.Enumeration;

/**
 * ArduinoSerial.java
 * Edited from sample code on: http://playground.arduino.cc/Interfacing/Java
 *
 */
public class ArduinoSerial{
	SerialPort serialPort;
	
	private static final String PORT_NAMES[] = { 
			"/dev/tty.usbserial-A9007UX1", // Mac OS X
			"/dev/tty.usbserial",
			"/dev/ttyUSB0", // Linux
			"COM3", // Windows
			"/dev/tty.usbmodem.*"
			};
	
	/** Buffered input stream from the port */
	private InputStream input;
	public InputStream input(){return input;}
	
	/** The output stream to the port */
	private OutputStream output;
	public OutputStream output(){return output;}
	
	/** Milliseconds to block while waiting for port open */
	private static final int TIME_OUT = 2000;
	/** Default bits per second for COM port. */
	private static final int DATA_RATE = 9600;

	public boolean initialize() {
		CommPortIdentifier portId = null;
		
		Enumeration portEnum = CommPortIdentifier.getPortIdentifiers();
		while (portEnum.hasMoreElements()) {
			CommPortIdentifier currPortId = (CommPortIdentifier) portEnum.nextElement();
			for (String portName : PORT_NAMES) {
				if (currPortId.getName().matches(portName)) {
					portId = currPortId;
					break;
				}
			}
		}

		if (portId == null) {
			System.out.println("Could not find COM port.");
			return false;
		}

		try {
			// open serial port, and use class name for the appName.
			serialPort = (SerialPort) portId.open(this.getClass().getName(),TIME_OUT);

			// set port parameters
			serialPort.setSerialPortParams(DATA_RATE,
					SerialPort.DATABITS_8,
					SerialPort.STOPBITS_1,
					SerialPort.PARITY_NONE);

			// open the streams
			input = serialPort.getInputStream();
			output = serialPort.getOutputStream();

			//just in case
			Thread.sleep(1500);

			return true;
			
		} catch (Exception e) {
			e.printStackTrace();
		}
		return false;
	}

	/**
	 * This should be called when you stop using the port.
	 * This will prevent port locking on platforms like Linux.
	 */
	public synchronized void close() {
		if (serialPort != null) {
			serialPort.removeEventListener();
			serialPort.close();
		}
	}

}