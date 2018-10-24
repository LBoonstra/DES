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

class slave:
    '''
    classdocs
    '''


    def __init__(self, address):
        self.address=address
        self.sock = None
        self.sockWMake= None
        self.sockRMake = None
        self.port=3
        
    def connect(self,server_mac):
        self.sock = bluetooth.BluetoothSocket(bluetooth.RFCOMM)
        print('Connecting...')
        self.sock.connect((server_mac, self.port)) 
        print('Connected to ', server_mac)
        self.sockRMake = self.sock.makefile('r')
        self.sockWMake=self.sock.makefile('w')
        
    def disconnect(self,sock):
        sock.close()
        
    def listen(self, sock_in, sock_out):
        print('Now listening...')
        while True:
            data = int(sock_in.readline())
            print('Received ' + str(data))
            data += 1
            sleep(1)
            sock_out.write(str(data) + '\n')
            sock_out.flush()
            print('Sent ' + str(data))
        
    def run(self):
        listener = threading.Thread(target=self.listen, args=(self.sockRMake, self.sockWMake))
        listener.start()
        i = 0
        while i < 20:
            print('[' + str(i) + '] Doing something...')
            sleep(1)
            i += 1
        self.disconnect(self.sockRMake)
        self.disconnect(self.sockWMake)
        self.disconnect(self.sock)
        
        