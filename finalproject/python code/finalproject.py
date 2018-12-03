#!/usr/bin/env python3

import ev3dev.auto as ev3
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

#is_master = True
is_master = False
busy = True
server_mac = 'CC:78:AB:50:DA:17'
colors_found = [False, False, False]
colorsList = ['blue', 'yellow', 'red']
global otherNotDone
otherNotDone= True
stopColors= [6]

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

'''
def start_listening(sock_in, sock_out):
    i = 1
    sock_out.write(str(1) + '\n')
    sock_out.flush()
    print('Sent ' + str(1))
    listen(sock_in, sock_out)
'''
    
def sendInfo(sock_out, integerFound):
    sock_out.write(str(integerFound) + '\n')
    sock_out.flush()
    print(str(integerFound))

def listen(sock_in):
    print('Now listening...', flush=True)
    global otherNotDone
    global stopColors
    translator= [2,4,5]
    while busy:
        data = int(sock_in.readline())
        print("Received something", flush=True)
        if data==3:
            otherNotDone=False
        elif colors_found[data]==False:
            colors_found[data]=True
            s.speak("Received " + colorsList[data] + " found")
            stopColors.remove(translator[data])
        sleep(1)
        #sock_out.write(str(1) + '\n')
        #sock_out.flush()
        #print('Sent ' + str(1))

colors_found = [False, False, False]
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
#csLeft.calibrate_white()

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
        
def mainfunction():
    global otherNotDone
    global stopColors
    #sock, sock_in, sock_out = connect(server_mac, is_master)
    #listener = threading.Thread(target=listen, args=(sock_in, ))
    #listener.start()
    counter =50
    notpressed=True
    btn = ev3.Button()
    while notpressed:
        if btn.left:
            print("I was pressed")
            notpressed=False
        else:
            sleep(1)
    while True:
        if counter ==50:
            counter =0
            speedLeft=random.randint(10,30)
            speedRight=random.randint(10,30)
        else:
            counter+=1
        left_motor.on_for_seconds(SpeedPercent(speedLeft), 10,  block=False)
        right_motor.on_for_seconds(SpeedPercent(speedRight), 10,  block=False)
        new_colorLeft = csLeft.color
        new_colorMid = csMid.color
        new_colorRight = csRight.color
        distance = us.value()/10
        if (new_colorLeft in stopColors) or (new_colorMid in stopColors) or (new_colorRight in stopColors): # == 1 or new_color == 2 or :
            left_motor.stop()
            right_motor.stop()
            color_check = []
            '''
            for x in range(0,100):
                color_check.append(cs.color)
            
            conclusion = max(color_check,key=color_check.count)
            if conclusion == 2 and not colors_found[0]==True:
                colors_found[0]=True
                s.speak("Found Blue")
                #sendInfo(sock_out, 0)
                stopColors.remove(conclusion)
            elif conclusion == 4 and not colors_found[1]==True:
                colors_found[1]=True
                s.speak("Found Yellow")
                #sendInfo(sock_out, 1)
                stopColors.remove(conclusion)
            elif conclusion == 5 and not colors_found[2]==True:
                colors_found[2]=True
                s.speak("Found red")
                #sendInfo(sock_out, 2)
                stopColors.remove(conclusion)
                '''
            #if conclusion ==6:
            leds.set_color("LEFT", "RED")
            leds.set_color("RIGHT", "RED") 
            recoverLine()
            leds.set_color("LEFT", "GREEN")
            leds.set_color("RIGHT", "GREEN") 
            counter =0
            speedLeft=random.randint(10,30)
            speedRight=random.randint(10,30)
            '''
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
            '''
        if all(colorF==True for colorF in colors_found):
            left_motor.stop()
            right_motor.stop()
            break
    #sendInfo(sock_out,3)
    #while otherNotDone:
    #    sleep(0.1)
    busy=False
    #disconnect(sock_in)
    #disconnect(sock_out)
    #disconnect(sock)
    s.speak("Mission complete")
        
mainfunction()
    
    