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
@property (assign, nonatomic) GLKMatrix4 modelMatrix;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 使用透视投影矩阵
    float aspect = self.view.frame.size.width / self.view.frame.size.height;
    self.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), aspect, 0.1, 100.0);
    
    // 设置摄像机在 0，0，2 坐标，看向 0，0，0点。Y轴正向为摄像机顶部指向的方向
    self.cameraMatrix = GLKMatrix4MakeLookAt(0, 0, 2, 0, 0, 0, 0, 1, 0);
    
    self.modelMatrix = GLKMatrix4Identity;
}

#pragma mark - Update Delegate

- (void)update {
    [super update];
    float varyingFactor = (sin(self.elapsedTime) + 1) / 2.0; // 0 ~ 1
    self.cameraMatrix = GLKMatrix4MakeLookAt(0, 0, 2 * (varyingFactor + 1), 0, 0, 0, 0, 1, 0);
    
    GLKMatrix4 rotateMatrix = GLKMatrix4MakeRotation(varyingFactor * M_PI * 2, 1, 1, 1);
    self.modelMatrix = rotateMatrix;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [super glkView:view drawInRect:rect];
  
    GLuint projectionMatrixUniformLocation = glGetUniformLocation(self.shaderProgram, "projectionMatrix");
    glUniformMatrix4fv(projectionMatrixUniformLocation, 1, 0, self.projectionMatrix.m);
    GLuint cameraMatrixUniformLocation = glGetUniformLocation(self.shaderProgram, "cameraMatrix");
    glUniformMatrix4fv(cameraMatrixUniformLocation, 1, 0, self.cameraMatrix.m);
    
    GLuint modelMatrixUniformLocation = glGetUniformLocation(self.shaderProgram, "modelMatrix");
    glUniformMatrix4fv(modelMatrixUniformLocation, 1, 0, self.modelMatrix.m);
    [self drawCube];
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

- (void)drawCube {
    [self drawXPlanes];
    [self drawYPlanes];
    [self drawZPlanes];
}

- (void)drawXPlanes {
    static GLfloat triangleData[] = {
// X轴0.5处的平面
      0.5,  -0.5,    0.5f, 1,  0,  0,
      0.5,  -0.5f,  -0.5f, 1,  0,  0,
      0.5,  0.5f,   -0.5f, 1,  0,  0,
      0.5,  0.5,    -0.5f, 1,  0,  0,
      0.5,  0.5f,    0.5f, 1,  0,  0,
      0.5,  -0.5f,   0.5f, 1,  0,  0,
// X轴-0.5处的平面
      -0.5,  -0.5,    0.5f, 1,  0,  0,
      -0.5,  -0.5f,  -0.5f, 1,  0,  0,
      -0.5,  0.5f,   -0.5f, 1,  0,  0,
      -0.5,  0.5,    -0.5f, 1,  0,  0,
      -0.5,  0.5f,    0.5f, 1,  0,  0,
      -0.5,  -0.5f,   0.5f, 1,  0,  0,
    };
    [self bindAttribs:triangleData];
    glDrawArrays(GL_TRIANGLES, 0, 12);
}

- (void)drawYPlanes {
    static GLfloat triangleData[] = {
        -0.5,  0.5,  0.5f, 0,  1,  0,
        -0.5f, 0.5, -0.5f, 0,  1,  0,
        0.5f, 0.5,  -0.5f, 0,  1,  0,
        0.5,  0.5,  -0.5f, 0,  1,  0,
        0.5f, 0.5,   0.5f, 0,  1,  0,
        -0.5f, 0.5,  0.5f, 0,  1,  0,
         -0.5, -0.5,   0.5f, 0,  1,  0,
         -0.5f, -0.5, -0.5f, 0,  1,  0,
         0.5f, -0.5,  -0.5f, 0,  1,  0,
         0.5,  -0.5,  -0.5f, 0,  1,  0,
         0.5f, -0.5,   0.5f, 0,  1,  0,
         -0.5f, -0.5,  0.5f, 0,  1,  0,
    };
    [self bindAttribs:triangleData];
    glDrawArrays(GL_TRIANGLES, 0, 12);
}

- (void)drawZPlanes {
    static GLfloat triangleData[] = {
        -0.5,   0.5f,  0.5,   0,  0,  1,
        -0.5f,  -0.5f,  0.5,  0,  0,  1,
        0.5f,   -0.5f,  0.5,  0,  0,  1,
        0.5,    -0.5f, 0.5,   0,  0,  1,
        0.5f,  0.5f,  0.5,    0,  0,  1,
        -0.5f,   0.5f,  0.5,  0,  0,  1,
        -0.5,   0.5f,  -0.5,   0,  0,  1,
        -0.5f,  -0.5f,  -0.5,  0,  0,  1,
        0.5f,   -0.5f,  -0.5,  0,  0,  1,
        0.5,    -0.5f, -0.5,   0,  0,  1,
        0.5f,  0.5f,  -0.5,    0,  0,  1,
        -0.5f,   0.5f,  -0.5,  0,  0,  1,
    };
    [self bindAttribs:triangleData];
    glDrawArrays(GL_TRIANGLES, 0, 12);
}

@end
