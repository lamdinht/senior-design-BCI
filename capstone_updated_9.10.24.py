<<<<<<< Updated upstream
# 9/10/24 - Implementing Embedded Stuffs

import serial.tools.list_ports_windows
import re

ports = serial.tools.list_ports_windows.comports()
serialInst = serial.Serial()

portsList = []
arduinoPort = []

for onePort in ports:
    portsList.append(str(onePort))
    if "Arduino Uno" in str(onePort):
        arduinoPort = list(map(int, re.findall('\d+', str(onePort))))[0]
    
print(arduinoPort)

# LAM'S REVIEW
serialInst.baudrate = 9600
serialInst.port = "COM" + str(arduinoPort)

serialInst.open()
'''
###############################################
prevStr = "180,90,90,90,90,10" # this is the bootup default arm state
prevStr = prevStr.replace(" ", "") # remove any spaces if present
prevState = list(prevStr.split(",")) # turns the string into a list so we may compare values, split by ,

while True:
    termInput = input("What would you like to do?\n")

    if termInput.lower() == "update":
        print("Old prev state: %s\n" % prevStr)
        currStr = input("Input format: M1,M2,M3,M4,M5,M6\n")
        currStr = currStr.replace(" ", "") # remove spaces
        currState = list(currStr.split(",")) # split into list via ,

        while currState != prevState:
            for i in range(len(currState)):
                if currState[i] != prevState[i]:
                    prevState[i] = currState[i]
            prevStr = ','.join(prevState)
        
        print("New prev state: %s\n" % prevStr)
        serialInst.write(prevStr.encode('utf-8'))
        print("Values Updated\n")

    elif termInput.lower() == "condition 2":
        cond2 = input("Whatever condition read and do\n")

# write a state that basically if we take in s1,s2,...,sn, and only s2 changes, we save the previous state and ONLY update s2.
'''
=======
# 9/10/24 - Implementing Embedded Stuffs

import serial.tools.list_ports_windows
import re

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

serialInst.baudrate = 9600
serialInst.port = "COM" + str(arduinoPort)

serialInst.open()

###############################################

# try to integrate keyboard controls? (tkinter/pygame)

pygame.init()
window = pygame.display.set_mode((1280,720))
clock = pygame.time.Clock()
ang_vel = 5
running = True
tick = 0

while running:
    for event in pygame.event.get():
        if event.type == pygame.quit:
            running = False
    key = pygame.key.get_pressed()

    if key[pygame.K_w]:
        # move m2 up (set 5* per call?)
    if key[pygame.K_a]:
        # rotate m1 to the left
    if key[pygame.K_s]:
        # move m2 down
    if key[pygame.K_d]:
        # move m1 to the right
    if key[pygame.K_t]:
        # move m3 up
    if key[pygame.K_g]:
        # move m4 down
    if key[pygame.K_LEFT]:
        # turn m5 to left
    if key[pygame.K_RIGHT]:
        # turn m5 to right
    if key[pygame.K_UP]:
        # open m6
    if key[pygame.K_DOWN]:
        # close m6
    


# tick = clock.tick(60)/1000 # returns the val. since last call in ms

###############################################
prevStr = "180,90,90,90,90,10" # this is the bootup default arm state
prevStr = prevStr.replace(" ", "") # remove any spaces if present
prevState = list(prevStr.split(",")) # turns the string into a list so we may compare values, split by ,

while True:
    termInput = input("What would you like to do?\n")

    if termInput.lower() == "update":
        print("Old prev state: %s\n" % prevStr)
        currStr = input("Input format: M1,M2,M3,M4,M5,M6\n")
        currStr = currStr.replace(" ", "") # remove spaces
        currState = list(currStr.split(",")) # split into list via ,

        while currState != prevState:
            for i in range(len(currState)):
                if currState[i] != prevState[i]:
                    prevState[i] = currState[i]
            prevStr = ','.join(prevState)
        
        print("New prev state: %s\n" % prevStr)
        serialInst.write(prevStr.encode('utf-8'))
        print("Values Updated\n")

    elif termInput.lower() == "condition 2":
        cond2 = input("Whatever condition read and do\n")
###############################################
# write a state that basically if we take in s1,s2,...,sn, and only s2 changes, we save the previous state and ONLY update s2.

pygame.quit()
>>>>>>> Stashed changes
