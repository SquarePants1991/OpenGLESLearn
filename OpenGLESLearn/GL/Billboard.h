//
//  Billboard.h
//  OpenGLESLearn
//
//  Created by wang yang on 2017/10/27.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "GLObject.h"

@interface Billboard : GLObject
@property (assign, nonatomic) GLKVector2 billboardSize;
@property (assign, nonatomic) GLKVector3 billboardCenterPosition;
@property (assign, nonatomic) BOOL lockToYAxis;

- (instancetype)initWithGLContext:(GLContext *)context texture:(GLKTextureInfo *)texture;
- (void)update:(NSTimeInterval)timeSinceLastUpdate;
- (void)draw:(GLContext *)glContext;
@end
