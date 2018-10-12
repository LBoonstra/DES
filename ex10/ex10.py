#!/usr/bin/env python3

from ev3dev2.motor import LargeMotor, OUTPUT_A, OUTPUT_D, SpeedPercent
from ev3dev2.sound import Sound
from ev3dev2.display import Display
from ev3dev2.sensor.lego import ColorSensor
import random

left_motor = LargeMotor(OUTPUT_A)
right_motor = LargeMotor(OUTPUT_D)
s = Sound()
s.speak("To infinity, but not beyond. Definitely not beyond")
cs = ColorSensor()
counter =20
speedLeft=0
speedRight=0

def recover():
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
    if new_color == 1:
        left_motor.stop()
        right_motor.stop()
        recover()
        counter =0
        speedLeft=random.randint(10,30)
        speedRight=random.randint(10,30)