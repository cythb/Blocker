//
//  MJViewController.m
//  Blocker
//
//  Created by apple on 13-8-13.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MJViewController.h"
#import <QuartzCore/QuartzCore.h>

#define BALL_VELOCITY_Y (-100)

@interface MJViewController (){
    CADisplayLink *_displayLink;

    CGPoint _ballV;    //小球速度  x: + 向右 - 向左
                        //         y: + 向下 - 向上
    
    NSMutableArray *_blocksM;
    
    CGFloat _paddleV;   //挡板速度
    
    CFTimeInterval _paddleInterval;
    
    CGPoint _oriBallCenter; //小球初始中心点
    CGPoint _oriPaddleCenter; //挡板初始中心点
}

- (void)handleIntersectWithBlocks;
- (void)handleIntersectWithPaddle;
- (void)handleIntersectWithScreen;

- (void)pauseGame;
- (void)resetGame;

- (void)checkWin;
@end

@implementation MJViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _oriBallCenter = self.ball.center;
    _oriPaddleCenter = self.paddle.center;
    
    [self resetGame];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private
- (void)handleIntersectWithBlocks{
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return CGRectIntersectsRect(self.ball.frame, [evaluatedObject frame]);
    }];
    
    NSArray *intersectsBlocks = [_blocksM filteredArrayUsingPredicate:predicate];
    UIView *block = [intersectsBlocks lastObject];
    if (block) {
        // 从界面移除
        [block removeFromSuperview];
        
        // 从数组里移除
        [_blocksM removeObject:block];
        
        _ballV.y *= -1;
    }
}

// 处理小球与挡板碰撞
- (void)handleIntersectWithPaddle{
    
    if (CGRectIntersectsRect(self.ball.frame, self.paddle.frame)) {
        // 小球与挡板相撞
        
        _ballV.y = -ABS(_ballV.y);
        
        _ballV.x += _paddleV;
        _paddleInterval = _displayLink.timestamp;
    }
}

// 处理小球与屏幕碰撞
- (void)handleIntersectWithScreen{
    if (CGRectGetMinY(self.ball.frame) <= 0) {  //和上面碰撞
        _ballV.y = ABS(_ballV.y);;
    }
    
    // 左边
    if (CGRectGetMinX(self.ball.frame) <= 0) {
        _ballV.x = ABS(_ballV.x);
    }
    
    // 右边
    if (CGRectGetMaxX(self.ball.frame) >= 320) {
        _ballV.x = -1 * ABS(_ballV.x);
    }
    
    // 下面
    if (CGRectGetMinY(self.ball.frame) >= 460) {
        self.msgLabel.text = @"您输了";
        self.msgLabel.hidden = NO;
        
        // 游戏暂停
        [self pauseGame];
        
        self.tapGR.enabled = YES;
    }
}

- (void)pauseGame{
    [_displayLink invalidate];
}

- (void)resetGame{
    _displayLink = [CADisplayLink displayLinkWithTarget:self
                                               selector:@selector(step:)];
    // control + cmd + j
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop]
                       forMode:NSDefaultRunLoopMode];
    
    _ballV = CGPointMake(0, BALL_VELOCITY_Y);
    
    _blocksM = [NSMutableArray arrayWithArray:self.blocks];
    
    self.tapGR.enabled = NO;
    
    // 恢复小球位置
    self.ball.center = _oriBallCenter;
    
    // 恢复挡板位置
    self.paddle.center = _oriPaddleCenter;
    
    // 恢复砖块
    [self.blocks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self.view addSubview:obj];
    }];
    
    // 隐藏提示
    [self.msgLabel setHidden:YES];
}

- (void)checkWin{
    if (0 == _blocksM.count) {
        self.msgLabel.text = @"恭喜，您胜利了";
        self.msgLabel.hidden = NO;
        
        self.tapGR.enabled = YES;
        [self pauseGame];
    }
}


#pragma mark - actions
- (void)step:(CADisplayLink *)sender{
    [self handleIntersectWithBlocks];
    [self handleIntersectWithPaddle];
    [self handleIntersectWithScreen];
    
    [self checkWin];
    
    CFTimeInterval duration = 0;
    if (0 != _paddleInterval) {
        duration = (sender.timestamp - _paddleInterval);
        _paddleInterval = sender.timestamp;
    }
    
    self.ball.center = CGPointMake(self.ball.center.x + _ballV.x * duration,
                                   self.ball.center.y + _ballV.y * sender.duration);
}

- (IBAction)onPaddlePan:(UIPanGestureRecognizer *)sender {
    static CGPoint originalCenter;
    
    if (UIGestureRecognizerStateBegan == sender.state) {
        originalCenter = self.paddle.center;
    }
    
    CGPoint trans = [sender translationInView:self.view];
    if (UIGestureRecognizerStateChanged == sender.state) {
        // paddle.x = originalCenter.x + trans.x
        self.paddle.center = CGPointMake(trans.x + originalCenter.x,
                                         self.paddle.center.y);
        
        _paddleV = [sender velocityInView:self.view].x;
    }
    
    if (UIGestureRecognizerStateEnded == sender.state) {
        _paddleV = 0;
    }
}

- (IBAction)onTapScreen:(id)sender {
    [self resetGame];
}
@end
