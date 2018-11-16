package lego.rover.generator

import lego.rover.rdsl.DoNothingMission
import lego.rover.rdsl.DriveMission
import lego.rover.rdsl.FindColorsMission
import lego.rover.rdsl.FollowLineMission
import lego.rover.rdsl.Mission
import lego.rover.rdsl.ObstaclesEnum
import lego.rover.rdsl.ParkingMission

class PythonGenerator {
	def static toPy(Mission root){
		'''
		#marsrovermission.py
		«"\n"»
		«"\n"»
		«onStartUp()»
		«mission2Text(root)»
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
			colors_found = [False, False, False]«"\n"»
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
	'''
	def static dispatch mission2Text(DriveMission mission)'''
			
	'''
	
	def static dispatch mission2Text(DoNothingMission mission)'''
			currenttime = int(time.time())«"\n"»
			while (int(time.time()) - currenttime)> «mission.time»:«"\n"»
			«"\t"»time.sleep(1)«"\n"»
	'''
	def static dispatch mission2Text(FindColorsMission mission)'''
			
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
	
}