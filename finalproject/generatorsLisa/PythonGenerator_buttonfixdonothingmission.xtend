package dsl.finalproject.generator

import dsl.finalproject.fp.Button
import dsl.finalproject.fp.ButtonPress
import dsl.finalproject.fp.Color
import dsl.finalproject.fp.ColorWithName
import dsl.finalproject.fp.DirectionOptions
import dsl.finalproject.fp.DoNothingMission
import dsl.finalproject.fp.DriveMission
import dsl.finalproject.fp.FindLakesMission
import dsl.finalproject.fp.FollowLineMission
import dsl.finalproject.fp.Obstacles
import dsl.finalproject.fp.ObstaclesEnum
import dsl.finalproject.fp.SpeedOptions
import dsl.finalproject.fp.Task
import dsl.finalproject.fp.TimeObject
import dsl.finalproject.fp.TrackingOptions
import dsl.finalproject.fp.UseObstacle
import dsl.finalproject.fp.Mission

class PythonGenerator {
	def static toPy(Task root){
		'''
		«imports()»«"\n"»
		«blueToothCode()»«"\n"»
		«doNotFallOff()»«"\n"»
		«colorAvoid()»«"\n"»
		«motorModerator()»«"\n"»
		«stateSwitch()»«"\n"»
		«state2Text(root.mission)»«"\n"»
		«sensor2Text(root.mission)»«"\n"»
		«speedDef(root.mission)»
		«mainThread()»
		'''
	}
	
	def static dispatch speedDef(DoNothingMission Mission)'''
		global standardSpeed«"\n"»
		standardSpeed =0
	'''
	
	def static dispatch speedDef(DriveMission Mission)'''
		«normSpeedDef(Mission.speed)»
		'''
	
	def static normSpeedDef(SpeedOptions speed)'''
	global standardSpeed«"\n"»
	standardSpeed = «toText(speed)»
	'''
	
	def static imports()'''
		#!/usr/bin/env python3«"\n"»
		«"\n"»
		import ev3dev.auto as ev3«"\n"»
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
		global backUnsafe«"\n"»
		global forwardCLUnsafe«"\n"»
		global forwardCRUnsafe«"\n"»
		global forwardCMUnsafe«"\n"»
		global leftBumperUnsafe«"\n"»
		global rightBumperUnsafe«"\n"»
		global forwardSonarUnsafe«"\n"»
		«"\n"»
		print("Start!")«"\n"»
		backUnsafe=False«"\n"»
		forwardCLUnsafe=False«"\n"»
		forwardCRUnsafe=False«"\n"»
		forwardCMUnsafe=False«"\n"»
		leftBumperUnsafe=False«"\n"»
		rightBumperUnsafe=False«"\n"»
		forwardSonarUnsafe=False«"\n"»
		«"\n"»
		global motLeftSpeed«"\n"»
		global motRightSpeed«"\n"»
		«"\n"»
		motorCommand = 'Stop'«"\n"»
		motSpeed =[0,0]«"\n"»
		global ending
		ending= False«"\n"»
		«"\n"»
		stopColors= [0,2,3,5,6]«"\n"»
		left_motor = LargeMotor(OUTPUT_A)«"\n"»
		right_motor = LargeMotor(OUTPUT_D)«"\n"»
		measurement_arm = Motor(OUTPUT_B)«"\n"»
		leds = Leds()«"\n"»
		s = Sound()«"\n"»
		csLeft = ColorSensor(INPUT_1)«"\n"»
		csMid = ColorSensor(INPUT_3)«"\n"»
		csRight = ColorSensor(INPUT_4)«"\n"»
		leds.set_color("LEFT", "GREEN")«"\n"»
		leds.set_color("RIGHT", "GREEN")«"\n"»
		us = UltrasonicSensor()«"\n"»
		us.mode = 'US-DIST-CM'«"\n"»
		units = us.units«"\n"»
		distance = us.value()«"\n"»
		my_display = Display()«"\n"»
		my_display.clear()«"\n"»
		btn = ev3.Button()«"\n"»
		«"\n"»
		server_mac = 'CC:78:AB:50:B2:46'«"\n"»
		sock, sock_in, sock_out = connect(server_mac)«"\n"»
		senMod = threading.Thread(target=sensorModerator, args=())«"\n"»
		statMod = threading.Thread(target=stateModerator, args=())«"\n"»
		motMod = threading.Thread(target=motorModerator, args=())«"\n"»
		blueMod = threading.Thread(target=listen, args=(sock_in,))«"\n"»
		blueMod.start()«"\n"»
		senMod.start()«"\n"»
		sleep(1)«"\n"»
		statMod.start()«"\n"»
		motMod.start()«"\n"»
		senMod.join()«"\n"»
		sendInfo(sock_out, 2)«"\n"»
		blueMod.join()«"\n"»
		disconnect(sock_in)«"\n"»
		disconnect(sock_out)«"\n"»
		disconnect(sock)«"\n"»
		statMod.join()«"\n"»
		motMod.join()«"\n"»
		print("Finished")«"\n"»
		sleep(5)«"\n"»
	'''
	
	def static blueToothCode()'''
		def connect(server_mac):«"\n"»
		«"\t"»port = 3«"\n"»
		«"\t"»server_sock = bluetooth.BluetoothSocket(bluetooth.RFCOMM)«"\n"»
		«"\t"»server_sock.bind((server_mac, port))«"\n"»
		«"\t"»server_sock.listen(1)«"\n"»
		«"\t"»print('Listening...')«"\n"»
		«"\t"»client_sock, address = server_sock.accept()«"\n"»
		«"\t"»print('Accepted connection from ', address)«"\n"»
		«"\t"»return client_sock, client_sock.makefile('r'), client_sock.makefile('w')«"\n"»
		«"\n"»
		def disconnect(sock):«"\n"»
		«"\t"»sock.close()«"\n"»
		«"\n"»
		def listen(sock_in):«"\n"»
		«"\t"»global ending«"\n"»
		«"\t"»global leftBumperUnsafe
		«"\t"»global rightBumperUnsafe«"\n"»
		«"\t"»global forwardSonarUnsafe«"\n"»
		«"\t"»print('Now listening...')«"\n"»
		«"\t"»while True:«"\n"»
		«"\t"»«"\t"»data = int(sock_in.readline())«"\n"»
		«"\t"»«"\t"»if data==1:«"\n"»
		«"\t"»«"\t"»«"\t"»leftBumperUnsafe=True«"\n"»
		«"\t"»«"\t"»«"\t"»print("Left hit")«"\n"»
		«"\t"»«"\t"»if data==2:«"\n"»
		«"\t"»«"\t"»«"\t"»leftBumperUnsafe=False«"\n"»
		«"\t"»«"\t"»«"\t"»print("Left no longer hit")«"\n"»
		«"\t"»«"\t"»elif data==3:«"\n"»
		«"\t"»«"\t"»«"\t"»rightBumperUnsafe=True«"\n"»
		«"\t"»«"\t"»«"\t"»print("right hit")«"\n"»
		«"\t"»«"\t"»elif data==4:«"\n"»
		«"\t"»«"\t"»«"\t"»rightBumperUnsafe=False«"\n"»
		«"\t"»«"\t"»«"\t"»print("right no longer hit")«"\n"»
		«"\t"»«"\t"»elif data==5:«"\n"»
		«"\t"»«"\t"»«"\t"»forwardSonarUnsafe=True«"\n"»
		«"\t"»«"\t"»«"\t"»print("sonar hit. Somehow. Not quite sure how.")«"\n"»
		«"\t"»«"\t"»elif data==6:«"\n"»
		«"\t"»«"\t"»«"\t"»forwardSonarUnsafe=False«"\n"»
		«"\t"»«"\t"»«"\t"»print("sonar no longer hit. That makes more sense")«"\n"»
		«"\t"»«"\t"»elif data==7:«"\n"»
		«"\t"»«"\t"»«"\t"»print("Other one is ending, I will end now too")«"\n"»
		«"\t"»«"\t"»sleep(1)«"\n"»
		«"\t"»«"\t"»if ending:«"\n"»
		«"\t"»«"\t"»«"\t"»break«"\n"»
		«"\n"»
		def sendInfo(sock_out, message):«"\n"»
		«"\t"»sock_out.write(str(message)+ '\n')«"\n"»
		«"\t"»sock_out.flush()«"\n"»
		'''

	def static doNotFallOff()'''
		def doNotFallOff():«"\n"»
		«"\t"»global backUnsafe«"\n"»
		«"\t"»global forwardCLUnsafe«"\n"»
		«"\t"»global forwardCRUnsafe«"\n"»
		«"\t"»global forwardCMUnsafe«"\n"»
		«"\t"»new_colorLeft = csLeft.color«"\n"»
		«"\t"»new_colorMid = csMid.color«"\n"»
		«"\t"»new_colorRight = csRight.color«"\n"»
		«"\t"»distance = us.value()/10«"\n"»
		«"\t"»if new_colorLeft==0:«"\n"»
		«"\t"»«"\t"»forwardCLUnsafe=True«"\n"»
		«"\t"»else:«"\n"»
		«"\t"»«"\t"»forwardCLUnsafe=False«"\n"»
		«"\t"»if new_colorMid==0:«"\n"»
		«"\t"»«"\t"»forwardCMUnsafe=True«"\n"»
		«"\t"»else:«"\n"»
		«"\t"»«"\t"»forwardCMUnsafe=False«"\n"»
		«"\t"»if new_colorRight==0:«"\n"»
		«"\t"»«"\t"»forwardCRUnsafe=True«"\n"»
		«"\t"»else:«"\n"»
		«"\t"»«"\t"»forwardCRUnsafe=False«"\n"»
		«"\t"»if distance>4:«"\n"»
		«"\t"»«"\t"»backUnsafe=True«"\n"»
		«"\t"»else:«"\n"»
		«"\t"»«"\t"»backUnsafe=False«"\n"»
	'''
	
	def static motorModerator()'''
		def motorModerator():«"\n"»
		«"\t"»global ending«"\n"»
		«"\t"»while True:«"\n"»
		«"\t"»«"\t"»global motSpeed«"\n"»
		«"\t"»«"\t"»if motSpeed[0]==0:
		«"\t"»«"\t"»«"\t"»left_motor.stop()«"\n"»
		«"\t"»«"\t"»else:
		«"\t"»«"\t"»«"\t"»left_motor.on_for_seconds(SpeedPercent(motSpeed[0]), 1,  block=False)«"\n"»
		«"\t"»«"\t"»if motSpeed[1]==0:
		«"\t"»«"\t"»«"\t"»right_motor.stop()«"\n"»
		«"\t"»«"\t"»else:
		«"\t"»«"\t"»«"\t"»right_motor.on_for_seconds(SpeedPercent(motSpeed[1]), 1,  block=False)«"\n"»
		«"\t"»«"\t"»if ending:«"\n"»
		«"\t"»«"\t"»«"\t"»left_motor.stop()«"\n"»
		«"\t"»«"\t"»«"\t"»right_motor.stop()«"\n"»
		«"\t"»«"\t"»«"\t"»break«"\n"»
		«"\t"»«"\t"»sleep(0.1)«"\n"»
	'''
	
	def static colorAvoid()'''
	def colorAvoid(color):«"\n"»
	«"\t"»global forwardCLUnsafe«"\n"»
	«"\t"»global forwardCRUnsafe«"\n"»
	«"\t"»global forwardCMUnsafe«"\n"»
	«"\t"»new_colorLeft = csLeft.color«"\n"»
	«"\t"»new_colorMid = csMid.color«"\n"»
	«"\t"»new_colorRight = csRight.color«"\n"»
	«"\t"»if new_colorLeft==color:«"\n"»
	«"\t"»«"\t"»forwardCLUnsafe=True«"\n"»
	«"\t"»else:«"\n"»
	«"\t"»«"\t"»forwardCLUnsafe=False«"\n"»
	«"\t"»if new_colorMid==color:«"\n"»
	«"\t"»«"\t"»forwardCMUnsafe=True«"\n"»
	«"\t"»else:«"\n"»
	«"\t"»«"\t"»forwardCMUnsafe=False«"\n"»
	«"\t"»if new_colorRight==color:«"\n"»
	«"\t"»«"\t"»forwardCRUnsafe=True«"\n"»
	«"\t"»else:«"\n"»
	«"\t"»«"\t"»forwardCRUnsafe=False«"\n"»
	'''
	
	def static stateSwitch()'''
	def stateExp():«"\n"»
	«"\t"»global backUnsafe«"\n"»
	«"\t"»global forwardCLUnsafe«"\n"»
	«"\t"»global forwardCRUnsafe«"\n"»
	«"\t"»global forwardCMUnsafe«"\n"»
	«"\t"»global leftBumperUnsafe«"\n"»
	«"\t"»global rightBumperUnsafe«"\n"»
	«"\t"»global forwardSonarUnsafe«"\n"»
	«"\t"»if backUnsafe and (forwardCMUnsafe or forwardCLUnsafe or forwardCRUnsafe):«"\n"»
	«"\t"»«"\t"»return 'DesperateTurn'«"\n"»
	«"\t"»elif backUnsafe:«"\n"»
	«"\t"»«"\t"»return 'BackDepthAvoidance'«"\n"»
	«"\t"»elif forwardCMUnsafe:«"\n"»
	«"\t"»«"\t"»return 'ForwardMidDepthAvoidance'«"\n"»
	«"\t"»elif forwardCLUnsafe:«"\n"»
	«"\t"»«"\t"»return 'ForwardLeftDepthAvoidance'«"\n"»
	«"\t"»elif forwardCRUnsafe:«"\n"»
	«"\t"»«"\t"»return 'ForwardRightDepthAvoidance'«"\n"»
	«"\t"»elif leftBumperUnsafe:«"\n"»
	«"\t"»«"\t"»return 'LeftBumperAvoidance'«"\n"»
	«"\t"»elif rightBumperUnsafe:«"\n"»
	«"\t"»«"\t"»return 'RightBumperAvoidance'«"\n"»
	«"\t"»elif forwardSonarUnsafe:«"\n"»
	«"\t"»«"\t"»return 'ForwardDepthAvoidance'«"\n"»
	«"\t"»return ''«"\n"»
	«"\n"»
	def stateObstacle():
	«"\t"»global backUnsafe«"\n"»
	«"\t"»global forwardCLUnsafe«"\n"»
	«"\t"»global forwardCRUnsafe«"\n"»
	«"\t"»global forwardCMUnsafe«"\n"»
	«"\t"»global leftBumperUnsafe«"\n"»
	«"\t"»global rightBumperUnsafe«"\n"»
	«"\t"»global forwardSonarUnsafe«"\n"»
	«"\t"»if backUnsafe and (forwardCMUnsafe or forwardCLUnsafe or forwardCRUnsafe):«"\n"»
	«"\t"»«"\t"»return 'DesperateTurn'«"\n"»
	«"\t"»elif backUnsafe:«"\n"»
	«"\t"»«"\t"»return 'BackDepthAvoidance'«"\n"»
	«"\t"»elif forwardCMUnsafe:«"\n"»
	«"\t"»«"\t"»return 'ForwardMidDepthAvoidance'«"\n"»
	«"\t"»elif forwardCLUnsafe:«"\n"»
	«"\t"»«"\t"»return 'ForwardLeftDepthAvoidance'«"\n"»
	«"\t"»elif forwardCRUnsafe:«"\n"»
	«"\t"»«"\t"»return 'ForwardRightDepthAvoidance'«"\n"»
	«"\t"»elif leftBumperUnsafe:«"\n"»
	«"\t"»«"\t"»return 'LeftBumperAvoidance'«"\n"»
	«"\t"»elif rightBumperUnsafe:«"\n"»
	«"\t"»«"\t"»return 'RightBumperAvoidance'«"\n"»
	«"\t"»return ''«"\n"»
	«"\n"»
	def stateBumper():
	«"\t"»global backUnsafe«"\n"»
	«"\t"»global forwardCLUnsafe«"\n"»
	«"\t"»global forwardCRUnsafe«"\n"»
	«"\t"»global forwardCMUnsafe«"\n"»
	«"\t"»global leftBumperUnsafe«"\n"»
	«"\t"»global rightBumperUnsafe«"\n"»
	«"\t"»global forwardSonarUnsafe«"\n"»
	«"\t"»if backUnsafe and (forwardCMUnsafe or forwardCLUnsafe or forwardCRUnsafe):«"\n"»
	«"\t"»«"\t"»return 'DesperateTurn'«"\n"»
	«"\t"»elif backUnsafe:«"\n"»
	«"\t"»«"\t"»return 'BackDepthAvoidance'«"\n"»
	«"\t"»elif forwardCMUnsafe:«"\n"»
	«"\t"»«"\t"»return 'ForwardMidDepthAvoidance'«"\n"»
	«"\t"»elif forwardCLUnsafe:«"\n"»
	«"\t"»«"\t"»return 'ForwardLeftDepthAvoidance'«"\n"»
	«"\t"»elif forwardCRUnsafe:«"\n"»
	«"\t"»«"\t"»return 'ForwardRightDepthAvoidance'«"\n"»
	«"\t"»return ''«"\n"»
	«"\n"»
	def stateF():«"\n"»
	«"\t"»global backUnsafe«"\n"»
	«"\t"»global forwardCLUnsafe«"\n"»
	«"\t"»global forwardCRUnsafe«"\n"»
	«"\t"»global forwardCMUnsafe«"\n"»
	«"\t"»if backUnsafe:«"\n"»
	«"\t"»«"\t"»return 'DesperateTurn'«"\n"»
	«"\t"»else:«"\n"»
	«"\t"»«"\t"»return ''«"\n"»
	«"\n"»
	def stateBD():«"\n"»
	«"\t"»global backUnsafe«"\n"»
	«"\t"»global forwardCLUnsafe«"\n"»
	«"\t"»global forwardCRUnsafe«"\n"»
	«"\t"»global forwardCMUnsafe«"\n"»
	«"\t"»if forwardCLUnsafe or forwardCRUnsafe or forwardCMUnsafe:«"\n"»
	«"\t"»«"\t"»return 'DesperateTurn'«"\n"»
	«"\t"»else:«"\n"»
	«"\t"»«"\t"»return ''«"\n"»
    '''
    
    def static dispatch state2Text(DoNothingMission Mission)'''
    def stateModerator():
    «"\t"»global ending«"\n"»
    «"\t"»while True:«"\n"»
    «"\t"»«"\t"»if ending:«"\n"»
    «"\t"»«"\t"»«"\t"»break«"\n"»
    '''

    
    def static dispatch state2Text(DriveMission Mission)'''
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
        return nextState if not (nextState=='') else curState
    
    def expMot(curTime):
        global motSpeed
        global backUnsafe
        global forwardCLUnsafe
        global forwardCRUnsafe
        global forwardCMUnsafe
        «toText(Mission.dir)»
        return curTime, 'Exploring'
        
    def bdMot(curTime):
        global motSpeed
        global backUnsafe
        global forwardCLUnsafe
        global forwardCRUnsafe
        global forwardCMUnsafe
        if backUnsafe:
            motSpeed[0]=standardSpeed
            motSpeed[1]=standardSpeed
            return curTime, 'BackDepthAvoidance'
        motSpeed =[0,0]
        return time(), 'Exploring'
        
    def flMot(curTime):
        global motSpeed
        global backUnsafe
        global forwardCLUnsafe
        global forwardCRUnsafe
        global forwardCMUnsafe
        if forwardCLUnsafe:
            motSpeed[0]=-standardSpeed
            motSpeed[1]=-standardSpeed
            curTime=time()
            return curTime, 'ForwardLeftDepthAvoidance'
        elif (int(time()) - curTime)<0.5:
        	motSpeed[0]=5
        	motSpeed[1]=-5
        	return curTime, 'ForwardLeftDepthAvoidance'
        motSpeed =[0,0]
        return time(), 'Exploring'
        
    def fmMot(curTime):
        global motSpeed
        global backUnsafe
        global forwardCLUnsafe
        global forwardCRUnsafe
        global forwardCMUnsafe
        if forwardCMUnsafe:
            motSpeed[0]=-standardSpeed
            motSpeed[1]=-standardSpeed
            curTime=time()
            return curTime, 'ForwardMidDepthAvoidance'
        elif (int(time()) - curTime)<0.5:
            motSpeed[0]=5
            motSpeed[1]=-5
            return curTime, 'ForwardMidDepthAvoidance'
        motSpeed =[0,0]
        return time(), 'Exploring'
        
    def frMot(curTime):
        global motSpeed
        global backUnsafe
        global forwardCLUnsafe
        global forwardCRUnsafe
        global forwardCMUnsafe
        if forwardCRUnsafe:
            motSpeed[0]=-standardSpeed
            motSpeed[1]=-standardSpeed
            curTime=time()
            return curTime, 'ForwardRightDepthAvoidance'
        elif (int(time()) - curTime)<0.5:
            motSpeed[0]=-5
            motSpeed[1]=5
            return curTime, 'ForwardRightDepthAvoidance'
        motSpeed =[0,0]
        return time(), 'Exploring'
        
    def lbMot(curTime):
            global motSpeed
            global leftBumperUnsafe«"\n"»
            global rightBumperUnsafe«"\n"»
            global forwardSonarUnsafe«"\n"»
            if leftBumperUnsafe:
                motSpeed[0]=-standardSpeed
                motSpeed[1]=-standardSpeed
                curTime=time()
                return curTime, 'LeftBumperAvoidance'
            elif (int(time()) - curTime)<0.5:
            	motSpeed[0]=5
            	motSpeed[1]=-5
            	return curTime, 'LeftBumperAvoidance'
            motSpeed =[0,0]
            return time(), 'Exploring'
            
    def fdMot(curTime):
        global motSpeed
        global leftBumperUnsafe«"\n"»
        global rightBumperUnsafe«"\n"»
        global forwardSonarUnsafe«"\n"»
        if forwardSonarUnsafe:
            motSpeed[0]=-standardSpeed
            motSpeed[1]=-standardSpeed
            curTime=time()
            return curTime, 'ForwardDepthAvoidance'
        elif (int(time()) - curTime)<0.5:
            motSpeed[0]=5
            motSpeed[1]=-5
            return curTime, 'ForwardDepthAvoidance'
        motSpeed =[0,0]
        return time(), 'Exploring'
            
    def rbMot(curTime):
        global motSpeed
        global leftBumperUnsafe«"\n"»
        global rightBumperUnsafe«"\n"»
        global forwardSonarUnsafe«"\n"»
        if rightBumperUnsafe:
            motSpeed[0]=-standardSpeed
            motSpeed[1]=-standardSpeed
            curTime=time()
            return curTime, 'RightBumperAvoidance'
        elif (int(time()) - curTime)<0.5:
            motSpeed[0]=-5
            motSpeed[1]=5
            return curTime, 'RightBumperAvoidance'
        motSpeed =[0,0]
        return time(), 'Exploring'
    
    def despTurn(curTime):
        global motSpeed
        global backUnsafe
        global forwardCLUnsafe
        global forwardCRUnsafe
        global forwardCMUnsafe
        if backUnsafe and (forwardCMUnsafe or forwardCLUnsafe or forwardCRUnsafe):
            motSpeed[0]=5
            motSpeed[1]=-5
            return curTime, 'DesperateTurn'
        motSpeed =[0,0]
        return time(), 'Exploring'
    
    def stateModerator():
    «"\t"»global ending«"\n"»
    «"\t"»global motSpeed«"\n"»
    «"\t"»curState= 'Exploring'«"\n"»
    «"\t"»nextState='Exploring'«"\n"»
    «"\t"»curTime = time()«"\n"»
    «"\t"»while True:«"\n"»
    «"\t"»«"\t"»nextState = determineState(curState)«"\n"»
    «"\t"»«"\t"»if nextState!=curState:«"\n"»
    «"\t"»«"\t"»«"\t"»curTime = time()«"\n"»
    «"\t"»«"\t"»if nextState=="Exploring":«"\n"»
    «"\t"»«"\t"»«"\t"»curTime, curState=expMot(curTime)«"\n"»
    «"\t"»«"\t"»elif nextState=="LeftBumperAvoidance":
    «"\t"»«"\t"»«"\t"»curTime, curState = lbMot(curTime)
    «"\t"»«"\t"»elif nextState=="RightBumperAvoidance":
    «"\t"»«"\t"»«"\t"»curTime, curState = rbMot(curTime)
    «"\t"»«"\t"»elif nextState=="ForwardDepthAvoidance":
    «"\t"»«"\t"»«"\t"»curTime, curState = fdMot(curTime)
    «"\t"»«"\t"»elif nextState== "BackDepthAvoidance":«"\n"»
    «"\t"»«"\t"»«"\t"»curTime, curState=bdMot(curTime)«"\n"»
    «"\t"»«"\t"»elif nextState== "ForwardLeftDepthAvoidance":«"\n"»
    «"\t"»«"\t"»«"\t"»curTime, curState=flMot(curTime)«"\n"»
    «"\t"»«"\t"»elif nextState== "ForwardMidDepthAvoidance":«"\n"»
    «"\t"»«"\t"»«"\t"»curTime, curState=fmMot(curTime)«"\n"»
    «"\t"»«"\t"»elif nextState== "ForwardRightDepthAvoidance":«"\n"»
    «"\t"»«"\t"»«"\t"»curTime, curState=frMot(curTime)«"\n"»
    «"\t"»«"\t"»elif nextState== "DesperateTurn":«"\n"»
    «"\t"»«"\t"»«"\t"»curTime, curState=despTurn(curTime)«"\n"»
    «"\t"»«"\t"»if ending:«"\n"»
    «"\t"»«"\t"»«"\t"»break«"\n"»
    «"\t"»«"\t"»sleep(0.1)«"\n"»
    '''
	
	def static dispatch sensor2Text(DriveMission Mission)'''
		def sensorModerator():«"\n"»
		«"\t"»global ending«"\n"»
		«"\t"»curTime=time()«"\n"»
		«"\t"»while True:
		«"\t"»«"\t"»doNotFallOff()
		«"\t"»«"\t"»new_colorLeft = csLeft.color
		«"\t"»«"\t"»new_colorMid = csMid.color
		«"\t"»«"\t"»new_colorRight = csRight.color
		«"\t"»«"\t"»if «FOR stpc : Mission.stopcons SEPARATOR " or " AFTER ":"»«stopCon2Text(stpc)»«ENDFOR»«"\n"»
		«"\t"»«"\t"»«"\t"»break«"\n"»
		«IF Mission.avoid !== null»
		«FOR avoidC : Mission.avoid»
		«avoidToText(avoidC)»
		«ENDFOR»
		«ENDIF»
		«"\t"»ending=True«"\n"»
		'''
	
	def static dispatch sensor2Text(DoNothingMission Mission)'''
		def sensorModerator():«"\n"»
		«"\t"»global ending«"\n"»
		«"\t"»curTime=time()«"\n"»
		«"\t"»while True:«"\n"»
		«IF Mission.offB !== null»
		«"\t"»«"\t"»if «FOR btnElement : Mission.offB SEPARATOR " or " AFTER ":"»«toText(btnElement.buttons)»«ENDFOR»«"\n"»
		«"\t"»«"\t"»«"\t"»break«"\n"»«ENDIF»
		«"\t"»«"\t"»if (int(time()) - curTime)>«Mission.time»:«"\n"»
		«"\t"»«"\t"»«"\t"»break«"\n"»
		«"\t"»ending=True«"\n"»
		'''
		
	def static dispatch avoidToText(UseObstacle avoidC)''''''
	
	def static dispatch avoidToText(ColorWithName avoidC)'''
	«"\t"»«"\t"»colorAvoid(«toText(avoidC.color)»)«"\n"»
	'''
/* 
	def static dispatch mission2Text(DriveMission mission)'''
		while (True):«"\n"» 
		«"\t"»speed = «toText(mission.speed)»«"\n"»
		«toText(mission.dir)»
		«"\t"»new_color = cs.color«"\n"»
		«"\t"»distance = us.value()/10«"\n"»
		«IF mission.avoid !== null»
		«"\t"»if «FOR obst : mission.avoid SEPARATOR " or " AFTER ":"»«obstacles2Text(obst)»«ENDFOR»«"\n"»
		«avoidFunction()»«ENDIF»
		«"\t"»if «FOR stpc : mission.stopcons SEPARATOR " or " AFTER ":"»«stopCon2Text(stpc)»«ENDFOR»«"\n"»
		«"\t"»«"\t"»left_motor.stop()«"\n"»
		«"\t"»«"\t"»right_motor.stop()«"\n"»
		«"\t"»«"\t"»break«"\n"»'''
	
	def static dispatch mission2Text(DoNothingMission mission)'''
		while (int(time.time()) - currenttime)> «mission.time»:«"\n"»
		«"\t"»time.sleep(1)«"\n"»
	'''
	def static dispatch mission2Text(FindLakesMission mission)'''
		colorsToFind = [«FOR fc : mission.findcolor SEPARATOR "," AFTER "]"»«toText(fc.colors)»«ENDFOR»«"\n"»
		while (True):«"\n"» 
		«"\t"»speed = «toText(mission.speed)»«"\n"»
		«randomMotor()»
		«"\t"»new_color = cs.color«"\n"»
		«"\t"»distance = us.value()/10«"\n"»
		«IF mission.avoid !== null»
		«"\t"»if «FOR obst : mission.avoid SEPARATOR " or " AFTER ":"»«obstacles2Text(obst)»«ENDFOR»«"\n"»
		«avoidFunction()»«ENDIF»
		«"\t"»if colorsToFind ==[] or «FOR stpc : mission.stopcons SEPARATOR " or " AFTER ":"»«stopCon2Text(stpc)»«ENDFOR»«"\n"»
		«"\t"»«"\t"»left_motor.stop()«"\n"»
		«"\t"»«"\t"»right_motor.stop()«"\n"»
		«"\t"»«"\t"»break«"\n"»
		«"\t"»if new_color in colorsToFind:«"\n"»
		«"\t"»«"\t"»colorsToFind.remove(new_color)«"\n"»
		
	'''
	def static dispatch mission2Text(FollowLineMission mission)'''
		colorToFollow = «toText(mission.followColor)»«"\n"»
		colorsToAvoid = [1,2,4,5]«"\n"»
		colorsToAvoid.remove(colorToFollow)«"\n"»
		while True:«"\n"»
		«"\t"»speed = «toText(mission.speed)»«"\n"»
		«forwardMotor()»
		«"\t"»new_color = cs.color«"\n"»
		«"\t"»distance = us.value()/10«"\n"»
		«"\t"»if «FOR stpc : mission.stopcons SEPARATOR " or " AFTER ":"»«stopCon2Text(stpc)»«ENDFOR»«"\n"»
		«"\t"»«"\t"»left_motor.stop()«"\n"»
		«"\t"»«"\t"»right_motor.stop()«"\n"»
		«"\t"»«"\t"»break«"\n"»
		«"\t"»if new_color in colorsToAvoid:«"\n"»
		«"\t"»«"\t"»left_motor.stop()«"\n"»
		«"\t"»«"\t"»right_motor.stop()«"\n"»
		«"\t"»«"\t"»curTime=0.1
		«"\t"»«"\t"»leftForward=1
		«"\t"»«"\t"»while new_color != colorToFollow:«"\n"»
		«"\t"»«"\t"»«"\t"»left_motor.on_for_seconds(SpeedPercent(leftForward), curTime,  block=False)«"\n"»
		«"\t"»«"\t"»«"\t"»right_motor.on_for_seconds(SpeedPercent(leftForward), curTime,  block=True)«"\n"»
		«"\t"»«"\t"»«"\t"»leftForward=leftForward*-1
		«"\t"»«"\t"»«"\t"»curtime+=0.1
		'''*/
		
	def static dispatch stopCon2Text(Obstacles obst)'''«obstacles2Text(obst)»'''
	
	def static dispatch stopCon2Text(TimeObject timeOb) '''(int(time()) - curTime)> «timeOb.time»'''
	
	def static dispatch obstacles2Text(UseObstacle obst)'''«toText(obst.OE)»'''
	
	def static dispatch obstacles2Text(ColorWithName colorN)'''new_colorLeft==«toText(colorN.color)» or new_colorMid==«toText(colorN.color)» or new_colorRight==«toText(colorN.color)»'''
	
	def static dispatch stopCon2Text(ButtonPress button)'''«toText(button.buttonloc)» '''	
	
	def static CharSequence toText(ObstaclesEnum obst){
		switch(obst){
			case ObstaclesEnum:: BUMPER: return bumperFunction()
			case ObstaclesEnum:: OBJECT: return objectFunction()
		}
	}
	
	def static CharSequence toText(TrackingOptions option){
		switch(option){
			case TrackingOptions::LAKES: return''''''
			case TrackingOptions::TIME: return ''''''
			case TrackingOptions::BRICK: return ''''''
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
			case SpeedOptions:: NOT_MOVING: return '''0'''
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
			case Button:: LEFT: return '''btn.left'''
			case Button:: TOP: return '''btn.up'''
			case Button:: MID: return '''btn.center'''
			case Button:: RIGHT: return '''btn.right'''
			case Button:: DOWN: return '''btn.down'''
			case Button:: ANY: return '''btn.any'''
		}
	}

		def static leftMotor()'''
			left_motor.on_for_seconds(SpeedPercent(standardSpeed), 1,  block=False)«"\n"»
			right_motor.on_for_seconds(SpeedPercent(-standardSpeed), 1,  block=False)«"\n"»
		'''
		def static rightMotor()'''
			left_motor.on_for_seconds(SpeedPercent(-standardSpeed), 1,  block=False)«"\n"»
			right_motor.on_for_seconds(SpeedPercent(standardSpeed), 1,  block=False)«"\n"»
		'''
		def static forwardMotor()'''
			left_motor.on_for_seconds(SpeedPercent(standardSpeed), 1,  block=False)«"\n"»
			right_motor.on_for_seconds(SpeedPercent(standardSpeed), 1,  block=False)«"\n"»
		'''
		def static backwardMotor()'''
			left_motor.on_for_seconds(SpeedPercent(-standardSpeed), 1,  block=False)«"\n"»
			right_motor.on_for_seconds(SpeedPercent(-standardSpeed), 1,  block=False)«"\n"»
		'''
		def static randomMotor()'''
			if time()-curTime<2:«"\n"»
			«"\t"»motSpeed[0]=random.randint(standardSpeed-5,standardSpeed+5)«"\n"»
			«"\t"»motSpeed[1]=random.randint(standardSpeed-5,standardSpeed+5)«"\n"»
			elif time()-curTime>5:«"\n"»
			«"\t"»curTime=time()«"\n"»
		'''
	
		def static avoidFunction()'''
			«"\t"»«"\t"»left_motor.stop()«"\n"»
			«"\t"»«"\t"»right_motor.stop()«"\n"»
			«"\t"»«"\t"»leds.set_color("LEFT", "RED")«"\n"»
			«"\t"»«"\t"»leds.set_color("RIGHT", "RED") «"\n"»
			«"\t"»«"\t"»left_motor.on_for_seconds(SpeedPercent(-10), 0.5,  block=False)«"\n"»
			«"\t"»«"\t"»right_motor.on_for_seconds(SpeedPercent(-10), 0.5,  block=True)«"\n"»
			«"\t"»«"\t"»choice = random.randint(1,3)«"\n"»
			«"\t"»«"\t"»if choice==1:«"\n"»
			«"\t"»«"\t"»«"\t"»left_motor.on_for_seconds(SpeedPercent(-20), 1, block=True)«"\n"»
			«"\t"»«"\t"»else:«"\n"»
			«"\t"»«"\t"»«"\t"»right_motor.on_for_seconds(SpeedPercent(-20), 1, block=True)«"\n"»
		'''
		def static bumperFunction()'''tsLeft.is_pressed or tsRight.is_pressed'''
		
		def static objectFunction()'''distance < 28'''
}