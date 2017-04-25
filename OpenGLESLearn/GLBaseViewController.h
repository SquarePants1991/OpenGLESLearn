//
//  GLBaseViewController.h
//  OpenGLESLearn
//
//  Created by wangyang on 2017/4/24.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface GLBaseViewController : GLKViewController
@property (assign, nonatomic) GLuint shaderProgram;
@property (assign, nonatomic) GLfloat elapsedTime;

- (void)update;
- (void)bindAttribs:(GLfloat *)triangleData;
@end
