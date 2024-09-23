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