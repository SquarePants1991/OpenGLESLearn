//
//  Plane.m
//  OpenGLESLearn
//
//  Created by wang yang on 2017/6/15.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "VideoPlane.h"

@interface VideoPlane() {
    GLuint vbo;
    GLuint vao;
}
@end

@implementation VideoPlane
- (instancetype)initWithGLContext:(GLContext *)context
{
    self = [super initWithGLContext:context];
    if (self) {
        self.modelMatrix = GLKMatrix4Identity;
        [self genVBO];
        [self genVAO];
    }
    return self;
}

- (void)dealloc {
    glDeleteBuffers(1, &vbo);
    glDeleteBuffers(1, &vao);
}

- (GLfloat *)cubeData {
    static GLfloat cubeData[] = {
        -0.5,   0.5f,  0.0,   0,  0,  1, 0, 0,
        -0.5f,  -0.5f,  0.0,  0,  0,  1, 0, 1,
        0.5f,   -0.5f,  0.0,  0,  0,  1, 1, 1,
        0.5,    -0.5f, 0.0,   0,  0,  1, 1, 1,
        0.5f,  0.5f,  0.0,    0,  0,  1, 1, 0,
        -0.5f,   0.5f,  0.0,  0,  0,  1, 0, 0,
    };
    return cubeData;
}

- (void)genVBO {
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, 6 * 8 * sizeof(GLfloat), [self cubeData], GL_STATIC_DRAW);
}

- (void)genVAO {
    glGenVertexArraysOES(1, &vao);
    glBindVertexArrayOES(vao);
    
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    [self.context bindAttribs:NULL];
    
    glBindVertexArrayOES(0);
}

- (void)update:(NSTimeInterval)timeSinceLastUpdate {
    
}

- (void)draw:(GLContext *)glContext {
    [glContext setUniformMatrix4fv:@"modelMatrix" value:self.modelMatrix];
    bool canInvert;
    GLKMatrix4 normalMatrix = GLKMatrix4InvertAndTranspose(self.modelMatrix, &canInvert);
    [glContext setUniformMatrix4fv:@"normalMatrix" value:canInvert ? normalMatrix : GLKMatrix4Identity];
    [glContext bindTextureName:self.yuv_yTexture to:GL_TEXTURE0 uniformName:@"yMap"];
    [glContext bindTextureName:self.yuv_uvTexture to:GL_TEXTURE1 uniformName:@"uvMap"];
    [glContext drawTrianglesWithVAO:vao vertexCount:6];
}
@end
