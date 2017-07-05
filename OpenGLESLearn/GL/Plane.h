//
//  Plane.h
//  OpenGLESLearn
//
//  Created by wang yang on 2017/7/5.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "GLObject.h"

@interface Plane : GLObject
- (instancetype)initWithGLContext:(GLContext *)context texture:(GLuint)texture;
- (void)update:(NSTimeInterval)timeSinceLastUpdate;
- (void)draw:(GLContext *)glContext;
@end
