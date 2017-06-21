//
//  FeaturePointCloud.h
//  OpenGLESLearn
//
//  Created by wang yang on 2017/6/21.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "GLObject.h"
#import <ARKit/ARKit.h>

@interface FeaturePointCloud : GLObject
- (id)initWithGLContext:(GLContext *)context;
- (void)setCloudData:(ARPointCloud *)pointCloud;
- (void)update:(NSTimeInterval)timeSinceLastUpdate;
- (void)draw:(GLContext *)glContext;
@end
