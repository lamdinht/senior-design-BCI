# Date: 11/30/24
# NOTES: This is using Python 3.10.4, tensorflow 2.17.1, keras 3.7.0, ml_dtypes 0.5.0 (old was 0.4.1)
import os
import csv
import tensorflow as tf 
import numpy as np
from keras import saving, Model
import time
# from multiprocessing.connection import Client
#############################################################################
# conn = Client(('localhost', 6000), authkey=b'secret password') # make this program a client

loopMax = 156 # max iterations
maxEle = 19968 # = 128*156
offset = 83 # offset number of elements from the beginning
buffer = np.zeros((14, maxEle)); # creates 4(rows)x19,968(columns) array of zeroes
nnBuffer = np.zeros((128, 9, 9)) # creates 128 sets of 9(rows)x9(columns) arrays
nnOutput = np.zeros((2,2))
timeStart = 0.0
timeEnd = 0.0
fpath = "C:\\Users\\borde\\Downloads\\ECE 3970-001 - Capstone\\Main Code 11.25.24\\3-Branch-CNN-25-11.keras" # path to keras file
cpath = "C:\\Users\\borde\\Downloads\\ECE 3970-001 - Capstone\\Main Code 11.25.24\\capstone_final_test.csv" # path to csv file

loaded_model = saving.load_model(fpath) # load the keras model into loaded_model
# Model.summary(loaded_model) # load summary of loaded_model

# We first load the CSV data into a 14x19968 element array (oldest stored neart 0, newest near index 19967)
for i in range(14): # iterate through the columns (AF3-AF4)
    with open(cpath, 'r') as f:
        csvRead = csv.reader(f)
        mycsv = list(csvRead)
    for x in range(maxEle): # iterate through the 128 rows/markers
        buffer[i][x] = mycsv[(x + offset)][i + 4]
# Now, we feed the buffer data into the neural network. We begin by loading the buffer data we got into a 9x9x128 3D-array

# timeStart = time.time() # time to run for loops

# Syntax: nnBuffer[set number (0-127)][row (0-8)][col (0-8)]
for count in range(maxEle - 128):
    n0 = np.sum(buffer[0][count:(count + 127)])/128.0
    n1 = np.sum(buffer[1][count:(count + 127)])/128.0
    n2 = np.sum(buffer[2][count:(count + 127)])/128.0
    n3 = np.sum(buffer[3][count:(count + 127)])/128.0
    n4 = np.sum(buffer[4][count:(count + 127)])/128.0
    n5 = np.sum(buffer[5][count:(count + 127)])/128.0
    n6 = np.sum(buffer[6][count:(count + 127)])/128.0
    n7 = np.sum(buffer[7][count:(count + 127)])/128.0
    n8 = np.sum(buffer[8][count:(count + 127)])/128.0
    n9 = np.sum(buffer[9][count:(count + 127)])/128.0
    n10 = np.sum(buffer[10][count:(count + 127)])/128.0
    n11 = np.sum(buffer[11][count:(count + 127)])/128.0
    n12 = np.sum(buffer[12][count:(count + 127)])/128.0
    n13 = np.sum(buffer[13][count:(count + 127)])/128.0

    for i in range(128): # Load AF3 
        nnBuffer[i][1][3] = buffer[0][i + count] - n0
    for i in range(128): # Load F7
        nnBuffer[i][2][0] = buffer[1][i + count] - n1
    for i in range(128): # Load F3 
        nnBuffer[i][2][2] = buffer[2][i + count] - n2
    for i in range(128): # Load FC5
        nnBuffer[i][3][1] = buffer[3][i + count] - n3
    for i in range(128): # Load T7 
        nnBuffer[i][4][0] = buffer[4][i + count] - n4
    for i in range(128): # Load P7 
        nnBuffer[i][6][0] = buffer[5][i + count] - n5
    for i in range(128): # Load O1 
        nnBuffer[i][8][3] = buffer[6][i + count] - n6
    for i in range(128): # Load O2 
        nnBuffer[i][8][5] = buffer[7][i + count] - n7
    for i in range(128): # Load P8 
        nnBuffer[i][6][8] = buffer[8][i + count] - n8
    for i in range(128): # Load T8 
        nnBuffer[i][4][8] = buffer[9][i + count] - n9
    for i in range(128): # Load FC6 
        nnBuffer[i][3][7] = buffer[10][i + count] - n10
    for i in range(128): # Load F4
        nnBuffer[i][2][6] = buffer[11][i + count] - n11
    for i in range(128): # Load F8 
        nnBuffer[i][2][8] = buffer[12][i + count] - n12
    for i in range(128): # Load AF4
        nnBuffer[i][1][5] = buffer[13][i + count] - n13

    newBuffer = nnBuffer.reshape(1, 9, 9, 128, 1) # reshape and feed into nn
    # timeMid = time.time()
    modelResults = Model.predict(loaded_model, newBuffer)
    # timeEnd = time.time()
    nnOutput = np.append(nnOutput, modelResults, axis=0)

print(nnOutput)
np.savetxt('C:\\Users\\borde\\Downloads\\ECE 3970-001 - Capstone\\Main Code 11.25.24\\nnOutput.csv', nnOutput, delimiter=',', fmt='%d') # output results into csv file

"""
print("\nTime between Start and Mid: ")
print(timeMid - timeStart)
print("\nTime between Mid and End: ")
print(timeEnd - timeMid)

"""