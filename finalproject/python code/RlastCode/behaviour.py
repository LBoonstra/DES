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
'''
#is_master = True
is_master = False
busy = True
server_mac = '00:17:E9:B4:CB:EB'
colors_found = [False, False, False]
colorsList = ['blue', 'yellow', 'red']

def connect(server_mac, is_master = True):
    port = 3
    if is_master:
        server_sock = bluetooth.BluetoothSocket(bluetooth.RFCOMM)
        server_sock.bind((server_mac, port))
        server_sock.listen(1)
        print('Listening...')
        client_sock, address = server_sock.accept()
        print('Accepted connection from ', address)
        return client_sock, client_sock.makefile('r'), client_sock.makefile('w')
    else:
        sock = bluetooth.BluetoothSocket(bluetooth.RFCOMM)
        print('Connecting...')
        sock.connect((server_mac, port)) 
        print('Connected to ', server_mac)
        return sock, sock.makefile('r'), sock.makefile('w')
    
def disconnect(sock):
    sock.close()


def start_listening(sock_in, sock_out):
    i = 1
    sock_out.write(str(1) + '\n')
    sock_out.flush()
    print('Sent ' + str(1))
    listen(sock_in, sock_out)

    
def sendInfo(sock_out, integerFound):
    sock_out.write(str(integerFound) + '\n')
    sock_out.flush()
    print(str(integerFound))

def listen(sock_in):
    print('Now listening...')
    while busy:
        data = int(sock_in.readline())
        print("Received something")
        if colors_found[data]==False:
            colors_found[data]=True
            s.speak("Received " + colorsList[data] + " found")
        sleep(1)
        #sock_out.write(str(1) + '\n')
        #sock_out.flush()
        #print('Sent ' + str(1))f
'''

def stateExp():
    global backUnsafe
    global forwardCLUnsafe
    global forwardCRUnsafe
    global forwardCMUnsafe
    if backUnsafe and (forwardCMUnsafe or forwardCLUnsafe or forwardCRUnsafe):
        return 'DesperateTurn'
    elif backUnsafe:
        return 'BackDepthAvoidance'
    elif forwardCMUnsafe:
        return 'ForwardMidDepthAvoidance'
    elif forwardCLUnsafe:
        return 'ForwardLeftDepthAvoidance'
    elif forwardCRUnsafe:
        return 'ForwardRightDepthAvoidance'
    return ''
    

def stateF():
    global backUnsafe
    global forwardCLUnsafe
    global forwardCRUnsafe
    global forwardCMUnsafe
    if backUnsafe:
        return 'DesperateTurn'
    else:
        return ''
    
def stateBD():
    global backUnsafe
    global forwardCLUnsafe
    global forwardCRUnsafe
    global forwardCMUnsafe
    if forwardCLUnsafe or forwardCRUnsafe or forwardCMUnsafe:
        return 'DesperateTurn'
    else:
        return ''

def determineState(curState):
    switcher = { 
        'Exploring': stateExp,
        #'BumperAvoidance': stateBump(), 
        #'ObstacleAvoidance':stateObst(), 
        'BackDepthAvoidance': stateBD, 
        'ForwardLeftDepthAvoidance': stateF, 
        'ForwardMidDepthAvoidance': stateF, 
        'ForwardRightDepthAvoidance': stateF, 
        'DesperateTurn': 'DesperateTurn',
        }
    nextState= switcher.get(curState)
    if curState=='Exploring':
        nextState=stateExp()
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
    if time()-curTime<2:
        motSpeed[0]=random.randint(5,15)
        motSpeed[1]=random.randint(5,15)
    elif time()-curTime>5:
        curTime=time()
    return curTime, 'Exploring'
    
def bdMot(curTime):
    global motSpeed
    global backUnsafe
    global forwardCLUnsafe
    global forwardCRUnsafe
    global forwardCMUnsafe
    if backUnsafe:
        motSpeed=[10,10]
        motSpeed[0]=10
        motSpeed[1]=10
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
        motSpeed[0]=10
        motSpeed[1]=-10
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
        motSpeed[0]=-10
        motSpeed[1]=-10
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
        motSpeed[0]=-10
        motSpeed[1]=10
        return curTime, 'ForwardRightDepthAvoidance'
    motSpeed =[0,0]
    return time(), 'Exploring'

def despTurn(curTime):
    global motSpeed
    global backUnsafe
    global forwardCLUnsafe
    global forwardCRUnsafe
    global forwardCMUnsafe
    if backUnsafe and (forwardCMUnsafe or forwardCLUnsafe or forwardCRUnsafe):
        motSpeed=[10,-10]
        motSpeed[0]=10
        motSpeed[1]=-10
        return curTime, 'DesperateTurn'
    motSpeed =[0,0]
    return time(), 'Exploring'
        

def stateModerator():
    global motSpeed
    curState= 'Exploring'
    nextState='Exploring'
    curTime = time()
    while True:
        nextState = determineState(curState)
        if nextState!=curState:
            curTime = time()
        if nextState=="Exploring":
            curTime, curState=expMot(curTime)
        elif nextState== "BackDepthAvoidance":
            curTime, curState=bdMot(curTime)
        elif nextState== "ForwardLeftDepthAvoidance":
            curTime, curState=flMot(curTime)
        elif nextState== "ForwardMidDepthAvoidance":
            curTime, curState=fmMot(curTime)
        elif nextState== "ForwardRightDepthAvoidance":
            curTime, curState=frMot(curTime)
        elif nextState== "DesperateTurn":
            curTime, curState=despTurn(curTime)
            
        if ending:
            break
        sleep(0.1)
            
def sensorModerator():
    # Sensors work, at least csLeft
    global backUnsafe
    global forwardCLUnsafe
    global forwardCRUnsafe
    global forwardCMUnsafe
    while True:
        new_colorLeft = csLeft.color
        new_colorMid = csMid.color
        new_colorRight = csRight.color
        distance = us.value()/10
        if new_colorLeft in stopColors:
            forwardCLUnsafe=True
        else:
            forwardCLUnsafe=False
        if new_colorMid in stopColors:
            forwardCMUnsafe=True
        else:
            forwardCMUnsafe=False
        if new_colorRight in stopColors:
            forwardCRUnsafe=True
        else:
            forwardCRUnsafe=False
        if distance>4:
            backUnsafe=True
        else:
            backUnsafe=False
        if ending:
            break
        sleep(0.1)
        
def motorModerator():
    while True:
        global motSpeed
        left_motor.on_for_seconds(SpeedPercent(motSpeed[0]), 1,  block=False)
        right_motor.on_for_seconds(SpeedPercent(motSpeed[1]), 1,  block=False)
        if ending:
            left_motor.stop()
            right_motor.stop()
            break
        sleep(0.1)
        

global backUnsafe
global forwardCLUnsafe
global forwardCRUnsafe
global forwardCMUnsafe

print("Start!")
backUnsafe=False
forwardCLUnsafe=False
forwardCRUnsafe=False
forwardCMUnsafe=False

global motLeftSpeed
global motRightSpeed

motorCommand = 'Stop'
motSpeed =[0,0]
ending= False

stopColors= [0,2,3,5,6]
left_motor = LargeMotor(OUTPUT_A)
right_motor = LargeMotor(OUTPUT_D)
measurement_arm = Motor(OUTPUT_B)
#tsLeft = TouchSensor(INPUT_1)
#tsRight = TouchSensor(INPUT_4)
leds = Leds()
s = Sound()
#s.speak("To infinity, but not beyond. Definitely not beyond")
csLeft = ColorSensor(INPUT_1)
csMid = ColorSensor(INPUT_3)
csRight = ColorSensor(INPUT_4)
leds.set_color("LEFT", "GREEN")
leds.set_color("RIGHT", "GREEN") 
us = UltrasonicSensor() 
us.mode = 'US-DIST-CM'
units = us.units
distance = us.value()
my_display = Display()
my_display.clear()

        
senMod = threading.Thread(target=sensorModerator, args=())
statMod = threading.Thread(target=stateModerator, args=())
motMod = threading.Thread(target=motorModerator, args=())
senMod.start()
sleep(1)
statMod.start()
motMod.start()
sleep(20)
ending=True
sleep(5)



    