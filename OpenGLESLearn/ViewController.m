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
@property (assign, nonatomic) GLuint diffuseTextureWithGLCommands;
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
    
    // 设置平行光方向
    self.lightDirection = GLKVector3Make(1, -1, 0);

    [self genTexture];
    [self genTextureWithGLCommands];
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
    
    [self drawCube];
}

#pragma mark - Texture
- (void)genTexture {
    NSString *textureFile = [[NSBundle mainBundle] pathForResource:@"texture" ofType:@"jpg"];
    NSError *error;
    self.diffuseTexture = [GLKTextureLoader textureWithContentsOfFile:textureFile options:nil error:&error];
}

- (void)genTextureWithGLCommands {
    UIImage *img = [UIImage imageNamed:@"texture.jpg"];
    // 将图片数据以RGBA的格式导出到textureData中
    CGImageRef imageRef = [img CGImage];
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    GLubyte *textureData = (GLubyte *)malloc(width * height * 4);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    
    CGContextRef context = CGBitmapContextCreate(textureData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    // 生成纹理
    GLuint texture;
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)width, (GLsizei)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    self.diffuseTextureWithGLCommands = texture;
}

#pragma mark - Draw Many Things
- (void)drawRectangle {
    static GLfloat triangleData[36] = {
            -0.5, 0.5f, 0, 1, 0, 0, // x, y, z, r, g, b,每一行存储一个点的信息，位置和颜色
            -0.5f, -0.5f, 0, 0, 1, 0,
            0.5f, -0.5f, 0, 0, 0, 1,
            0.5, -0.5f, 0, 0, 0, 1,
            0.5f, 0.5f, 0, 0, 1, 0,
            -0.5f, 0.5f, 0, 1, 0, 0,
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
      0.5,  -0.5f,   0.5f, 1,  0,  0, 0, 0,
// X轴-0.5处的平面
      -0.5,  -0.5,    0.5f, -1,  0,  0, 0, 0,
      -0.5,  -0.5f,  -0.5f, -1,  0,  0, 0, 1,
      -0.5,  0.5f,   -0.5f, -1,  0,  0, 1, 1,
      -0.5,  0.5,    -0.5f, -1,  0,  0, 1, 1,
      -0.5,  0.5f,    0.5f, -1,  0,  0, 1, 0,
      -0.5,  -0.5f,   0.5f, -1,  0,  0, 0, 0,
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
        -0.5f, 0.5,  0.5f, 0,  1,  0, 0, 0,
         -0.5, -0.5,   0.5f, 0,  -1,  0, 0, 0,
         -0.5f, -0.5, -0.5f, 0,  -1,  0, 0, 1,
         0.5f, -0.5,  -0.5f, 0,  -1,  0, 1, 1,
         0.5,  -0.5,  -0.5f, 0,  -1,  0, 1, 1,
         0.5f, -0.5,   0.5f, 0,  -1,  0, 1, 0,
         -0.5f, -0.5,  0.5f, 0,  -1,  0, 0, 0,
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
        -0.5f,   0.5f,  0.5,  0,  0,  1, 0, 0,
        -0.5,   0.5f,  -0.5,   0,  0,  -1, 0, 0,
        -0.5f,  -0.5f,  -0.5,  0,  0,  -1, 0, 1,
        0.5f,   -0.5f,  -0.5,  0,  0,  -1, 1, 1,
        0.5,    -0.5f, -0.5,   0,  0,  -1, 1, 1,
        0.5f,  0.5f,  -0.5,    0,  0,  -1, 1, 0,
        -0.5f,   0.5f,  -0.5,  0,  0,  -1, 0, 0,
    };
    [self bindAttribs:triangleData];
    glDrawArrays(GL_TRIANGLES, 0, 12);
}

@end
