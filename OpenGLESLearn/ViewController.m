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
    float varyingFactor = self.elapsedTime;
    
    GLKMatrix4 rotateMatrix = GLKMatrix4MakeRotation(varyingFactor, 0, 1, 0);
#define UsePerspective // 注释这行运行查看正交投影效果，解除注释运行查看透视投影效果
#ifdef UsePerspective
    // 透视投影
    float aspect = self.view.frame.size.width / self.view.frame.size.height;
    GLKMatrix4 perspectiveMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), aspect, 0.1, 10.0);
    GLKMatrix4 translateMatrix = GLKMatrix4MakeTranslation(0, 0, -1.6);
    self.transformMatrix = GLKMatrix4Multiply(translateMatrix, rotateMatrix);
    self.transformMatrix = GLKMatrix4Multiply(perspectiveMatrix, self.transformMatrix);
#else
    // 正交投影
    float viewWidth = self.view.frame.size.width;
    float viewHeight = self.view.frame.size.height;
    GLKMatrix4 orthMatrix = GLKMatrix4MakeOrtho(-viewWidth/2, viewWidth/2, -viewHeight / 2, viewHeight/2, -10, 10);
    GLKMatrix4 scaleMatrix = GLKMatrix4MakeScale(200, 200, 200);
    self.transformMatrix = GLKMatrix4Multiply(scaleMatrix, rotateMatrix);
    self.transformMatrix = GLKMatrix4Multiply(orthMatrix, self.transformMatrix);
#endif
    
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
        -0.5,   0.5f,  0,   1,  0,  0, // x, y, z, r, g, b,每一行存储一个点的信息，位置和颜色
        -0.5f,  -0.5f,  0,  0,  1,  0,
        0.5f,   -0.5f,  0,  0,  0,  1,
        0.5,    -0.5f, 0,   0,  0,  1,
        0.5f,  0.5f,  0,    0,  1,  0,
        -0.5f,   0.5f,  0,  1,  0,  0,
    };
    [self bindAttribs:triangleData];
    glDrawArrays(GL_TRIANGLES, 0, 6);
}

@end
