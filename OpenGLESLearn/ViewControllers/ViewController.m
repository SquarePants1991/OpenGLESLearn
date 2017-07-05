//
//  ViewController.m
//  OpenGLESDemo
//
//  Created by wangyang on 15/8/28.
//  Copyright (c) 2015年 wangyang. All rights reserved.
//

#import "ViewController.h"
#import "GLContext.h"
#import "Cube.h"
#import "Cylinder.h"
#import "Terrain.h"
#import "WavefrontOBJ.h"
#import "Plane.h"
typedef struct  {
    GLKVector3 position;
    GLKVector3 color;
    GLfloat indensity;
    GLfloat ambientIndensity;
} PointLight;

typedef struct {
    GLKVector3 diffuseColor;
    GLKVector3 ambientColor;
    GLKVector3 specularColor;
    GLfloat smoothness; // 0 ~ 1000 越高显得越光滑
} Material;

@interface ViewController () {
    GLuint framebuffer;
    GLuint framebufferColorTexture;
    GLuint framebufferDepthTexture;
}
@property (assign, nonatomic) GLKMatrix4 projectionMatrix; // 投影矩阵
@property (assign, nonatomic) GLKMatrix4 cameraMatrix; // 观察矩阵
@property (assign, nonatomic) PointLight light;
@property (assign, nonatomic) Material material;
@property (assign, nonatomic) GLKVector3 eyePosition;

@property (strong, nonatomic) WavefrontOBJ *carModel;
@property (strong, nonatomic) Plane *displayFramebufferPlane;
@property (assign, nonatomic) CGSize framebufferSize;
@property (assign, nonatomic) GLKMatrix4 planeProjectionMatrix; // 显示framebuffer平面的投影矩阵
@property (strong, nonatomic) NSMutableArray<GLObject *> * objects;
@property (assign, nonatomic) BOOL useNormalMap;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 使用透视投影矩阵
    float aspect = self.view.frame.size.width / self.view.frame.size.height;
    self.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), aspect, 0.1, 1000.0);
    self.cameraMatrix = GLKMatrix4MakeLookAt(0, 1, 6.5, 0, 0, 0, 0, 1, 0);
    
    PointLight defaultLight;
    defaultLight.color = GLKVector3Make(1, 1, 1); // 白色的灯
    defaultLight.position = GLKVector3Make(30, 100, 0);
    defaultLight.indensity = 1.0;
    defaultLight.ambientIndensity = 0.1;
    self.light = defaultLight;
    
    Material material;
    material.ambientColor = GLKVector3Make(1, 1, 1);
    material.diffuseColor = GLKVector3Make(0.1, 0.1, 0.1);
    material.specularColor = GLKVector3Make(1, 1, 1);
    material.smoothness = 70;
    self.material = material;
    
    self.useNormalMap = YES;
    
    self.objects = [NSMutableArray new];
    [self createMonkeyFromObj];
    self.framebufferSize = CGSizeMake(512, 512);
    [self createTextureFramebuffer:self.framebufferSize];
    [self createPlane];
}

- (void)createPlane {
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"vertex" ofType:@".glsl"];
    NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"frag_framebuffer_plane" ofType:@".glsl"];
    GLContext *displayFramebufferPlaneContext = [GLContext contextWithVertexShaderPath:vertexShaderPath fragmentShaderPath:fragmentShaderPath];
    self.displayFramebufferPlane = [[Plane alloc] initWithGLContext:displayFramebufferPlaneContext texture:framebufferColorTexture];
    self.displayFramebufferPlane.modelMatrix = GLKMatrix4Identity;
    self.planeProjectionMatrix = GLKMatrix4MakeOrtho(-2.5, 0.5, -4.5, 0.5, -100, 100);
}

- (void)createMonkeyFromObj {
    UIImage *normalImage = [UIImage imageNamed:@"normal.png"];
    GLKTextureInfo *normalMap = [GLKTextureLoader textureWithCGImage:normalImage.CGImage options:nil error:nil];
    UIImage *diffuseImage = [UIImage imageNamed:@"texture.jpg"];
    GLKTextureInfo *diffuseMap = [GLKTextureLoader textureWithCGImage:diffuseImage.CGImage options:nil error:nil];
    
    NSString *objFilePath = [[NSBundle mainBundle] pathForResource:@"cube" ofType:@"obj"];
    self.carModel = [WavefrontOBJ objWithGLContext:self.glContext objFile:objFilePath diffuseMap:diffuseMap normalMap:normalMap];
    self.carModel.modelMatrix = GLKMatrix4MakeRotation(- M_PI / 2.0, 0, 1, 0);
    [self.objects addObject:self.carModel];
}

- (void)createTextureFramebuffer:(CGSize)framebufferSize {
    
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    
    // 生成颜色缓冲区的纹理对象并绑定到framebuffer上
    glGenTextures(1, &framebufferColorTexture);
    glBindTexture(GL_TEXTURE_2D, framebufferColorTexture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, framebufferSize.width, framebufferSize.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, framebufferColorTexture, 0);
    
    // 生成深度缓冲区的纹理对象并绑定到framebuffer上
    glGenTextures(1, &framebufferDepthTexture);
    glBindTexture(GL_TEXTURE_2D, framebufferDepthTexture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT, framebufferSize.width, framebufferSize.height, 0, GL_DEPTH_COMPONENT, GL_UNSIGNED_INT, NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT
                           , GL_TEXTURE_2D, framebufferDepthTexture, 0);
    
//    // 下面这段代码不使用纹理作为深度缓冲区。
//    GLuint depthBufferID;
//    glGenRenderbuffers(1, &depthBufferID);
//    glBindRenderbuffer(GL_RENDERBUFFER, depthBufferID);
//    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, framebufferSize.width, framebufferSize.height);
//    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthBufferID);
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        // framebuffer生成失败
    }
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

#pragma mark - Update Delegate

- (void)update {
    [super update];
    self.eyePosition = GLKVector3Make(0, 2, 6);
    GLKVector3 lookAtPosition = GLKVector3Make(0, 0, 0);
    self.cameraMatrix = GLKMatrix4MakeLookAt(self.eyePosition.x, self.eyePosition.y, self.eyePosition.z, lookAtPosition.x, lookAtPosition.y, lookAtPosition.z, 0, 1, 0);
    
    self.carModel.modelMatrix = GLKMatrix4MakeRotation(- M_PI / 2.0 * self.elapsedTime / 4.0, 1, 1, 1);
    [self.objects enumerateObjectsUsingBlock:^(GLObject *obj, NSUInteger idx, BOOL *stop) {
        [obj update:self.timeSinceLastUpdate];
    }];
}

- (void)drawObjects {
    [self.objects enumerateObjectsUsingBlock:^(GLObject *obj, NSUInteger idx, BOOL *stop) {
        [obj.context active];
        [obj.context setUniform1f:@"elapsedTime" value:(GLfloat)self.elapsedTime];
        [obj.context setUniformMatrix4fv:@"projectionMatrix" value:self.projectionMatrix];
        [obj.context setUniformMatrix4fv:@"cameraMatrix" value:self.cameraMatrix];
        [obj.context setUniform3fv:@"eyePosition" value:self.eyePosition];
        [obj.context setUniform3fv:@"light.position" value:self.light.position];
        [obj.context setUniform3fv:@"light.color" value:self.light.color];
        [obj.context setUniform1f:@"light.indensity" value:self.light.indensity];
        [obj.context setUniform1f:@"light.ambientIndensity" value:self.light.ambientIndensity];
        [obj.context setUniform3fv:@"material.diffuseColor" value:self.material.diffuseColor];
        [obj.context setUniform3fv:@"material.ambientColor" value:self.material.ambientColor];
        [obj.context setUniform3fv:@"material.specularColor" value:self.material.specularColor];
        [obj.context setUniform1f:@"material.smoothness" value:self.material.smoothness];
        
        [obj.context setUniform1i:@"useNormalMap" value:self.useNormalMap];
        
        [obj draw:obj.context];
    }];
}

- (void)drawPlane {
    [self.displayFramebufferPlane.context active];
    [self.displayFramebufferPlane.context setUniformMatrix4fv:@"projectionMatrix" value:self.planeProjectionMatrix];
    [self.displayFramebufferPlane.context setUniformMatrix4fv:@"cameraMatrix" value:GLKMatrix4Identity];
    [self.displayFramebufferPlane draw:self.displayFramebufferPlane.context];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glViewport(0, 0, self.framebufferSize.width, self.framebufferSize.height);
    glClearColor(0.8, 0.8, 0.8, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    self.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), self.framebufferSize.width / self.framebufferSize.height, 0.1, 1000.0);
    self.cameraMatrix = GLKMatrix4MakeLookAt(0, 1, sin(self.elapsedTime) * 5.0 + 9.0, 0, 0, 0, 0, 1, 0);
    [self drawObjects];
    
    [view bindDrawable];
    glClearColor(0.7, 0.7, 0.7, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    float aspect = self.view.frame.size.width / self.view.frame.size.height;
    self.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), aspect, 0.1, 1000.0);
    self.cameraMatrix = GLKMatrix4MakeLookAt(0, 1, 6.5, 0, 0, 0, 0, 1, 0);
    [self drawObjects];
    [self drawPlane];
    
}

#pragma mark - Arguments Adjust

- (IBAction)smoothnessAdjust:(UISlider *)sender {
    Material _material = self.material;
    _material.smoothness = sender.value;
    self.material = _material;
}

- (IBAction)indensityAdjust:(UISlider *)sender {
    PointLight _light = self.light;
    _light.indensity = sender.value;
    self.light = _light;
    
}

- (IBAction)lightColorAdjust:(UISlider *)sender {
    GLKVector3 yuv = GLKVector3Make(1.0, (cos(sender.value) + 1.0) / 2.0, (sin(sender.value) + 1.0) / 2.0);
    PointLight _light = self.light;
    _light.color = [self colorFromYUV:yuv];
    if (sender.value == sender.maximumValue) {
        _light.color = GLKVector3Make(1, 1, 1);
    }
    self.light = _light;
        sender.backgroundColor = [UIColor colorWithRed:_light.color.r green:_light.color.g blue:_light.color.b alpha:1.0];
}

- (IBAction)ambientColorAdjust:(UISlider *)sender {
    GLKVector3 yuv = GLKVector3Make(1.0, (cos(sender.value) + 1.0) / 2.0, (sin(sender.value) + 1.0) / 2.0);
    Material _material = self.material;
    _material.ambientColor = [self colorFromYUV:yuv];
    if (sender.value == sender.maximumValue) {
        _material.ambientColor = GLKVector3Make(1, 1, 1);
    }
    self.material = _material;
    sender.backgroundColor = [UIColor colorWithRed:_material.ambientColor.r green:_material.ambientColor.g blue:_material.ambientColor.b alpha:1.0];
}

- (IBAction)diffuseColorAdjust:(UISlider *)sender {
    GLKVector3 yuv = GLKVector3Make(1.0, (cos(sender.value) + 1.0) / 2.0, (sin(sender.value) + 1.0) / 2.0);
    Material _material = self.material;
    _material.diffuseColor = [self colorFromYUV:yuv];
    if (sender.value == sender.maximumValue) {
        _material.diffuseColor = GLKVector3Make(1, 1, 1);
    }
    if (sender.value == sender.minimumValue) {
        _material.diffuseColor = GLKVector3Make(0.1, 0.1, 0.1);
    }
    self.material = _material;
    sender.backgroundColor = [UIColor colorWithRed:_material.diffuseColor.r green:_material.diffuseColor.g blue:_material.diffuseColor.b alpha:1.0];
}

- (IBAction)specularColorAdjust:(UISlider *)sender {
    GLKVector3 yuv = GLKVector3Make(1.0, (cos(sender.value) + 1.0) / 2.0, (sin(sender.value) + 1.0) / 2.0);
    Material _material = self.material;
    _material.specularColor = [self colorFromYUV:yuv];
    if (sender.value == sender.maximumValue) {
        _material.specularColor = GLKVector3Make(1, 1, 1);
    }
    self.material = _material;
    sender.backgroundColor = [UIColor colorWithRed:_material.specularColor.r green:_material.specularColor.g blue:_material.specularColor.b alpha:1.0];
}

- (IBAction)toggleUseNormalMap:(UISwitch *)sender {
    self.useNormalMap = sender.isOn;
}



- (GLKVector3)colorFromYUV:(GLKVector3)yuv {
    float Cb, Cr, Y;
    float R ,G, B;
    Y = yuv.x * 255.0;
    Cb = yuv.y * 255.0 - 128.0;
    Cr = yuv.z * 255.0 - 128.0;
    
    R = 1.402 * Cr + Y;
    G = -0.344 * Cb - 0.714 * Cr + Y;
    B = 1.772 * Cb + Y;
    
    return GLKVector3Make(MIN(1.0, R / 255.0), MIN(1.0, G / 255.0), MIN(1.0, B / 255.0));
}

@end

