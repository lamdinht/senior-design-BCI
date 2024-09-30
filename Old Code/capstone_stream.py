#8.9.24

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

serialInst.baudrate = 9600
serialInst.port = "COM" + str(arduinoPort)

serialInst.open()

###############################################
prevStr = "180,90,90,90,90,10"
prevState = list(prevStr.split(","))
currStr = input("Input format: M1,M2,M3,M4,M5,M6\n")
currState = list(currStr.split(","))

while currState != prevState:
    for i in range(len(currState)):
       if currState[i] != prevState[i]:
           prevState[i] = currState[i]
    prevStr = ''.join(prevState)

###############################################

while True:
    command = input("Input format: M1,M2,M3,M4,M5,M6\n")

    #termInput = input("What would you like to do?\n")
    
    # if termInput.lower() == "update":
    #   updVals = input("Input format: M1,M2,M3,M4,M5,M6\n")
    #   serialInst.write(updVals.encode('utf-8'))

    serialInst.write(command.encode('utf-8'))




# write a state that basically if we take in s1,s2,...,sn, and only s2 changes, we save the previous state and ONLY update s2.