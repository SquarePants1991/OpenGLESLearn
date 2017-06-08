//
//  Terrain.h
//  OpenGLESLearn
//
//  Created by wangyang on 2017/6/8.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "GLObject.h"

@interface Terrain : GLObject
- (id)initWithGLContext:(GLContext *)context heightMap:(UIImage *)image size:(CGSize)terrainSize height:(CGFloat)terrainHeight grass:(GLKTextureInfo *)grassTexture dirt:(GLKTextureInfo *)dirtTexture;
- (void)update:(NSTimeInterval)timeSinceLastUpdate;
- (void)draw:(GLContext *)glContext;
@end
