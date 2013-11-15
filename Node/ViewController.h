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
@property (strong, nonatomic) IBOutlet UISwitch *trebleSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *bassSwitch;
-(void) foundTone: (float) key;
-(IBAction)resetScore:(id)sender;
-(IBAction)trebleSwitched:(UISwitch *)sender;
-(IBAction)bassSwitched:(UISwitch *)sender;
@end
