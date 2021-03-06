# Must have loaded envPaths via st.cmd.linux or st.cmd.win32

errlogInit(20000)

dbLoadDatabase("$(TOP)/dbd/softDetectorApp.dbd")
softDetectorApp_registerRecordDeviceDriver(pdbbase) 

# Prefix for all records
epicsEnvSet("PREFIX", "djv:")
# The port name for the detector
epicsEnvSet("PORT",   "SOFT1")
# The queue size for all plugins
epicsEnvSet("QSIZE",  "20")
# The maximum image width; used for row profiles in the NDPluginStats plugin
epicsEnvSet("XSIZE",  "2000")
# The maximum image height; used for column profiles in the NDPluginStats plugin
epicsEnvSet("YSIZE",  "1500")
# The maximum number of time series points in the NDPluginStats plugin
epicsEnvSet("NCHANS", "2048")
# The maximum number of frames buffered in the NDPluginCircularBuff plugin
epicsEnvSet("CBUFFS", "500")
# The search path for database files
epicsEnvSet("EPICS_DB_INCLUDE_PATH", "$(ADCORE)/db")

#asynSetMinTimerPeriod(0.001)

# The EPICS environment variable EPICS_CA_MAX_ARRAY_BYTES needs to be set to a value at least as large
# as the largest image that the standard arrays plugin will send.
# That vlaue is $(XSIZE) * $(YSIZE) * sizeof(FTVL data type) for the FTVL used when loading the NDStdArrays.template file.
# The variable can be set in the environment before running the IOC or it can be set here.
# It is often convenient to set it in the environment outside the IOC to the largest array any client 
# or server will need.  For example 10000000 (ten million) bytes may be enough.
# If it is set here then remember to also set it outside the IOC for any CA clients that need to access the waveform record.  
# Do not set EPICS_CA_MAX_ARRAY_BYTES to a value much larger than that required, because EPICS Channel Access actually
# allocates arrays of this size every time it needs a buffer larger than 16K.
# Uncomment the following line to set it in the IOC.
epicsEnvSet("EPICS_CA_MAX_ARRAY_BYTES", "13000000")

# Create a softDetector driver
# softDetectorConfig(const char *portName, int maxSizeX, int maxSizeY, int dataType,
#                   int maxBuffers, int maxMemory, int priority, int stackSize)
softDetectorConfig("$(PORT)", $(XSIZE), $(YSIZE), 1, 0, 0)
dbLoadRecords("$(ADSOFT)/db/softDetector.template","P=$(PREFIX),R=cam1:,PORT=$(PORT),ADDR=0,TIMEOUT=1,NCHANS=12000000")

# Create a second softDetector driver
softDetectorConfig("SOFT2", 300, 200, 1, 50, 50000000)
dbLoadRecords("$(ADSOFT)/db/softDetector.template","P=$(PREFIX),R=cam2:,PORT=SOFT2,ADDR=0,TIMEOUT=1,NCHANS=12000000")

# Load an NDFile database.  This is not supported for the softDetector which does not write files.
#dbLoadRecords("NDFile.template","P=$(PREFIX),R=cam1:,PORT=SOFT1,ADDR=0,TIMEOUT=1")

# Create a standard arrays plugin, set it to get data from first simDetector driver.
NDStdArraysConfigure("Image1", 3, 0, "$(PORT)", 0)

# This creates a waveform large enough for 2000x2000x3 (e.g. RGB color) arrays.
# This waveform only allows transporting 8-bit images
dbLoadRecords("NDStdArrays.template", "P=$(PREFIX),R=image1:,PORT=Image1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=$(PORT),TYPE=Int8,FTVL=UCHAR,NELEMENTS=12000000")
# This waveform only allows transporting 16-bit images
#dbLoadRecords("NDStdArrays.template", "P=$(PREFIX),R=image1:,PORT=Image1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=$(PORT),TYPE=Int16,FTVL=USHORT,NELEMENTS=12000000")
# This waveform allows transporting 32-bit images
#dbLoadRecords("NDStdArrays.template", "P=$(PREFIX),R=image1:,PORT=Image1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=$(PORT),TYPE=Int32,FTVL=LONG,NELEMENTS=12000000")

# Create a standard arrays plugin, set it to get data from second simDetector driver.
NDStdArraysConfigure("Image2", 1, 0, "SOFT2", 0)

# This creates a waveform large enough for 640x480x3 (e.g. RGB color) arrays.
# This waveform allows transporting 64-bit images, so it can handle any detector data type at the expense of more memory and bandwidth
dbLoadRecords("NDStdArrays.template", "P=$(PREFIX),R=image2:,PORT=Image2,ADDR=0,TIMEOUT=1,NDARRAY_PORT=SOFT2,TYPE=Float64,FTVL=DOUBLE,NELEMENTS=921600")

# Load all other plugins using commonPlugins.cmd
< $(ADCORE)/iocBoot/commonPlugins.cmd
set_requestfile_path("$(ADSOFT)/softApp/Db")

asynSetTraceIOMask("$(PORT)",0,2)
asynSetTraceMask("$(PORT)",0,255)
#asynSetTraceIOMask("FileNetCDF",0,2)
#asynSetTraceMask("FileNetCDF",0,255)
#asynSetTraceMask("FileNexus",0,255)
#asynSetTraceMask("SOFT2",0,255)

iocInit()

# save things every thirty seconds
create_monitor_set("auto_settings.req", 30, "P=$(PREFIX)")
