//
//  Cylinder.h
//  OpenGLESLearn
//
//  Created by wangyang on 2017/6/6.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "GLObject.h"

@interface Cylinder : GLObject
@property (assign, nonatomic) int sideCount;
@property (assign, nonatomic) GLfloat radius;
@property (assign, nonatomic) GLfloat height;

- (id)initWithGLContext:(GLContext *)context sides:(int)sides radius:(GLfloat)radius height:(GLfloat)height texture:(GLKTextureInfo *)texture;
- (void)update:(NSTimeInterval)timeSinceLastUpdate;
- (void)draw:(GLContext *)glContext;
@end
