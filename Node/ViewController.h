//
//  ViewController.h
//  Node
//
//  Created by Hans Kyndesgaard on 23/05/13.
//  Copyright (c) 2013 Hans Kyndesgaard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *Power;
@property (strong, nonatomic) IBOutlet UIImageView *NoteImage;
-(void) foundTone: (float) key;
@end
