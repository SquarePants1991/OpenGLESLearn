//
//  Camera.m
//  OpenGLESLearn
//
//  Created by wang yang on 2017/9/5.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "Camera.h"

@implementation Camera
- (void)setupCameraWithEye:(GLKVector3)eye lookAt:(GLKVector3)lookAt up:(GLKVector3)up {
    self.forward = GLKVector3Normalize(GLKVector3Subtract(lookAt, eye));
    self.up = GLKVector3Normalize(up);
    self.position = eye;
}

- (GLKVector3)reflect:(GLKVector3)sourceVector normalVector:(GLKVector3)normalVector {
    CGFloat normalScalar = 2 * GLKVector3DotProduct(sourceVector, normalVector);
    GLKVector3 scaledNormalVector = GLKVector3MultiplyScalar(normalVector, normalScalar);
    GLKVector3 reflectVector = GLKVector3Subtract(sourceVector, scaledNormalVector);
    return reflectVector;
}

- (void)mirrorTo:(Camera *)targetCamera plane:(GLKVector4)plane {
    GLKVector3 planeNormal = GLKVector3Normalize(GLKVector3Make(plane.x, plane.y, plane.z));
    
    GLKVector3 mirrorForward = GLKVector3Normalize([self reflect:self.forward normalVector:planeNormal]);
    GLKVector3 mirrorUp = GLKVector3Normalize([self reflect:self.up normalVector:planeNormal]);
    
    GLKVector3 planeCenter = GLKVector3MultiplyScalar(planeNormal, plane.w);
    GLKVector3 eyeVector = GLKVector3Subtract(planeCenter, self.position);
    CGFloat eyeVectorLength = GLKVector3Length(eyeVector);
    eyeVector = GLKVector3Normalize(eyeVector);
    GLKVector3 mirrorEyeVector = GLKVector3Normalize([self reflect:eyeVector normalVector:planeNormal]);
    mirrorEyeVector = GLKVector3MultiplyScalar(mirrorEyeVector, eyeVectorLength);
    GLKVector3 mirrorPosition = GLKVector3Subtract(planeCenter, mirrorEyeVector);
    
    targetCamera.position = mirrorPosition;
    targetCamera.up = mirrorUp;
    targetCamera.forward = mirrorForward;
}

- (GLKMatrix4)cameraMatrix {
    GLKVector3 eye = self.position;
    GLKVector3 lookAt = GLKVector3Add(eye, self.forward);
    return GLKMatrix4MakeLookAt(eye.x, eye.y, eye.z, lookAt.x, lookAt.y, lookAt.z, self.up.x, self.up.y, self.up.z);
}
@end
