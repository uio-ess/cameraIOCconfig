# < envPaths
errlogInit(20000)

epicsEnvSet("EPICS_CA_MAX_ARRAY_BYTES", 90000000)

#epicsEnvSet("TOP", "/home/haavagj/ess/epics/synApps_6_1/support/areaDetector-R3-7/aravisGigE/iocs/aravisGigEIOC")
epicsEnvSet("TOP", "/home/kyrsjo/code/EPICS/synApps_6_2/support/areaDetector-R3-10/aravisGigE/iocs/aravisGigEIOC")
#epicsEnvSet("ARAVISGIGE", "/home/haavagj/ess/epics/synApps_6_1/support/areaDetector-R3-7/aravisGigE")
epicsEnvSet("ARAVISGIGE", "/home/kyrsjo/code/EPICS/synApps_6_2/support/areaDetector-R3-10/aravisGigE/")
#epicsEnvSet("ADCORE", "/home/haavagj/ess/epics/synApps_6_1/support/areaDetector-R3-7/ADCore"
epicsEnvSet("ADCORE", "/home/kyrsjo/code/EPICS/synApps_6_2/support/areaDetector-R3-10/ADCore/")

dbLoadDatabase("$(TOP)/dbd/aravisGigEApp.dbd")
aravisGigEApp_registerRecordDeviceDriver(pdbbase)

# Prefix for all records
epicsEnvSet("PREFIX", "CAM1:")
# The port name for the detector
epicsEnvSet("PORT",   "CAM1")
# The queue size for all plugins
epicsEnvSet("QSIZE",  "20")
# The maximim image width; used for row profiles in the NDPluginStats plugin
epicsEnvSet("XSIZE",  "1936")
# The maximim image height; used for column profiles in the NDPluginStats plugin
epicsEnvSet("YSIZE",  "1216")
# The maximum number of time series points in the NDPluginStats plugin
epicsEnvSet("NCHANS", "2048")
# The maximum number of frames buffered in the NDPluginCircularBuff plugin
epicsEnvSet("CBUFFS", "500")
# The search path for database files
epicsEnvSet("EPICS_DB_INCLUDE_PATH", "$(ADCORE)/db")

aravisCameraConfig("$(PORT)", "Allied Vision Technologies-50-0503373249")

# asynSetTraceMask("$(PORT)",0,0x21)
dbLoadRecords("$(ARAVISGIGE)/db/aravisCamera.template", "P=$(PREFIX),R=det1:,PORT=$(PORT),ADDR=0,TIMEOUT=1")

dbLoadRecords("/home/haavagj/ess/epics/synApps_6_1/support/areaDetector-R3-7/aravisGigE/aravisGigEApp/Db/avt_g235b.template","P=$(PREFIX),R=det1:,PORT=$(PORT),ADDR=0,TIMEOUT=1")


# Create a standard arrays plugin
NDStdArraysConfigure("Image1", 5, 0, "$(PORT)", 0, 0)
# Allow for cameras up to 2048x2048x3 for RGB
dbLoadRecords("$(ADCORE)/db/NDStdArrays.template", "P=$(PREFIX),R=image1:,PORT=Image1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=$(PORT),TYPE=Int16,FTVL=SHORT,NELEMENTS=12582912")

# Load all other plugins using commonPlugins.cmd
# < $(ADCORE)/iocBoot/commonPlugins.cmd
# set_requestfile_path("$(ADPILATUS)/prosilicaApp/Db")

#asynSetTraceMask("$(PORT)",0,255)
#asynSetTraceMask("$(PORT)",0,3)


iocInit()


# save things every thirty seconds
# create_monitor_set("auto_settings.req", 30,"P=$(PREFIX)")


# dbpf CAM1:det1:ArrayCallbacks 1
dbpf CAM1:det1:Acquire 0
dbpf CAM1:image1:EnableCallbacks 1
dbpf CAM1:image1:ArrayCallbacks 1
dbpf CAM1:det1:DataType 1
dbpf CAM1:det1:LEFTSHIFT 0
dbpf CAM1:det1:ImageMode 0
