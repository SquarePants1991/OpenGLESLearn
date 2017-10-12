//
//  GameObject.m
//  OpenGLESLearn
//
//  Created by wang yang on 2017/10/12.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "GameObject.h"

@implementation GameObject
- (void)update:(NSTimeInterval)deltaTime {
    if (self.rigidBody) {
        self.geometry.modelMatrix = self.rigidBody.rigidBodyTransform;
    }
}
@end
