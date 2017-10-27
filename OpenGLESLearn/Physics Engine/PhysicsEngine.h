//
//  PhysicsEngine.h
//  OpenGLESLearn
//
//  Created by wang yang on 2017/10/11.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RigidBody.h"

@interface PhysicsEngine : NSObject
- (void)update:(NSTimeInterval)deltaTime;
- (void)addRigidBody:(RigidBody *)rigidBody;
@end
