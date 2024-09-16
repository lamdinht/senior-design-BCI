# 9/10/24 - Implementing Embedded Stuffs

import serial.tools.list_ports_windows
import re
import time
import pygame

ports = serial.tools.list_ports_windows.comports()
serialInst = serial.Serial()

portsList = []
arduinoPort = []

for onePort in ports:
    portsList.append(str(onePort))
    if "Arduino Uno" in str(onePort):
        arduinoPort = list(map(int, re.findall('\d+', str(onePort))))[0]
    
print(arduinoPort)

serialInst.baudrate = 38400
serialInst.port = "COM" + str(arduinoPort)

serialInst.open()

###############################################
pygame.init()

window = pygame.display.set_mode((1280,720))
clock = pygame.time.Clock()
ang_vel = 5
running = True

prevStr = "90,90,90,90,90,20" # this is the bootup default arm state
# Arm angle ranges: m1: 0-180, m2: 15-165, m3: 0-18-, m4: 0-180, m5: 0-180, m6: 10-73

# prevStr = prevStr.replace(" ", "") # remove any spaces if present
currState = list(prevStr.split(",")) # turns the string into a list so we may compare values, split by ,
currStateStr = currState
for i in range(len(currState)):
    currState[i] = int(currState[i]) # turns list elements from str to int

lastTime = 0.0 # gives the time the last key was pressed

def updateSerial():
    print("Current State: %s\n" % currState)
    for i in range(len(currState)): # turn back to str
        currStateStr[i] = str(currState[i])

    currStr = ','.join(currStateStr) # turn str list into str

    serialInst.write(currStr.encode('utf-8')) # write to Arduino serial monitor
    print("Values Updated\n")

    for i in range(len(currState)):
        currState[i] = int(currState[i]) # turns list elements from str to int

while running:
    currTime = time.process_time()

    if currTime - lastTime >= 0.2:

        for event in pygame.event.get():
            if event.type == pygame.quit:
                running = False
        key = pygame.key.get_pressed()

        if key[pygame.K_w]: # move m2 up
            if int(currState[1]) <= 160 and int(currState[1]) >= 15:
                currState[1] += ang_vel
                updateSerial()
                lastTime = time.process_time()

        if key[pygame.K_a]: # turn m1 left
            if int(currState[0]) <= 180 and int(currState[0]) >= 5:
                currState[0] -= ang_vel
                updateSerial()
                lastTime = time.process_time()

        if key[pygame.K_s]: # move m2 down
            if int(currState[1]) <= 165 and int(currState[1]) >= 20:
                currState[1] -= ang_vel
                updateSerial()
                lastTime = time.process_time()

        if key[pygame.K_d]: # turn m1 right
            if int(currState[0]) <= 175 and int(currState[0]) >= 0:
                currState[0] += ang_vel
                updateSerial()
                lastTime = time.process_time()

        if key[pygame.K_t]: # move m3 up
            if int(currState[2]) <= 175 and int(currState[2]) >= 0:
                currState[2] += ang_vel
                updateSerial()
                lastTime = time.process_time()

        if key[pygame.K_g]: # move m3 down
            if int(currState[2]) <= 180 and int(currState[2]) >= 5:
                currState[2] -= ang_vel
                updateSerial()
                lastTime = time.process_time()

        if key[pygame.K_y]: # move m4 up
            if int(currState[3]) <= 175 and int(currState[3]) >= 0:
                currState[3] += ang_vel
                updateSerial()
                lastTime = time.process_time()
        
        if key[pygame.K_h]: # move m4 down
            if int(currState[3]) <= 180 and int(currState[3]) >= 5:
                currState[3] -= ang_vel
                updateSerial()
                lastTime = time.process_time()

        if key[pygame.K_LEFT]: # turn m5 to left
            if int(currState[4]) <= 180 and int(currState[4]) >= 5:
                currState[4] -= ang_vel
                updateSerial()
                lastTime = time.process_time()

        if key[pygame.K_RIGHT]: # turn m5 to right
            if int(currState[4]) <= 175 and int(currState[4]) >= 0:
                currState[4] += ang_vel
                updateSerial()
                lastTime = time.process_time()

        if key[pygame.K_UP]: # open m6
            if int(currState[5]) <= 68 and int(currState[5]) >= 10:
                currState[5] += ang_vel
                updateSerial()
                lastTime = time.process_time()

        if key[pygame.K_DOWN]: # close m6
            if int(currState[5]) <= 73 and int(currState[5]) >= 15:
                currState[5] -= ang_vel
                updateSerial()
                lastTime = time.process_time()
