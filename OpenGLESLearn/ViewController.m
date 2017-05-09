//
//  ViewController.m
//  OpenGLESDemo
//
//  Created by wangyang on 15/8/28.
//  Copyright (c) 2015年 wangyang. All rights reserved.
//

#import "ViewController.h"
#import "GLContext.h"
#import "Laser.h"

@interface ViewController ()
@property (strong, nonatomic) GLContext *laserContext;
@property (assign, nonatomic) GLKMatrix4 projectionMatrix; // 投影矩阵
@property (assign, nonatomic) GLKMatrix4 cameraMatrix; // 观察矩阵
@property (assign, nonatomic) GLKVector3 lightDirection; // 平行光光照方向

@property (strong, nonatomic) NSMutableArray<Laser *> * lasers;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 使用透视投影矩阵
    float aspect = self.view.frame.size.width / self.view.frame.size.height;
    self.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), aspect, 0.1, 100.0);

    self.cameraMatrix = GLKMatrix4MakeLookAt(1.5, -1, 0, 0, 0, -10, 0, 1, 0);

    // 设置平行光方向
    self.lightDirection = GLKVector3Make(1, -1, 0);


    self.lasers = [NSMutableArray new];
    [self prepareLasers];
    [self prepareLaserGLContext];
}

- (void)prepareLasers {
    Laser *laser = [[Laser alloc] initWithLaserImage:[UIImage imageNamed:@"laser.png"]];
    laser.position = GLKVector3Make(0, 0, -40);
    laser.direction = GLKVector3Make(0.08, 0.08, 1);
    laser.length = 60;
    laser.radius = 1;
    [self.lasers addObject:laser];

    laser = [[Laser alloc] initWithLaserImage:[UIImage imageNamed:@"laser.png"]];
    laser.position = GLKVector3Make(0, 0, -40);
    laser.direction = GLKVector3Make(-0.08, -0.08, 1);
    laser.length = 60;
    laser.radius = 1;
    [self.lasers addObject:laser];

    laser = [[Laser alloc] initWithLaserImage:[UIImage imageNamed:@"laser.png"]];
    laser.position = GLKVector3Make(0, 0, -40);
    laser.direction = GLKVector3Make(-0.08, -0.08, 1);
    laser.length = 60;
    laser.radius = 1;
    [self.lasers addObject:laser];

    laser = [[Laser alloc] initWithLaserImage:[UIImage imageNamed:@"laser.png"]];
    laser.position = GLKVector3Make(0, 0, -40);
    laser.direction = GLKVector3Make(-0.08, -0.08, 1);
    laser.length = 60;
    laser.radius = 1;
    [self.lasers addObject:laser];
}

- (void)prepareLaserGLContext {
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"vertex" ofType:@".glsl"];
    NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"frg_laser" ofType:@".glsl"];
    self.laserContext = [GLContext contextWithVertexShaderPath:vertexShaderPath fragmentShaderPath:fragmentShaderPath];
}

#pragma mark - Update Delegate

- (void)update {
    [super update];
    [self.lasers enumerateObjectsUsingBlock:^(Laser *obj, NSUInteger idx, BOOL *stop) {
        [obj update:self.timeSinceLastUpdate];
    }];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [super glkView:view drawInRect:rect];

    [self.laserContext active];
    [self.laserContext setUniform1f:@"elapsedTime" value:(GLfloat)self.elapsedTime];
    [self.laserContext setUniformMatrix4fv:@"projectionMatrix" value:self.projectionMatrix];
    [self.laserContext setUniformMatrix4fv:@"cameraMatrix" value:self.cameraMatrix];

    [self.laserContext setUniform3fv:@"lightDirection" value:self.lightDirection];

    [self.lasers enumerateObjectsUsingBlock:^(Laser *obj, NSUInteger idx, BOOL *stop) {
        [obj draw:self.laserContext];
    }];

}

@end
