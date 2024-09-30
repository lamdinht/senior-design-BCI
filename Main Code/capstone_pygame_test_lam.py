# 9/26/24 - Serial Comms w/o Strings
import serial.tools.list_ports_windows
import re
import serial
import time
import pygame

#########################################################################################################
# This section opens COM5 (for this PC) serial monitor to the Arduino and sends over a string with the angles for the arm (DO NOT EDIT)
ports = serial.tools.list_ports_windows.comports()
serialInst = serial.Serial()

portsList = []
arduinoPort = []

for onePort in ports:
    portsList.append(str(onePort))
    if "Arduino Uno" in str(onePort):
        arduinoPort = list(map(int, re.findall('\d+', str(onePort))))[0]
    
print(arduinoPort)

serialInst.baudrate = 9600
serialInst.port = "COM" + str(arduinoPort)

serialInst.open()
#########################################################################################################
# LAM'S REVIEW
'''
/*  INPUT INCLUDES ANGLES FOR ARM MOVEMENT
    FORMAT: byte 0 has to be 255          --> Extra layer for error checking 
            1st byte: M1
            2nd byte: M2
            3rd byte: M3
            4th byte: M4
            5th byte: M5
            6th byte: M6
            ending byte has to be 254     --> Extra layer for error checking 
    INPUT SEQUENCE EXAMPLE: [255, 90, 90, 90, 90, 90, 73, 254] equivalent to hex: [0xFF, 0x5A, 0x5A, 0x5A, 0x5A, 0x5A, 0x49, 0xFE]
    BUFFER: [90, 90, 90, 90, 90, 73]
    OUTPUT: Move arm to position (90, 90, 90, 90, 90, 73)
'''

currState = [90,90,90,90,90,20] # this is the bootup default arm state
# outputBuffer = [200, 90, 90, 90, 90, 90, 20, 199] # this is the bootup default arm state *changed from 255, 254 to 200, 199 <- This is what newOutput is

pygame.init() # just for keyboard control

window = pygame.display.set_mode((200,200))
clock = pygame.time.Clock() # we prob don't need this
running = True # keep pygame wind. open

lastTime = 0.0 # gives the time the last key was pressed
lastSave = 0.0 # init. time as 0

beginRead = 200 # 200 first index
endRead = 199 # 199 last index

ang_vel = 10 # basically the degree increment per call


def updateSerial():
    global lastSave # not a local function; used to limit the time between instructions sent to the arduino serial monitor
    if delayTime - lastSave >= 0.5: 
        for i in range(8):
            if i == 0:
                serialInst.write(bytearray([beginRead]))
                print("Sent over: ", beginRead, "\n")
                print(serialInst.read(1))

            elif i == 7:
                serialInst.write(bytearray([endRead]))
                print("Sent over: ", endRead, "\n")
            else:
                serialInst.write(bytearray([currState[i - 1]]))
                print("Sent over: ", currState[i-1], "\n")

        print("Updated Values: ")
        print(currState,"\n")

        lastSave = time.process_time() # update last time flag


        
while running:
    currTime = time.process_time()
    if currTime - lastTime >= 0.1:

        for event in pygame.event.get():
            if event.type == pygame.quit:
                running = False
        key = pygame.key.get_pressed()

        if key[pygame.K_w]: # move m2 up
            if int(currState[1]) <= (165 - ang_vel) and int(currState[1]) >= 15:
                currState[1] += ang_vel
                delayTime = time.process_time()
                updateSerial()
                lastTime = time.process_time()

        if key[pygame.K_a]: # turn m1 left
            if int(currState[0]) <= 180 and int(currState[0]) >= ang_vel:
                currState[0] -= ang_vel
                delayTime = time.process_time()
                updateSerial()
                lastTime = time.process_time()

        if key[pygame.K_s]: # move m2 down
            if int(currState[1]) < 165 and int(currState[1]) >= (15 + ang_vel):
                currState[1] -= ang_vel
                delayTime = time.process_time()
                updateSerial()
                lastTime = time.process_time()

        if key[pygame.K_d]: # turn m1 right
            if int(currState[0]) <= (180 - ang_vel) and int(currState[0]) >= 0:
                currState[0] += ang_vel
                delayTime = time.process_time()
                updateSerial()
                lastTime = time.process_time()

        if key[pygame.K_t]: # move m3 up
            if int(currState[2]) <= (180 - ang_vel) and int(currState[2]) >= 0:
                currState[2] += ang_vel
                delayTime = time.process_time()
                updateSerial()
                lastTime = time.process_time()

        if key[pygame.K_g]: # move m3 down
            if int(currState[2]) <= 180 and int(currState[2]) >= ang_vel:
                currState[2] -= ang_vel
                delayTime = time.process_time()
                updateSerial()
                lastTime = time.process_time()

        if key[pygame.K_y]: # move m4 up
            if int(currState[3]) <= (180 - ang_vel) and int(currState[3]) >= 0:
                currState[3] += ang_vel
                delayTime = time.process_time()
                updateSerial()
                lastTime = time.process_time()

    
        if key[pygame.K_h]: # move m4 down
            if int(currState[3]) <= 180 and int(currState[3]) >= ang_vel:
                currState[3] -= ang_vel
                delayTime = time.process_time()
                updateSerial()
                lastTime = time.process_time()

        if key[pygame.K_LEFT]: # turn m5 to left
            if int(currState[4]) <= 180 and int(currState[4]) >= ang_vel:
                currState[4] -= ang_vel
                delayTime = time.process_time()
                updateSerial()
                lastTime = time.process_time()

        if key[pygame.K_RIGHT]: # turn m5 to right
            if int(currState[4]) <= (180 - ang_vel) and int(currState[4]) >= 0:
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
