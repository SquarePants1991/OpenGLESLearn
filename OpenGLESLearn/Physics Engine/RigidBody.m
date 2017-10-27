//
//  RigidBody.m
//  OpenGLESLearn
//
//  Created by wang yang on 2017/10/11.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "RigidBody.h"

@implementation RigidBody
- (void)commonInit {
    self.mass = 1.0;
    self.velocity = GLKVector3Make(0, 0, 0);
    self.restitution = 0.2;
    self.friction = 0.8;
}

- (instancetype)initAsBox:(GLKVector3)size {
    self = [super init];
    if (self) {
        RigidBodyShape rigidBodyShape;
        rigidBodyShape.type = RigidBodyShapeTypeBox;
        rigidBodyShape.shapes.box.size = size;
        self.rigidbodyShape = rigidBodyShape;
        
        [self commonInit];
    }
    return self;
}
@end
