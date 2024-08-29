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

while True:
    command = input("Input format: M1,M2,M3,M4,M5,M6\n")
    serialInst.write(command.encode('utf-8'))

