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
    server_sock = bluetooth.BluetoothSocket(bluetooth.RFCOMM)
    server_sock.bind((server_mac, port))
    server_sock.listen(1)
    print('Listening...')
    client_sock, address = server_sock.accept()
    print('Accepted connection from ', address)
    return client_sock, client_sock.makefile('r'), client_sock.makefile('w')

def disconnect(sock):
    sock.close()

def listen(sock_in):
    global ending
    global leftBumperUnsafe
    global rightBumperUnsafe
    global forwardSonarUnsafe
    print('Now listening...')
    while True:
        data = int(sock_in.readline())
        if data==1:
            leftBumperUnsafe=True
            print("Left hit")
        if data==2:
            leftBumperUnsafe=False
            print("Left no longer hit")
        elif data==3:
            rightBumperUnsafe=True
            print("right hit")
        elif data==4:
            rightBumperUnsafe=False
            print("right no longer hit")
        elif data==5:
            forwardSonarUnsafe=True
            print("sonar hit. Somehow. Not quite sure how.")
        elif data==6:
            forwardSonarUnsafe=False
            print("sonar no longer hit. That makes more sense")
        elif data==7:
            print("Other one is ending, I will end now too")
        sleep(1)
        if ending:
            break

def sendInfo(sock_out, message):
    sock_out.write(str(message)+ '\n')
    sock_out.flush()

def doNotFallOff():
    global backUnsafe
    global forwardCLUnsafe
    global forwardCRUnsafe
    global forwardCMUnsafe
    new_colorLeft = csLeft.color
    new_colorMid = csMid.color
    new_colorRight = csRight.color
    distance = us.value()/10
    if new_colorLeft==0:
        forwardCLUnsafe=True
    else:
        forwardCLUnsafe=False
    if new_colorMid==0:
        forwardCMUnsafe=True
    else:
        forwardCMUnsafe=False
    if new_colorRight==0:
        forwardCRUnsafe=True
    else:
        forwardCRUnsafe=False
    if distance>4:
        backUnsafe=True
    else:
        backUnsafe=False

def colorAvoid(color):
    global forwardCLUnsafe
    global forwardCRUnsafe
    global forwardCMUnsafe
    new_colorLeft = csLeft.color
    new_colorMid = csMid.color
    new_colorRight = csRight.color
    if new_colorLeft==color:
        forwardCLUnsafe=True
    else:
        forwardCLUnsafe=False
    if new_colorMid==color:
        forwardCMUnsafe=True
    else:
        forwardCMUnsafe=False
    if new_colorRight==color:
        forwardCRUnsafe=True
    else:
        forwardCRUnsafe=False

def motorModerator():
    global ending
    while True:
        global motSpeed
        if motSpeed[0]==0:
            left_motor.stop()
        else:
            left_motor.on_for_seconds(SpeedPercent(motSpeed[0]), 1,  block=False)
        if motSpeed[1]==0:
            right_motor.stop()
        else:
            right_motor.on_for_seconds(SpeedPercent(motSpeed[1]), 1,  block=False)
        if ending:
            left_motor.stop()
            right_motor.stop()
            break
        sleep(0.1)

def stateExp():
    global backUnsafe
    global forwardCLUnsafe
    global forwardCRUnsafe
    global forwardCMUnsafe
    global leftBumperUnsafe
    global rightBumperUnsafe
    global forwardSonarUnsafe
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
    elif leftBumperUnsafe:
        return 'LeftBumperAvoidance'
    elif rightBumperUnsafe:
        return 'RightBumperAvoidance'
    elif forwardSonarUnsafe:
        return 'ForwardDepthAvoidance'
    return ''

def stateObstacle():
    global backUnsafe
    global forwardCLUnsafe
    global forwardCRUnsafe
    global forwardCMUnsafe
    global leftBumperUnsafe
    global rightBumperUnsafe
    global forwardSonarUnsafe
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
    elif leftBumperUnsafe:
        return 'LeftBumperAvoidance'
    elif rightBumperUnsafe:
        return 'RightBumperAvoidance'
    return ''

def stateBumper():
    global backUnsafe
    global forwardCLUnsafe
    global forwardCRUnsafe
    global forwardCMUnsafe
    global leftBumperUnsafe
    global rightBumperUnsafe
    global forwardSonarUnsafe
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
    if curState=='Exploring':
        nextState=stateExp()
    elif curState=='ForwardDepthAvoidance':
        nextState = stateObstacle()
    elif curState=='RightBumperAvoidance' or curState=='LeftBumperAvoidance':
        nextState = stateBumper()
    elif curState=='BackDepthAvoidance':
        nextState= stateBD()
    elif curState== 'ForwardLeftDepthAvoidance' or curState== 'ForwardMidDepthAvoidance' or curState=='ForwardRightDepthAvoidance':
        nextState= stateF()
    elif curState=='DesperateTurn':
        nextState= 'DesperateTurn'
    return nextState if not (nextState=='') else curState

def expMot(curTime, rotationChoice):
    global motSpeed
    global backUnsafe
    global forwardCLUnsafe
    global forwardCRUnsafe
    global forwardCMUnsafe
    if time()-curTime<2:
        motSpeed[0]=random.randint(standardSpeed-5,standardSpeed+5)
        motSpeed[1]=random.randint(standardSpeed-5,standardSpeed+5)
    elif time()-curTime>5:
        curTime=time()
    return curTime, 'Exploring', None
    
def bdMot(curTime, rotationChoice):
    global motSpeed
    global backUnsafe
    global forwardCLUnsafe
    global forwardCRUnsafe
    global forwardCMUnsafe
    if backUnsafe:
        motSpeed[0]=standardSpeed
        motSpeed[1]=standardSpeed
        return curTime, 'BackDepthAvoidance', None
    elif (int(time()) - curTime)<0.5:
        if rotationChoice == None:
            rotationChoice=random.randint(1,2)
        if rotationChoice ==1:
            motSpeed[0]=5
            motSpeed[1]=-5
        else:
            motSpeed[0]=-5
            motSpeed[1]=5
        return curTime, 'BackDepthAvoidance', rotationChoice
    motSpeed =[0,0]
    return time(), 'Exploring', None
    
def flMot(curTime, rotationChoice):
    global motSpeed
    global backUnsafe
    global forwardCLUnsafe
    global forwardCRUnsafe
    global forwardCMUnsafe
    if forwardCLUnsafe:
        motSpeed[0]=-standardSpeed
        motSpeed[1]=-standardSpeed
        curTime=time()
        return curTime, 'ForwardLeftDepthAvoidance', None
    elif (int(time()) - curTime)<0.5:
        motSpeed[0]=5
        motSpeed[1]=-5
        return curTime, 'ForwardLeftDepthAvoidance', None
    motSpeed =[0,0]
    return time(), 'Exploring', None
    
def fmMot(curTime, rotationChoice):
    global motSpeed
    global backUnsafe
    global forwardCLUnsafe
    global forwardCRUnsafe
    global forwardCMUnsafe
    if forwardCMUnsafe:
        motSpeed[0]=-standardSpeed
        motSpeed[1]=-standardSpeed
        curTime=time()
        return curTime, 'ForwardMidDepthAvoidance', None
    elif (int(time()) - curTime)<0.5:
        if rotationChoice == None:
            rotationChoice=random.randint(1,2)
        if rotationChoice ==1:
            motSpeed[0]=5
            motSpeed[1]=-5
        else:
            motSpeed[0]=-5
            motSpeed[1]=5
        return curTime, 'ForwardMidDepthAvoidance', rotationChoice
    motSpeed =[0,0]
    return time(), 'Exploring', None
    
def frMot(curTime, rotationChoice):
    global motSpeed
    global backUnsafe
    global forwardCLUnsafe
    global forwardCRUnsafe
    global forwardCMUnsafe
    if forwardCRUnsafe:
        motSpeed[0]=-standardSpeed
        motSpeed[1]=-standardSpeed
        curTime=time()
        return curTime, 'ForwardRightDepthAvoidance', None
    elif (int(time()) - curTime)<0.5:
        motSpeed[0]=-5
        motSpeed[1]=5
        return curTime, 'ForwardRightDepthAvoidance', None
    motSpeed =[0,0]
    return time(), 'Exploring', None
    
def lbMot(curTime, rotationChoice):
        global motSpeed
        global leftBumperUnsafe
        global rightBumperUnsafe
        global forwardSonarUnsafe
        if leftBumperUnsafe:
            motSpeed[0]=-standardSpeed
            motSpeed[1]=-standardSpeed
            curTime=time()
            return curTime, 'LeftBumperAvoidance', None
        elif (int(time()) - curTime)<0.5:
            motSpeed[0]=5
            motSpeed[1]=-5
            return curTime, 'LeftBumperAvoidance', None
        motSpeed =[0,0]
        return time(), 'Exploring', None
        
def fdMot(curTime, rotationChoice):
    global motSpeed
    global leftBumperUnsafe
    global rightBumperUnsafe
    global forwardSonarUnsafe
    if forwardSonarUnsafe:
        motSpeed[0]=-standardSpeed
        motSpeed[1]=-standardSpeed
        curTime=time()
        return curTime, 'ForwardDepthAvoidance', None
    elif (int(time()) - curTime)<0.5:
        if rotationChoice == None:
            rotationChoice=random.randint(1,2)
        if rotationChoice ==1:
            motSpeed[0]=5
            motSpeed[1]=-5
        else:
            motSpeed[0]=-5
            motSpeed[1]=5
        return curTime, 'ForwardDepthAvoidance', rotationChoice
    motSpeed =[0,0]
    return time(), 'Exploring', None
        
def rbMot(curTime, rotationChoice):
    global motSpeed
    global leftBumperUnsafe
    global rightBumperUnsafe
    global forwardSonarUnsafe
    if rightBumperUnsafe:
        motSpeed[0]=-standardSpeed
        motSpeed[1]=-standardSpeed
        curTime=time()
        return curTime, 'RightBumperAvoidance', None
    elif (int(time()) - curTime)<0.5:
        motSpeed[0]=-5
        motSpeed[1]=5
        return curTime, 'RightBumperAvoidance', None
    motSpeed =[0,0]
    return time(), 'Exploring', None

def despTurn(curTime, rotationChoice):
    global motSpeed
    global backUnsafe
    global forwardCLUnsafe
    global forwardCRUnsafe
    global forwardCMUnsafe
    if backUnsafe and (forwardCMUnsafe or forwardCLUnsafe or forwardCRUnsafe):
        if rotationChoice == None:
            rotationChoice=random.randint(1,2)
        if rotationChoice ==1:
            motSpeed[0]=5
            motSpeed[1]=-5
        else:
            motSpeed[0]=-5
            motSpeed[1]=5
        return curTime, 'DesperateTurn', rotationChoice
    motSpeed =[0,0]
    return time(), 'Exploring', None

def stateModerator():
    global ending
    global motSpeed
    curState= 'Exploring'
    nextState='Exploring'
    curTime = time()
    rotationChoice = None
    while True:
        nextState = determineState(curState)
        if nextState!=curState:
            curTime = time()
        if nextState=="Exploring":
            curTime, curState, rotationChoice=expMot(curTime, rotationChoice)
        elif nextState=="LeftBumperAvoidance":
            curTime, curState, rotationChoice = lbMot(curTime, rotationChoice)
        elif nextState=="RightBumperAvoidance":
            curTime, curState, rotationChoice = rbMot(curTime, rotationChoice)
        elif nextState=="ForwardDepthAvoidance":
            curTime, curState, rotationChoice = fdMot(curTime, rotationChoice)
        elif nextState== "BackDepthAvoidance":
            curTime, curState, rotationChoice=bdMot(curTime, rotationChoice)
        elif nextState== "ForwardLeftDepthAvoidance":
            curTime, curState, rotationChoice=flMot(curTime, rotationChoice)
        elif nextState== "ForwardMidDepthAvoidance":
            curTime, curState, rotationChoice=fmMot(curTime, rotationChoice)
        elif nextState== "ForwardRightDepthAvoidance":
            curTime, curState, rotationChoice=frMot(curTime, rotationChoice)
        elif nextState== "DesperateTurn":
            curTime, curState, rotationChoice=despTurn(curTime, rotationChoice)
        if ending:
            break
        sleep(0.1)

def sensorModerator():
    global ending
    curTime=time()
    while True:
        doNotFallOff()
        new_colorLeft = csLeft.color
        new_colorMid = csMid.color
        new_colorRight = csRight.color
        if new_colorLeft==5 or new_colorMid==5 or new_colorRight==5 or (int(time()) - curTime)> 50:
            break
        colorAvoid(5)
        colorAvoid(6)
    ending=True

global standardSpeed
standardSpeed = 20
global backUnsafe
global forwardCLUnsafe
global forwardCRUnsafe
global forwardCMUnsafe
global leftBumperUnsafe
global rightBumperUnsafe
global forwardSonarUnsafe

print("Start!")
backUnsafe=False
forwardCLUnsafe=False
forwardCRUnsafe=False
forwardCMUnsafe=False
leftBumperUnsafe=False
rightBumperUnsafe=False
forwardSonarUnsafe=False

global motLeftSpeed
global motRightSpeed

motorCommand = 'Stop'
motSpeed =[0,0]
global ending
ending= False

stopColors= [0,2,3,5,6]
left_motor = LargeMotor(OUTPUT_A)
right_motor = LargeMotor(OUTPUT_D)
measurement_arm = Motor(OUTPUT_B)
leds = Leds()
s = Sound()
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

server_mac = 'CC:78:AB:50:B2:46'
sock, sock_in, sock_out = connect(server_mac)
senMod = threading.Thread(target=sensorModerator, args=())
statMod = threading.Thread(target=stateModerator, args=())
motMod = threading.Thread(target=motorModerator, args=())
blueMod = threading.Thread(target=listen, args=(sock_in,))
blueMod.start()
senMod.start()
sleep(1)
statMod.start()
motMod.start()
senMod.join()
sendInfo(sock_out, 2)
blueMod.join()
disconnect(sock_in)
disconnect(sock_out)
disconnect(sock)
statMod.join()
motMod.join()
print("Finished")
sleep(5)
