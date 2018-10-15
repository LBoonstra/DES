#!/usr/bin/env python3

from ev3dev2.motor import LargeMotor, OUTPUT_A, OUTPUT_D, SpeedPercent
from ev3dev2.sound import Sound
from ev3dev2.display import Display
from ev3dev2.sensor.lego import ColorSensor
from ev3dev2.sensor.lego import TouchSensor
from ev3dev2._platform.ev3 import INPUT_4, INPUT_1
from ev3dev2.led import Leds
from ev3dev2.sensor.lego import UltrasonicSensor
import random

left_motor = LargeMotor(OUTPUT_A)
right_motor = LargeMotor(OUTPUT_D)
tsLeft = TouchSensor(INPUT_1)
tsRight = TouchSensor(INPUT_4)
leds = Leds()
s = Sound()
s.speak("To infinity, but not beyond. Definitely not beyond")
cs = ColorSensor()
counter =20
speedLeft=0
speedRight=0
leds.set_color("LEFT", "GREEN")
leds.set_color("RIGHT", "GREEN") 
us = UltrasonicSensor() 
us.mode = 'US-DIST-CM'
units = us.units
distance = us.value()
my_display = Display()
my_display.clear()


def recoverLine():
    while cs.color==0 or cs.color==1:
        left_motor.on_for_rotations(SpeedPercent(-10), 1,  block=False)
        right_motor.on_for_rotations(SpeedPercent(-10), 1,  block=False)
    left_motor.on_for_seconds(SpeedPercent(-10), 1,  block=False)
    right_motor.on_for_seconds(SpeedPercent(-10), 1,  block=True)
    left_motor.stop()
    right_motor.stop()
    choice = random.randint(1,3)
    if choice==1:
        left_motor.on_for_seconds(SpeedPercent(-20), 1, block=True)
    else:
        right_motor.on_for_seconds(SpeedPercent(-20), 1, block=True)
        

while True:
    if counter ==50:
        counter =0
        speedLeft=random.randint(10,30)
        speedRight=random.randint(10,30)
    else:
        counter+=1
    left_motor.on_for_seconds(SpeedPercent(speedLeft), 10,  block=False)
    right_motor.on_for_seconds(SpeedPercent(speedRight), 10,  block=False)
    new_color = cs.color
    distance = us.value()/10
    if new_color == 1:
        left_motor.stop()
        right_motor.stop()
        leds.set_color("LEFT", "RED")
        leds.set_color("RIGHT", "RED") 
        recoverLine()
        leds.set_color("LEFT", "GREEN")
        leds.set_color("RIGHT", "GREEN") 
        counter =0
        speedLeft=random.randint(10,30)
        speedRight=random.randint(10,30)
    elif tsLeft.is_pressed:
        left_motor.stop()
        right_motor.stop()
        leds.set_color("LEFT", "RED")
        leds.set_color("RIGHT", "GREEN") 
        left_motor.on_for_seconds(SpeedPercent(-10), 1,  block=False)
        right_motor.on_for_seconds(SpeedPercent(-10), 1,  block=True)
        right_motor.on_for_seconds(SpeedPercent(-20), 1, block=True)
        leds.set_color("LEFT", "GREEN")
        leds.set_color("RIGHT", "GREEN") 
        speedLeft=20
        speedRight=20
        counter=-50
    elif tsRight.is_pressed:
        left_motor.stop()
        right_motor.stop()
        leds.set_color("LEFT", "GREEN")
        leds.set_color("RIGHT", "RED") 
        left_motor.on_for_seconds(SpeedPercent(-10), 1,  block=False)
        right_motor.on_for_seconds(SpeedPercent(-10), 1,  block=True)
        left_motor.on_for_seconds(SpeedPercent(-20), 1, block=True)
        leds.set_color("LEFT", "GREEN")
        leds.set_color("RIGHT", "GREEN") 
        speedLeft=20
        speedRight=20
        counter=-50
    elif distance<28:
        left_motor.stop()
        right_motor.stop()
        print("Too close!")
        leds.set_color("LEFT", "RED")
        leds.set_color("RIGHT", "RED") 
        s.speak("No drinking on the mission")
        left_motor.on_for_seconds(SpeedPercent(-10), 0.5,  block=False)
        right_motor.on_for_seconds(SpeedPercent(-10), 0.5,  block=True)
        choice = random.randint(1,3)
        if choice==1:
            left_motor.on_for_seconds(SpeedPercent(-20), 1, block=True)
        else:
            right_motor.on_for_seconds(SpeedPercent(-20), 1, block=True)
        leds.set_color("LEFT", "GREEN")
        leds.set_color("RIGHT", "GREEN") 
        speedLeft=20
        speedRight=20
        counter=-50
        
        
    
    