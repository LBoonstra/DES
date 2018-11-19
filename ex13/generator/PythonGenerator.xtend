package rover.lego.generator

import rover.lego.rdsl.Color
import rover.lego.rdsl.DirectionOptions
import rover.lego.rdsl.DoNothingMission
import rover.lego.rdsl.DriveMission
import rover.lego.rdsl.FindColorsMission
import rover.lego.rdsl.FollowLineMission
import rover.lego.rdsl.Obstacles
import rover.lego.rdsl.ObstaclesEnum
import rover.lego.rdsl.SpeedOptions
import rover.lego.rdsl.Task
import rover.lego.rdsl.UseObstacle

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
		«mission.dir»
		«"\t"»new_color = cs.color«"\n"»
		«"\t"»distance = us.value()/10«"\n"»
		«IF mission.avoid !== null»
		«"\t"»if «obstacles2Text(mission.avoid)»: 
		«"\t"»«"\t"»«avoidFunction()»«ENDIF»
		«"\t"»if «FOR stpc : mission.stopcons SEPARATOR " or " AFTER ":"»«"\n"»
			«stopCon2Text(stpc)»
		«ENDFOR»
		«"\t"»«"\t"»left_motor.stop()«"\n"»
		«"\t"»«"\t"»right_motor.stop()«"\n"»
		«"\t"»«"\t"»break«"\n"»
		
	'''
	
	def static dispatch mission2Text(DoNothingMission mission)'''
		while (int(time.time()) - currenttime)> «mission.time»:«"\n"»
		«"\t"»time.sleep(1)«"\n"»
	'''
	def static dispatch mission2Text(FindColorsMission mission)'''
		colorsToFind = [«FOR fc : mission.findcolor SEPARATOR "," AFTER "]"»
			«toText(fc.colors)»
		«ENDFOR»
		while (True):«"\n"» 
		«"\t"»speed = «mission.speed»«"\n"»
		«randomMotor()»
		«"\t"»new_color = cs.color«"\n"»
		«"\t"»distance = us.value()/10«"\n"»
		«IF mission.avoid !== null»
		«"\t"»if «obstacles2Text(mission.avoid)»: 
		«"\t"»«"\t"»«avoidFunction()»«ENDIF»
		«"\t"»if colorsToFind ==[] or«FOR stpc : mission.stopcons SEPARATOR " or " AFTER ":"»«"\n"»
			«stopCon2Text(stpc)»
		«ENDFOR»
		«"\t"»«"\t"»left_motor.stop()«"\n"»
		«"\t"»«"\t"»right_motor.stop()«"\n"»
		«"\t"»«"\t"»break«"\n"»
		«"\t"»if new_color in colorsToFind:«"\n"»
		«"\t"»«"\t"»colorsToFind.remove(new_color)«"\n"»
		
	'''
	def static dispatch mission2Text(FollowLineMission mission)'''
		colorToFollow = «toText(mission.followColor)»
		colorsToAvoid = [1,2,4,5]
		colorsToAvoid.remove(colorToFollow)
		while True:
			«"\t"»speed = «mission.speed»«"\n"»
			«forwardMotor()»
			«"\t"»new_color = cs.color«"\n"»
			«"\t"»distance = us.value()/10«"\n"»
			«"\t"»if new_color in colorsToAvoid:«"\n"»
			«"\t"»«"\t"»left_motor.stop()«"\n"»
			«"\t"»«"\t"»right_motor.stop()«"\n"»
			«"\t"»«"\t"» 
		«"\t"»if «FOR stpc : mission.stopcons SEPARATOR " or " AFTER ":"»«"\n"»
			«stopCon2Text(stpc)»
		«ENDFOR»
		«"\t"»«"\t"»left_motor.stop()«"\n"»
		«"\t"»«"\t"»right_motor.stop()«"\n"»
		«"\t"»«"\t"»break«"\n"»
		'''
		
	def static dispatch stopCon2Text(Obstacles obst)'''
			«obstacles2Text(obst)»
	'''
	def static dispatch stopCon2Text(int time) '''
		(int(time.time()) - currenttime)> «time»:«"\n"»
	'''
	
	def static dispatch obstacles2Text(UseObstacle obst)'''
			«toText(obst.OE)»
	'''
	
	def static dispatch obstacles2Text(Color color)'''
			new_color==«toText(color)»
			'''
	
	def static CharSequence toText(ObstaclesEnum obst){
		switch(obst){
			case ObstaclesEnum:: BUMPER: return bumperFunction()
			case ObstaclesEnum:: OBJECT: return objectFunction()
		}
	}
	def static CharSequence toText(Color color){
		switch(color){
			case Color:: YELLOW: return '''4
			'''
			case Color:: BLUE: return '''2'''
			case Color:: RED: return '''5'''
			case Color:: BLACK: return '''1'''
		}
	}
		def static CharSequence toText(SpeedOptions speed){
		switch(speed){
			case SpeedOptions:: NOT_MOVING: return stopMoving()
			case SpeedOptions:: SLOW: return speedSlow()
			case SpeedOptions:: MEDIUM: return speedMedium()
			case SpeedOptions:: FAST: return speedFast()
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
			speedLeft=5«"\n"»
			speedRight=5«"\n"»
		'''
		def static speedMedium()'''
			speedLeft=10«"\n"»
			speedRight=10«"\n"»
		'''
		def static speedFast()'''
			speedLeft=15«"\n"»
			speedRight=15«"\n"»
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
            speedLeft=random.randint(speed/2,speed*2)«"\n"»
            speedRight=random.randint(speed/2,speed*2)«"\n"»
			left_motor.on_for_seconds(SpeedPercent(speedLeft), 10,  block=False)«"\n"»
	        right_motor.on_for_seconds(SpeedPercent(speedRight), 10,  block=False)«"\n"»
		'''
	
		def static avoidFunction()'''
			left_motor.stop()«"\n"»
            right_motor.stop()«"\n"»
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
			sLeft.is_pressed or sRight.is_pressed«"\n"»

		'''
		
		def static objectFunction()'''
			distance < 28
		'''
}