#!/usr/bin/env python3

from ev3dev2.motor import LargeMotor, OUTPUT_A, OUTPUT_D, OUTPUT_B, SpeedPercent, Motor
from ev3dev2.sound import Sound
from ev3dev2.display import Display
from ev3dev2.sensor.lego import ColorSensor
from ev3dev2.sensor.lego import TouchSensor
from ev3dev2._platform.ev3 import INPUT_4, INPUT_1, INPUT_2, INPUT_3
from ev3dev2.led import Leds
from ev3dev2.sensor.lego import UltrasonicSensor
import random
import bluetooth, threading
from time import sleep
from time import time

def connect(server_mac):
    port = 3
    sock = bluetooth.BluetoothSocket(bluetooth.RFCOMM)
    print('Connecting...')
    sock.connect((server_mac, port))
    print('Connected to ', server_mac)
    return sock, sock.makefile('r'), sock.makefile('w')

def disconnect(sock):
    sock.close()

def listen(sock_in):
    global ending
    print('Now listening...')
    while True:
        data = int(sock_in.readline())
        if data==2:
            ending=True
            break
        sleep(1)

def sendInfo(sock_out, sensortype):
    sock_out.write(str(sensortype)+ '\n')
    sock_out.flush()

def leftBumperSensor(sock_out):
    tsLeft = TouchSensor(INPUT_1)
    pressedIn= False
    while True:
        if tsLeft.is_pressed:
            sendInfo(sock_out,1)
            sleep(1)
            pressedIn=True
        elif pressedIn:
            pressedIn=False
            sendInfo(sock_out,2)
        if ending:
            break

def rightBumperSensor(sock_out):
    tsRight = TouchSensor(INPUT_4)
    pressedIn= False
    while True:
        if tsRight.is_pressed:
            sendInfo(sock_out,3)
            sleep(1)
            pressedIn=True
        elif pressedIn:
            pressedIn=False
            sendInfo(sock_out,4)
        if ending:
            break

def forwSonarSensor(sock_out):
    us = UltrasonicSensor()
    us.code = 'US-DIST-CM'
    pressedIn= False
    while True:
        if us.value()/10<17:
            sendInfo(sock_out,5)
            sleep(1)
            pressedIn=True
        elif pressedIn:
            pressedIn=False
            sendInfo(sock_out,6)
        if ending:
            break

global ending
ending=False
server_mac = 'CC:78:AB:50:B2:46'
is_master=False
sock, sock_in, sock_out = connect(server_mac)
blueListener = threading.Thread(target=listen, args=(sock_in,))
blueListener.start()
leftBListener = threading.Thread(target=leftBumperSensor, args=(sock_out,))
leftBListener.start()
rightBListener= threading.Thread(target=rightBumperSensor, args=(sock_out,))
rightBListener.start()
sonarListener = threading.Thread(target=forwSonarSensor, args=(sock_out,))
sonarListener.start()
blueListener.join()
sendInfo(sock_out, 7)
disconnect(sock_in)
disconnect(sock_out)
disconnect(sock)
leftBListener.join()
rightBListener.join()
sonarListener.join()
