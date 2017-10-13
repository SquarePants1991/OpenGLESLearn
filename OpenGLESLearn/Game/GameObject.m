//
//  GameObject.m
//  OpenGLESLearn
//
//  Created by wang yang on 2017/10/12.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "GameObject.h"

@interface GameObject() {
    GLKMatrix4 originGeometryMatrix;
}
@end

@implementation GameObject

- (instancetype)initWithGeometry:(GLObject *)geometry rigidBody:(RigidBody *)rigidBody
{
    self = [super init];
    if (self) {
        self.geometry = geometry;
        self.rigidBody = rigidBody;
        self.rigidBody.rigidBodyTransform = geometry.modelMatrix;
        // 提取出原始的缩放分量，平移和旋转交给物理引擎去处理
        originGeometryMatrix = GLKMatrix4MakeScale(self.geometry.modelMatrix.m00, self.geometry.modelMatrix.m11, self.geometry.modelMatrix.m22);
    }
    return self;
}

- (void)update:(NSTimeInterval)deltaTime {
    if (self.rigidBody) {
        if (self.geometry) {
            self.geometry.modelMatrix = GLKMatrix4Multiply(self.rigidBody.rigidBodyTransform, originGeometryMatrix);
            [self.geometry update:deltaTime];
        }
    }
}
@end

