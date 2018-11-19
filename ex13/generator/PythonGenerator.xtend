package lego.rover.generator

import lego.rover.rdsl.Color
import lego.rover.rdsl.DirectionOptions
import lego.rover.rdsl.DoNothingMission
import lego.rover.rdsl.DriveMission
import lego.rover.rdsl.FindColorsMission
import lego.rover.rdsl.FollowLineMission
import lego.rover.rdsl.Obstacles
import lego.rover.rdsl.ObstaclesEnum
import lego.rover.rdsl.SpeedOptions
import lego.rover.rdsl.Task

class PythonGenerator {
	def static toPy(Task root){
		'''
		#!/usr/bin/env python3
		«"\n"»
		«onStartUp()»
		«mission2Text(root.mission)»
		'''
	}
	def static onStartUp()'''
			from ev3dev2.motor import LargeMotor, OUTPUT_A, OUTPUT_D, SpeedPercent«"\n"»
			from ev3dev2.sound import Sound«"\n"»
			from ev3dev2.display import Display«"\n"»
			from ev3dev2.sensor.lego import ColorSensor«"\n"»
			from ev3dev2.sensor.lego import TouchSensor«"\n"»
			from ev3dev2._platform.ev3 import INPUT_4, INPUT_1«"\n"»
			from ev3dev2.led import Leds«"\n"»
			from ev3dev2.sensor.lego import UltrasonicSensor«"\n"»
			import random«"\n"»
			import time«"\n"»
			«"\n"»
			colors_found = [False, False, False, False]«"\n"»
			left_motor = LargeMotor(OUTPUT_A)«"\n"»
			right_motor = LargeMotor(OUTPUT_D)«"\n"»
			tsLeft = TouchSensor(INPUT_1)«"\n"»
			tsRight = TouchSensor(INPUT_4)«"\n"»
			leds = Leds()«"\n"»
			s = Sound()«"\n"»
			cs = ColorSensor()«"\n"»
			speedLeft=0«"\n"»
			speedRight=0«"\n"»
			leds.set_color("LEFT", "GREEN")«"\n"»
			leds.set_color("RIGHT", "GREEN") «"\n"»
			us = UltrasonicSensor()«"\n"»
			us.mode = 'US-DIST-CM'«"\n"»
			units = us.units«"\n"»
			distance = us.value()«"\n"»
			my_display = Display()«"\n"»
			my_display.clear()«"\n"»
			cs.calibrate_white()«"\n"»
			currenttime = int(time.time())«"\n"»
	'''
	def static dispatch mission2Text(DriveMission mission)'''
			while (True):«"\n"» 
			«"\t"»speed = «mission.speed»«"\n"»
			«"\t"»«mission.dir»«"\n"»
			«IF mission.avoid !== null»
			«"\t"»«avoid2Text(mission.avoid)»«ENDIF»
			«"\t"»«"\t"»«"\n"»
	'''
	def static dispatch avoid2Text(Obstacles obst)'''
			«obstacles2Text(obst.stopcon1)»
	'''
	def static dispatch avoid2Text(int time) '''
		if (int(time.time()) - currenttime)> «time»:«"\n"»
	'''
	
	def static dispatch obstacles2Text(ObstaclesEnum obst)'''
			«toText(obst)»
	'''
	
	def static dispatch obstacles2Text(Color color)'''
			«toText(color)»
			'''

	def static dispatch mission2Text(DoNothingMission mission)'''
			while (int(time.time()) - currenttime)> «mission.time»:«"\n"»
			«"\t"»time.sleep(1)«"\n"»
	'''
	def static dispatch mission2Text(FindColorsMission mission)'''
	'''
	def static dispatch mission2Text(FollowLineMission mission)'''
			
	'''
	
	def static CharSequence toText(ObstaclesEnum obst){
		switch(obst){
			case ObstaclesEnum:: BUMPER: return avoidFunction()
			case ObstaclesEnum:: OBJECT: return bumperFunction()
		}
	}
	def static CharSequence toText(Color color){
		switch(color){
			case Color:: YELLOW: return '''
			'''
			case Color:: BLUE: return '''b'''
			case Color:: RED: return '''r'''
			case Color:: BLACK: return '''bl'''
		}
	}
		def static CharSequence toText(SpeedOptions speed){
		switch(speed){
			case SpeedOptions:: NOT_MOVING: return stopMoving()
			case SpeedOptions:: SLOW: return '''b'''
			case SpeedOptions:: MEDIUM: return '''r'''
			case SpeedOptions:: FAST: return '''bl'''
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
		def static stopMoving()'''
			left_motor.stop()«"\n"»
			right_mot.stop()«"\n"»
		'''
		def static speedSlow()'''
			speedLeft=5
			speedRight=5
		'''
		def static speedMedium()'''
			speedLeft=10
			speedRight=10
		'''
		def static speedFast()'''
			speedLeft=15
			speedRight=15
		'''
		def static leftMotor()'''
			left_motor.on_for_seconds(SpeedPercent(speed), 10,  block=False)«"\n"»
	        right_motor.on_for_seconds(SpeedPercent(-speed), 10,  block=False)«"\n"»
		'''
		def static rightMotor()'''
			left_motor.on_for_seconds(SpeedPercent(-speed), 10,  block=False)«"\n"»
	        right_motor.on_for_seconds(SpeedPercent(speed), 10,  block=False)«"\n"»
		'''
		def static forwardMotor()'''
			left_motor.on_for_seconds(SpeedPercent(speed), 10,  block=False)«"\n"»
	        right_motor.on_for_seconds(SpeedPercent(speed), 10,  block=False)«"\n"»
		'''
		def static backwardMotor()'''
			left_motor.on_for_seconds(SpeedPercent(-speed), 10,  block=False)«"\n"»
	        right_motor.on_for_seconds(SpeedPercent(-speed), 10,  block=False)«"\n"»
		'''
		def static randomMotor()'''
            speedLeft=random.randint(10,30)«"\n"»
            speedRight=random.randint(10,30)«"\n"»
			left_motor.on_for_seconds(SpeedPercent(speedLeft), 10,  block=False)«"\n"»
	        right_motor.on_for_seconds(SpeedPercent(speedRight), 10,  block=False)«"\n"»
		'''
	
		def static avoidFunction()'''
			left_motor.stop()«"\n"»
            right_motor.stop()«"\n"»
            print("Too close!")«"\n"»
            leds.set_color("LEFT", "RED")«"\n"»
            leds.set_color("RIGHT", "RED") «"\n"»
            left_motor.on_for_seconds(SpeedPercent(-10), 0.5,  block=False)«"\n"»
            right_motor.on_for_seconds(SpeedPercent(-10), 0.5,  block=True)«"\n"»
            choice = random.randint(1,3)«"\n"»
			if choice==1:«"\n"»
			«"\t"»left_motor.on_for_seconds(SpeedPercent(-20), 1, block=True)«"\n"»
			else:«"\n"»
			«"\t"»right_motor.on_for_seconds(SpeedPercent(-20), 1, block=True)«"\n"»
		'''
		def static bumperFunction()'''
			if sLeft.is_pressed:«"\n"»
	            left_motor.stop()«"\n"»
	            right_motor.stop()«"\n"»
	            leds.set_color("LEFT", "RED")«"\n"»
	            leds.set_color("RIGHT", "GREEN") «"\n"»
	            left_motor.on_for_seconds(SpeedPercent(-10), 1,  block=False)«"\n"»
	            right_motor.on_for_seconds(SpeedPercent(-10), 1,  block=True)«"\n"»
	            right_motor.on_for_seconds(SpeedPercent(-20), 1, block=True)«"\n"»
	            leds.set_color("LEFT", "GREEN")«"\n"»
	            leds.set_color("RIGHT", "GREEN") «"\n"»
	            speedLeft=20«"\n"»
	            speedRight=20«"\n"»
            elif sRight.is_pressed:«"\n"»
	            left_motor.stop()«"\n"»
	            right_motor.stop()«"\n"»
	            leds.set_color("LEFT", "GREEN")«"\n"»
	            leds.set_color("RIGHT", "RED") «"\n"»
	            left_motor.on_for_seconds(SpeedPercent(-10), 1,  block=False)«"\n"»
	            right_motor.on_for_seconds(SpeedPercent(-10), 1,  block=True)«"\n"»
	            left_motor.on_for_seconds(SpeedPercent(-20), 1, block=True)«"\n"»
	            leds.set_color("LEFT", "GREEN")«"\n"»
	            leds.set_color("RIGHT", "GREEN")«"\n"»
	            speedLeft=20«"\n"»
	            speedRight=20«"\n"»
		'''
}