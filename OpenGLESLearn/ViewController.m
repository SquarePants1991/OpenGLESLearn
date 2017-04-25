//
//  ViewController.m
//  OpenGLESDemo
//
//  Created by wangyang on 15/8/28.
//  Copyright (c) 2015年 wangyang. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (assign, nonatomic) GLKMatrix4 transformMatrix;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.transformMatrix = GLKMatrix4Identity;
}

#pragma mark - Update Delegate

- (void)update {
    [super update];
    float varyingFactor = sin(self.elapsedTime);
    GLKMatrix4 scaleMatrix = GLKMatrix4MakeScale(varyingFactor, varyingFactor, 1.0);
    GLKMatrix4 rotateMatrix = GLKMatrix4MakeRotation(varyingFactor , 0.0, 0.0, 1.0);
    GLKMatrix4 translateMatrix = GLKMatrix4MakeTranslation(varyingFactor, 0.0, 0.0);
    // transformMatrix = translateMatrix * rotateMatrix * scaleMatrix
    // 矩阵会按照从右到左的顺序应用到position上。也就是先缩放（scale）,再旋转（rotate）,最后平移（translate）
    // 如果这个顺序反过来，就完全不同了。从线性代数角度来讲，就是矩阵A乘以矩阵B不等于矩阵B乘以矩阵A。
    self.transformMatrix = GLKMatrix4Multiply(translateMatrix, rotateMatrix);
    self.transformMatrix = GLKMatrix4Multiply(self.transformMatrix, scaleMatrix);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [super glkView:view drawInRect:rect];
    
    GLuint transformUniformLocation = glGetUniformLocation(self.shaderProgram, "transform");
    glUniformMatrix4fv(transformUniformLocation, 1, 0, self.transformMatrix.m);
    [self drawTriangle];
}


#pragma mark - Draw Many Things
- (void)drawTriangle {
    static GLfloat triangleData[36] = {
        0,      0.5f,  0,  1,  0,  0, // x, y, z, r, g, b,每一行存储一个点的信息，位置和颜色
        -0.5f,  0.0f,  0,  0,  1,  0,
        0.5f,   0.0f,  0,  0,  0,  1,
        0,      -0.5f,  0,  1,  0,  0,
        -0.5f,  0.0f,  0,  0,  1,  0,
        0.5f,   0.0f,  0,  0,  0,  1,
    };
    [self bindAttribs:triangleData];
    glDrawArrays(GL_TRIANGLES, 0, 6);
}

@end
