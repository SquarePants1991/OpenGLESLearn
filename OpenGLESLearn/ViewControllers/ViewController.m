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
#import "Building.h"

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
    [self createCylinder];
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
    NSMutableArray *shape = [NSMutableArray new];
    [shape addObject:[NSValue valueWithCGPoint:CGPointMake(-0.4, -0.3)]];
    [shape addObject:[NSValue valueWithCGPoint:CGPointMake(0.3, -0.34)]];
    [shape addObject:[NSValue valueWithCGPoint:CGPointMake(0.15, 0.38)]];
    [shape addObject:[NSValue valueWithCGPoint:CGPointMake(0, 0.58)]];
    [shape addObject:[NSValue valueWithCGPoint:CGPointMake(-0.2, 0.3)]];
    
    Building * cylinder = [[Building alloc] initWithGLContext:self.glContext shape:shape height:1.2 texture:metal1];
    cylinder.modelMatrix = GLKMatrix4MakeTranslation(0, 0, 0);
    [self.objects addObject:cylinder];
}

#pragma mark - Update Delegate

- (void)update {
    [super update];
    GLKVector3 eyePosition = GLKVector3Make(4 * sin(self.elapsedTime), 4 * sin(self.elapsedTime), 4 * cos(self.elapsedTime));
    self.cameraMatrix = GLKMatrix4MakeLookAt(eyePosition.x, eyePosition.y, eyePosition.z, 0, 0, 0, 0, 1, 0);
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
