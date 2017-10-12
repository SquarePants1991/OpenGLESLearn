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
#import "SkyBox.h"
#import "Terrain.h"
#import "Cube.h"
#import "Cylinder.h"
#import "PhysicsEngine.h"

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

typedef enum : NSUInteger {
    FogTypeLinear = 0,
    FogTypeExp = 1,
    FogTypeExpSquare  = 2,
} FogType;

typedef struct {
    FogType fogType;
    // for linear
    GLfloat fogStart;
    GLfloat fogEnd;
    // for exp & exp square
    GLfloat fogIndensity;
    GLKVector3 fogColor;
} Fog;

@interface ViewController ()

@property (assign, nonatomic) GLKMatrix4 projectionMatrix; // 投影矩阵
@property (assign, nonatomic) GLKMatrix4 cameraMatrix; // 观察矩阵
@property (assign, nonatomic) DirectionLight light;
@property (assign, nonatomic) Material material;
@property (assign, nonatomic) GLKVector3 eyePosition;

@property (strong, nonatomic) NSMutableArray<GLObject *> * objects;
@property (assign, nonatomic) BOOL useNormalMap;

@property (strong, nonatomic) GLKTextureInfo * cubeTexture;

@property (strong, nonatomic) SkyBox * skyBox;
@property (assign, nonatomic) Fog fog;

@property (strong, nonatomic) PhysicsEngine *physicsEngine;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 使用透视投影矩阵
    float aspect = self.view.frame.size.width / self.view.frame.size.height;
    self.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(60), aspect, 0.1, 10000.0);
    self.cameraMatrix = GLKMatrix4MakeLookAt(0, 1, 6.5, 0, 0, 0, 0, 1, 0);
    
    DirectionLight defaultLight;
    defaultLight.color = GLKVector3Make(1, 1, 1); // 白色的灯
    defaultLight.direction = GLKVector3Make(-1, -1, 0);
    defaultLight.indensity = 1.0;
    defaultLight.ambientIndensity = 0.1;
    self.light = defaultLight;
    
    Material material;
    material.ambientColor = GLKVector3Make(1, 1, 1);
    material.diffuseColor = GLKVector3Make(0.8, 0.1, 0.2);
    material.specularColor = GLKVector3Make(0, 0, 0);
    material.smoothness = 0;
    self.material = material;
    
    Fog fog;
    fog.fogColor = GLKVector3Make(1, 1,1);
    fog.fogStart = 0;
    fog.fogEnd = 200;
    fog.fogIndensity = 0.02;
    fog.fogType = FogTypeExpSquare;
    self.fog = fog;
    
    self.useNormalMap = NO;
    
    self.objects = [NSMutableArray new];
    
    // Physics
    self.physicsEngine = [PhysicsEngine new];
    RigidBody *rigidBody = [[RigidBody alloc] initAsBox:GLKVector3Make(1, 1, 1)];
    [self.physicsEngine addRigidBody:rigidBody];
    
    [self createPhysicsCube];
}

- (void)createPhysicsCube {
    UIImage *normalImage = [UIImage imageNamed:@"metal.jpg"];
    GLKTextureInfo *normalMap = [GLKTextureLoader textureWithCGImage:normalImage.CGImage options:nil error:nil];
    UIImage *diffuseImage = [UIImage imageNamed:@"metal.jpg"];
    GLKTextureInfo *diffuseMap = [GLKTextureLoader textureWithCGImage:diffuseImage.CGImage options:nil error:nil];
    Cylinder * cube = [[Cylinder alloc] initWithGLContext:self.glContext sides:10 radius:1 height:1 texture:diffuseMap];
    // Cylinder *cube = [[Cube alloc] initWithGLContext:self.glContext diffuseMap:diffuseMap normalMap:normalMap];
    cube.modelMatrix = GLKMatrix4Identity;
    [self.objects addObject:cube];
}

#pragma mark - Update Delegate

- (void)update {
    [super update];
    [self.physicsEngine update: self.timeSinceLastUpdate];
    self.eyePosition = GLKVector3Make(0, 0, 1);
    GLKVector3 lookAtPosition = GLKVector3Make(0, 0, 0);
    self.cameraMatrix = GLKMatrix4MakeLookAt(self.eyePosition.x, self.eyePosition.y, self.eyePosition.z, lookAtPosition.x, lookAtPosition.y, lookAtPosition.z, 0, 1, 0);
    
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

        [obj draw:obj.context];
    }];
}


- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.1, 0.7, 0.7, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [self drawObjects];
}
@end

