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
    void postImage();

private:
    virtual asynStatus readImage();

    epicsEventId startEventId;
    epicsEventId stopEventId;

};

typedef enum {
    Overwrite,
    Append,
}WriteModes_t;


