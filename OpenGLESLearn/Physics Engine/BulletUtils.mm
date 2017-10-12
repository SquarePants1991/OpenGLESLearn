//
//  BulletUtils.m
//  OpenGLESLearn
//
//  Created by wang yang on 2017/10/11.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#include "Bullet/btBulletCollisionCommon.h"
#import <GLKit/GLKit.h>

static btTransform btTransformFromGLK(GLKMatrix4 glkMatrix) {
    GLKQuaternion glkQuaternion = GLKQuaternionMakeWithMatrix4(glkMatrix);
    btQuaternion quaternion(glkQuaternion.x,glkQuaternion.y,glkQuaternion.z,glkQuaternion.w);
    btTransform btTransform(quaternion,btVector3(glkMatrix.m30, glkMatrix.m31, glkMatrix.m32));
    return btTransform;
}

static GLKMatrix4 glkTransformFromBT(btTransform bttransform) {
    GLKMatrix4 translateMatrix = GLKMatrix4MakeTranslation(bttransform.getOrigin().x(), bttransform.getOrigin().y(), bttransform.getOrigin().z());
    
    btQuaternionFloatData quaternionFloatData;
    bttransform.getRotation().serialize(quaternionFloatData);
    GLKQuaternion quaternion = GLKQuaternionMake((float)quaternionFloatData.m_floats[0], (float)quaternionFloatData.m_floats[1], (float)quaternionFloatData.m_floats[2], (float)quaternionFloatData.m_floats[3]);
    
    GLKMatrix4 glkTransform = GLKMatrix4Multiply(translateMatrix, GLKMatrix4MakeWithQuaternion(quaternion));
    return glkTransform;
}
