//
//  MJViewController.h
//  Blocker
//
//  Created by apple on 13-8-13.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MJViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *ball;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *blocks;
@property (weak, nonatomic) IBOutlet UIImageView *paddle;
@property (weak, nonatomic) IBOutlet UILabel *msgLabel;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGR;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panGR;


- (IBAction)onPaddlePan:(UIPanGestureRecognizer *)sender;
- (IBAction)onTapScreen:(id)sender;

@end
