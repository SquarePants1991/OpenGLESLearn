//
//  GLObject.h
//  OpenGLESLearn
//
//  Created by wang yang on 2017/5/16.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/glext.h>
#import "GLContext.h"

@interface GLObject : NSObject
@property (strong, nonatomic) GLContext *context;
@property (assign, nonatomic) GLKMatrix4 modelMatrix;

- (id)initWithGLContext:(GLContext *)context;
- (void)update:(NSTimeInterval)timeSinceLastUpdate;
- (void)draw:(GLContext *)glContext;
@end
