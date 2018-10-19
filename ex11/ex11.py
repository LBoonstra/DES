'''
Created on 19 okt. 2018

@author: Richa
'''
from robotica import slave
from robotica import master
from robotica import roleInLife

if __name__ == '__main__':
    server_mac = '00:17:E9:B4:C7:4E'
    position = roleInLife(slave(server_mac))
    position.connect()
    position.run()