# Capstone Project
# Date: 11/12/14
# This will receive from the main_lsl.py program and feed into the neural network. This program must be run BEFORE main_lsl.py does
# because this is the server, and main_lsl is the client. Values are loaded onto msg

# open terminal and do cd 'directory to this file loc' and then do 'python test_receiver.py' to run. Once this is running, the nyou can run main_lsl.py
from multiprocessing.connection import Listener
listener = Listener(('localhost', 6000), authkey=b'secret password')
running = True
while running:
    conn = listener.accept()
    print('connection accepted from', listener.last_accepted) # accept identity
    while True:
        msg = conn.recv()
        print(msg)
