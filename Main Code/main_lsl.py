# 11/6/24 (MAIN CODE FILE)
# check for available streams and stream LSL data into a 4x256 array (then push out to NN)
from pylsl import StreamInlet, resolve_stream
import numpy as np
import sys

def main():
    arrFlag = 1 # flag that indicates inital array has been populated
    y = 255 # max index for EEGbuffer array
    EEGbuffer = np.zeros((4,256)); # creates 4x256 array
    # first resolve an EEG stream on the lab network

    print("Looking for an EEG stream...\n")
    streams = resolve_stream('type', 'EEG')

    # create a new inlet to read from the stream
    inlet = StreamInlet(streams[0])

    while True:
        # get a new sample (you can also omit the timestamp part if you're not
        # interested in it)

        sample, timestamp = inlet.pull_sample() # pull in a new sample
        # sys.stdout.write(str(timestamp))
        
        if arrFlag: 
            for x in range(4): # iterate through the 4 rows
                EEGbuffer[x][y] = sample[x] # fill in the array w/ sample value starting from index 255 -> 0
            y -= 1 # decrement y (starts at 255, goes until 0)
            
        else:
            EEGbuffer = rShiftArr(EEGbuffer, 1) # right shift the numpy array by 1 (will have roll over, but we will replace it)
            for x1 in range(4): # iterate through each of the 4 rows and update the leftmost column for npArr (rightmost is shifted out, essentially)
                EEGbuffer[x1][0] = sample[x1] # pull the value from sample at [0...3] and replace npArr[0...3][0] (leftmost column)
        
            outArr = np.concatenate((EEGbuffer[0, :], EEGbuffer[1, :], EEGbuffer[2, :], EEGbuffer[3, :]), axis=None) # this is the 1x1024 array
            # sys.stdout.write(outArr) # write it out to terminal? <------ START HERE
            # print(outArr, len(outArr))

        if y <= 0: # when y <= 0, the 4x256 will have been completely filled up w/ data, newest to the left, oldest to the right
            arrFlag = 0 # disable original array populating code

def rShiftArr(arr, n): # right shift function (really a right rollover)
    nArr = np.roll(arr, n, axis = 1) # shift by n
    return nArr # return shifted array

if __name__ == '__main__': # some boilerplate thingy
    main()