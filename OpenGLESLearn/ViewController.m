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
@property (strong, nonatomic) GLKTextureInfo *opaqueTexture;
@property (strong, nonatomic) GLKTextureInfo *redTransparencyTexture;
@property (strong, nonatomic) GLKTextureInfo *greenTransparencyTexture;
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
}

#pragma mark - Update Delegate

- (void)update {
    [super update];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [super glkView:view drawInRect:rect];
  
    GLuint projectionMatrixUniformLocation = glGetUniformLocation(self.shaderProgram, "projectionMatrix");
    glUniformMatrix4fv(projectionMatrixUniformLocation, 1, 0, self.projectionMatrix.m);
    GLuint cameraMatrixUniformLocation = glGetUniformLocation(self.shaderProgram, "cameraMatrix");
    glUniformMatrix4fv(cameraMatrixUniformLocation, 1, 0, self.cameraMatrix.m);
    
    GLuint lightDirectionUniformLocation = glGetUniformLocation(self.shaderProgram, "lightDirection");
    glUniform3fv(lightDirectionUniformLocation, 1,self.lightDirection.v);

    [self drawPlaneAt:GLKVector3Make(0, 0, -0.3) texture:self.opaqueTexture];
    
    glDepthMask(false);
    [self drawPlaneAt:GLKVector3Make(0.2, 0.2, 0) texture:self.greenTransparencyTexture];
    [self drawPlaneAt:GLKVector3Make(-0.2, 0.3, -0.5) texture:self.redTransparencyTexture];
    glDepthMask(true);

}

- (void)drawPlaneAt:(GLKVector3)position texture:(GLKTextureInfo *)texture {
    self.modelMatrix = GLKMatrix4MakeTranslation(position.x, position.y, position.z);
    GLuint modelMatrixUniformLocation = glGetUniformLocation(self.shaderProgram, "modelMatrix");
    glUniformMatrix4fv(modelMatrixUniformLocation, 1, 0, self.modelMatrix.m);
    bool canInvert;
    GLKMatrix4 normalMatrix = GLKMatrix4InvertAndTranspose(self.modelMatrix, &canInvert);
    if (canInvert) {
        GLuint modelMatrixUniformLocation = glGetUniformLocation(self.shaderProgram, "normalMatrix");
        glUniformMatrix4fv(modelMatrixUniformLocation, 1, 0, normalMatrix.m);
    }
    
    // 绑定纹理
    GLuint diffuseMapUniformLocation = glGetUniformLocation(self.shaderProgram, "diffuseMap");
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture.name);
    glUniform1i(diffuseMapUniformLocation, 0);
    
    [self drawRectangle];
}

#pragma mark - Texture
- (void)genTexture {
    NSString *opaqueTextureFile = [[NSBundle mainBundle] pathForResource:@"texture" ofType:@"jpg"];
    NSString *redTransparencyTextureFile = [[NSBundle mainBundle] pathForResource:@"red" ofType:@"png"];
    NSString *greenTransparencyTextureFile = [[NSBundle mainBundle] pathForResource:@"green" ofType:@"png"];
    NSError *error;
    self.opaqueTexture = [GLKTextureLoader textureWithContentsOfFile:opaqueTextureFile options:nil error:&error];
    self.redTransparencyTexture = [GLKTextureLoader textureWithContentsOfFile:redTransparencyTextureFile options:nil error:&error];
    self.greenTransparencyTexture = [GLKTextureLoader textureWithContentsOfFile:greenTransparencyTextureFile options:nil error:&error];
}

#pragma mark - Draw Many Things
- (void)drawRectangle {
    static GLfloat triangleData[] = {
        -0.5,   0.5f,  0,   0,  0,  1, 0, 0,
        -0.5f,  -0.5f,  0,  0,  0,  1, 0, 1,
        0.5f,   -0.5f,  0,  0,  0,  1, 1, 1,
        0.5,    -0.5f, 0,   0,  0,  1, 1, 1,
        0.5f,  0.5f,  0,    0,  0,  1, 1, 0,
        -0.5f,   0.5f,  0,  0,  0,  1, 0, 0,
    };
    [self bindAttribs:triangleData];
    glDrawArrays(GL_TRIANGLES, 0, 6);
}
@end
