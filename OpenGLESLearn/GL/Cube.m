//
//  Cube.m
//  OpenGLESLearn
//
//  Created by wang yang on 2017/5/16.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "Cube.h"

@interface Cube() {
    GLuint vbo;
    GLuint vao;
}
@property (strong, nonatomic) GLKTextureInfo *normalMap;
@property (strong, nonatomic) GLKTextureInfo *diffuseMap;
@end

@implementation Cube
- (id)initWithGLContext:(GLContext *)context diffuseMap:(GLKTextureInfo *)diffuseMap normalMap:(GLKTextureInfo *)normalMap {
    self = [super initWithGLContext:context];
    if (self) {
        self.modelMatrix = GLKMatrix4Identity;
        [self genVBO];
        [self genVAO];
        self.diffuseMap = diffuseMap;
        self.normalMap = normalMap;
    }
    return self;
}

- (void)dealloc {
    glDeleteBuffers(1, &vbo);
    glDeleteBuffers(1, &vao);
}

- (GLfloat *)cubeData {
    static GLfloat cubeData[] = {
        // X轴0.5处的平面
        0.5,  -0.5,    0.5f, 1,  0,  0, 0, 0,
        0.5,  -0.5f,  -0.5f, 1,  0,  0, 0, 1,
        0.5,  0.5f,   -0.5f, 1,  0,  0, 1, 1,
        0.5,  0.5,    -0.5f, 1,  0,  0, 1, 1,
        0.5,  0.5f,    0.5f, 1,  0,  0, 1, 0,
        0.5,  -0.5f,   0.5f, 1,  0,  0, 0, 0,
        // X轴-0.5处的平面
        -0.5,  -0.5,    0.5f, -1,  0,  0, 0, 0,
        -0.5,  -0.5f,  -0.5f, -1,  0,  0, 0, 1,
        -0.5,  0.5f,   -0.5f, -1,  0,  0, 1, 1,
        -0.5,  0.5,    -0.5f, -1,  0,  0, 1, 1,
        -0.5,  0.5f,    0.5f, -1,  0,  0, 1, 0,
        -0.5,  -0.5f,   0.5f, -1,  0,  0, 0, 0,
        
        -0.5,  0.5,  0.5f, 0,  1,  0, 0, 0,
        -0.5f, 0.5, -0.5f, 0,  1,  0, 0, 1,
        0.5f, 0.5,  -0.5f, 0,  1,  0, 1, 1,
        0.5,  0.5,  -0.5f, 0,  1,  0, 1, 1,
        0.5f, 0.5,   0.5f, 0,  1,  0, 1, 0,
        -0.5f, 0.5,  0.5f, 0,  1,  0, 0, 0,
        -0.5, -0.5,   0.5f, 0,  -1,  0, 0, 0,
        -0.5f, -0.5, -0.5f, 0,  -1,  0, 0, 1,
        0.5f, -0.5,  -0.5f, 0,  -1,  0, 1, 1,
        0.5,  -0.5,  -0.5f, 0,  -1,  0, 1, 1,
        0.5f, -0.5,   0.5f, 0,  -1,  0, 1, 0,
        -0.5f, -0.5,  0.5f, 0,  -1,  0, 0, 0,
        
        -0.5,   0.5f,  0.5,   0,  0,  1, 0, 0,
        -0.5f,  -0.5f,  0.5,  0,  0,  1, 0, 1,
        0.5f,   -0.5f,  0.5,  0,  0,  1, 1, 1,
        0.5,    -0.5f, 0.5,   0,  0,  1, 1, 1,
        0.5f,  0.5f,  0.5,    0,  0,  1, 1, 0,
        -0.5f,   0.5f,  0.5,  0,  0,  1, 0, 0,
        -0.5,   0.5f,  -0.5,   0,  0,  -1, 0, 0,
        -0.5f,  -0.5f,  -0.5,  0,  0,  -1, 0, 1,
        0.5f,   -0.5f,  -0.5,  0,  0,  -1, 1, 1,
        0.5,    -0.5f, -0.5,   0,  0,  -1, 1, 1,
        0.5f,  0.5f,  -0.5,    0,  0,  -1, 1, 0,
        -0.5f,   0.5f,  -0.5,  0,  0,  -1, 0, 0,
    };
    return cubeData;
}

- (void)genVBO {
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, 36 * 8 * sizeof(GLfloat), [self cubeData], GL_STATIC_DRAW);
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
    [glContext bindTexture:self.diffuseMap to:GL_TEXTURE0 uniformName:@"diffuseMap"];
    [glContext bindTexture:self.normalMap to:GL_TEXTURE1 uniformName:@"normalMap"];
    [glContext drawTrianglesWithVAO:vao vertexCount:36];
}
@end
