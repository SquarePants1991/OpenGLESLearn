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
@property (strong, nonatomic) GLKTextureInfo *diffuseTexture;
@end

@implementation Cube
- (instancetype)initWithGLContext:(GLContext *)context
{
    self = [super initWithGLContext:context];
    if (self) {
        [self genTexture:[UIImage imageNamed:@"texture.jpg"]];
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
    [glContext bindTexture:self.diffuseTexture to:GL_TEXTURE0 uniformName:@"diffuseMap"];
    [glContext drawTrianglesWithVAO:vao vertexCount:36];
}

#pragma mark - Texture
- (void)genTexture:(UIImage *)image {
    if (image) {
        NSError *error;
        self.diffuseTexture = [GLKTextureLoader textureWithCGImage:image.CGImage options:nil error:&error];
    }
}
@end
