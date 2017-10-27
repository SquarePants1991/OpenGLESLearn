//
//  Billboard.m
//  OpenGLESLearn
//
//  Created by wang yang on 2017/10/27.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "Billboard.h"

@interface Billboard() {
    GLuint vbo;
    GLuint vao;
    GLKTextureInfo * diffuseTexture;
    GLKVector3 *lookAtVectorPointer;
    GLKMatrix4 forwardRotationMatrix;
}
@end

@implementation Billboard
- (instancetype)initWithGLContext:(GLContext *)context texture:(GLKTextureInfo *)texture
{
    self = [super initWithGLContext:context];
    if (self) {
        self.modelMatrix = GLKMatrix4Identity;
        forwardRotationMatrix = GLKMatrix4Identity;
        diffuseTexture = texture;
        [self genVBO];
        [self genVAO];
    }
    return self;
}

- (void)setLookAtVectorPointer:(GLKVector3 *)lookAtVector {
    lookAtVectorPointer = lookAtVector;
}

- (void)dealloc {
    glDeleteBuffers(1, &vbo);
    glDeleteBuffers(1, &vao);
}

- (GLfloat *)planeData {
    static GLfloat planeData[] = {
        -0.5,   0.5f,  0.0,   0,  0,  1, 0, 0,
        -0.5f,  -0.5f,  0.0,  0,  0,  1, 0, 1,
        0.5f,   -0.5f,  0.0,  0,  0,  1, 1, 1,
        0.5,    -0.5f, 0.0,   0,  0,  1, 1, 1,
        0.5f,  0.5f,  0.0,    0,  0,  1, 1, 0,
        -0.5f,   0.5f,  0.0,  0,  0,  1, 0, 0,
    };
    return planeData;
}

- (void)genVBO {
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, 36 * 8 * sizeof(GLfloat), [self planeData], GL_STATIC_DRAW);
}

- (void)genVAO {
    glGenVertexArraysOES(1, &vao);
    glBindVertexArrayOES(vao);
    
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    [self.context bindAttribs:NULL];
    
    glBindVertexArrayOES(0);
}

- (void)update:(NSTimeInterval)timeSinceLastUpdate {
    GLKVector3 newForwardVector = GLKVector3MultiplyScalar(*lookAtVectorPointer, -1);
    // 移除newForwardVector的y分量
    newForwardVector.y = 0;
    newForwardVector = GLKVector3Normalize(newForwardVector);
    GLKVector3 oldForwardVector = GLKVector3Make(0, 0, 1);
    GLKVector3 axis = GLKVector3Normalize(GLKVector3CrossProduct(oldForwardVector, newForwardVector));
    float acosValue = GLKVector3DotProduct(oldForwardVector, newForwardVector);
    float angle = acos(acosValue);
    GLKQuaternion quaternion = GLKQuaternionMakeWithAngleAndAxis(angle, axis.x, axis.y, axis.z);
    forwardRotationMatrix = GLKMatrix4MakeWithQuaternion(quaternion);
}

- (void)draw:(GLContext *)glContext {
    glDisable(GL_CULL_FACE);
    [glContext setUniformMatrix4fv:@"modelMatrix" value:GLKMatrix4Multiply(self.modelMatrix, forwardRotationMatrix)];
    bool canInvert;
    GLKMatrix4 normalMatrix = GLKMatrix4InvertAndTranspose(self.modelMatrix, &canInvert);
    [glContext setUniformMatrix4fv:@"normalMatrix" value:canInvert ? normalMatrix : GLKMatrix4Identity];
    [glContext bindTextureName:diffuseTexture.name to:GL_TEXTURE0 uniformName:@"diffuseMap"];
    [glContext drawTrianglesWithVAO:vao vertexCount:6];
    glEnable(GL_CULL_FACE);
}

@end
