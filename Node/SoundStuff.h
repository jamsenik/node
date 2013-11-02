//
//  SoundStuff.h
//  Node
//
//  Created by Hans Kyndesgaard on 23/05/13.
//  Copyright (c) 2013 Hans Kyndesgaard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewController.h"

@interface SoundStuff : NSObject
-(int) initAudioSession;
-(int) initAudioStreams;
-(int) startAudioUnit;
-(void) setViewController:(ViewController *) theController;
@end
