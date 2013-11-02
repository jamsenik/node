//
//  SoundStuff.m
//  Node
//
//  Created by Hans Kyndesgaard on 23/05/13.
//  Copyright (c) 2013 Hans Kyndesgaard. All rights reserved.
//

#import "SoundStuff.h"
#import <AudioUnit/AudioUnit.h>
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
//#import <vDSP.h>
//#import <vDSP_translate.h>
#import <Accelerate/Accelerate.h>
#import "ViewController.h"


@implementation SoundStuff{
    float power;
    UILabel *aLabel;
}

// Yeah, global variables suck, but it's kind of a necessary evil here
AudioUnit *audioUnit;
float *floatBuffer;
int bufferCount;
int powerCount = 0;
int bufferLength = 2048;
int sampleRate  = 44100;
SoundStuff *theStuff;
float *difference;
float power;
ViewController *vc;

-(void) setViewController:(ViewController*) theController{
    vc = theController;
};

- (int) initAudioSession {
    audioUnit = (AudioUnit*)malloc(sizeof(AudioUnit));
    theStuff = self;
    
    if(AudioSessionInitialize(NULL, NULL, NULL, NULL) != noErr) {
        return 1;
    }
    
    if(AudioSessionSetActive(true) != noErr) {
        return 1;
    }
    
    UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
    if(AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                               sizeof(UInt32), &sessionCategory) != noErr) {
        return 1;
    }
    
    Float32 bufferSizeInSec = 0.02f;
    if(AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration,
                               sizeof(Float32), &bufferSizeInSec) != noErr) {
        return 1;
    }
    
    UInt32 overrideCategory = 1;
    if(AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,
                               sizeof(UInt32), &overrideCategory) != noErr) {
        return 1;
    }
    
    // There are many properties you might want to provide callback functions for:
    // kAudioSessionProperty_AudioRouteChange
    // kAudioSessionProperty_OverrideCategoryEnableBluetoothInput
    // etc.
    
    return 0;
}

-(int) initAudioStreams {
    UInt32 audioCategory = kAudioSessionCategory_PlayAndRecord;
    if(AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                               sizeof(UInt32), &audioCategory) != noErr) {
        return 1;
    }
    
    UInt32 overrideCategory = 1;
    if(AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,
                               sizeof(UInt32), &overrideCategory) != noErr) {
        // Less serious error, but you may want to handle it and bail here
    }
    
    AudioComponentDescription componentDescription;
    componentDescription.componentType = kAudioUnitType_Output;
    componentDescription.componentSubType = kAudioUnitSubType_RemoteIO;
    componentDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    componentDescription.componentFlags = 0;
    componentDescription.componentFlagsMask = 0;
    AudioComponent component = AudioComponentFindNext(NULL, &componentDescription);
    if(AudioComponentInstanceNew(component, audioUnit) != noErr) {
        return 1;
    }
    
    UInt32 enable = 1;
    if(AudioUnitSetProperty(*audioUnit, kAudioOutputUnitProperty_EnableIO,
                            kAudioUnitScope_Input, 1, &enable, sizeof(UInt32)) != noErr) {
        return 1;
    }
    
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = renderCallback; // Render function
    callbackStruct.inputProcRefCon = NULL;
    if(AudioUnitSetProperty(*audioUnit, kAudioUnitProperty_SetRenderCallback,
                            kAudioUnitScope_Input, 0, &callbackStruct,
                            sizeof(AURenderCallbackStruct)) != noErr) {
        return 1;
    }
    
    AudioStreamBasicDescription streamDescription;
    // You might want to replace this with a different value, but keep in mind that the
    // iPhone does not support all sample rates. 8kHz, 22kHz, and 44.1kHz should all work.
    streamDescription.mSampleRate = sampleRate;
    // Yes, I know you probably want floating point samples, but the iPhone isn't going
    // to give you floating point data. You'll need to make the conversion by hand from
    // linear PCM <-> float.
    streamDescription.mFormatID = kAudioFormatLinearPCM;
    // This part is important!
    streamDescription.mFormatFlags = kAudioFormatFlagIsSignedInteger |
    kAudioFormatFlagsNativeEndian |
    kAudioFormatFlagIsPacked;
    // Not sure if the iPhone supports recording >16-bit audio, but I doubt it.
    streamDescription.mBitsPerChannel = 16;
    // 1 sample per frame, will always be 2 as long as 16-bit samples are being used
    streamDescription.mBytesPerFrame = 2;
    // Record in mono. Use 2 for stereo, though I don't think the iPhone does true stereo recording
    streamDescription.mChannelsPerFrame = 1;
    streamDescription.mBytesPerPacket = streamDescription.mBytesPerFrame *
    streamDescription.mChannelsPerFrame;
    // Always should be set to 1
    streamDescription.mFramesPerPacket = 1;
    // Always set to 0, just to be sure
    streamDescription.mReserved = 0;
    
    
    //Setup the output stream, which we will be sending the processed audio to
    if(AudioUnitSetProperty(*audioUnit, kAudioUnitProperty_StreamFormat,
                            kAudioUnitScope_Output, 1, &streamDescription, sizeof(streamDescription)) != noErr) {
        return 1;
    }
    
    return 0;
}

-(int) startAudioUnit {
    if(AudioUnitInitialize(*audioUnit) != noErr) {
        return 1;
    }
    
    if(AudioOutputUnitStart(*audioUnit) != noErr) {
        return 1;
    }
    
    return 0;
}


OSStatus renderCallback(void *userData, AudioUnitRenderActionFlags *actionFlags,
                        const AudioTimeStamp *audioTimeStamp, UInt32 busNumber,
                        UInt32 numFrames, AudioBufferList *buffers) {
    OSStatus status = AudioUnitRender(*audioUnit, actionFlags, audioTimeStamp,
                                      1, numFrames, buffers);
    if(status != noErr) {
        return status;
    }
    
    if(floatBuffer == NULL) {
        // Lazy initialization of this buffer is necessary because we don't
        // know the frame count until the first callback
        floatBuffer = (float*)malloc(sizeof(float) * bufferLength);
        bufferCount = 0;
        difference = (float*)malloc(sizeof(float) * bufferLength);
        
        
    }
    
    
    SInt16 *inputFrames = (SInt16*)(buffers->mBuffers->mData);
    
    if (fillBuffer(inputFrames, numFrames)){
        float tone = differenceFunction();
        if (tone > 0){
            [vc foundTone:tone];
        }
        
    }
    
    return noErr;
}

bool fillBuffer(SInt16 *inputFrames, int length){
    for(int i = 0; i < length && bufferCount < bufferLength; i++) {
        floatBuffer[bufferCount++] = inputFrames[i] / 40000.0f;
        //floatBuffer[bufferCount++] = sample [i];
        //printf("%f", inputFrames[i] / 40000.0f);
        powerCount += abs(inputFrames[i]);
    }
    if (bufferCount == bufferLength){
        bufferCount = 0;
        power = 1.0f * powerCount;
        powerCount = 0;
        //printf("Power: %f\n", power);
        return YES;
    } else {
        return  NO;
    }
}

float differenceFunction(){
    float power = 0.0f;
    float sum = 0.0;
    
    for (int i = 0; i < bufferLength; i++){
        sum += fabs(floatBuffer[i]);
    }
    
    power = sum / bufferLength;
    
    if (power < 0.1f){
        return -1;
    }
    
    float minBin = 0;
    float minDiff = bufferLength;
    for(int tau = 22; tau < 500; tau++){
        difference[tau] = 0;
        for(int j = 0; j + tau < bufferLength; j++){
            float temp = (floatBuffer[j] - floatBuffer [j+tau]);
            difference[tau] += temp * temp;
        }
        if (difference[tau] < minDiff){
            minBin = tau;
            minDiff = difference[tau];
        }
        //printf("%i\t%i\n", (int)(1000*floatBuffer[tau]),(int)(1000*diffenrence[tau]));
    }
    
    float freq = sampleRate / minBin;
    
    return freq;
}

@end