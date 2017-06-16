//
//  ARGLBaseViewController.h
//  OpenGLESLearn
//
//  Created by wang yang on 2017/6/15.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLBaseViewController.h"

@import ARKit;

@interface ARGLBaseViewController : GLBaseViewController <ARSessionDelegate>
@property (strong, nonatomic) ARSession *arSession;
@property (assign, nonatomic) GLKMatrix4 worldProjectionMatrix; // 3D世界投影矩阵
@property (assign, nonatomic) GLKMatrix4 cameraMatrix; // 3D世界观察矩阵
@end
