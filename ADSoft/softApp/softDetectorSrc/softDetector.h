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
    
    virtual asynStatus writeInt32(asynUser *pasynUser, epicsInt32 value);
    void startTask();

protected:
    int postMode;
    int dataSourcePVName; /* Name of waveform PV containing image data. */

#define FIRST_SOFT_DETECTOR_PARAM postMode
#define LAST_SOFT_DETECTOR_PARAM dataSourcePVName

private:
    epicsEventId startEventId;
    epicsEventId stopEventId;
    NDArray *pRaw;

};

typedef enum {
    postModeOverwrite,
    postModeAppend,
}postModes_t;

#define postModeString         "POST_MODE"
#define dataSourcePVNameString "DATA_SOURCE_PV_NAME"

#define NUM_SOFT_DETECTOR_PARAMS ((int)(&LAST_SOFT_DETECTOR_PARAM - &FIRST_SOFT_DETECTOR_PARAM + 1))
