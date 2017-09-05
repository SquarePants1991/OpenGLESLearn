//
//  Camera.h
//  OpenGLESLearn
//
//  Created by wang yang on 2017/9/5.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface Camera : NSObject
@property (assign, nonatomic) GLKVector3 forward;
@property (assign, nonatomic) GLKVector3 up;
@property (assign, nonatomic) GLKVector3 position;

- (void)setupCameraWithEye:(GLKVector3)eye lookAt:(GLKVector3)lookAt up:(GLKVector3)up;
- (void)mirrorTo:(Camera *)targetCamera plane:(GLKVector4)plane;
- (GLKMatrix4)cameraMatrix;
@end
