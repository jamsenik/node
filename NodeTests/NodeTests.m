//
//  NodeTests.m
//  NodeTests
//
//  Created by Hans Kyndesgaard on 23/05/13.
//  Copyright (c) 2013 Hans Kyndesgaard. All rights reserved.
//

#import "NodeTests.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation NodeTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class] ];
    
    NSString *sourceFilePath = [bundle pathForResource:@"Piano.mf.Bb3" ofType:@"aiff"];
    
    ExtAudioFileRef sourceFile;
    
    NSURL *fileUrl = [NSURL fileURLWithPath:sourceFilePath];
    OSStatus error = noErr;
    
    //
    // Open the file
    //
    error = ExtAudioFileOpenURL((__bridge  CFURLRef)fileUrl, &sourceFile);
    
    if(error){
        STFail(@"AudioClip: Error opening file at %@.  Error code %d", sourceFilePath, (int)error);
    }
    
    
    
    //
    // Store the number of frames in the file
    //
    UInt32 numberOfFrames = 0;
    UInt32 propSize = sizeof(SInt64);
    error = ExtAudioFileGetProperty(sourceFile, kExtAudioFileProperty_FileLengthFrames, &propSize, &numberOfFrames);
    
    if(error){
        STFail(@"AudioClip: Error retreiving number of frames: %d", (int) error);
    }
    
    AudioStreamBasicDescription		theFileFormat;
    UInt32							thePropertySize = sizeof(theFileFormat);
    // Get the audio data format
    error = ExtAudioFileGetProperty(sourceFile,
                                  kExtAudioFileProperty_FileDataFormat,
                                  &thePropertySize,
                                  &theFileFormat);
    if(error) {
        STFail(@"AudioClip: Error retreiving format: %d", (int) error);
    }
    
    if (theFileFormat.mChannelsPerFrame > 2)  {
        STFail(@"AudioClip: wrong numer of channels: %d", (int) theFileFormat.mChannelsPerFrame);
    }
    
    AudioStreamBasicDescription		theOutputFormat;
    // Set the client format to 16 bit signed integer (native-endian) data
    // Maintain the channel count and sample rate of the original source format
    theOutputFormat.mSampleRate			= theFileFormat.mSampleRate;
    theOutputFormat.mChannelsPerFrame	= theFileFormat.mChannelsPerFrame;
    theOutputFormat.mFormatID			= kAudioFormatLinearPCM;
    theOutputFormat.mBitsPerChannel		= 16;
    theOutputFormat.mBytesPerPacket		= 2 * theOutputFormat.mChannelsPerFrame;
    theOutputFormat.mFramesPerPacket	= 1;
    theOutputFormat.mBytesPerFrame		= 2 * theOutputFormat.mChannelsPerFrame;
    theOutputFormat.mFormatFlags		= (kAudioFormatFlagsNativeEndian |
                                           kAudioFormatFlagIsPacked |
                                           kAudioFormatFlagIsSignedInteger);
    
    // Set the desired client (output) data format
    error = ExtAudioFileSetProperty(sourceFile,
                                  kExtAudioFileProperty_ClientDataFormat, 
                                  sizeof(theOutputFormat), 
                                  &theOutputFormat);
    
    
    if (theFileFormat.mChannelsPerFrame > 2)  {
        STFail(@"Unable to set format: %d", (int) theFileFormat.mChannelsPerFrame);
    }

    
    //int dataByteSize = numberOfFrames * 1;
    short *theSignal = (short *)malloc(numberOfFrames * sizeof(short));
    
    AudioBufferList *audioBufferList;
    audioBufferList = malloc(sizeof(AudioBufferList));
    audioBufferList->mNumberBuffers = 1;
    audioBufferList->mBuffers[0].mNumberChannels = theOutputFormat.mChannelsPerFrame;
    audioBufferList->mBuffers[0].mDataByteSize = numberOfFrames * sizeof(short);
    audioBufferList->mBuffers[0].mData = theSignal;
    
    error = ExtAudioFileRead(sourceFile, &numberOfFrames, audioBufferList);
    
    if(error){
        STFail(@"AudioClip: Error reading file: %d", (int) error);
    }
    
    for(int i = 0; i < numberOfFrames; i++){
        NSLog(@"Sample: %i", theSignal[i]);
    }
//
//    if(error){
//        NSLog(@"AudioClip: Error getting source audio file properties: %d", error);
//        [self closeAudioFile];
//        return NO;
//    }
//    
//    //
//    // Set the format for our read.  We read in PCM, clip, then write out mp3
//    //
//    memset(&readFileFormat, 0, sizeof(AudioStreamBasicDescription));
//    
//    readFileFormat.mFormatID            = kAudioFormatLinearPCM;
//    readFileFormat.mSampleRate          = 44100;
//    readFileFormat.mFormatFlags         = kAudioFormatFlagsCanonical | kAudioFormatFlagIsNonInterleaved;
//    readFileFormat.mChannelsPerFrame    = 1;
//    readFileFormat.mBitsPerChannel      = 8 * sizeof(AudioSampleType);
//    readFileFormat.mFramesPerPacket     = 1;
//    readFileFormat.mBytesPerFrame       = sizeof(AudioSampleType);
//    readFileFormat.mBytesPerPacket      = sizeof(AudioSampleType);
//    readFileFormat.mReserved            = 0;
//    
//    propSize = sizeof(readFileFormat);
//    error = ExtAudioFileSetProperty(sourceFile, kExtAudioFileProperty_ClientDataFormat, propSize, &readFileFormat);
//    
//    if(error){
//        NSLog(@"AudioClip: Error setting read format: %d", error);
//        [self closeAudioFile];
//        return NO;
//    }
//    
//
    int sampleSize = 1024;
    short *sample 
    
    for (int sample = 0; sample < numberOfFrames / sampleSize; sample++) {
        short
    }
    
    
    STFail(@"Unit tests are not implemented yet in NodeTests");
}

@end
