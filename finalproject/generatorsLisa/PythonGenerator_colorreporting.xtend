package dsl.finalproject.generator

import dsl.finalproject.fp.Button
import dsl.finalproject.fp.ButtonPress
import dsl.finalproject.fp.Color
import dsl.finalproject.fp.ColorWithName
import dsl.finalproject.fp.DirectionOptions
import dsl.finalproject.fp.DoNothingMission
import dsl.finalproject.fp.DriveMission
import dsl.finalproject.fp.FindLakesMission
import dsl.finalproject.fp.Obstacles
import dsl.finalproject.fp.ObstaclesEnum
import dsl.finalproject.fp.SpeedOptions
import dsl.finalproject.fp.Task
import dsl.finalproject.fp.TimeObject
import dsl.finalproject.fp.TrackingOptions
import dsl.finalproject.fp.UseObstacle
import dsl.finalproject.fp.Mission
import dsl.finalproject.fp.Boole

class PythonGenerator {
	def static toPy(Task root){
		'''
		�imports()��"\n"�
		�blueToothCode()��"\n"�
		�doNotFallOff()��"\n"�
		�colorAvoid()��"\n"�
		�motorModerator()��"\n"�
		�stateSwitch()��"\n"�
		�state2Text()��"\n"�
		�sensor2Text()��"\n"�
		�motorOptions()��"\n"�
		�mainThread(root)�
		'''
	}
	
	def static dispatch speedDef(DoNothingMission Mission)'''
		standardSpeed =0
	'''
	
	def static dispatch speedDef(DriveMission Mission)'''
		�normSpeedDef(Mission.speed)�
		'''
	
	def static normSpeedDef(SpeedOptions speed)'''
		standardSpeed = �toText(speed)�
	'''
	
	def static imports()'''
		#!/usr/bin/env python3�"\n"�
		�"\n"�
		import ev3dev.auto as ev3�"\n"�
		from ev3dev2.motor import LargeMotor, OUTPUT_A, OUTPUT_D, OUTPUT_B, SpeedPercent, Motor�"\n"�
		from ev3dev2.sound import Sound�"\n"�
		from ev3dev2.display import Display�"\n"�
		from ev3dev2.sensor.lego import ColorSensor�"\n"�
		from ev3dev2.sensor.lego import TouchSensor�"\n"�
		from ev3dev2._platform.ev3 import INPUT_4, INPUT_1, INPUT_2, INPUT_3�"\n"�
		from ev3dev2.led import Leds�"\n"�
		from ev3dev2.sensor.lego import UltrasonicSensor�"\n"�
		import random�"\n"�
		import bluetooth, threading�"\n"�
		from time import sleep�"\n"�
		from time import time�"\n"�
	'''
	
	def static mainThread(Task root)'''
		global backUnsafe�"\n"�
		global forwardCLUnsafe�"\n"�
		global forwardCRUnsafe�"\n"�
		global forwardCMUnsafe�"\n"�
		global leftBumperUnsafe�"\n"�
		global rightBumperUnsafe�"\n"�
		global forwardSonarUnsafe�"\n"�
		global needToHandleForSonar�"\n"�
		global needToHandleLeftBumper�"\n"�
		global needToHandleRightBumper�"\n"�
		global exploreMotor
		global standardSpeed�"\n"�
		global startTime
		global btn
		global leftColorF�"\n"�
		global midColorF�"\n"�
		global rightColorF�"\n"�
		global measurementDone
		�"\n"�
		measurementDone=False
		print("Start!")�"\n"�
		backUnsafe=False�"\n"�
		forwardCLUnsafe=False�"\n"�
		forwardCRUnsafe=False�"\n"�
		forwardCMUnsafe=False�"\n"�
		leftBumperUnsafe=False�"\n"�
		rightBumperUnsafe=False�"\n"�
		forwardSonarUnsafe=False�"\n"�
		needToHandleForSonar=False�"\n"�
		needToHandleLeftBumper=False�"\n"�
		needToHandleRightBumper=False�"\n"�
		leftColorF=False
		midColorF=False
		rightColorF=False
		�"\n"�
		motorCommand = 'Stop'�"\n"�
		motSpeed =[0,0]�"\n"�
		global ending
		ending= False�"\n"�
		global trueEnd
		trueEnd= False
		�"\n"�
		left_motor = LargeMotor(OUTPUT_A)�"\n"�
		right_motor = LargeMotor(OUTPUT_D)�"\n"�
		measurement_arm = Motor(OUTPUT_B)�"\n"�
		leds = Leds()�"\n"�
		s = Sound()�"\n"�
		csLeft = ColorSensor(INPUT_1)�"\n"�
		csMid = ColorSensor(INPUT_3)�"\n"�
		csRight = ColorSensor(INPUT_4)�"\n"�
		leds.set_color("LEFT", "GREEN")�"\n"�
		leds.set_color("RIGHT", "GREEN")�"\n"�
		us = UltrasonicSensor()�"\n"�
		us.mode = 'US-DIST-CM'�"\n"�
		units = us.units�"\n"�
		distance = us.value()�"\n"�
		my_display = Display()�"\n"�
		my_display.clear()�"\n"�
		btn = ev3.Button()�"\n"�
		�"\n"�
		global colorsToFind�"\n"�
		colorsToFind= []�"\n"�
		global countobjects�"\n"�
		countobjects = 0�"\n"�
		global numSamples #aanpassen�"\n"�
		global numLakesFound #aanpassen�"\n"�
		numSamples = 0 #aanpassen�"\n"�
		numLakesFound = 0 #aanpassen�"\n"�
		�"\n"�
		server_mac = '00:17:E9:B4:C7:63'�"\n"�
		sock, sock_in, sock_out = connect(server_mac)�"\n"�
		blueMod = threading.Thread(target=listen, args=(sock_in,))�"\n"�
		blueMod.start()�"\n"�
		�FOR mission : root.mission SEPARATOR "\n"+"ending=False \n"�
			�missionMain(mission)�
		�ENDFOR�
		
		trueEnd=True
		sendInfo(sock_out, 2)�"\n"�
		blueMod.join()�"\n"�
		disconnect(sock_in)�"\n"�
		disconnect(sock_out)�"\n"�
		disconnect(sock)�"\n"�
		print("Finished")�"\n"�
		sleep(5)�"\n"�
		
	'''
	
	def static dispatch missionMain(DoNothingMission Mission)'''
		startTime= time()
		standardSpeed = 0
		colorsToFind=[]�"\n"�
		�IF Mission.offB === null�
		stopList = [lambda :time()-startTime>�Mission.time�]
		�ELSE�
		stopList = [lambda :time()-startTime>�Mission.time�, �FOR button : Mission.offB SEPARATOR " , "��toText(button.buttons)��ENDFOR�]
		�ENDIF�
		�"\n"�
		removal=False
		takeSample=False
		avoidList = []
		senMod = threading.Thread(target=sensorModerator, args=(stopList, avoidList,colorsToFind,removal,takeSample,))�"\n"�
		senMod.start()�"\n"�
		sleep(1)�"\n"�
		senMod.join()�"\n"�
		s.speak("Mission complete!")�"\n"�
	'''
	
	def static dispatch missionMain(DriveMission Mission)'''
		startTime= time()
		colorsToFind=[]�"\n"�
		countobjects=0�"\n"�
		standardSpeed= �toText(Mission.speed)�
		exploreMotor= lambda prevTime:�toText(Mission.dir)�
		stopList = [�FOR stpc : Mission.stopcons SEPARATOR " , "��stopCon2Text(stpc)��ENDFOR�]
		�IF Mission.avoid !== null�
		avoidList = [�FOR avoidC : Mission.avoid SEPARATOR " , "��avoidCon2Text(avoidC)��ENDFOR�]
		�ELSE�
		avoidList=[]
		�ENDIF�
		�IF Mission.keeptrack !== null�
		trackList = [�FOR trackO : Mission.keeptrack SEPARATOR " , "��trackCon2Text(trackO)��ENDFOR�]
		�ELSE�
		trackList=[]
		�ENDIF�
		removal=False
		takeSample=False
		statMod = threading.Thread(target=stateModerator, args=())�"\n"�
		motMod = threading.Thread(target=motorModerator, args=())�"\n"�
		senMod = threading.Thread(target=sensorModerator, args=(stopList, avoidList,colorsToFind,removal,takeSample,))�"\n"�
		senMod.start()�"\n"�
		sleep(1)�"\n"�
		statMod.start()�"\n"�
		motMod.start()�"\n"�
		senMod.join()�"\n"�
		statMod.join()�"\n"�
		motMod.join()�"\n"�
		needToHandleForSonar=False�"\n"�
		needToHandleLeftBumper=False�"\n"�
		needToHandleRightBumper=False�"\n"�
		s.speak("Mission complete!")�"\n"�
		if trackList != []:
		�"\t"�if 1 in trackList:
		�"\t"��"\t"�s.speak("You have instructed me to count lakes")�"\n"�
		�"\t"��"\t"�s.speak("However I was just driving around not keeping track of the scenery")�"\n"�
		�"\t"�if 2 in trackList:
		�"\t"��"\t"�tracktime=int(time()-startTime)
		�"\t"��"\t"�s.speak("The time that has passed is " + str(tracktime) + " seconds")�"\n"�
		�"\t"�if 3 in trackList: # bumperChecker() should be in avoid list.
		�"\t"��"\t"�if countobjects == 1:
		�"\t"��"\t"��"\t"�s.speak("I have bumped into " + countobjects + " object")�"\n"�
		�"\t"��"\t"�else:
		�"\t"��"\t"��"\t"�s.speak("I have bumped into " + countobjects + " objects")�"\n"�
	'''
	
	def static dispatch missionMain(FindLakesMission Mission)'''
		startTime= time()
		countobjects=0
		colorsToFind= [�FOR col : Mission.findcolor SEPARATOR " , "��toText(col.colors)��ENDFOR�]
		removal= �toText(Mission.findCO)�
		takeSample=�toText(Mission.takeSamples)�
		standardSpeed= �toText(Mission.speed)�
		exploreMotor= lambda prevTime:randomMotor(prevTime)
		stopList = [�FOR stpc : Mission.stopcons SEPARATOR " , "��stopCon2Text(stpc)��ENDFOR�]
		�IF Mission.avoid !== null�
		avoidList = [�FOR avoidC : Mission.avoid SEPARATOR " , "��avoidCon2Text(avoidC)��ENDFOR�]
		�ELSE�
		avoidList=[]
		�ENDIF�
		�IF Mission.keeptrack !== null�
		trackList = [�FOR trackO : Mission.keeptrack SEPARATOR " , "��trackCon2Text(trackO)��ENDFOR�]
		�ELSE�
		trackList=[]
		�ENDIF�
		statMod = threading.Thread(target=stateModerator, args=())�"\n"�
		motMod = threading.Thread(target=motorModerator, args=())�"\n"�
		senMod = threading.Thread(target=sensorModerator, args=(stopList, avoidList,colorsToFind,removal,takeSample,))�"\n"�
		senMod.start()�"\n"�
		sleep(1)�"\n"�
		statMod.start()�"\n"�
		motMod.start()�"\n"�
		senMod.join()�"\n"�
		colorsToFind=[]�"\n"�
		statMod.join()�"\n"�
		motMod.join()�"\n"�
		leftColorF=False
		midColorF=False
		rightColorF=False
		measurementDone=False
		needToHandleForSonar=False�"\n"�
		needToHandleLeftBumper=False�"\n"�
		needToHandleRightBumper=False�"\n"�
		s.speak("Mission complete!")�"\n"�
		if trackList != []:
		�"\t"�if 1 in trackList:
		�"\t"��"\t"�if numLakesFound == 1:
		�"\t"��"\t"��"\t"�s.speak("I have found " + numLakesFound + " lake")
		�"\t"��"\t"�else:
		�"\t"��"\t"��"\t"�s.speak("I have found " + numLakesFound + " lakes")
		�"\t"��"\t"�#I have detected .. find colors lakes. and take ... measurements
		�"\t"��"\t"�if takeSample and numSamples == 1:
		�"\t"��"\t"��"\t"�s.speak("I have taken "+ numSamples + " sample")
		�"\t"��"\t"�elif takeSample:
		�"\t"��"\t"��"\t"�s.speak("I have taken "+ numSamples + " samples")
		�"\t"�if 2 in trackList:
		�"\t"��"\t"�tracktime=int(time()-startTime)
		�"\t"��"\t"�s.speak("The time that has passed is " + str(tracktime) + " seconds")�"\n"�
		�"\t"�if 3 in trackList: # bumperChecker() should be in avoid list.
		�"\t"��"\t"�if countobjects == 1:
		�"\t"��"\t"��"\t"�s.speak("I have bumped into " + countobjects + " object")�"\n"�
		�"\t"��"\t"�else:
		�"\t"��"\t"��"\t"�s.speak("I have bumped into " + countobjects + " objects")�"\n"�
	'''
	
	def static blueToothCode()'''
		def connect(server_mac):�"\n"�
		�"\t"�port = 3�"\n"�
		�"\t"�server_sock = bluetooth.BluetoothSocket(bluetooth.RFCOMM)�"\n"�
		�"\t"�server_sock.bind((server_mac, port))�"\n"�
		�"\t"�server_sock.listen(1)�"\n"�
		�"\t"�print('Listening...')�"\n"�
		�"\t"�client_sock, address = server_sock.accept()�"\n"�
		�"\t"�print('Accepted connection from ', address)�"\n"�
		�"\t"�return client_sock, client_sock.makefile('r'), client_sock.makefile('w')�"\n"�
		�"\n"�
		def disconnect(sock):�"\n"�
		�"\t"�sock.close()�"\n"�
		�"\n"�
		def listen(sock_in):�"\n"�
		�"\t"�global trueEnd�"\n"�
		�"\t"�global leftBumperUnsafe
		�"\t"�global rightBumperUnsafe�"\n"�
		�"\t"�global forwardSonarUnsafe�"\n"�
		�"\t"�print('Now listening...')�"\n"�
		�"\t"�while True:�"\n"�
		�"\t"��"\t"�data = int(sock_in.readline())�"\n"�
		�"\t"��"\t"�if data==1:�"\n"�
		�"\t"��"\t"��"\t"�leftBumperUnsafe=True�"\n"�
		�"\t"��"\t"�if data==2:�"\n"�
		�"\t"��"\t"��"\t"�leftBumperUnsafe=False�"\n"�
		�"\t"��"\t"�elif data==3:�"\n"�
		�"\t"��"\t"��"\t"�rightBumperUnsafe=True�"\n"�
		�"\t"��"\t"�elif data==4:�"\n"�
		�"\t"��"\t"��"\t"�rightBumperUnsafe=False�"\n"�
		�"\t"��"\t"�elif data==5:�"\n"�
		�"\t"��"\t"��"\t"�forwardSonarUnsafe=True�"\n"�
		�"\t"��"\t"�elif data==6:�"\n"�
		�"\t"��"\t"��"\t"�forwardSonarUnsafe=False�"\n"�
		�"\t"��"\t"�elif data==7:�"\n"�
		�"\t"��"\t"��"\t"�print("Other one is ending, I will end now too")�"\n"�
		�"\t"��"\t"�sleep(0.1)�"\n"�
		�"\t"��"\t"�if trueEnd:�"\n"�
		�"\t"��"\t"��"\t"�break�"\n"�
		�"\n"�
		def sendInfo(sock_out, message):�"\n"�
		�"\t"�sock_out.write(str(message)+ '\n')�"\n"�
		�"\t"�sock_out.flush()�"\n"�
		'''

	def static doNotFallOff()'''
		def doNotFallOff():�"\n"�
		�"\t"�global backUnsafe�"\n"�
		�"\t"�global forwardCLUnsafe�"\n"�
		�"\t"�global forwardCRUnsafe�"\n"�
		�"\t"�global forwardCMUnsafe�"\n"�
		�"\t"�new_colorLeft = csLeft.color�"\n"�
		�"\t"�new_colorMid = csMid.color�"\n"�
		�"\t"�new_colorRight = csRight.color�"\n"�
		�"\t"�distance = us.value()/10�"\n"�
		�"\t"�if new_colorLeft==0:�"\n"�
		�"\t"��"\t"�forwardCLUnsafe=True�"\n"�
		�"\t"�else:�"\n"�
		�"\t"��"\t"�forwardCLUnsafe=False�"\n"�
		�"\t"�if new_colorMid==0:�"\n"�
		�"\t"��"\t"�forwardCMUnsafe=True�"\n"�
		�"\t"�else:�"\n"�
		�"\t"��"\t"�forwardCMUnsafe=False�"\n"�
		�"\t"�if new_colorRight==0:�"\n"�
		�"\t"��"\t"�forwardCRUnsafe=True�"\n"�
		�"\t"�else:�"\n"�
		�"\t"��"\t"�forwardCRUnsafe=False�"\n"�
		�"\t"�if distance>4.8:�"\n"�
		�"\t"��"\t"�backUnsafe=True�"\n"�
		�"\t"�else:�"\n"�
		�"\t"��"\t"�backUnsafe=False�"\n"�
	'''
	
	def static motorModerator()'''
		def motorModerator():�"\n"�
		�"\t"�global ending�"\n"�
		�"\t"�while True:�"\n"�
		�"\t"��"\t"�global motSpeed�"\n"�
		�"\t"��"\t"�if motSpeed[0]==0:
		�"\t"��"\t"��"\t"�left_motor.stop()�"\n"�
		�"\t"��"\t"�else:
		�"\t"��"\t"��"\t"�left_motor.on_for_seconds(SpeedPercent(motSpeed[0]), 1,  block=False)�"\n"�
		�"\t"��"\t"�if motSpeed[1]==0:
		�"\t"��"\t"��"\t"�right_motor.stop()�"\n"�
		�"\t"��"\t"�else:
		�"\t"��"\t"��"\t"�right_motor.on_for_seconds(SpeedPercent(motSpeed[1]), 1,  block=False)�"\n"�
		�"\t"��"\t"�if ending:�"\n"�
		�"\t"��"\t"��"\t"�left_motor.stop()�"\n"�
		�"\t"��"\t"��"\t"�right_motor.stop()�"\n"�
		�"\t"��"\t"��"\t"�break�"\n"�
		�"\t"��"\t"�sleep(0.1)�"\n"�
	'''
	
	def static colorAvoid()'''
	def colorAvoid(color):�"\n"�
	�"\t"�global forwardCLUnsafe�"\n"�
	�"\t"�global forwardCRUnsafe�"\n"�
	�"\t"�global forwardCMUnsafe�"\n"�
	�"\t"�new_colorLeft = csLeft.color�"\n"�
	�"\t"�new_colorMid = csMid.color�"\n"�
	�"\t"�new_colorRight = csRight.color�"\n"�
	�"\t"�if new_colorLeft==color:�"\n"�
	�"\t"��"\t"�forwardCLUnsafe=True�"\n"�
	�"\t"�else:�"\n"�
	�"\t"��"\t"�forwardCLUnsafe=False�"\n"�
	�"\t"�if new_colorMid==color:�"\n"�
	�"\t"��"\t"�forwardCMUnsafe=True�"\n"�
	�"\t"�else:�"\n"�
	�"\t"��"\t"�forwardCMUnsafe=False�"\n"�
	�"\t"�if new_colorRight==color:�"\n"�
	�"\t"��"\t"�forwardCRUnsafe=True�"\n"�
	�"\t"�else:�"\n"�
	�"\t"��"\t"�forwardCRUnsafe=False�"\n"�
	'''
	
	def static stateSwitch()'''
	def stateExp():�"\n"�
	�"\t"�global backUnsafe�"\n"�
	�"\t"�global forwardCLUnsafe�"\n"�
	�"\t"�global forwardCRUnsafe�"\n"�
	�"\t"�global forwardCMUnsafe�"\n"�
	�"\t"�global needToHandleForSonar�"\n"�
	�"\t"�global needToHandleLeftBumper�"\n"�
	�"\t"�global needToHandleRightBumper�"\n"�
	�"\t"�global leftColorF�"\n"�
	�"\t"�global midColorF�"\n"�
	�"\t"�global rightColorF�"\n"�
	�"\t"�if backUnsafe and (forwardCMUnsafe or forwardCLUnsafe or forwardCRUnsafe):�"\n"�
	�"\t"��"\t"�return 'DesperateTurn'�"\n"�
	�"\t"�elif backUnsafe:�"\n"�
	�"\t"��"\t"�return 'BackDepthAvoidance'�"\n"�
	�"\t"�elif forwardCMUnsafe:�"\n"�
	�"\t"��"\t"�return 'ForwardMidDepthAvoidance'�"\n"�
	�"\t"�elif forwardCLUnsafe:�"\n"�
	�"\t"��"\t"�return 'ForwardLeftDepthAvoidance'�"\n"�
	�"\t"�elif forwardCRUnsafe:�"\n"�
	�"\t"��"\t"�return 'ForwardRightDepthAvoidance'�"\n"�
	�"\t"�elif needToHandleLeftBumper:�"\n"�
	�"\t"��"\t"�return 'LeftBumperAvoidance'�"\n"�
	�"\t"�elif needToHandleRightBumper:�"\n"�
	�"\t"��"\t"�return 'RightBumperAvoidance'�"\n"�
	�"\t"�elif needToHandleForSonar:�"\n"�
	�"\t"��"\t"�return 'ForwardDepthAvoidance'�"\n"�
	�"\t"�elif leftColorF or midColorF or rightColorF:�"\n"�
	�"\t"��"\t"�return 'MeasurementState'�"\n"�
	�"\t"�return ''�"\n"�
	�"\n"�
	def stateObstacle():
	�"\t"�global backUnsafe�"\n"�
	�"\t"�global forwardCLUnsafe�"\n"�
	�"\t"�global forwardCRUnsafe�"\n"�
	�"\t"�global forwardCMUnsafe�"\n"�
	�"\t"�global needToHandleLeftBumper�"\n"�
	�"\t"�global needToHandleRightBumper�"\n"�
	�"\t"�if backUnsafe and (forwardCMUnsafe or forwardCLUnsafe or forwardCRUnsafe):�"\n"�
	�"\t"��"\t"�return 'DesperateTurn'�"\n"�
	�"\t"�elif backUnsafe:�"\n"�
	�"\t"��"\t"�return 'BackDepthAvoidance'�"\n"�
	�"\t"�elif forwardCMUnsafe:�"\n"�
	�"\t"��"\t"�return 'ForwardMidDepthAvoidance'�"\n"�
	�"\t"�elif forwardCLUnsafe:�"\n"�
	�"\t"��"\t"�return 'ForwardLeftDepthAvoidance'�"\n"�
	�"\t"�elif forwardCRUnsafe:�"\n"�
	�"\t"��"\t"�return 'ForwardRightDepthAvoidance'�"\n"�
	�"\t"�elif needToHandleLeftBumper:�"\n"�
	�"\t"��"\t"�return 'LeftBumperAvoidance'�"\n"�
	�"\t"�elif needToHandleRightBumper:�"\n"�
	�"\t"��"\t"�return 'RightBumperAvoidance'�"\n"�
	�"\t"�return ''�"\n"�
	�"\n"�
	def stateBumper():
	�"\t"�global backUnsafe�"\n"�
	�"\t"�global forwardCLUnsafe�"\n"�
	�"\t"�global forwardCRUnsafe�"\n"�
	�"\t"�global forwardCMUnsafe�"\n"�
	�"\t"�if backUnsafe and (forwardCMUnsafe or forwardCLUnsafe or forwardCRUnsafe):�"\n"�
	�"\t"��"\t"�return 'DesperateTurn'�"\n"�
	�"\t"�elif backUnsafe:�"\n"�
	�"\t"��"\t"�return 'BackDepthAvoidance'�"\n"�
	�"\t"�elif forwardCMUnsafe:�"\n"�
	�"\t"��"\t"�return 'ForwardMidDepthAvoidance'�"\n"�
	�"\t"�elif forwardCLUnsafe:�"\n"�
	�"\t"��"\t"�return 'ForwardLeftDepthAvoidance'�"\n"�
	�"\t"�elif forwardCRUnsafe:�"\n"�
	�"\t"��"\t"�return 'ForwardRightDepthAvoidance'�"\n"�
	�"\t"�return ''�"\n"�
	�"\n"�
	def stateF():�"\n"�
	�"\t"�global backUnsafe�"\n"�
	�"\t"�global forwardCLUnsafe�"\n"�
	�"\t"�global forwardCRUnsafe�"\n"�
	�"\t"�global forwardCMUnsafe�"\n"�
	�"\t"�if backUnsafe:�"\n"�
	�"\t"��"\t"�return 'DesperateTurn'�"\n"�
	�"\t"�else:�"\n"�
	�"\t"��"\t"�return ''�"\n"�
	�"\n"�
	def stateBD():�"\n"�
	�"\t"�global backUnsafe�"\n"�
	�"\t"�global forwardCLUnsafe�"\n"�
	�"\t"�global forwardCRUnsafe�"\n"�
	�"\t"�global forwardCMUnsafe�"\n"�
	�"\t"�if forwardCLUnsafe or forwardCRUnsafe or forwardCMUnsafe:�"\n"�
	�"\t"��"\t"�return 'DesperateTurn'�"\n"�
	�"\t"�else:�"\n"�
	�"\t"��"\t"�return ''�"\n"�
	
	def stateMeasure():
	�"\t"�global backUnsafe�"\n"�
	�"\t"�global forwardCLUnsafe�"\n"�
	�"\t"�global forwardCRUnsafe�"\n"�
	�"\t"�global forwardCMUnsafe�"\n"�
	�"\t"�if forwardCLUnsafe or forwardCRUnsafe or forwardCMUnsafe:�"\n"�
	�"\t"��"\t"�return 'DesperateTurn'�"\n"�
	�"\t"�return ''�"\n"�
    '''
    
    def static state2Text()'''
    def determineState(curState):
        if curState=='Exploring':
            nextState=stateExp()
        elif curState=='ForwardDepthAvoidance':
        	nextState = stateObstacle()
        elif curState=='RightBumperAvoidance' or curState=='LeftBumperAvoidance':
        	nextState = stateBumper()
        elif curState=='BackDepthAvoidance':
            nextState= stateBD()
        elif curState== 'ForwardLeftDepthAvoidance' or curState== 'ForwardMidDepthAvoidance' or curState=='ForwardRightDepthAvoidance':
            nextState= stateF()
        elif curState=='DesperateTurn':
            nextState= 'DesperateTurn'
        elif curState=='MeasurementState':
        	nextState=stateMeasure()
        return nextState if not (nextState=='') else curState
    
    def expMot(prevTime, rotationChoice):
        global motSpeed
        global backUnsafe
        global forwardCLUnsafe
        global forwardCRUnsafe
        global forwardCMUnsafe
        global exploreMotor
        prevTime=exploreMotor(prevTime)
        return prevTime, 'Exploring', rotationChoice
        
    def bdMot(prevTime, rotationChoice):
        global motSpeed
        global backUnsafe
        global forwardCLUnsafe
        global forwardCRUnsafe
        global forwardCMUnsafe
        if backUnsafe:
            motSpeed[0]=standardSpeed
            motSpeed[1]=standardSpeed
            prevTime=time()
            return prevTime, 'BackDepthAvoidance', rotationChoice
        elif (int(time()) - prevTime)<0.3:
        	if rotationChoice == None:
        		rotationChoice=random.randint(1,2)
        	if rotationChoice ==1:
        		motSpeed[0]=5
        		motSpeed[1]=-5
        	else:
        		motSpeed[0]=-5
        		motSpeed[1]=5
        	return prevTime, 'BackDepthAvoidance', rotationChoice
        motSpeed =[0,0]
        return time(), 'Exploring', rotationChoice
        
    def flMot(prevTime, rotationChoice):
        global motSpeed
        global backUnsafe
        global forwardCLUnsafe
        global forwardCRUnsafe
        global forwardCMUnsafe
        if forwardCLUnsafe:
            motSpeed[0]=-standardSpeed
            motSpeed[1]=-standardSpeed
            prevTime=time()
            return prevTime, 'ForwardLeftDepthAvoidance', rotationChoice
        elif (int(time()) - prevTime)<0.3:
        	if rotationChoice == None:
                rotationChoice=1
        	if rotationChoice ==1:
                motSpeed[0]=5
                motSpeed[1]=-5
            else:
                motSpeed[0]=-5
                motSpeed[1]=5
        	return prevTime, 'ForwardLeftDepthAvoidance', rotationChoice
        motSpeed =[0,0]
        return time(), 'Exploring', rotationChoice
        
    def fmMot(prevTime, rotationChoice):
        global motSpeed
        global backUnsafe
        global forwardCLUnsafe
        global forwardCRUnsafe
        global forwardCMUnsafe
        if forwardCMUnsafe:
            motSpeed[0]=-standardSpeed
            motSpeed[1]=-standardSpeed
            prevTime=time()
            return prevTime, 'ForwardMidDepthAvoidance', rotationChoice
        elif (int(time()) - prevTime)<0.3:
            if rotationChoice == None:
                rotationChoice=random.randint(1,2)
            if rotationChoice ==1:
                motSpeed[0]=5
                motSpeed[1]=-5
            else:
                motSpeed[0]=-5
                motSpeed[1]=5
            return prevTime, 'ForwardMidDepthAvoidance', rotationChoice
        motSpeed =[0,0]
        return time(), 'Exploring', rotationChoice
        
    def frMot(prevTime, rotationChoice):
        global motSpeed
        global backUnsafe
        global forwardCLUnsafe
        global forwardCRUnsafe
        global forwardCMUnsafe
        if forwardCRUnsafe:
            motSpeed[0]=-standardSpeed
            motSpeed[1]=-standardSpeed
            prevTime=time()
            return prevTime, 'ForwardRightDepthAvoidance', rotationChoice
        elif (int(time()) - prevTime)<0.3:
        	if rotationChoice == None:
                rotationChoice=2
        	if rotationChoice ==1:
                motSpeed[0]=5
                motSpeed[1]=-5
            else:
                motSpeed[0]=-5
                motSpeed[1]=5
            return prevTime, 'ForwardRightDepthAvoidance', rotationChoice
        motSpeed =[0,0]
        return time(), 'Exploring', rotationChoice
        
    def lbMot(prevTime, rotationChoice):
            global motSpeed
            global needToHandleForSonar
            global needToHandleLeftBumper
            global needToHandleRightBumper
            if needToHandleLeftBumper:
                motSpeed[0]=-standardSpeed
                motSpeed[1]=-standardSpeed
                prevTime=time()
                return prevTime, 'LeftBumperAvoidance', None
            elif (int(time()) - prevTime)<0.5:
            	motSpeed[0]=5
            	motSpeed[1]=-5
            	return prevTime, 'LeftBumperAvoidance', None
            motSpeed =[0,0]
            return time(), 'Exploring', None
            
    def fdMot(prevTime, rotationChoice):
        global motSpeed
        global needToHandleForSonar
        global needToHandleLeftBumper
        global needToHandleRightBumper
        if needToHandleForSonar:
            motSpeed[0]=-standardSpeed
            motSpeed[1]=-standardSpeed
            prevTime=time()
            return prevTime, 'ForwardDepthAvoidance', None
        elif (int(time()) - prevTime)<0.5:
            if rotationChoice == None:
                rotationChoice=random.randint(1,2)
            if rotationChoice ==1:
                motSpeed[0]=5
                motSpeed[1]=-5
            else:
                motSpeed[0]=-5
                motSpeed[1]=5
            return prevTime, 'ForwardDepthAvoidance', rotationChoice
        motSpeed =[0,0]
        return time(), 'Exploring', None
            
    def rbMot(prevTime, rotationChoice):
        global motSpeed
        global needToHandleForSonar
        global needToHandleLeftBumper
        global needToHandleRightBumper
        if needToHandleRightBumper:
            motSpeed[0]=-standardSpeed
            motSpeed[1]=-standardSpeed
            prevTime=time()
            return prevTime, 'RightBumperAvoidance', None
        elif (int(time()) - prevTime)<0.5:
            motSpeed[0]=-5
            motSpeed[1]=5
            return prevTime, 'RightBumperAvoidance', None
        motSpeed =[0,0]
        return time(), 'Exploring', None
    
    def despTurn(prevTime, rotationChoice):
        global motSpeed
        global backUnsafe
        global forwardCLUnsafe
        global forwardCRUnsafe
        global forwardCMUnsafe
        if (backUnsafe and (forwardCMUnsafe or forwardCLUnsafe or forwardCRUnsafe)) or time()-prevTime<0.5:
        	if rotationChoice == None:
                rotationChoice=random.randint(1,2)
        	if rotationChoice ==1:
                motSpeed[0]=5
                motSpeed[1]=-5
            else:
                motSpeed[0]=-5
                motSpeed[1]=5
            return prevTime, 'DesperateTurn', rotationChoice
        motSpeed =[0,0]
        return time(), 'Exploring', rotationChoice
    
    def MeasurementTaking(prevTime, rotationChoice):
    	global leftColorF�"\n"�
    	global midColorF�"\n"�
    	global rightColorF�"\n"�
    	global motSpeed
    	global measurementDone
    	global numSamples
    	if midColorF and not leftColorF and rightColorF:
    		motSpeed=[0,0]
    		measurement_arm.on_for_rotations(-10, 0.30, block=True)
    		sleep(3)
    		measurement_arm.on_for_rotations(10,0.30, block=True)
    		measurementDone=True
    		numSamples+=1
    		return time(), 'Exploring', None
    	elif midColorF and not leftColorF and not rightColorF:
    		motSpeed[0]=-5
    		motSpeed[1]=5
    		return time(), 'MeasurementState', None
    	elif midColorF and leftColorF and not rightColorF:
    		motSpeed[0]=-5
    		motSpeed[1]=5
    		return time(), 'MeasurementState', None
    	elif midColorF and leftColorF and rightColorF:
    		motSpeed[0]=-5
    		motSpeed[1]=-5
    		return time(), 'MeasurementState', None
    	elif not midColorF and leftColorF and rightColorF:
    		motSpeed[0]=-5
    		motSpeed[1]=-5
    		return time(), 'MeasurementState', None
    	elif not midColorF and leftColorF and not rightColorF:
    		motSpeed[0]=-5
    		motSpeed[1]=5
    		return time(), 'MeasurementState', None
    	elif not midColorF and not leftColorF and rightColorF:
    		motSpeed[0]=5
    		motSpeed[1]=-5
    		return time(), 'MeasurementState', None
    	motSpeed=[0,0]
    	return time(), 'Exploring', None
    		
    
    def stateModerator():
    �"\t"�global ending�"\n"�
    �"\t"�global motSpeed�"\n"�
    �"\t"�curState= 'Exploring'�"\n"�
    �"\t"�nextState='Exploring'�"\n"�
    �"\t"�prevTime = time()�"\n"�
    �"\t"�rotationChoice = None�"\n"�
    �"\t"�while True:�"\n"�
    �"\t"��"\t"�nextState = determineState(curState)�"\n"�
    �"\t"��"\t"�if nextState!=curState:�"\n"�
    �"\t"��"\t"��"\t"�prevTime = time()�"\n"�
    �"\t"��"\t"�if nextState=="Exploring":�"\n"�
    �"\t"��"\t"��"\t"�prevTime, curState, rotationChoice=expMot(prevTime, rotationChoice)�"\n"�
    �"\t"��"\t"�elif nextState=="LeftBumperAvoidance":
    �"\t"��"\t"��"\t"�prevTime, curState, rotationChoice = lbMot(prevTime, rotationChoice)
    �"\t"��"\t"�elif nextState=="RightBumperAvoidance":
    �"\t"��"\t"��"\t"�prevTime, curState, rotationChoice = rbMot(prevTime, rotationChoice)
    �"\t"��"\t"�elif nextState=="ForwardDepthAvoidance":
    �"\t"��"\t"��"\t"�prevTime, curState, rotationChoice = fdMot(prevTime, rotationChoice)
    �"\t"��"\t"�elif nextState== "BackDepthAvoidance":�"\n"�
    �"\t"��"\t"��"\t"�prevTime, curState, rotationChoice=bdMot(prevTime, rotationChoice)�"\n"�
    �"\t"��"\t"�elif nextState== "ForwardLeftDepthAvoidance":�"\n"�
    �"\t"��"\t"��"\t"�prevTime, curState, rotationChoice=flMot(prevTime, rotationChoice)�"\n"�
    �"\t"��"\t"�elif nextState== "ForwardMidDepthAvoidance":�"\n"�
    �"\t"��"\t"��"\t"�prevTime, curState, rotationChoice=fmMot(prevTime, rotationChoice)�"\n"�
    �"\t"��"\t"�elif nextState== "ForwardRightDepthAvoidance":�"\n"�
    �"\t"��"\t"��"\t"�prevTime, curState, rotationChoice=frMot(prevTime, rotationChoice)�"\n"�
    �"\t"��"\t"�elif nextState== "DesperateTurn":�"\n"�
    �"\t"��"\t"��"\t"�prevTime, curState, rotationChoice=despTurn(prevTime, rotationChoice)�"\n"�
    �"\t"��"\t"�elif nextState== "MeasurementState":�"\n"�
    �"\t"��"\t"��"\t"�prevTime, curState, rotationChoice=MeasurementTaking(prevTime, rotationChoice)�"\n"�
    �"\t"��"\t"�if ending:�"\n"�
    �"\t"��"\t"��"\t"�break�"\n"�
    �"\t"��"\t"�if time()-prevTime>2:
    �"\t"��"\t"��"\t"�rotationChoice=None
    �"\t"��"\t"�sleep(0.1)�"\n"�
    '''
	/* 
	def static dispatch sensor2Text(DriveMission Mission)'''
		def sensorModerator():�"\n"�
		�"\t"�global ending�"\n"�
		�"\t"�curTime=time()�"\n"�
		�"\t"�while True:
		�"\t"��"\t"�doNotFallOff()
		�"\t"��"\t"�new_colorLeft = csLeft.color
		�"\t"��"\t"�new_colorMid = csMid.color
		�"\t"��"\t"�new_colorRight = csRight.color
		�"\t"��"\t"�if �FOR stpc : Mission.stopcons SEPARATOR " or " AFTER ":"��stopCon2Text(stpc)��ENDFOR��"\n"�
		�"\t"��"\t"��"\t"�break�"\n"�
		�IF Mission.avoid !== null�
		�FOR avoidC : Mission.avoid�
		�avoidToText(avoidC)�
		�ENDFOR�
		�ENDIF�
		�"\t"�ending=True�"\n"�
		'''*/
		
	def static sensor2Text()'''
		def sonarChecker():
			global forwardSonarUnsafe
			global needToHandleForSonar
			if forwardSonarUnsafe:
				needToHandleForSonar= True
			else:
				needToHandleForSonar= False
		
		def bumperChecker():
		�"\t"�global leftBumperUnsafe�"\n"�
		�"\t"�global rightBumperUnsafe�"\n"�
		�"\t"�global needToHandleLeftBumper�"\n"�
		�"\t"�global needToHandleRightBumper�"\n"�
		�"\t"�global countobjects�"\n"�
		�"\t"�if leftBumperUnsafe:�"\n"�
		�"\t"��"\t"�needToHandleLeftBumper=True�"\n"�
		�"\t"�elif needToHandleLeftBumper and not leftBumperUnsafe:�"\n"�
		�"\t"��"\t"�countobjects+=1�"\n"�
		�"\t"��"\t"�needToHandleLeftBumper=False�"\n"�
		�"\t"�else:�"\n"�
		�"\t"��"\t"�needToHandleLeftBumper=False�"\n"�
		�"\t"�if rightBumperUnsafe:�"\n"�
		�"\t"��"\t"�needToHandleRightBumper=True�"\n"�
		�"\t"�elif needToHandleRightBumper and not rightBumperUnsafe:�"\n"�
		�"\t"��"\t"�countobjects+=1�"\n"�
		�"\t"��"\t"�needToHandleRightBumper=False�"\n"�
		�"\t"�else:�"\n"�
		�"\t"��"\t"�needToHandleRightBumper=False�"\n"�
		
		def sensorModerator(stopList, avoidList, colorsToFind, removal, takeSample):�"\n"�
		�"\t"�global ending�"\n"�
		�"\t"�global btn�"\n"�
		�"\t"�global leftColorF�"\n"�
		�"\t"�global midColorF�"\n"�
		�"\t"�global rightColorF�"\n"�
		�"\t"�global measurementDone�"\n"�
		�"\t"�global forwardCMUnsafe�"\n"�
		�"\t"�global backUnsafe�"\n"�
		�"\t"�global numLakesFound�"\n"�
		�"\t"�prevTime=time()�"\n"�
		�"\t"�shouldFindColors= False
		�"\t"�needToAvoidColor=-1
		�"\t"�if colorsToFind!=[]:
		�"\t"��"\t"�shouldFindColors=True
		�"\t"�while True:
		�"\t"��"\t"�doNotFallOff()
		�"\t"��"\t"�new_colorLeft = csLeft.color
		�"\t"��"\t"�new_colorMid = csMid.color
		�"\t"��"\t"�new_colorRight = csRight.color
		�"\t"��"\t"�shouldStop=False
		�"\t"��"\t"�for stopEle in stopList:
		�"\t"��"\t"��"\t"�if stopEle():
		�"\t"��"\t"��"\t"��"\t"�shouldStop=True
		�"\t"��"\t"�if shouldStop:
		�"\t"��"\t"��"\t"�break
		�"\t"��"\t"�for avoidEle in avoidList:
		�"\t"��"\t"��"\t"�avoidEle()
		�"\t"��"\t"�if shouldFindColors:
		�"\t"��"\t"��"\t"�if colorsToFind==[]:
		�"\t"��"\t"��"\t"��"\t"�break
		�"\t"��"\t"��"\t"�if takeSample:
		�"\t"��"\t"��"\t"��"\t"�colorDetected=0
		�"\t"��"\t"��"\t"��"\t"�if new_colorLeft in colorsToFind and not measurementDone:
		�"\t"��"\t"��"\t"��"\t"��"\t"�leftColorF=True
		�"\t"��"\t"��"\t"��"\t"�elif new_colorLeft in colorsToFind:
		�"\t"��"\t"��"\t"��"\t"��"\t"�colorDetected=new_colorLeft
		�"\t"��"\t"��"\t"��"\t"��"\t"�leftColorF=False
		�"\t"��"\t"��"\t"��"\t"�else:
		�"\t"��"\t"��"\t"��"\t"��"\t"�leftColorF=False
		�"\t"��"\t"��"\t"��"\t"�if new_colorMid in colorsToFind and not measurementDone:
		�"\t"��"\t"��"\t"��"\t"��"\t"�midColorF=True
		�"\t"��"\t"��"\t"��"\t"�elif new_colorMid in colorsToFind:
		�"\t"��"\t"��"\t"��"\t"��"\t"�colorDetected=new_colorMid
		�"\t"��"\t"��"\t"��"\t"��"\t"�midColorF=False
		�"\t"��"\t"��"\t"��"\t"�else:
		�"\t"��"\t"��"\t"��"\t"��"\t"�midColorF=False
		�"\t"��"\t"��"\t"��"\t"�if new_colorRight in colorsToFind and not measurementDone:
		�"\t"��"\t"��"\t"��"\t"��"\t"�rightColorF=True
		�"\t"��"\t"��"\t"��"\t"�elif new_colorRight in colorsToFind:
		�"\t"��"\t"��"\t"��"\t"��"\t"�colorDetected=new_colorRight
		�"\t"��"\t"��"\t"��"\t"��"\t"�midColorF=False
		�"\t"��"\t"��"\t"��"\t"�else:
		�"\t"��"\t"��"\t"��"\t"��"\t"�rightColorF=False
		�"\t"��"\t"��"\t"��"\t"�if colorDetected!=0 and needToAvoidColor==-1:
		�"\t"��"\t"��"\t"��"\t"��"\t"�avoidList.append(lambda copy=colorDetected : colorAvoid(copy))
		�"\t"��"\t"��"\t"��"\t"��"\t"�numLakesFound+=1 #aanpassen
		�"\t"��"\t"��"\t"��"\t"��"\t"�if removal:
		�"\t"��"\t"��"\t"��"\t"��"\t"��"\t"�colorsToFind.remove(colorDetected)
		�"\t"��"\t"��"\t"��"\t"��"\t"��"\t"�measurementDone=False
		�"\t"��"\t"��"\t"��"\t"��"\t"�else:
		�"\t"��"\t"��"\t"��"\t"��"\t"��"\t"�needToAvoidColor=colorDetected
		�"\t"��"\t"��"\t"��"\t"�elif colorDetected!=needToAvoidColor and not removal and measurementDone:
		�"\t"��"\t"��"\t"��"\t"��"\t"�del avoidList[-1]
		�"\t"��"\t"��"\t"��"\t"��"\t"�measurementDone=False
		�"\t"��"\t"��"\t"��"\t"��"\t"�needToAvoidColor=-1
		�"\t"��"\t"��"\t"��"\t"��"\t"�forwardCMUnsafe=True
		�"\t"��"\t"��"\t"��"\t"��"\t"�backUnsafe=True
		�"\t"��"\t"��"\t"��"\t"��"\t"�sleep(5)
		�"\t"��"\t"��"\t"��"\t"��"\t"�forwardCMUnsafe=False
		�"\t"��"\t"��"\t"��"\t"��"\t"�backUnsafe=False
		�"\t"��"\t"��"\t"�else:
		�"\t"��"\t"��"\t"��"\t"�if new_colorLeft in colorsToFind and needToAvoidColor==-1:
		�"\t"��"\t"��"\t"��"\t"��"\t"�print("Found a color ", new_colorLeft)
		�"\t"��"\t"��"\t"��"\t"��"\t"�avoidList.append(lambda copy=new_colorLeft : colorAvoid(copy))
		�"\t"��"\t"��"\t"��"\t"��"\t"�numLakesFound+=1 #aanpassen
		�"\t"��"\t"��"\t"��"\t"��"\t"�if removal:
		�"\t"��"\t"��"\t"��"\t"��"\t"��"\t"�colorsToFind.remove(new_colorLeft)
		�"\t"��"\t"��"\t"��"\t"��"\t"�else:
		�"\t"��"\t"��"\t"��"\t"��"\t"��"\t"�needToAvoidColor=new_colorLeft
		�"\t"��"\t"��"\t"��"\t"�if new_colorMid in colorsToFind and needToAvoidColor==-1:
		�"\t"��"\t"��"\t"��"\t"��"\t"�print("Found a color ", new_colorMid)
		�"\t"��"\t"��"\t"��"\t"��"\t"�avoidList.append(lambda copy=new_colorMid : colorAvoid(copy))
		�"\t"��"\t"��"\t"��"\t"��"\t"�numLakesFound+=1 #aanpassen
		�"\t"��"\t"��"\t"��"\t"��"\t"�if removal:
		�"\t"��"\t"��"\t"��"\t"��"\t"��"\t"�colorsToFind.remove(new_colorMid)
		�"\t"��"\t"��"\t"��"\t"��"\t"�else:
		�"\t"��"\t"��"\t"��"\t"��"\t"��"\t"�needToAvoidColor=new_colorMid
		�"\t"��"\t"��"\t"��"\t"�if new_colorRight in colorsToFind and needToAvoidColor==-1:
		�"\t"��"\t"��"\t"��"\t"��"\t"�print("Found a color ", new_colorRight)
		�"\t"��"\t"��"\t"��"\t"��"\t"�avoidList.append(lambda copy=new_colorRight : colorAvoid(copy))
		�"\t"��"\t"��"\t"��"\t"��"\t"�numLakesFound+=1 #aanpassen
		�"\t"��"\t"��"\t"��"\t"��"\t"�if removal:
		�"\t"��"\t"��"\t"��"\t"��"\t"��"\t"�colorsToFind.remove(new_colorRight)
		�"\t"��"\t"��"\t"��"\t"��"\t"�else:
		�"\t"��"\t"��"\t"��"\t"��"\t"��"\t"�needToAvoidColor=new_colorRight
		�"\t"��"\t"��"\t"��"\t"�if not removal and new_colorLeft!=needToAvoidColor and new_colorMid!=needToAvoidColor and new_colorRight!=needToAvoidColor:
		�"\t"��"\t"��"\t"��"\t"��"\t"�del avoidList[-1]
		�"\t"��"\t"��"\t"��"\t"��"\t"�needToAvoidColor=-1
		�"\t"��"\t"��"\t"��"\t"��"\t"�forwardCMUnsafe=True
		�"\t"��"\t"��"\t"��"\t"��"\t"�backUnsafe=True
		�"\t"��"\t"��"\t"��"\t"��"\t"�sleep(5)
		�"\t"��"\t"��"\t"��"\t"��"\t"�forwardCMUnsafe=False
		�"\t"��"\t"��"\t"��"\t"��"\t"�backUnsafe=False
		�"\t"�ending=True�"\n"�
		'''
/* 
	def static dispatch sensor2Text(DoNothingMission Mission)'''
		def sensorModerator():�"\n"�
		�"\t"�global ending�"\n"�
		�"\t"�while (int(time())-currenttime)>�Mission.time�:�"\n"�
		�IF Mission.offB !== null�
		�"\t"��"\t"�if �FOR btnElement : Mission.offB SEPARATOR " or " AFTER ":"��toText(btnElement.buttons)��ENDFOR��"\n"�
		�"\t"��"\t"��"\t"�break�"\n"��ENDIF�
		�"\t"��"\t"�sleep(0.01)�"\n"�
		�"\t"�ending=True�"\n"�
		'''*/
		
	def static dispatch avoidToText(UseObstacle avoidC)''''''
	
	def static dispatch avoidToText(ColorWithName avoidC)'''
	�"\t"��"\t"�colorAvoid(�toText(avoidC.color)�)�"\n"�
	'''
/* 
	def static dispatch mission2Text(DriveMission mission)'''
		while (True):�"\n"� 
		�"\t"�speed = �toText(mission.speed)��"\n"�
		�toText(mission.dir)�
		�"\t"�new_color = cs.color�"\n"�
		�"\t"�distance = us.value()/10�"\n"�
		�IF mission.avoid !== null�
		�"\t"�if �FOR obst : mission.avoid SEPARATOR " or " AFTER ":"��obstacles2Text(obst)��ENDFOR��"\n"�
		�avoidFunction()��ENDIF�
		�"\t"�if �FOR stpc : mission.stopcons SEPARATOR " or " AFTER ":"��stopCon2Text(stpc)��ENDFOR��"\n"�
		�"\t"��"\t"�left_motor.stop()�"\n"�
		�"\t"��"\t"�right_motor.stop()�"\n"�
		�"\t"��"\t"�break�"\n"�'''
	
	def static dispatch mission2Text(DoNothingMission mission)'''
		while (int(time.time()) - currenttime)> �mission.time�:�"\n"�
		�"\t"�time.sleep(1)�"\n"�
	'''
	def static dispatch mission2Text(FindLakesMission mission)'''
		colorsToFind = [�FOR fc : mission.findcolor SEPARATOR "," AFTER "]"��toText(fc.colors)��ENDFOR��"\n"�
		while (True):�"\n"� 
		�"\t"�speed = �toText(mission.speed)��"\n"�
		�randomMotor()�
		�"\t"�new_color = cs.color�"\n"�
		�"\t"�distance = us.value()/10�"\n"�
		�IF mission.avoid !== null�
		�"\t"�if �FOR obst : mission.avoid SEPARATOR " or " AFTER ":"��obstacles2Text(obst)��ENDFOR��"\n"�
		�avoidFunction()��ENDIF�
		�"\t"�if colorsToFind ==[] or �FOR stpc : mission.stopcons SEPARATOR " or " AFTER ":"��stopCon2Text(stpc)��ENDFOR��"\n"�
		�"\t"��"\t"�left_motor.stop()�"\n"�
		�"\t"��"\t"�right_motor.stop()�"\n"�
		�"\t"��"\t"�break�"\n"�
		�"\t"�if new_color in colorsToFind:�"\n"�
		�"\t"��"\t"�colorsToFind.remove(new_color)�"\n"�
		
	'''
	def static dispatch mission2Text(FollowLineMission mission)'''
		colorToFollow = �toText(mission.followColor)��"\n"�
		colorsToAvoid = [1,2,4,5]�"\n"�
		colorsToAvoid.remove(colorToFollow)�"\n"�
		while True:�"\n"�
		�"\t"�speed = �toText(mission.speed)��"\n"�
		�forwardMotor()�
		�"\t"�new_color = cs.color�"\n"�
		�"\t"�distance = us.value()/10�"\n"�
		�"\t"�if �FOR stpc : mission.stopcons SEPARATOR " or " AFTER ":"��stopCon2Text(stpc)��ENDFOR��"\n"�
		�"\t"��"\t"�left_motor.stop()�"\n"�
		�"\t"��"\t"�right_motor.stop()�"\n"�
		�"\t"��"\t"�break�"\n"�
		�"\t"�if new_color in colorsToAvoid:�"\n"�
		�"\t"��"\t"�left_motor.stop()�"\n"�
		�"\t"��"\t"�right_motor.stop()�"\n"�
		�"\t"��"\t"�curTime=0.1
		�"\t"��"\t"�leftForward=1
		�"\t"��"\t"�while new_color != colorToFollow:�"\n"�
		�"\t"��"\t"��"\t"�left_motor.on_for_seconds(SpeedPercent(leftForward), curTime,  block=False)�"\n"�
		�"\t"��"\t"��"\t"�right_motor.on_for_seconds(SpeedPercent(leftForward), curTime,  block=True)�"\n"�
		�"\t"��"\t"��"\t"�leftForward=leftForward*-1
		�"\t"��"\t"��"\t"�curtime+=0.1
		'''*/
		
	def static dispatch stopCon2Text(Obstacles obst)'''�obstacles2Text(obst)�'''
	
	def static dispatch stopCon2Text(TimeObject timeOb) '''lambda : time() - startTime> �timeOb.time�'''
	
	def static dispatch obstacles2Text(UseObstacle obst)'''�toStopText(obst.OE)�'''
	
	def static dispatch obstacles2Text(ColorWithName colorN)'''lambda : csLeft.color==�toText(colorN.color)� or csMid.color==�toText(colorN.color)� or csRight.color==�toText(colorN.color)�'''
	
	def static dispatch avoidCon2Text(UseObstacle obst)'''�toAvoidText(obst.OE)�'''
	
	def static dispatch avoidCon2Text(ColorWithName colorN)'''lambda : colorAvoid(�toText(colorN.color)�)'''
	
	def static dispatch stopCon2Text(ButtonPress button)'''�toText(button.buttonloc)� '''	
	def static trackCon2Text(TrackingOptions option) '''�toText(option)�'''
	
	def static CharSequence toStopText(ObstaclesEnum obst){
		switch(obst){
			case ObstaclesEnum:: BUMPER: return '''lambda : leftBumperUnsafe or rightBumperUnsafe'''
			case ObstaclesEnum:: OBJECT: return '''lambda : forwardSonarUnsafe'''
		}
	}
	
	def static CharSequence toAvoidText(ObstaclesEnum obst){
		switch(obst){
			case ObstaclesEnum:: BUMPER: return '''lambda : bumperChecker()'''
			case ObstaclesEnum:: OBJECT: return '''lambda : sonarChecker()'''
		}
	}
	
	def static CharSequence toText(TrackingOptions option){
		switch(option){
			case TrackingOptions::LAKES: return'''1'''
			case TrackingOptions::TIME: return '''2'''
			case TrackingOptions::BRICK: return '''3'''
		}
	}
	
	def static CharSequence toText(Color color){
		switch(color){
			case Color:: YELLOW: return '''4'''
			case Color:: BLUE: return '''2'''
			case Color:: RED: return '''5'''
			case Color:: BLACK: return '''1'''
			case Color:: WHITE: return '''6'''
		}
	}
		def static CharSequence toText(SpeedOptions speed){
		switch(speed){
			case SpeedOptions:: SLOW: return '''10'''
			case SpeedOptions:: MEDIUM: return '''15'''
			case SpeedOptions:: FAST: return '''20'''
		}
	}
		def static CharSequence toText(DirectionOptions dir){
		switch(dir){
			case DirectionOptions:: LEFT: return leftMotor()
			case DirectionOptions:: RIGHT: return rightMotor()
			case DirectionOptions:: FORWARD: return forwardMotor()
			case DirectionOptions:: BACKWARD: return backwardMotor()
			case DirectionOptions:: RANDOM: return randomMotor()
		}
	}
			def static CharSequence toText(Button button){
		switch(button){
			case Button:: LEFT: return '''lambda : btn.left'''
			case Button:: TOP: return '''lambda : btn.up'''
			case Button:: MID: return '''lambda : btn.center'''
			case Button:: RIGHT: return '''lambda : btn.right'''
			case Button:: DOWN: return '''lambda : btn.down'''
			case Button:: ANY: return '''lambda : btn.any()'''
		}
	}
	
			def static CharSequence toText(Boole bool){
		switch(bool){
			case Boole:: TRUE: return '''True'''
			case Boole:: FALSE: return '''False'''
		}
	}
	
		def static motorOptions()'''
			def leftMotor(prevTime):
				global motSpeed
				global standardSpeed
				motSpeed[0]=standardSpeed
				motSpeed[1]=-standardSpeed
				return prevTime

				
			def rightMotor(prevTime):
				global motSpeed
				global standardSpeed
				motSpeed[0]=-standardSpeed
				motSpeed[1]=standardSpeed
				return prevTime
				
			def forwardMotor(prevTime):
				global motSpeed
				global standardSpeed
				motSpeed[0]=standardSpeed
				motSpeed[1]=standardSpeed
				return prevTime
				
			def backwardMotor(prevTime):
				global motSpeed
				global standardSpeed
				motSpeed[0]=-standardSpeed
				motSpeed[1]=-standardSpeed
				return prevTime
				
			def randomMotor(prevTime):
				global standardSpeed
				global motSpeed
				if time()-prevTime<2:�"\n"�
				�"\t"�motSpeed[0]=random.randint(standardSpeed-5,standardSpeed+5)�"\n"�
				�"\t"�motSpeed[1]=random.randint(standardSpeed-5,standardSpeed+5)�"\n"�
				elif time()-prevTime>5:�"\n"�
				�"\t"�prevTime=time()�"\n"�
				return prevTime
		'''

		def static leftMotor()'''leftMotor(prevTime)'''
		
		def static rightMotor()'''rightMotor(prevTime)'''

		def static forwardMotor()'''forwardMotor(prevTime)'''

		def static backwardMotor()'''backwardMotor(prevTime)'''
		
		def static randomMotor()'''randomMotor(prevTime)'''
}