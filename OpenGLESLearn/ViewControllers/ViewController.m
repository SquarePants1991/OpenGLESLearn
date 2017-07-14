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

@property (strong, nonatomic) NSMutableArray<GLObject *> * objects;
@property (assign, nonatomic) BOOL useNormalMap;

// 投影器矩阵
@property (assign, nonatomic) GLKMatrix4 projectorMatrix;
@property (strong, nonatomic) GLKTextureInfo * projectorMap;
@property (assign, nonatomic) BOOL useProjector;
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
    [self createBox:GLKVector3Make(-1, 0.5, -1.3)];
    [self createBox:GLKVector3Make(1, 0.2, 1)];
    [self createFloor];
    
    GLKMatrix4 projectorProjectionMatrix = GLKMatrix4MakeOrtho(-1, 1, -1, 1, -100, 100);
    GLKMatrix4 projectorCameraMatrix = GLKMatrix4MakeLookAt(0.4, 4, 0, 0, 0, 0, 0, 1, 0);
    self.projectorMatrix = GLKMatrix4Multiply(projectorProjectionMatrix, projectorCameraMatrix);
    
    UIImage *projectorImage = [UIImage imageNamed:@"squarepants.jpg"];
    self.projectorMap = [GLKTextureLoader textureWithCGImage:projectorImage.CGImage options:nil error:nil];
    
    self.useProjector = YES;
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

- (void)createBox:(GLKVector3)location {
    UIImage *normalImage = [UIImage imageNamed:@"normal.png"];
    GLKTextureInfo *normalMap = [GLKTextureLoader textureWithCGImage:normalImage.CGImage options:nil error:nil];
    UIImage *diffuseImage = [UIImage imageNamed:@"texture.jpg"];
    GLKTextureInfo *diffuseMap = [GLKTextureLoader textureWithCGImage:diffuseImage.CGImage options:nil error:nil];
    
    NSString *cubeObjFile = [[NSBundle mainBundle] pathForResource:@"cube" ofType:@"obj"];
    WavefrontOBJ *cube = [WavefrontOBJ objWithGLContext:self.glContext objFile:cubeObjFile diffuseMap:diffuseMap normalMap:normalMap];
    cube.modelMatrix = GLKMatrix4MakeTranslation(location.x, location.y, location.z);
    [self.objects addObject:cube];
}

#pragma mark - Update Delegate

- (void)update {
    [super update];
    self.eyePosition = GLKVector3Make(1, 4, 4);
    GLKVector3 lookAtPosition = GLKVector3Make(0, 0, 0);
    self.cameraMatrix = GLKMatrix4MakeLookAt(self.eyePosition.x, self.eyePosition.y, self.eyePosition.z, lookAtPosition.x, lookAtPosition.y, lookAtPosition.z, 0, 1, 0);
    
    [self.objects enumerateObjectsUsingBlock:^(GLObject *obj, NSUInteger idx, BOOL *stop) {
        [obj update:self.timeSinceLastUpdate];
    }];
    
    // update projector matrix
    GLKMatrix4 projectorProjectionMatrix = GLKMatrix4MakeOrtho(-2, 2, -2, 2, -100, 100);
    GLKMatrix4 projectorCameraMatrix = GLKMatrix4MakeLookAt(0, 4, 0, 0, 0, 0, cos(self.elapsedTime), 0, sin(self.elapsedTime));
    self.projectorMatrix = GLKMatrix4Multiply(projectorProjectionMatrix, projectorCameraMatrix);
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
        
        [obj.context setUniformMatrix4fv:@"projectorMatrix" value: self.projectorMatrix];
        [obj.context bindTexture:self.projectorMap to:GL_TEXTURE2 uniformName:@"projectorMap"];
        [obj.context setUniform1i:@"useProjector" value:self.useProjector];
        
        [obj draw:obj.context];
    }];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.7, 0.7, 0.7, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [self drawObjects];
}

#pragma mark - UI Control

- (IBAction)projectorEnableChanged:(UISwitch *)sender {
    self.useProjector = sender.isOn;
}

@end

