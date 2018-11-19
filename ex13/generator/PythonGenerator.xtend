package lego.rover.generator

import lego.rover.rdsl.Color
import lego.rover.rdsl.DirectionOptions
import lego.rover.rdsl.DoNothingMission
import lego.rover.rdsl.DriveMission
import lego.rover.rdsl.FindColorsMission
import lego.rover.rdsl.FollowLineMission
import lego.rover.rdsl.ObstaclesEnum
import lego.rover.rdsl.ParkingMission
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
			«"\t"»«mission.dir.»
			
	'''
	def static dispatch drive2Text(DirectionOptions drive)'''
	'''
	def static dispatch mission2Text(DoNothingMission mission)'''
			while (int(time.time()) - currenttime)> «mission.time»:«"\n"»
			«"\t"»time.sleep(1)«"\n"»
	'''
	def static dispatch mission2Text(FindColorsMission mission)'''
		//WHile niet alle kleuren gevonden rij random rond.
		«mission.findcolor.»
		while():«"\n"»
		«"\t"»
	'''
	def static dispatch mission2Text(FollowLineMission mission)'''
			
	'''
	def static dispatch mission2Text(ParkingMission mission)'''
			
	'''

	def static CharSequence toText(ObstaclesEnum obst){
		switch(obst){
			case ObstaclesEnum:: BUMPER: return '''m'''
			case ObstaclesEnum:: OBJECT: return '''h'''
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
			case SpeedOptions:: NOT_MOVING: return '''y'''
			case SpeedOptions:: SLOW: return '''b'''
			case SpeedOptions:: MEDIUM: return '''r'''
			case SpeedOptions:: FAST: return '''bl'''
		}
	}
		def static CharSequence toText(DirectionOptions dir){
		switch(dir){
			case DirectionOptions:: LEFT: return '''y'''
			case DirectionOptions:: RIGHT: return '''b'''
			case DirectionOptions:: FORWARD: return '''r'''
			case DirectionOptions:: BACKWARD: return '''bl'''
			case DirectionOptions:: RANDOM: return '''bl'''
		}
	}
	
}