//
//  GLObject.m
//  OpenGLESLearn
//
//  Created by wang yang on 2017/5/16.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "GLObject.h"

@implementation GLObject
- (id)initWithGLContext:(GLContext *)context {
    self = [super init];
    if (self) {
        self.context = context;
    }
    return self;
}

- (void)update:(NSTimeInterval)timeSinceLastUpdate {

}

- (void)draw:(GLContext *)glContext {
    
}
@end
