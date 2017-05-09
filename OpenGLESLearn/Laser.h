//
//  Laser.h
//  OpenGLESLearn
//
//  Created by wangyang on 2017/5/9.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import <GLKit/GLKit.h>

@class GLContext;

@interface Laser : NSObject
@property (assign, nonatomic) GLfloat life;
@property (assign, nonatomic) GLKVector3 position;
@property (assign, nonatomic) GLKVector3 direction;
@property (assign, nonatomic) float length;
@property (assign, nonatomic) float radius;

- (id)initWithLaserImage:(UIImage *)image;
- (void)update:(NSTimeInterval)timeSinceLastUpdate;
- (void)draw:(GLContext *)glContext;
@end
