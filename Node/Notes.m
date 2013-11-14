//
//  Notes.m
//  Node
//
//  Created by Hans Kyndesgaard on 25/10/13.
//  Copyright (c) 2013 Hans Kyndesgaard. All rights reserved.
//

#import "Notes.h"

float const DEVIATION = 0.1f;
float const SEMITONE = 1.05946309435929f;
float const A4 = 440.0f;
// Literal syntax

@implementation Notes {
    int currentKey;
    int currentClefisTreble;
    NSDictionary *noteNames;
    BOOL treble;
    BOOL bass;
    
}

- (id)init {
    self = [super init];
    
    if (self) {
        noteNames = @{
                      @(0) : @"A",
                      @(1) : @"Bb",
                      @(2) : @"H",
                      @(3) : @"C",
                      @(4) : @"C#",
                      @(5) : @"D",
                      @(6) : @"D#",
                      @(7) : @"E",
                      @(8) : @"F",
                      @(9) : @"F#",
                      @(10) : @"G",
                      @(11) : @"G#",
                      };
        
    }
    
    return self;
}


-(int) findKey:(float) freq {
    int key0 = roundf(12*log2(freq/440.0)+49);
    float freq0 = powf(SEMITONE, key0 - 49) * A4;
    float diff = fabsf(freq - freq0) / freq0;
    if (diff < DEVIATION){
        
        return key0;
    } else {
        return 0;
    }
}

-(NSString *) findKeyName:(int)key{
    int octave = key / 12;
    NSString *keyName = [noteNames objectForKey:@((key - 1)  % 12)];
    NSString *name = [NSString stringWithFormat:@"%@%i", keyName, octave];
    return name;
}

-(UIImage *) findImage:(int) key{
    NSString *name = (currentClefisTreble ?
                      [NSString stringWithFormat:@"T%i.jpg", key]
                      : [NSString stringWithFormat:@"B%i.jpg", key]);
    UIImage *img = [UIImage imageNamed:name];
    return img;
}

-(UIImage *) currentImage{
    return [self findImage:currentKey];
}

-(BOOL) isCurrentKey:(float) freq {
    return [self findKey:freq] == currentKey;
}

-(void) nextRandomKey {
    int trebleLowerBound = 38;
    int trebleUpperBound = 65;
    int bassLowerBound = 38;
    int bassUpperBound = 65;
    
    if (treble & bass){
        currentClefisTreble = (arc4random() % 2) == 0;
    } else if (treble) {
        currentClefisTreble = true;
    } else if (bass) {
        currentClefisTreble = false;
    } else {
        return;
    }
    
    int lowerBound = (currentClefisTreble ? trebleLowerBound : bassLowerBound);
    int upperBound = (currentClefisTreble ? trebleUpperBound : bassUpperBound);
    int rndValue = lowerBound + arc4random() % (upperBound - lowerBound);
    
    currentKey = rndValue;
}
-(void) enableTreble:(BOOL) enabled{
    treble = enabled;
};

-(void) enableBass:(BOOL) enabled{
    bass = enabled;
};

@end
