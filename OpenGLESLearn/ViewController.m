//
//  ViewController.m
//  OpenGLESDemo
//
//  Created by wangyang on 15/8/28.
//  Copyright (c) 2015年 wangyang. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
    GLuint textureID;
    GLuint framebufferID;
    GLuint depthBufferID;
}
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
    
    [self createTextureFramebuffer];
}

#pragma mark - Create Texture Framebuffer
- (void)createTextureFramebuffer {

    glGenFramebuffers(1, &framebufferID);
    glBindFramebuffer(GL_FRAMEBUFFER, framebufferID);
    
    glGenTextures(1, &textureID);
    glBindTexture(GL_TEXTURE_2D, textureID);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 1024, 1024, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, textureID, 0);
    
    glGenRenderbuffers(1, &depthBufferID);
    glBindRenderbuffer(GL_RENDERBUFFER, depthBufferID);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, 1024, 1024);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthBufferID);
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
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

    glViewport(0, 0, 1024, 1024);
    glBindFramebuffer(GL_FRAMEBUFFER, framebufferID);
    glEnable(GL_DEPTH_TEST);
    [super glkView:view drawInRect:rect];
  
    GLuint projectionMatrixUniformLocation = glGetUniformLocation(self.shaderProgram, "projectionMatrix");
    glUniformMatrix4fv(projectionMatrixUniformLocation, 1, 0, self.projectionMatrix.m);
    GLuint cameraMatrixUniformLocation = glGetUniformLocation(self.shaderProgram, "cameraMatrix");
    glUniformMatrix4fv(cameraMatrixUniformLocation, 1, 0, self.cameraMatrix.m);

    GLuint modelMatrixUniformLocation = glGetUniformLocation(self.shaderProgram, "modelMatrix");
    glUniformMatrix4fv(modelMatrixUniformLocation, 1, 0, self.modelMatrix.m);
    GLuint useDiffuseMapUniformLocation = glGetUniformLocation(self.shaderProgram, "useDiffuseMap");
    glUniform1i(useDiffuseMapUniformLocation, 0);
    [self drawCube];
    
    
    [((GLKView *) self.view) bindDrawable];
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, textureID);
    glClearColor(0.2, 0.2, 0.2, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glUseProgram(self.shaderProgram);
    
    glUniform1i(useDiffuseMapUniformLocation, 1);
    glUniformMatrix4fv(projectionMatrixUniformLocation, 1, 0, GLKMatrix4Identity.m);
    glUniformMatrix4fv(cameraMatrixUniformLocation, 1, 0, GLKMatrix4Identity.m);
    glUniformMatrix4fv(modelMatrixUniformLocation, 1, 0, GLKMatrix4Identity.m);
    
    [self drawRectangle];
}


#pragma mark - Draw Many Things
- (void)drawRectangle {
    static GLfloat triangleData[] = {
        -1,   1,  0,   0,  0,  0, 0, 0,
        -1,  -1,  0,  0,  0,  0, 0, 1,
        1,   -1,  0,  0,  0,  0, 1, 1,
        1,    -1, 0,   0,  0,  0, 1, 1,
        1,  1,  0,    0,  0,  0, 1, 0,
        -1,   1,  0,  0,  0,  0, 0, 0,
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
      0.5,  -0.5,    0.5f, 1,  0,  0, 0, 0,
      0.5,  -0.5f,  -0.5f, 1,  0,  0, 0, 1,
      0.5,  0.5f,   -0.5f, 1,  0,  0, 1, 1,
      0.5,  0.5,    -0.5f, 1,  0,  0, 1, 1,
      0.5,  0.5f,    0.5f, 1,  0,  0, 1, 0,
      0.5,  -0.5f,   0.5f, 1,  0,  0, 0, 1,
// X轴-0.5处的平面
      -0.5,  -0.5,    0.5f, 1,  0,  0, 0, 0,
      -0.5,  -0.5f,  -0.5f, 1,  0,  0, 0, 1,
      -0.5,  0.5f,   -0.5f, 1,  0,  0, 1, 1,
      -0.5,  0.5,    -0.5f, 1,  0,  0, 1, 1,
      -0.5,  0.5f,    0.5f, 1,  0,  0, 1, 0,
      -0.5,  -0.5f,   0.5f, 1,  0,  0, 0, 1,
    };
    [self bindAttribs:triangleData];
    glDrawArrays(GL_TRIANGLES, 0, 12);
}

- (void)drawYPlanes {
    static GLfloat triangleData[] = {
        -0.5,  0.5,  0.5f, 0,  1,  0, 0, 0,
        -0.5f, 0.5, -0.5f, 0,  1,  0, 0, 1,
        0.5f, 0.5,  -0.5f, 0,  1,  0, 1, 1,
        0.5,  0.5,  -0.5f, 0,  1,  0, 1, 1,
        0.5f, 0.5,   0.5f, 0,  1,  0, 1, 0,
        -0.5f, 0.5,  0.5f, 0,  1,  0, 0, 1,
         -0.5, -0.5,   0.5f, 0,  1,  0, 0, 0,
         -0.5f, -0.5, -0.5f, 0,  1,  0, 0, 1,
         0.5f, -0.5,  -0.5f, 0,  1,  0, 1, 1,
         0.5,  -0.5,  -0.5f, 0,  1,  0, 1, 1,
         0.5f, -0.5,   0.5f, 0,  1,  0, 1, 0,
         -0.5f, -0.5,  0.5f, 0,  1,  0, 0, 1,
    };
    [self bindAttribs:triangleData];
    glDrawArrays(GL_TRIANGLES, 0, 12);
}

- (void)drawZPlanes {
    static GLfloat triangleData[] = {
        -0.5,   0.5f,  0.5,   0,  0,  1, 0, 0,
        -0.5f,  -0.5f,  0.5,  0,  0,  1, 0, 1,
        0.5f,   -0.5f,  0.5,  0,  0,  1, 1, 1,
        0.5,    -0.5f, 0.5,   0,  0,  1, 1, 1,
        0.5f,  0.5f,  0.5,    0,  0,  1, 1, 0,
        -0.5f,   0.5f,  0.5,  0,  0,  1, 0, 1,
        -0.5,   0.5f,  -0.5,   0,  0,  1, 0, 0,
        -0.5f,  -0.5f,  -0.5,  0,  0,  1, 0, 1,
        0.5f,   -0.5f,  -0.5,  0,  0,  1, 1, 1,
        0.5,    -0.5f, -0.5,   0,  0,  1, 1, 1,
        0.5f,  0.5f,  -0.5,    0,  0,  1, 1, 0,
        -0.5f,   0.5f,  -0.5,  0,  0,  1, 0, 1,
    };
    [self bindAttribs:triangleData];
    glDrawArrays(GL_TRIANGLES, 0, 12);
}

@end
