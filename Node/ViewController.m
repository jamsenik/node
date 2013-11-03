//
//  ViewController.m
//  Node
//
//  Created by Hans Kyndesgaard on 23/05/13.
//  Copyright (c) 2013 Hans Kyndesgaard. All rights reserved.
//

#import "ViewController.h"
#import "SoundStuff.h"
#import "Notes.h"


@interface ViewController (){
    SoundStuff *ss;
    Notes *notes;
    int right;
}

@end

@implementation ViewController
@synthesize Power = _Power;
@synthesize NoteImage = _NoteImage;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    ss = [SoundStuff alloc];
    
    int res = [ss initAudioSession];
    res = [ss initAudioStreams];
    res = [ss startAudioUnit];
    [ss setViewController:self];
    notes = [[Notes alloc] init];
    [notes nextRandomKey];
    [_NoteImage setImage:[notes currentImage]];
    right = 0;
    
    // Override point for customization after application launch.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) foundTone: (float) freq{
    if ([notes isCurrentKey:freq]){
        right++;
        
        [notes nextRandomKey];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [_NoteImage setImage:[notes currentImage]];
            [_Power setText:[NSString stringWithFormat:@"%i", right]];
        }];
        
    } else {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [_NoteImage setImage:[notes currentImage]];
            [_Power setText:[NSString stringWithFormat:@"%i (%i)", right, (int) freq]];
        }];
    }
}


@end    
