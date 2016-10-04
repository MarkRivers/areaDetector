/* softDriver.h
 * 
 * This is a driver that allows any software to send images to area detector.
 * 
 * Author: David J. Vine
 * Berkeley National Lab
 * 
 * Created: September 28, 2016
 *
 */


#include <epicsEvent.h>
#include "ADDriver.h"

class epicsShareClass softDetector : public ADDriver {
public:
    softDetector(const char *portName,
                 int maxBuffers, size_t maxMemory,
                 int priority, int stackSize);
    
    virtual asynStatus writeInt8Array(asynUser *pasynUserm epicsInt8, value);
    virtual asynStatus writeUInt8Array(asynUser *pasynUserm epicsUInt8, value);
    virtual asynStatus writeInt16Array(asynUser *pasynUserm epicsInt16, value);
    virtual asynStatus writeUInt16Array(asynUser *pasynUserm epicsUInt16, value);
    virtual asynStatus writeInt32(asynUser *pasynUser, epicsInt32 value);
    virtual asynStatus writeUInt32(asynUser *pasynUser, epicsUInt32 value);
    virtual asynStatus writeFloat32(asynUser *pasynUser, epicsFloat32 value);
    virtual asynStatus writeFloat64(asynUser *pasynUser, epicsFloat64 value);
    void startTask();

protected:
    int arrayMode;      /* 0: Overwrite, 1: Append */
    int arrayInInt8;    /* Input array of Int8     */
    int arrayInIntU8;   /* Input array of UInt8    */
    int arrayInInt16;   /* Input array of Int16    */
    int arrayInUInt16;  /* Input array of UInt16   */
    int arrayInInt32;   /* Input array of Int32    */
    int arrayInUInt32;  /* Input array of UInt32   */
    int arrayInFloat32; /* Input array of Float32  */
    int arrayInFloat64; /* Input array of Float64  */

#define FIRST_SOFT_DETECTOR_PARAM arrayMode
#define LAST_SOFT_DETECTOR_PARAM arrayInFloat64

private:
    epicsEventId startEventId;
    epicsEventId stopEventId;

};

#define arrayModeString       "ARRAY_MODE"         /* (asynInt32,        r/w) Overwrite or append */
#define arrayInInt8String     "ARRAY_IN_INT8"      /* (asynInt8Array,    r/w) holds image data */
#define arrayInUInt8String    "ARRAY_IN_UINT8"     /* (asynUInt8Array,   r/w) holds image data */
#define arrayInInt16String    "ARRAY_IN_INT16"     /* (asynInt16Array,   r/w) holds image data */
#define arrayInUInt16String   "ARRAY_IN_UINT16"    /* (asynUInt16Array,  r/w) holds image data */
#define arrayInInt32String    "ARRAY_IN_INT32"     /* (asynInt32Array,   r/w) holds image data */
#define arrayInUInt32String   "ARRAY_IN_UINT32"    /* (asynUInt32Array,  r/w) holds image data */
#define arrayInFloat32String  "ARRAY_IN_FLOAT32"   /* (asynFloat32Array, r/w) holds image data */
#define arrayInFloat64String  "ARRAY_IN_FLOAT64"   /* (asynFloat64Array, r/w) holds image data */

#define NUM_SOFT_DETECTOR_PARAMS ((int)(&LAST_SOFT_DETECTOR_PARAM - &FIRST_SOFT_DETECTOR_PARAM + 1))
