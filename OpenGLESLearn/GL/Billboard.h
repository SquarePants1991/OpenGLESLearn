//
//  Billboard.h
//  OpenGLESLearn
//
//  Created by wang yang on 2017/10/27.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "GLObject.h"

@interface Billboard : GLObject
- (instancetype)initWithGLContext:(GLContext *)context texture:(GLKTextureInfo *)texture;
- (void)setLookAtVectorPointer:(GLKVector3 *)lookAtVector;
- (void)update:(NSTimeInterval)timeSinceLastUpdate;
- (void)draw:(GLContext *)glContext;
@end
