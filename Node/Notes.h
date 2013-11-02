//
//  Notes.h
//  Node
//
//  Created by Hans Kyndesgaard on 25/10/13.
//  Copyright (c) 2013 Hans Kyndesgaard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Notes : NSObject
-(int) findKey:(float) freq;
-(NSString *) findKeyName:(int) key;
-(UIImage *) findImage:(int) key;
-(void) nextRandomKey;
-(BOOL) isCurrentKey:(float) freq;
-(UIImage *) currentImage;
@end
