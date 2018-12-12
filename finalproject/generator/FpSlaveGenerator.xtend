package dsl.finalproject.generator

import dsl.finalproject.fp.Task

class FpSlaveGenerator {
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
	
		def static bumperSensorLeft()  '''
			def leftBumperSensor():
				tsLeft = TouchSensor(INPUT_1)
				while True:
					if tsLeft.is_pressed:
						sendInfo(1)
		'''
		
		def static bumperSensorRight()  '''
			def rightBumperSensor():
				tsRight = TouchSensor(INPUT_4)
				while True:
					if tsRight.is_pressed:
						sendInfo(2)
		'''
	
		def static sonarSensor() '''
			us = UltrasonicSensor()
			us.code = 'US-DIST-CM'
			while True:
				if us.value()<28:
					sendInfo(3)
		'''

		def static blueToothCode()'''
			def connect(server_mac):«"\n"»
			«"\t"»port = 3«"\n"»
			«"\t"»sock = bluetooth.BluetoothSocket(bluetooth.RFCOMM)«"\n"»
			«"\t"»print('Connecting...')«"\n"»
			«"\t"»sock.connect((server_mac, port))«"\n"»
			«"\t"»print('Connected to ', server_mac)«"\n"»
			«"\t"»return sock, sock.makefile('r'), sock.makefile('w')«"\n"»
			«"\n"»
			def disconnect(sock):«"\n"»
			«"\t"»sock.close()«"\n"»
			«"\n"»
			def listen(sock_in, sock_out):«"\n"»
			«"\t"»global ending«"\n"»
			«"\t"»print('Now listening...')«"\n"»
			«"\t"»while True:«"\n"»
			«"\t"»«"\t"»data = int(sock_in.readline())«"\n"»
			«"\t"»«"\t"»if data==2:«"\n"»
			«"\t"»«"\t"»«"\t"»ending=True«"\n"»
			«"\t"»«"\t"»sleep(1)«"\n"»
			«"\n"»
			def sendInfo(sock_out, sensortype):«"\n"»
			«"\t"»sock_out.write(sensortype)«"\n"»
			«"\t"»sock_out.flush()«"\n"»
		'''
	
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
	
	def static mainThread()'''
		global ending«"\n"»
		ending=False«"\n"»
		server_mac = 'CC:78:AB:50:B2:46'«"\n"»
		is_master=False«"\n"»
		sock, sock_in, sock_out = connect(server_mac)«"\n"»
		blueListener = threading.Thread(target=listen, args=(sock_in,))«"\n"»
		blueListener.start()«"\n"»
		leftBListener = threading.Thread(target=listen, args=())«"\n"»
		leftBListener.start()«"\n"»
		rightBListener= threading.Thread(target=listen, args=())«"\n"»
		rightBListener.start()«"\n"»
		sonarListener = threading.Thread(target=listen, args=())«"\n"»
		sonarListener.start()«"\n"»
		while not ending:«"\n"»
		«"\t"»sleep(1)«"\n"»
		blueListener.terminate()«"\n"»
		leftBListener.terminate()«"\n"»
		rightBListener.terminate()«"\n"»
		sonarListener.terminate()«"\n"»
		disconnect(sock_in)«"\n"»
		disconnect(sock_out)«"\n"»
		disconnect(sock)«"\n"»
		sleep(5)«"\n"»
	'''
}