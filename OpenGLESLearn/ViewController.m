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
@property (assign, nonatomic) GLKVector3 lightDirection; // 平行光光照方向
@property (strong, nonatomic) GLKTextureInfo *diffuseTexture;
@property (assign, nonatomic) GLKVector3 position;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 使用透视投影矩阵
    float aspect = self.view.frame.size.width / self.view.frame.size.height;
    self.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), aspect, 0.1, 100.0);
    
    // 设置摄像机在 0，0，2 坐标，看向 0，0，0点。Y轴正向为摄像机顶部指向的方向
    self.cameraMatrix = GLKMatrix4MakeLookAt(2, 2, 2, 0, 0, 0, 0, 1, 0);
    
    self.modelMatrix = GLKMatrix4Identity;
    
    // 设置平行光方向
    self.lightDirection = GLKVector3Make(1, -1, 0);

    self.position = GLKVector3Make(0, 0, 0);
    
    [self genTexture];
}

#pragma mark - Update Delegate

- (void)update {
    [super update];
    self.position = GLKVector3Make(0, 0, -self.elapsedTime * 8
                                   );
    if (self.position.z < -5) {
        self.position = GLKVector3Make(0, 0, 0);
        self.elapsedTime = 10.0;
    }
    
    GLKMatrix4 scaleMatrix = GLKMatrix4MakeScale(2,0.2,0.2);
    GLKMatrix4 rotateMatrix = GLKMatrix4MakeRotation(M_PI / 2, 0, 1, 0);
    self.modelMatrix = GLKMatrix4Multiply(rotateMatrix, scaleMatrix);
    self.modelMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(self.position.x, self.position.y, self.position.z), self.modelMatrix);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [super glkView:view drawInRect:rect];
  
    GLuint projectionMatrixUniformLocation = glGetUniformLocation(self.shaderProgram, "projectionMatrix");
    glUniformMatrix4fv(projectionMatrixUniformLocation, 1, 0, self.projectionMatrix.m);
    GLuint cameraMatrixUniformLocation = glGetUniformLocation(self.shaderProgram, "cameraMatrix");
    glUniformMatrix4fv(cameraMatrixUniformLocation, 1, 0, self.cameraMatrix.m);
    
    GLuint modelMatrixUniformLocation = glGetUniformLocation(self.shaderProgram, "modelMatrix");
    glUniformMatrix4fv(modelMatrixUniformLocation, 1, 0, self.modelMatrix.m);
    bool canInvert;
    GLKMatrix4 normalMatrix = GLKMatrix4InvertAndTranspose(self.modelMatrix, &canInvert);
    if (canInvert) {
        GLuint modelMatrixUniformLocation = glGetUniformLocation(self.shaderProgram, "normalMatrix");
        glUniformMatrix4fv(modelMatrixUniformLocation, 1, 0, normalMatrix.m);
    }
    
    
    GLuint lightDirectionUniformLocation = glGetUniformLocation(self.shaderProgram, "lightDirection");
    glUniform3fv(lightDirectionUniformLocation, 1,self.lightDirection.v);

    // 绑定纹理
    GLuint diffuseMapUniformLocation = glGetUniformLocation(self.shaderProgram, "diffuseMap");
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.diffuseTexture.name);
    glUniform1i(diffuseMapUniformLocation, 0);
    
    [self drawLaser];
}

#pragma mark - Texture
- (void)genTexture {
    NSString *textureFile = [[NSBundle mainBundle] pathForResource:@"laser" ofType:@"png"];
    NSError *error;
    self.diffuseTexture = [GLKTextureLoader textureWithContentsOfFile:textureFile options:nil error:&error];
}

#pragma mark - Draw Many Things
- (void)drawLaser {
    glDisable(GL_DEPTH_TEST);
    static GLfloat plane1[] = {
        -0.5, 0.5f, 0, 1, 0, 0,     1, 0, // x, y, z, r, g, b,每一行存储一个点的信息，位置和颜色
        -0.5f, -0.5f, 0, 0, 1, 0,   0, 0,
        0.5f, -0.5f, 0, 0, 0, 1,    0, 1,
        0.5, -0.5f, 0, 0, 0, 1,     0, 1,
        0.5f, 0.5f, 0, 0, 1, 0,     1, 1,
        -0.5f, 0.5f, 0, 1, 0, 0,    1, 0,
    };
    [self bindAttribs:plane1];
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    static GLfloat plane2[] = {
        -0.5,0, 0.5f,  1, 0, 0,     1, 0, // x, y, z, r, g, b,每一行存储一个点的信息，位置和颜色
        -0.5f,0, -0.5f,  0, 1, 0,   0, 0,
        0.5f, 0, -0.5f, 0, 0, 1,    0, 1,
        0.5,0, -0.5f,  0, 0, 1,     0, 1,
        0.5f, 0, 0.5f, 0, 1, 0,     1, 1,
        -0.5f, 0,0.5f,  1, 0, 0,    1, 0,
    };
    [self bindAttribs:plane2];
    glDrawArrays(GL_TRIANGLES, 0, 6);
    glEnable(GL_DEPTH_TEST);
}

@end
