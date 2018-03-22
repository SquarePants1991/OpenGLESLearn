//
//  GLBaseViewController.h
//  OpenGLESLearn
//
//  Created by wangyang on 2017/4/24.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import <GLKit/GLKit.h>

@class GLContext;
@interface GLBaseViewController : UIViewController
@property (strong, nonatomic) GLContext * glContext;
@property (assign, nonatomic) GLfloat elapsedTime;
@property (assign, nonatomic) NSTimeInterval timeSinceLastUpdate;

- (void)update;
- (void)bindAttribs:(GLfloat *)triangleData;
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect;
@end
