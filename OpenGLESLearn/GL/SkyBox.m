//
//  SkyBox.m
//  OpenGLESLearn
//
//  Created by wang yang on 2017/9/13.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "SkyBox.h"

@implementation SkyBox
- (void)update:(NSTimeInterval)timeSinceLastUpdate {
    [super update:timeSinceLastUpdate];
}

- (void)draw:(GLContext *)glContext {
    glCullFace(GL_FRONT);
    glDepthMask(GL_FALSE);
    [super draw:glContext];
    glDepthMask(GL_TRUE);
    glCullFace(GL_BACK);
}
@end
