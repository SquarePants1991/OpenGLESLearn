//
//  ViewController.m
//  OpenGLESDemo
//
//  Created by wangyang on 15/8/28.
//  Copyright (c) 2015年 wangyang. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (assign, nonatomic) GLKMatrix4 projectionMatrix; // 投影矩阵
@property (assign, nonatomic) GLKMatrix4 cameraMatrix; // 观察矩阵
@property (assign, nonatomic) GLKMatrix4 modelMatrix1; // 第一个矩形的模型变换
@property (assign, nonatomic) GLKMatrix4 modelMatrix2; // 第二个矩形的模型变换
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 使用透视投影矩阵
    float aspect = self.view.frame.size.width / self.view.frame.size.height;
    self.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), aspect, 0.1, 100.0);
    
    // 设置摄像机在 0，0，2 坐标，看向 0，0，0点。Y轴正向为摄像机顶部指向的方向
    self.cameraMatrix = GLKMatrix4MakeLookAt(0, 0, 2, 0, 0, 0, 0, 1, 0);
    
    // 先初始化矩形1的模型矩阵为单位矩阵
    self.modelMatrix1 = GLKMatrix4Identity;
    // 先初始化矩形2的模型矩阵为单位矩阵
    self.modelMatrix2 = GLKMatrix4Identity;
}

#pragma mark - Update Delegate

- (void)update {
    [super update];
    float varyingFactor = (sin(self.elapsedTime) + 1) / 2.0; // 0 ~ 1
    self.cameraMatrix = GLKMatrix4MakeLookAt(0, 0, 2 * (varyingFactor + 1), 0, 0, 0, 0, 1, 0);
    
    GLKMatrix4 translateMatrix1 = GLKMatrix4MakeTranslation(-0.7, 0, 0);
    GLKMatrix4 rotateMatrix1 = GLKMatrix4MakeRotation(varyingFactor * M_PI * 2, 0, 1, 0);
    self.modelMatrix1 = GLKMatrix4Multiply(translateMatrix1, rotateMatrix1);
    
    GLKMatrix4 translateMatrix2 = GLKMatrix4MakeTranslation(0.7, 0, 0);
    GLKMatrix4 rotateMatrix2 = GLKMatrix4MakeRotation(varyingFactor * M_PI, 0, 0, 1);
    self.modelMatrix2 = GLKMatrix4Multiply(translateMatrix2, rotateMatrix2);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [super glkView:view drawInRect:rect];
  
    GLuint projectionMatrixUniformLocation = glGetUniformLocation(self.shaderProgram, "projectionMatrix");
    glUniformMatrix4fv(projectionMatrixUniformLocation, 1, 0, self.projectionMatrix.m);
    GLuint cameraMatrixUniformLocation = glGetUniformLocation(self.shaderProgram, "cameraMatrix");
    glUniformMatrix4fv(cameraMatrixUniformLocation, 1, 0, self.cameraMatrix.m);
    
    GLuint modelMatrixUniformLocation = glGetUniformLocation(self.shaderProgram, "modelMatrix");
    // 绘制第一个矩形
    glUniformMatrix4fv(modelMatrixUniformLocation, 1, 0, self.modelMatrix1.m);
    [self drawRectangle];
    
    // 绘制第二个矩形
    glUniformMatrix4fv(modelMatrixUniformLocation, 1, 0, self.modelMatrix2.m);
    [self drawRectangle];
}


#pragma mark - Draw Many Things
- (void)drawRectangle {
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
