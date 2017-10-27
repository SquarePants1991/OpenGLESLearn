//
//  GameObject.h
//  OpenGLESLearn
//
//  Created by wang yang on 2017/10/12.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLObject.h"
#import "RigidBody.h"

@interface GameObject : NSObject
@property (strong, nonatomic) GLObject * geometry;
@property (strong, nonatomic) RigidBody * rigidBody;

- (instancetype)initWithGeometry:(GLObject *)geometry rigidBody:(RigidBody *)rigidBody;
- (void)update:(NSTimeInterval)deltaTime;
@end
