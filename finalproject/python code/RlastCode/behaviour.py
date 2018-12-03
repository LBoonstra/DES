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
import bluetooth, threading
from time import sleep
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
backUnsafe=False
forwardCLUnsafe=False
forwardCRUnsafe=False
forwardCMUnsafe=False

def stateF():
    if backUnsafe:
        return 'DesperateTurn'
    else:
        return ''
    
def stateBD():
    if forwardCLUnsafe or forwardCRUnsafe or forwardCMUnsafe:
        return 'DesperateTurn'
    else:
        return ''

def determineState(curState):
    switcher = { 
        'Exploring': stateExp(),
        #'BumperAvoidance': stateBump(), 
        #'ObstacleAvoidance':stateObst(), 
        'BackDepthAvoidance': stateBD(), 
        'ForwardLeftDepthAvoidance': stateF(), 
        'ForwardMidDepthAvoidance': stateF(), 
        'ForwardRightDepthAvoidance': stateF(), 
        'DesperateTurn': 'DesperateTurn',
        }
    nextState= switcher.get(curState)
    return nextState if not (nextState=='') else curState

def motorBehaviour():
    states = ['Exploring', 'BumperAvoidance', 'ObstacleAvoidance', 'BackDepthAvoidance', 'ForwardLeftDepthAvoidance', 'ForwardMidDepthAvoidance', 'ForwardRightDepthAvoidance', 'DesperateTurn']
    curState= 'Exploring'
    while True:
        curState = determineState(curState)
        switcher = { 
            'Exploring': exploreMotor(),
            'BumperAvoidance': bumperAvoid(), 
            'ObstacleAvoidance':ObstacleAvoid(), 
            'BackDepthAvoidance': backAvoid(), 
            'ForwardLeftDepthAvoidance': forLefAvoid(), 
            'ForwardMidDepthAvoidance': forMidAvoid(), 
            'ForwardRightDepthAvoidance': forRightAvoid(), 
            'DesperateTurn': despTurn(),
            }

colors_found = [False, False, False]
left_motor = LargeMotor(OUTPUT_A)
right_motor = LargeMotor(OUTPUT_D)
tsLeft = TouchSensor(INPUT_1)
tsRight = TouchSensor(INPUT_4)
leds = Leds()
s = Sound()
#s.speak("To infinity, but not beyond. Definitely not beyond")
cs = ColorSensor()
counter =50
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
cs.calibrate_white()

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
        
def run():
    sock, sock_in, sock_out = connect(server_mac, is_master)
    listener = threading.Thread(target=listen, args=(sock_in))
    listener.start()
    while True:
        if counter ==50:
            print("hi")
            counter =0
            speedLeft=random.randint(10,30)
            speedRight=random.randint(10,30)
            print("bye")
        else:
            print("hi2")
            counter+=1
            print("bye1")
        print("Past if statement")
        left_motor.on_for_seconds(SpeedPercent(speedLeft), 10,  block=False)
        right_motor.on_for_seconds(SpeedPercent(speedRight), 10,  block=False)
        new_color = cs.color
        distance = us.value()/10
        print("I should be riding")
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
            #s.speak("No drinking on the mission")
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
        if new_color == 2 and not colors_found[0]==True:
            left_motor.stop()
            right_motor.stop()
            colors_found[0]=True
            s.speak("Found Blue")
            sendInfo(sock_out, 0)
        if new_color == 4 and not colors_found[1]==True:
            left_motor.stop()
            right_motor.stop()
            colors_found[1]=True
            s.speak("Found Yellow")
            sendInfo(sock_out, 1)
        if new_color == 5 and not colors_found[2]==True:
            left_motor.stop()
            right_motor.stop()
            colors_found[2]=True
            s.speak("Found red")
            sendInfo(sock_out, 2)
        if all(colorF==True for colorF in colors_found):
            left_motor.stop()
            right_motor.stop()
            break
    busy=False
    disconnect(sock_in)
    disconnect(sock_out)
    disconnect(sock)
    s.speak("Mission complete")
        
run()
    
    