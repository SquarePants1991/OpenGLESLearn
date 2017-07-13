//
//  Cube.h
//  OpenGLESLearn
//
//  Created by wang yang on 2017/5/16.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "GLObject.h"

@interface Cube : GLObject
- (id)initWithGLContext:(GLContext *)context diffuseMap:(GLKTextureInfo *)diffuseMap normalMap:(GLKTextureInfo *)normalMap;
- (void)update:(NSTimeInterval)timeSinceLastUpdate;
- (void)draw:(GLContext *)glContext;
@end
