# Code for receiving results sent out from emotiv_lsl receiver. Results are interpreted and sent out to Arduino code
# Date: 12/1/24

# General imports
import serial.tools.list_ports_windows
import re
import time
import serial

# Socket communication code
from multiprocessing.connection import Listener
listener = Listener(('localhost', 6000), authkey=b'secret password')
# conn = listener.accept()

# Define constants/variables
currState = [90, 90, 90, 90, 90, 20] # this is the bootup default arm state
beginRead = 200 # 200 first index
endRead = 199 # 199 last index
ang_vel = 5 # basically the degree increment per call


# Opens COM5 port to Arduino code
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

# Function to send updated buffer to Arduino code
def updateSerial():
    for i in range(8):
        if i == 0:
            serialInst.write(bytearray([beginRead]))
            print("Sent over: ", beginRead, "\n")
            # print(serialInst.read(1))
        elif i == 7:
            serialInst.write(bytearray([endRead]))
            print("Sent over: ", endRead, "\n")
        else:
            serialInst.write(bytearray([currState[i - 1]]))
            print("Sent over: ", currState[i-1], "\n")

    print("Updated Values: ")
    print(currState,"\n")

# Get's whatever data is in the sender's (emotiv receiever) buffer
def getData():
    global receievedVal
    print('connection accepted from', listener.last_accepted) # accept identity
    receievedVal = conn.recv()
    receievedVal = int(receievedVal) # typecast as int
    print('Received val: ')
    print(receievedVal)

# Main iterated code
def main():
    getData() # call function to update recievedVal
    if (receievedVal == 1): # move m2 up
        if int(currState[1]) <= (165 - ang_vel) and int(currState[1]) >= 15:
            print('\nReceived a 1 successfully: \n')
            currState[1] += ang_vel
            updateSerial()
    if (receievedVal == 0): # move m2 down
        if int(currState[1]) <= 165 and int(currState[1]) >= (15 + ang_vel):
            currState[1] -= ang_vel
            updateSerial()

cnt = 0
while True: # some boilerplate thingy
    if (cnt < 1):
        conn = listener.accept()
        cnt += 1
    main()
