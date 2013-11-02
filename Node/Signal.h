//
//  Signal.h
//  Node
//
//  Created by Hans Kyndesgaard on 24/05/13.
//  Copyright (c) 2013 Hans Kyndesgaard. All rights reserved.
//

#ifndef Node_Signal_h
#define Node_Signal_h

OSStatus renderCallback(void *userData, AudioUnitRenderActionFlags *actionFlags,
                        const AudioTimeStamp *audioTimeStamp, UInt32 busNumber,
                        UInt32 numFrames, AudioBufferList *buffers);

#endif
