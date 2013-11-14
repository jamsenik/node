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


#define kInputBus 1
#define kOutputBus 0
#define kBufferSize 1024
#define kBufferCount 1
#define N 10


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
AUGraph processingGraph;
AudioUnit ioUnit;
AudioBufferList* bufferList;


-(void) setViewController:(ViewController*) theController{
    vc = theController;
};



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


#pragma mark -
#pragma mark Generic Audio Controls
- (void)initializeAndStartProcessingGraph {
	OSStatus result = AUGraphInitialize(processingGraph);
	if (result >= 0) {
		AUGraphStart(processingGraph);
	} else {
		//XThrow(result, "error initializing processing graph");
	}
}

- (void)stopProcessingGraph {
	AUGraphStop(processingGraph);
}

#pragma mark -
#pragma mark Audio Rendering
OSStatus RenderFFTCallback (void					*inRefCon,
                            AudioUnitRenderActionFlags 	*ioActionFlags,
                            const AudioTimeStamp			*inTimeStamp,
                            UInt32 						inBusNumber,
                            UInt32 						inNumberFrames,
                            AudioBufferList				*ioData)
{
	
//	COMPLEX_SPLIT A = THIS->A;
//	void *dataBuffer = THIS->dataBuffer;
//	float *outputBuffer = THIS->outputBuffer;
//	FFTSetup fftSetup = THIS->fftSetup;
//	
//	uint32_t log2n = THIS->log2n;
//	uint32_t n = THIS->n;
//	uint32_t nOver2 = THIS->nOver2;
//	uint32_t stride = 1;
//	int bufferCapacity = THIS->bufferCapacity;
//	SInt16 index = THIS->index;
//	
	AudioUnit rioUnit =  ioUnit;
	OSStatus renderErr;
	UInt32 bus1 = 1;
	
	renderErr = AudioUnitRender(rioUnit, ioActionFlags,
								inTimeStamp, bus1, inNumberFrames, bufferList);
	if (renderErr < 0) {
		return renderErr;
	}
	
    
    if(floatBuffer == NULL) {
        // Lazy initialization of this buffer is necessary because we don't
        // know the frame count until the first callback
        floatBuffer = (float*)malloc(sizeof(float) * bufferLength);
        bufferCount = 0;
        difference = (float*)malloc(sizeof(float) * bufferLength);
        
        
    }
    
    
    SInt16 *inputFrames = (SInt16*)(bufferList->mBuffers->mData);
    
    if (fillBuffer(inputFrames, inNumberFrames)){
        float tone = differenceFunction();
        if (tone > 0){
            [vc foundTone:tone];
        }
        
    }

	return noErr;
}



#pragma mark -
#pragma mark Audio Session/Graph Setup
// Sets up the audio session based on the properties that were set in the init
// method.
- (void)initializeAudioSession {
	NSError	*err = nil;
	AVAudioSession *session = [AVAudioSession sharedInstance];
	
	[session setPreferredSampleRate:sampleRate error:&err];
	[session setCategory:AVAudioSessionCategoryPlayAndRecord error:&err];
	[session setActive:YES error:&err];
	
	// After activation, update our sample rate. We need to update because there
	// is a possibility the system cannot grant our request.
	sampleRate = [session sampleRate];
}


// This method will create an AUGraph for either input or output.
// Our application will never perform both operations simultaneously.
- (void)createAUProcessingGraph {
	OSStatus err;
	// Configure the search parameters to find the default playback output unit
	// (called the kAudioUnitSubType_RemoteIO on iOS but
	// kAudioUnitSubType_DefaultOutput on Mac OS X)
	AudioComponentDescription ioUnitDescription;
	ioUnitDescription.componentType = kAudioUnitType_Output;
	ioUnitDescription.componentSubType = kAudioUnitSubType_RemoteIO;
	ioUnitDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
	ioUnitDescription.componentFlags = 0;
	ioUnitDescription.componentFlagsMask = 0;
	
	// Declare and instantiate an audio processing graph
	NewAUGraph(&processingGraph);
	
	// Add an audio unit node to the graph, then instantiate the audio unit.
	/*
	 An AUNode is an opaque type that represents an audio unit in the context
	 of an audio processing graph. You receive a reference to the new audio unit
	 instance, in the ioUnit parameter, on output of the AUGraphNodeInfo
	 function call.
	 */
	AUNode ioNode;
	AUGraphAddNode(processingGraph, &ioUnitDescription, &ioNode);
	
	AUGraphOpen(processingGraph); // indirectly performs audio unit instantiation
	
	// Obtain a reference to the newly-instantiated I/O unit. Each Audio Unit
	// requires its own configuration.
	AUGraphNodeInfo(processingGraph, ioNode, NULL, &ioUnit);
	
	// Initialize below.
	AURenderCallbackStruct callbackStruct = {0};
	UInt32 enableInput;
	UInt32 enableOutput;
	
	// Enable input and disable output.
	enableInput = 1; enableOutput = 0;
	callbackStruct.inputProc = RenderFFTCallback;
	//callbackStruct.inputProcRefCon = (__bridge void *)(self);
	
	err = AudioUnitSetProperty(ioUnit, kAudioOutputUnitProperty_EnableIO,
							   kAudioUnitScope_Input,
							   kInputBus, &enableInput, sizeof(enableInput));
	
	err = AudioUnitSetProperty(ioUnit, kAudioOutputUnitProperty_EnableIO,
							   kAudioUnitScope_Output,
							   kOutputBus, &enableOutput, sizeof(enableOutput));
	
	err = AudioUnitSetProperty(ioUnit, kAudioOutputUnitProperty_SetInputCallback,
							   kAudioUnitScope_Input,
							   kOutputBus, &callbackStruct, sizeof(callbackStruct));
	
    
	// Set the stream format.
	size_t bytesPerSample = [self ASBDForSoundMode];
	
	err = AudioUnitSetProperty(ioUnit, kAudioUnitProperty_StreamFormat,
							   kAudioUnitScope_Output,
							   kInputBus, &streamFormat, sizeof(streamFormat));
	
	err = AudioUnitSetProperty(ioUnit, kAudioUnitProperty_StreamFormat,
							   kAudioUnitScope_Input,
							   kOutputBus, &streamFormat, sizeof(streamFormat));
	
	
	
	
	// Disable system buffer allocation. We'll do it ourselves.
	UInt32 flag = 0;
	err = AudioUnitSetProperty(ioUnit, kAudioUnitProperty_ShouldAllocateBuffer,
                               kAudioUnitScope_Output,
                               kInputBus, &flag, sizeof(flag));
    
    
	// Allocate AudioBuffers for use when listening.
	// TODO: Move into initialization...should only be required once.
	bufferList = (AudioBufferList *)malloc(sizeof(AudioBuffer));
	bufferList->mNumberBuffers = 1;
	bufferList->mBuffers[0].mNumberChannels = 1;
	
	bufferList->mBuffers[0].mDataByteSize = kBufferSize*bytesPerSample;
	bufferList->mBuffers[0].mData = calloc(kBufferSize, bytesPerSample);
}


// Set the AudioStreamBasicDescription for listening to audio data. Set the
// stream member var here as well.
- (size_t)ASBDForSoundMode {
	AudioStreamBasicDescription asbd = {0};
	size_t bytesPerSample;
	bytesPerSample = sizeof(SInt16);
	asbd.mFormatID = kAudioFormatLinearPCM;
	asbd.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
	asbd.mBitsPerChannel = 8 * bytesPerSample;
	asbd.mFramesPerPacket = 1;
	asbd.mChannelsPerFrame = 1;
	asbd.mBytesPerPacket = bytesPerSample * asbd.mFramesPerPacket;
	asbd.mBytesPerFrame = bytesPerSample * asbd.mChannelsPerFrame;
	asbd.mSampleRate = sampleRate;
	
	streamFormat = asbd;
//	[self printASBD:streamFormat];
	
	return bytesPerSample;
}

#pragma mark -
#pragma mark Utility
- (void)printASBD:(AudioStreamBasicDescription)asbd {
	
    char formatIDString[5];
    UInt32 formatID = CFSwapInt32HostToBig (asbd.mFormatID);
    bcopy (&formatID, formatIDString, 4);
    formatIDString[4] = '\0';
	
    NSLog (@"  Sample Rate:         %10.0f",  asbd.mSampleRate);
    NSLog (@"  Format ID:           %10s",    formatIDString);
    NSLog (@"  Format Flags:        %10lX",    asbd.mFormatFlags);
    NSLog (@"  Bytes per Packet:    %10ld",    asbd.mBytesPerPacket);
    NSLog (@"  Frames per Packet:   %10ld",    asbd.mFramesPerPacket);
    NSLog (@"  Bytes per Frame:     %10ld",    asbd.mBytesPerFrame);
    NSLog (@"  Channels per Frame:  %10ld",    asbd.mChannelsPerFrame);
    NSLog (@"  Bits per Channel:    %10ld",    asbd.mBitsPerChannel);
}

@end