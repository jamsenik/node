//
//  SoundStuff.h
//  Node
//
//  Created by Hans Kyndesgaard on 23/05/13.
//  Copyright (c) 2013 Hans Kyndesgaard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioUnit/AudioUnit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <Accelerate/Accelerate.h>
#include <stdlib.h>
#import "ViewController.h"


@interface SoundStuff : NSObject {
     
	
	AudioStreamBasicDescription streamFormat;
	
	FFTSetup fftSetup;
	COMPLEX_SPLIT A;
	int log2n, n, nOver2;
	
	void *dataBuffer;
	float *outputBuffer;
	size_t bufferCapacity;	// In samples
	size_t index;	// In samples
    
	float sampleRate;
	float frequency;
}
-(void) setViewController:(ViewController *) theController;
-(void)initializeAudioSession;
-(void)createAUProcessingGraph;
-(void)initializeAndStartProcessingGraph;
@end
