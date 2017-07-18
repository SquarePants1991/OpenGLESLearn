//
//  ViewController.m
//  OpenGLESDemo
//
//  Created by wangyang on 15/8/28.
//  Copyright (c) 2015年 wangyang. All rights reserved.
//

#import "ViewController.h"
#import "GLContext.h"
#import "WavefrontOBJ.h"

typedef struct  {
    GLKVector3 direction;
    GLKVector3 color;
    GLfloat indensity;
    GLfloat ambientIndensity;
} DirectionLight;

typedef struct {
    GLKVector3 diffuseColor;
    GLKVector3 ambientColor;
    GLKVector3 specularColor;
    GLfloat smoothness; // 0 ~ 1000 越高显得越光滑
} Material;

@interface ViewController () {
    GLuint shadowMapFramebuffer;
    GLuint shadowDepthMap;
}
@property (assign, nonatomic) GLKMatrix4 projectionMatrix; // 投影矩阵
@property (assign, nonatomic) GLKMatrix4 cameraMatrix; // 观察矩阵
@property (assign, nonatomic) DirectionLight light;
@property (assign, nonatomic) Material material;
@property (assign, nonatomic) GLKVector3 eyePosition;

@property (strong, nonatomic) NSMutableArray<GLObject *> * objects;
@property (assign, nonatomic) BOOL useNormalMap;

// 投影器矩阵
@property (assign, nonatomic) GLKMatrix4 lightProjectionMatrix;
@property (assign, nonatomic) GLKMatrix4 lightCameraMatrix;
@property (assign, nonatomic) CGSize shadowMapSize;
@property (strong, nonatomic) GLContext * shadowMapContext;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 使用透视投影矩阵
    float aspect = self.view.frame.size.width / self.view.frame.size.height;
    self.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), aspect, 0.1, 1000.0);
    self.cameraMatrix = GLKMatrix4MakeLookAt(0, 1, 6.5, 0, 0, 0, 0, 1, 0);
    
    DirectionLight defaultLight;
    defaultLight.color = GLKVector3Make(1, 1, 1); // 白色的灯
    defaultLight.direction = GLKVector3Make(-1, -1, 0);
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
    [self createBox:GLKVector3Make(-1, 0.6, -1.3) size: GLKVector3Make(0.6, 0.6, 0.6)];
    [self createBox:GLKVector3Make(2, 1, 1) size: GLKVector3Make(0.4, 1, 0.4)];
    [self createBox:GLKVector3Make(0.2, 1.3, 0.8) size: GLKVector3Make(0.3, 1.3, 0.4)];
    [self createFloor];
    
    self.lightProjectionMatrix = GLKMatrix4MakeOrtho(-10, 10, -10, 10, -100, 100);
    self.lightCameraMatrix = GLKMatrix4MakeLookAt(-defaultLight.direction.x * 10, -defaultLight.direction.y * 10, -defaultLight.direction.z * 10, 0, 0, 0, 0, 1, 0);
    
    
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"vertex" ofType:@".glsl"];
    NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"frag_shadowmap" ofType:@".glsl"];
    self.shadowMapContext = [GLContext contextWithVertexShaderPath:vertexShaderPath fragmentShaderPath:fragmentShaderPath];
    
    [self createShadowMap];
}

- (void)createShadowMap {
    self.shadowMapSize = CGSizeMake(1024, 1024);
    glGenFramebuffers(1, &shadowMapFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, shadowMapFramebuffer);
    
    // 生成深度缓冲区的纹理对象并绑定到framebuffer上
    glGenTextures(1, &shadowDepthMap);
    glBindTexture(GL_TEXTURE_2D, shadowDepthMap);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT, self.shadowMapSize.width, self.shadowMapSize.height, 0, GL_DEPTH_COMPONENT, GL_UNSIGNED_INT, NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT
                           , GL_TEXTURE_2D, shadowDepthMap, 0);
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        // framebuffer生成失败
    }
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

- (void)createFloor {
    UIImage *normalImage = [UIImage imageNamed:@"stoneFloor_NRM.png"];
    GLKTextureInfo *normalMap = [GLKTextureLoader textureWithCGImage:normalImage.CGImage options:nil error:nil];
    UIImage *diffuseImage = [UIImage imageNamed:@"stoneFloor.jpg"];
    GLKTextureInfo *diffuseMap = [GLKTextureLoader textureWithCGImage:diffuseImage.CGImage options:nil error:nil];
    
    NSString *cubeObjFile = [[NSBundle mainBundle] pathForResource:@"cube" ofType:@"obj"];
    WavefrontOBJ *cube = [WavefrontOBJ objWithGLContext:self.glContext objFile:cubeObjFile diffuseMap:diffuseMap normalMap:normalMap];
    cube.modelMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(0, -0.1, 0), GLKMatrix4MakeScale(3, 0.2, 3 ));
    [self.objects addObject:cube];
}

- (void)createBox:(GLKVector3)location size:(GLKVector3)size {
    UIImage *normalImage = [UIImage imageNamed:@"normal.png"];
    GLKTextureInfo *normalMap = [GLKTextureLoader textureWithCGImage:normalImage.CGImage options:nil error:nil];
    UIImage *diffuseImage = [UIImage imageNamed:@"texture.jpg"];
    GLKTextureInfo *diffuseMap = [GLKTextureLoader textureWithCGImage:diffuseImage.CGImage options:nil error:nil];
    
    NSString *cubeObjFile = [[NSBundle mainBundle] pathForResource:@"cube" ofType:@"obj"];
    WavefrontOBJ *cube = [WavefrontOBJ objWithGLContext:self.glContext objFile:cubeObjFile diffuseMap:diffuseMap normalMap:normalMap];
    cube.modelMatrix = GLKMatrix4MakeTranslation(location.x, location.y, location.z);
    cube.modelMatrix = GLKMatrix4Multiply(cube.modelMatrix, GLKMatrix4MakeScale(size.x, size.y, size.z));
    [self.objects addObject:cube];
}

#pragma mark - Update Delegate

- (void)update {
    [super update];
    self.eyePosition = GLKVector3Make(1, 4, 4);
    GLKVector3 lookAtPosition = GLKVector3Make(0, 0, 0);
    self.cameraMatrix = GLKMatrix4MakeLookAt(self.eyePosition.x, self.eyePosition.y, self.eyePosition.z, lookAtPosition.x, lookAtPosition.y, lookAtPosition.z, 0, 1, 0);
    
    DirectionLight light = self.light;
    light.direction = GLKVector3Make(-sin(self.elapsedTime), -1, -cos(self.elapsedTime));
    self.light = light;
    self.lightProjectionMatrix = GLKMatrix4MakeOrtho(-10, 10, -10, 10, -100, 100);
    self.lightCameraMatrix = GLKMatrix4MakeLookAt(-light.direction.x * 10, -light.direction.y * 10, -light.direction.z * 10, 0, 0, 0, 0, 1, 0);
    
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
        [obj.context setUniform3fv:@"light.direction" value:self.light.direction];
        [obj.context setUniform3fv:@"light.color" value:self.light.color];
        [obj.context setUniform1f:@"light.indensity" value:self.light.indensity];
        [obj.context setUniform1f:@"light.ambientIndensity" value:self.light.ambientIndensity];
        [obj.context setUniform3fv:@"material.diffuseColor" value:self.material.diffuseColor];
        [obj.context setUniform3fv:@"material.ambientColor" value:self.material.ambientColor];
        [obj.context setUniform3fv:@"material.specularColor" value:self.material.specularColor];
        [obj.context setUniform1f:@"material.smoothness" value:self.material.smoothness];
        
        [obj.context setUniform1i:@"useNormalMap" value:self.useNormalMap];
        
        [obj.context setUniformMatrix4fv:@"lightMatrix" value:GLKMatrix4Multiply(self.lightProjectionMatrix, self.lightCameraMatrix)];
        [obj.context bindTextureName:shadowDepthMap to:GL_TEXTURE2 uniformName:@"shadowMap"];
        
        [obj draw:obj.context];
    }];
}

- (void)drawObjectsForShadowMap {
    [self.objects enumerateObjectsUsingBlock:^(GLObject *obj, NSUInteger idx, BOOL *stop) {
        [self.shadowMapContext active];
        [obj.context setUniformMatrix4fv:@"projectionMatrix" value:self.lightProjectionMatrix];
        [obj.context setUniformMatrix4fv:@"cameraMatrix" value:self.lightCameraMatrix];
        [obj draw:self.shadowMapContext];
    }];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glBindFramebuffer(GL_FRAMEBUFFER, shadowMapFramebuffer);
    glViewport(0, 0, self.shadowMapSize.width, self.shadowMapSize.height);
    glClearColor(0.7, 0.7, 0.7, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [self drawObjectsForShadowMap];
    
    [(GLKView *)(self.view) bindDrawable];
    glClearColor(0.7, 0.7, 0.7, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [self drawObjects];
}
@end

