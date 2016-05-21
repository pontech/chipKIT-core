#ifndef _HID_H
#define _HID_H

#if defined(_USB)

#include <Arduino.h>

class HID : public Stream {
    private:
        uint8_t rx_buffer[64];
};

#endif

#endif
