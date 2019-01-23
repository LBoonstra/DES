package dsl.finalproject.generator

import dsl.finalproject.fp.Task

class FpSlaveGenerator {
	//Central function to generate the file with. Call this in the FpGenerator to generate slave file.
		def static toPy(Task root){
		'''
		«imports()»«"\n"»
		«blueToothCode()»«"\n"»
		«bumperSensorLeft»«"\n"»
		«bumperSensorRight»«"\n"»
		«sonarSensor»«"\n"»
		«mainThread()»
		'''
	}
	//Code that checks if the left bumper on the robot is pressed. If true, the value 1 will be sent to the 
	//master. 
	//If the bumper is not pressed anymore but was pressed previously the slave will sent a 2 over to the 
	//master.
		def static bumperSensorLeft()  '''
			def leftBumperSensor(sock_out):
			«"\t"»#Test if the left bumper was pressed and send info if so. When the bumper stops being pressed, send info of that.
				tsLeft = TouchSensor(INPUT_1)
				pressedIn= False
				while True:
					if tsLeft.is_pressed:
						sendInfo(sock_out,1)
						sleep(1)
						pressedIn=True
					elif pressedIn:
						pressedIn=False
						sendInfo(sock_out,2)
					if ending:
						break
		'''
		//Code that checks if the right bumper on the robot is pressed. If true, the value 3 will be sent to the master. 
	//If the bumper is not pressed anymore but was pressed previously the slave will sent a 4 over to the master.	
		def static bumperSensorRight()  '''
			def rightBumperSensor(sock_out):
			«"\t"»#Test if the right bumper was pressed and send info if so. When the bumper stops being pressed, send info of that.
				tsRight = TouchSensor(INPUT_4)
				pressedIn= False
				while True:
					if tsRight.is_pressed:
						sendInfo(sock_out,3)
						sleep(1)
						pressedIn=True
					elif pressedIn:
						pressedIn=False
						sendInfo(sock_out,4)
					if ending:
						break
		'''
		
		//Code that checks if there is something in front of the robot. If true, the value 5 will be sent to 
		//the master. 
		//If there is no object that is close to the robot at the front end, but there was previously then 
		//the slave will sent a 6 over to the master.
		def static sonarSensor() '''
			def forwSonarSensor(sock_out):
			«"\t"»#Test if the sonar notices an object within 17 centimeters and send info if so. When the sonar stops detecting an object, send info of that.
				us = UltrasonicSensor()
				us.code = 'US-DIST-CM'
				pressedIn= False
				while True:
					if us.value()/10<17:
						sendInfo(sock_out,5)
						sleep(1)
						pressedIn=True
					elif pressedIn:
						pressedIn=False
						sendInfo(sock_out,6)
					if ending:
						break
		'''

		/*
		 * Creates the functions related to the bluetooth connection, such as connect, disconnect, listen
		 * and send info. Listen checks if the other brick is ending and this one should end then.
		 * SendInfo sends information determined by the other threads to the other brick.
		 */
		def static blueToothCode()'''
			def connect(server_mac):«"\n"»
			«"\t"»#Connects this brick with the other brick using the other brick's server_mac.
			«"\t"»port = 3«"\n"»
			«"\t"»sock = bluetooth.BluetoothSocket(bluetooth.RFCOMM)«"\n"»
			«"\t"»print('Connecting...')«"\n"»
			«"\t"»sock.connect((server_mac, port))«"\n"»
			«"\t"»print('Connected to ', server_mac)«"\n"»
			«"\t"»return sock, sock.makefile('r'), sock.makefile('w')«"\n"»
			«"\n"»
			def disconnect(sock):«"\n"»
			«"\t"»#Disconnects from the sock.
			«"\t"»sock.close()«"\n"»
			«"\n"»
			def listen(sock_in):«"\n"»
			«"\t"»#Keep listening to the sock_in for messages from the other brick. Messages come as integers and have to be translated to what they represent.
			«"\t"»global ending«"\n"»
			«"\t"»print('Now listening...')«"\n"»
			«"\t"»while True:«"\n"»
			«"\t"»«"\t"»data = int(sock_in.readline())«"\n"»
			«"\t"»«"\t"»if data==2:«"\n"»
			«"\t"»«"\t"»«"\t"»ending=True«"\n"»
			«"\t"»«"\t"»«"\t"»break«"\n"»
			«"\t"»«"\t"»sleep(1)«"\n"»
			«"\n"»
			def sendInfo(sock_out, sensortype):«"\n"»
			«"\t"»#Send a message (integer as string) to the other brick.
			«"\t"»sock_out.write(str(sensortype)+ '\n')«"\n"»
			«"\t"»sock_out.flush()«"\n"»
		'''
	
		//Inserts all necessary imports for the file to work
		def static imports()'''
		#!/usr/bin/env python3«"\n"»
		«"\n"»
		from ev3dev2.motor import LargeMotor, OUTPUT_A, OUTPUT_D, OUTPUT_B, SpeedPercent, Motor«"\n"»
		from ev3dev2.sound import Sound«"\n"»
		from ev3dev2.display import Display«"\n"»
		from ev3dev2.sensor.lego import ColorSensor«"\n"»
		from ev3dev2.sensor.lego import TouchSensor«"\n"»
		from ev3dev2._platform.ev3 import INPUT_4, INPUT_1, INPUT_2, INPUT_3«"\n"»
		from ev3dev2.led import Leds«"\n"»
		from ev3dev2.sensor.lego import UltrasonicSensor«"\n"»
		import random«"\n"»
		import bluetooth, threading«"\n"»
		from time import sleep«"\n"»
		from time import time«"\n"»
	'''
	
	/*
	 * Starts all other threads, including the bluetooth thread. Adjust server_mac according to the
	 * server_mac of the master (and also adjust this in the PythonGenerator). mainThread waits
	 * until all other threads have ended before ending itself.
	 */
	def static mainThread()'''
		global ending«"\n"»
		ending=False«"\n"»
		server_mac = '00:17:E9:B2:F2:93'«"\n"»
		is_master=False«"\n"»
		sock, sock_in, sock_out = connect(server_mac)«"\n"»
		blueListener = threading.Thread(target=listen, args=(sock_in,))«"\n"»
		blueListener.start()«"\n"»
		leftBListener = threading.Thread(target=leftBumperSensor, args=(sock_out,))«"\n"»
		leftBListener.start()«"\n"»
		rightBListener= threading.Thread(target=rightBumperSensor, args=(sock_out,))«"\n"»
		rightBListener.start()«"\n"»
		sonarListener = threading.Thread(target=forwSonarSensor, args=(sock_out,))«"\n"»
		sonarListener.start()«"\n"»
		blueListener.join()«"\n"»
		sendInfo(sock_out, 7)«"\n"»
		disconnect(sock_in)«"\n"»
		disconnect(sock_out)«"\n"»
		disconnect(sock)«"\n"»
		leftBListener.join()«"\n"»
		rightBListener.join()«"\n"»
		sonarListener.join()«"\n"»
	'''
}