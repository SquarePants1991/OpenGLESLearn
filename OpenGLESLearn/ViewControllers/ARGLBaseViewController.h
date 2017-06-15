//
//  ARGLBaseViewController.h
//  OpenGLESLearn
//
//  Created by wang yang on 2017/6/15.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLBaseViewController.h"

@interface ARGLBaseViewController : GLBaseViewController
@property (assign, nonatomic) GLKMatrix4 worldProjectionMatrix; // 投影矩阵
@property (assign, nonatomic) GLKMatrix4 cameraMatrix; // 观察矩阵
@end
