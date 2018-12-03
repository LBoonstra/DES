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
		'''
		
	def static dispatch stopCon2Text(Obstacles obst)'''«obstacles2Text(obst)»'''
	
	def static dispatch stopCon2Text(TimeObject timeOb) '''(int(time.time()) - currenttime)> «timeOb.time»'''
	
	def static dispatch obstacles2Text(UseObstacle obst)'''«toText(obst.OE)»'''
	
	def static dispatch obstacles2Text(ColorWithName colorN)'''new_color==«toText(colorN.color)»'''
	
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
			case SpeedOptions:: SLOW: return '''5'''
			case SpeedOptions:: MEDIUM: return '''10'''
			case SpeedOptions:: FAST: return '''15'''
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
			«"\t"»left_motor.on_for_seconds(SpeedPercent(speed), 10,  block=False)«"\n"»
			«"\t"»right_motor.on_for_seconds(SpeedPercent(-speed), 10,  block=False)«"\n"»
		'''
		def static rightMotor()'''
			«"\t"»left_motor.on_for_seconds(SpeedPercent(-speed), 10,  block=False)«"\n"»
			«"\t"»right_motor.on_for_seconds(SpeedPercent(speed), 10,  block=False)«"\n"»
		'''
		def static forwardMotor()'''
			«"\t"»left_motor.on_for_seconds(SpeedPercent(speed), 10,  block=False)«"\n"»
			«"\t"»right_motor.on_for_seconds(SpeedPercent(speed), 10,  block=False)«"\n"»
		'''
		def static backwardMotor()'''
			«"\t"»left_motor.on_for_seconds(SpeedPercent(-speed), 10,  block=False)«"\n"»
			«"\t"»right_motor.on_for_seconds(SpeedPercent(-speed), 10,  block=False)«"\n"»
		'''
		def static randomMotor()'''
			«"\t"»counter=0«"\n"»
			«"\t"»if counter>50:«"\n"»
			«"\t"»«"\t"»speedLeft=random.randint(speed/2,speed*2)«"\n"»
			«"\t"»«"\t"»speedRight=random.randint(speed/2,speed*2)«"\n"»
			«"\t"»«"\t"»counter=0«"\n"»
			«"\t"»else:«"\n"»
			«"\t"»«"\t"»counter+=1«"\n"»
			«"\t"»left_motor.on_for_seconds(SpeedPercent(speedLeft), 10,  block=False)«"\n"»
			«"\t"»right_motor.on_for_seconds(SpeedPercent(speedRight), 10,  block=False)«"\n"»
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