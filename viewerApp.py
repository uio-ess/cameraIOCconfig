#!/usr/bin/env python3

#Avoid errors from EPICS about finding multiple copies of the PVs
#Note: This only occurs if running on localhost
#Note: May need to adjust broadcast IP listed in EPICS_CA_ADDR_LIST
import os
os.environ["EPICS_CA_ADDR_LIST"]="192.168.1.255"
os.environ["EPICS_CA_AUTO_ADDR_LIST"]="NO"

import epics

import matplotlib.pyplot as plt
import numpy as np

import threading
import time

camName="CAM1"

#Initialize device
for pvname, value in {':image1:EnableCallbacks': 1,  # Enable
                      ':image1:ArrayCallbacks': 1,  # Enable
                      ':det1:DataType': 1,  # UInt16, 12-bit
                      ':det1:LEFTSHIFT': 0}.items():  # Disable
    epics.caput(camName + pvname, value)

#Fire a trigger to prefill the buffer
epics.caput(camName + ':det1:Acquire', 1)
time.sleep(0.5)

epics.caput(camName + ':det1:ImageMode', 0)  # Get a single image

data_nr = epics.caget(camName + ':det1:SizeY_RBV')
data_nc = epics.caget(camName + ':det1:SizeX_RBV')
print("numRows =", data_nr)
print("numCols =", data_nc)

#Initialize drawing
drawLock = threading.Lock()
fig = plt.figure()
data = np.zeros((data_nr,data_nc))
drawLock.acquire()
plt.imshow(data)
drawLock.release()

#Setup callback
def img_callback(pvname=None, value=None, char_value=None, **kw):
    global data
    drawLock.acquire()
    print("img_callback()")

    data = value
    data = data.reshape(data_nr,data_nc)

    plt.clf()
    plt.imshow(data)
    plt.draw()

    print()
    drawLock.release()

pv = epics.PV(camName + ':image1:ArrayData', auto_monitor=True, callback=img_callback)

#Start trigger thread
trig_on = True
def trigger_thread():
    global trig_on
    while trig_on:
        time.sleep(0.5)
        drawLock.acquire()
        epics.caput(camName + ':det1:Acquire', 1)
        drawLock.release()
tt = threading.Thread(target=trigger_thread)
tt.start()

#Show plot
plt.show()

#Stop when the plot is closed
trig_on = False
tt.join()
