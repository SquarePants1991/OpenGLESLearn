//
//  Laser.m
//  OpenGLESLearn
//
//  Created by wangyang on 2017/5/9.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "Laser.h"
#import "GLContext.h"

@interface Laser ()
@property (strong, nonatomic) GLKTextureInfo *diffuseTexture;
@property (assign, nonatomic) float hue;
@end

@implementation Laser
- (id)initWithLaserImage:(UIImage *)image context:(GLContext *)context {
    self = [super initWithGLContext:context];
    if (self) {
        [self genTexture:image];
        self.direction = GLKVector3Normalize(GLKVector3Make(0, 0, 1));
        self.position = GLKVector3Make(0, 0, 0);
        self.length = 4;
        self.radius = 0.2;
    }
    return self;
}

- (void)setDirection:(GLKVector3)direction {
    _direction = GLKVector3Normalize(direction);
}

- (void)update:(NSTimeInterval)timeSinceLastUpdate {
    self.life -= timeSinceLastUpdate;
    if (self.life <= 0) {
        self.life = 1;
        float x = rand() / (float)RAND_MAX * 0.1 - 0.05;
        float y = rand() / (float)RAND_MAX * 0.1 - 0.05;
        self.direction = GLKVector3Normalize(GLKVector3Make(x, y, 1));
        self.hue = rand() / (float)RAND_MAX * 1.0;
    }

    GLKVector3 defaultForward = GLKVector3Make(0, 0, 1);
    GLKVector3 rotateAxis = GLKVector3CrossProduct(defaultForward, self.direction);
    float cosAngle = GLKVector3DotProduct(defaultForward, self.direction);
    float angle = acos(cosAngle);

    GLKMatrix4 scaleMatrix = GLKMatrix4MakeScale(self.length, self.radius, self.radius);
    GLKMatrix4 rotateToZMatrix = GLKMatrix4MakeRotation(M_PI / 2, 0, 1, 0);
    GLKMatrix4 translateMatrix = GLKMatrix4MakeTranslation(0, 0, self.length / 2);
    GLKMatrix4 rotateMatrix = GLKMatrix4MakeRotation(angle, rotateAxis.x, rotateAxis.y, rotateAxis.z);
    GLKMatrix4 positionTranslateMatrix = GLKMatrix4MakeTranslation(self.position.x, self.position.y, self.position.z);
    self.modelMatrix = GLKMatrix4Multiply(rotateToZMatrix, scaleMatrix);
    self.modelMatrix = GLKMatrix4Multiply(translateMatrix, self.modelMatrix);
    self.modelMatrix = GLKMatrix4Multiply(rotateMatrix, self.modelMatrix);
    self.modelMatrix = GLKMatrix4Multiply(positionTranslateMatrix, self.modelMatrix);
}

- (void)draw:(GLContext *)glContext {
    [glContext setUniformMatrix4fv:@"modelMatrix" value:self.modelMatrix];
    bool canInvert;
    GLKMatrix4 normalMatrix = GLKMatrix4InvertAndTranspose(self.modelMatrix, &canInvert);
    [glContext setUniformMatrix4fv:@"normalMatrix" value:canInvert ? normalMatrix : GLKMatrix4Identity];

    [glContext setUniform1f:@"life" value:self.life];
    [glContext bindTexture:self.diffuseTexture to:GL_TEXTURE0 uniformName:@"diffuseMap"];
    [glContext setUniform1f:@"hue" value:self.hue];

    [self drawLaser: glContext];
}

- (void)drawLaser:(GLContext *)glContext{
    glDepthMask(GL_FALSE);

    static GLfloat plane1[] = {
        -0.5, 0.5f, 0, 1, 0, 0,     1, 0, // x, y, z, r, g, b,每一行存储一个点的信息，位置和颜色
        -0.5f, -0.5f, 0, 0, 1, 0,   0, 0,
        0.5f, -0.5f, 0, 0, 0, 1,    0, 1,
        0.5, -0.5f, 0, 0, 0, 1,     0, 1,
        0.5f, 0.5f, 0, 0, 1, 0,     1, 1,
        -0.5f, 0.5f, 0, 1, 0, 0,    1, 0,
    };
    [glContext drawTriangles:plane1 vertexCount:6];
    
    static GLfloat plane2[] = {
        -0.5,0, 0.5f,  1, 0, 0,     1, 0, // x, y, z, r, g, b,每一行存储一个点的信息，位置和颜色
        -0.5f,0, -0.5f,  0, 1, 0,   0, 0,
        0.5f, 0, -0.5f, 0, 0, 1,    0, 1,
        0.5,0, -0.5f,  0, 0, 1,     0, 1,
        0.5f, 0, 0.5f, 0, 1, 0,     1, 1,
        -0.5f, 0,0.5f,  1, 0, 0,    1, 0,
    };
    [glContext drawTriangles:plane2 vertexCount:6];

    glDepthMask(GL_TRUE);
}

#pragma mark - Texture
- (void)genTexture:(UIImage *)image {
    if (image) {
        NSError *error;
        self.diffuseTexture = [GLKTextureLoader textureWithCGImage:image.CGImage options:nil error:&error];
    }
}
@end
