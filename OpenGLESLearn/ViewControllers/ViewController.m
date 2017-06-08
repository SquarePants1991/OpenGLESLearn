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

@interface ViewController ()
@property (assign, nonatomic) GLKMatrix4 projectionMatrix; // 投影矩阵
@property (assign, nonatomic) GLKMatrix4 cameraMatrix; // 观察矩阵
@property (assign, nonatomic) GLKVector3 lightDirection; // 平行光光照方向

@property (strong, nonatomic) NSMutableArray<GLObject *> * objects;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 使用透视投影矩阵
    float aspect = self.view.frame.size.width / self.view.frame.size.height;
    self.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), aspect, 0.1, 1000.0);

    self.cameraMatrix = GLKMatrix4MakeLookAt(0, 1, 6.5, 0, 0, 0, 0, 1, 0);

    // 设置平行光方向
    self.lightDirection = GLKVector3Make(1, -1, 0);


    self.objects = [NSMutableArray new];
    [self createTerrain];
}

- (void)createCubes {
    for (int j = -4; j <= 4; ++j) {
        for (int i = -4; i <= 4; ++i) {
            Cube * cube = [[Cube alloc] initWithGLContext:self.glContext];
            cube.modelMatrix = GLKMatrix4MakeTranslation(j * 2, 0, i * 2);
            [self.objects addObject:cube];
        }
    }
}

- (void)createCylinder {
    GLKTextureInfo *metal1 = [GLKTextureLoader textureWithCGImage:[UIImage imageNamed:@"metal_01.png"].CGImage options:nil error:nil];
    GLKTextureInfo *metal2 = [GLKTextureLoader textureWithCGImage:[UIImage imageNamed:@"metal_02.jpg"].CGImage options:nil error:nil];
    GLKTextureInfo *metal3 = [GLKTextureLoader textureWithCGImage:[UIImage imageNamed:@"metal_03.png"].CGImage options:nil error:nil];
    // 四边的圆柱体就是一个四方体
    Cylinder * cylinder = [[Cylinder alloc] initWithGLContext:self.glContext sides:4 radius:0.9 height:1.2 texture:metal1];
    cylinder.modelMatrix = GLKMatrix4MakeTranslation(0, 2, 0);
    [self.objects addObject:cylinder];
    
    Cylinder * cylinder2 = [[Cylinder alloc] initWithGLContext:self.glContext sides:16 radius:0.2 height:4.0 texture:metal3];
    [self.objects addObject:cylinder2];
    
    // 四边的圆柱体就是一个正方体
    Cylinder * cylinder3 = [[Cylinder alloc] initWithGLContext:self.glContext sides:4 radius:0.41 height:0.3 texture:metal2];
    cylinder3.modelMatrix = GLKMatrix4MakeTranslation(0, -2, 0);
    [self.objects addObject:cylinder3];
}

- (void)createTerrain {
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"vertex" ofType:@".glsl"];
    NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"frag_terrain" ofType:@".glsl"];
    GLContext *terrainContext = [GLContext contextWithVertexShaderPath:vertexShaderPath fragmentShaderPath:fragmentShaderPath];
    
    GLKTextureInfo *grass = [GLKTextureLoader textureWithCGImage:[UIImage imageNamed:@"grass_01.jpg"].CGImage options:nil error:nil];
    NSError *error;
    GLKTextureInfo *dirt = [GLKTextureLoader textureWithCGImage:[UIImage imageNamed:@"dirt_01.jpg"].CGImage options:nil error:&error];
    glEnable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, grass.name);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glBindTexture(GL_TEXTURE_2D, dirt.name);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

    
    UIImage *heightMap = [UIImage imageNamed:@"terrain_01.jpg"];
    Terrain *terrain = [[Terrain alloc] initWithGLContext:terrainContext heightMap:heightMap size:CGSizeMake(500, 500) height:100 grass:grass dirt:dirt];
    terrain.modelMatrix = GLKMatrix4MakeTranslation(-250, 0, -250);
    [self.objects addObject:terrain];
}

#pragma mark - Update Delegate

- (void)update {
    [super update];
    GLKVector3 eyePosition = GLKVector3Make(500 * sin(self.elapsedTime / 2.0), sin(self.elapsedTime) * 50 + 250, 500 * cos(self.elapsedTime / 2.0));
    GLKVector3 lookAtPosition = GLKVector3Make(0, 0, 0);
    self.cameraMatrix = GLKMatrix4MakeLookAt(eyePosition.x, eyePosition.y, eyePosition.z, lookAtPosition.x, lookAtPosition.y, lookAtPosition.z, 0, 1, 0);
    [self.objects enumerateObjectsUsingBlock:^(GLObject *obj, NSUInteger idx, BOOL *stop) {
        [obj update:self.timeSinceLastUpdate];
    }];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [super glkView:view drawInRect:rect];

    [self.objects enumerateObjectsUsingBlock:^(GLObject *obj, NSUInteger idx, BOOL *stop) {
        [obj.context active];
        [obj.context setUniform1f:@"elapsedTime" value:(GLfloat)self.elapsedTime];
        [obj.context setUniformMatrix4fv:@"projectionMatrix" value:self.projectionMatrix];
        [obj.context setUniformMatrix4fv:@"cameraMatrix" value:self.cameraMatrix];
        
        [obj.context setUniform3fv:@"lightDirection" value:self.lightDirection];
        [obj draw:obj.context];
    }];

}

@end
