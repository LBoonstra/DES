'''
Created on 19 okt. 2018

@author: Richa
'''
from ev3dev2.motor import LargeMotor, OUTPUT_A, OUTPUT_D, SpeedPercent
from ev3dev2.sound import Sound
from ev3dev2.display import Display
from ev3dev2.sensor.lego import ColorSensor
from ev3dev2.sensor.lego import TouchSensor
from ev3dev2._platform.ev3 import INPUT_4, INPUT_1
from ev3dev2.led import Leds
from ev3dev2.sensor.lego import UltrasonicSensor
import random
import bluetooth, threading
from time import sleep
from robotica import slave
from robotica import master

class roleInLife(object):
    '''
    classdocs
    '''


    def __init__(self, address, role):
        self.role = role
        
    def connect(self):
        self.role.connect()
        
    def run(self):
        self.role.run()
        
    
        