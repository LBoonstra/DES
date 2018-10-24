'''
Created on 19 okt. 2018

@author: Richa
'''
from robotica import slave
from robotica import master
from robotica import roleInLife

if __name__ == '__main__':
    server_mac = 'CC:78:AB:50:DA:17'
    position = roleInLife(slave(server_mac))
    position.connect()
    position.run()