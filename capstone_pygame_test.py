# 9/10/24 - Implementing Embedded Stuffs
import serial.tools.list_ports_windows
import re
import time
import pygame

#########################################################################################################
# This section opens COM5 (for this PC) serial monitor to the Arduino and sends over a string with the angles for the arm
ports = serial.tools.list_ports_windows.comports()
serialInst = serial.Serial()

portsList = []
arduinoPort = []

for onePort in ports:
    portsList.append(str(onePort))
    if "Arduino Uno" in str(onePort):
        arduinoPort = list(map(int, re.findall('\d+', str(onePort))))[0]
    
print(arduinoPort)

serialInst.baudrate = 115200
serialInst.port = "COM" + str(arduinoPort)

serialInst.open()

#########################################################################################################

pygame.init() # just for keyboard control

window = pygame.display.set_mode((200,100))
clock = pygame.time.Clock()
running = True # keep pygame wind. open

prevStr = "90,90,90,90,90,20" # this is the bootup default arm state
# Arm angle ranges: m1: 0-180, m2: 15-165, m3: 0-180, m4: 0-180, m5: 0-180, m6: 10-73

# prevStr = prevStr.replace(" ", "") # remove any spaces if present
currState = list(prevStr.split(",")) # turns the string into a list so we may compare values, split by ,
currStateStr = currState
for i in range(len(currState)):
    currState[i] = int(currState[i]) # turns list elements from str to int

lastTime = 0.0 # gives the time the last key was pressed
lastSave = 0.0 # init. time as 0\

# define the max/mins for each servo (I don't know why I wrote this)
max1345 = 180 # min is zero; For m1, m3, m4, and m5
max2 = 165 # max for m2
min2 = 15 # min for m2
# for m6, max is 73 and min is 10

ang_vel = 10 # basically the degree increment per call

def updateSerial():
    global lastSave # not a local function; used to limit the time between instructions sent to the arduino serial monitor

    if delayTime - lastSave >= 1: 
        
        lastSave = time.process_time()

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
    if currTime - lastTime >= 0.1:

        for event in pygame.event.get():
            if event.type == pygame.quit:
                running = False
        key = pygame.key.get_pressed()

        if key[pygame.K_w]: # move m2 up
            if int(currState[1]) <= (max2-ang_vel) and int(currState[1]) >= min2:
                currState[1] += ang_vel
                delayTime = time.process_time()
                updateSerial()
                lastTime = time.process_time()

        if key[pygame.K_a]: # turn m1 left
            if int(currState[0]) <= max1345 and int(currState[0]) >= ang_vel:
                currState[0] -= ang_vel
                delayTime = time.process_time()
                updateSerial()
                lastTime = time.process_time()

        if key[pygame.K_s]: # move m2 down
            if int(currState[1]) < max2 and int(currState[1]) >= (min2 +ang_vel):
                currState[1] -= ang_vel
                delayTime = time.process_time()
                updateSerial()
                lastTime = time.process_time()

        if key[pygame.K_d]: # turn m1 right
            if int(currState[0]) <= (max1345 - ang_vel) and int(currState[0]) >= 0:
                currState[0] += ang_vel
                delayTime = time.process_time()
                updateSerial()
                lastTime = time.process_time()

        if key[pygame.K_t]: # move m3 up
            if int(currState[2]) <= (max1345 - ang_vel) and int(currState[2]) >= 0:
                currState[2] += ang_vel
                delayTime = time.process_time()
                updateSerial()
                lastTime = time.process_time()

        if key[pygame.K_g]: # move m3 down
            if int(currState[2]) <= max1345 and int(currState[2]) >= ang_vel:
                currState[2] -= ang_vel
                delayTime = time.process_time()
                updateSerial()
                lastTime = time.process_time()

        if key[pygame.K_y]: # move m4 up
            if int(currState[3]) <= (max1345 - ang_vel) and int(currState[3]) >= 0:
                currState[3] += ang_vel
                delayTime = time.process_time()
                updateSerial()
                lastTime = time.process_time()

    
        if key[pygame.K_h]: # move m4 down
            if int(currState[3]) <= max1345 and int(currState[3]) >= ang_vel:
                currState[3] -= ang_vel
                delayTime = time.process_time()
                updateSerial()
                lastTime = time.process_time()

        if key[pygame.K_LEFT]: # turn m5 to left
            if int(currState[4]) <= max1345 and int(currState[4]) >= ang_vel:
                currState[4] -= ang_vel
                delayTime = time.process_time()
                updateSerial()
                lastTime = time.process_time()

        if key[pygame.K_RIGHT]: # turn m5 to right
            if int(currState[4]) <= (max1345 - ang_vel) and int(currState[4]) >= 0:
                currState[4] += ang_vel
                delayTime = time.process_time()
                updateSerial()
                lastTime = time.process_time()

        if key[pygame.K_UP]: # open m6
            if int(currState[5]) <= (73 - ang_vel) and int(currState[5]) >= 10:
                currState[5] += ang_vel
                delayTime = time.process_time()
                updateSerial()
                lastTime = time.process_time()

        if key[pygame.K_DOWN]: # close m6
            if int(currState[5]) <= 73 and int(currState[5]) >= (10 + ang_vel):
                currState[5] -= ang_vel
                delayTime = time.process_time()
                updateSerial()
                lastTime = time.process_time()