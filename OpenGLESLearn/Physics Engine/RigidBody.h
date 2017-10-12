//
//  RigidBody.h
//  OpenGLESLearn
//
//  Created by wang yang on 2017/10/11.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import <GLKit/GLKit.h>

typedef enum {
    RigidBodyShapeTypeBox
} RigidBodyShapeType;

typedef struct
{
    RigidBodyShapeType type;
    union {
        struct {
            GLKVector3 size;
        } box;
        struct {
            GLfloat radius;
            GLfloat height;
        } cylinder;
    } shapes;
} RigidBodyShape;

@interface RigidBody : NSObject
@property (assign, nonatomic) GLfloat mass; // 重量
@property (assign, nonatomic) GLKVector3 velocity; // 速度
@property (assign, nonatomic) GLfloat restitution; // 弹性系数
@property (assign, nonatomic) GLfloat friction; // 摩擦系数

@property (assign, nonatomic) RigidBodyShape rigidbodyShape;
@property (assign, nonatomic) GLKMatrix4 rigidBodyTransform;

@property (assign, nonatomic) void * rawBtRigidBodyPointer;

- (instancetype)initAsBox:(GLKVector3)size;
@end
