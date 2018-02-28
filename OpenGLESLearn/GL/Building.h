//
//  Building.h
//  OpenGLESLearn
//
//  Created by ocean on 2018/2/28.
//  Copyright © 2018年 wangyang. All rights reserved.
//

#import "GLObject.h"

@interface Building : GLObject
@property (strong, nonatomic) NSArray *shape;
@property (assign, nonatomic) GLfloat radius;
@property (assign, nonatomic) GLfloat height;

- (id)initWithGLContext:(GLContext *)context shape:(NSArray *)shape height:(GLfloat)height texture:(GLKTextureInfo *)texture;
- (void)update:(NSTimeInterval)timeSinceLastUpdate;
- (void)draw:(GLContext *)glContext;
@end
