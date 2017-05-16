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

    self.cameraMatrix = GLKMatrix4MakeLookAt(0, 1, 3, 0, 0, 0, 0, 1, 0);

    // 设置平行光方向
    self.lightDirection = GLKVector3Make(1, -1, 0);


    self.objects = [NSMutableArray new];
    [self createCubes];
}

- (void)createCubes {
    for (int j = -4; j <= 4; ++j) {
        for (int i = -10; i <= 10; ++i) {
            Cube * cube = [[Cube alloc] initWithGLContext:self.glContext];
            cube.modelMatrix = GLKMatrix4MakeTranslation(j * 2, 0, i * 2);
            [self.objects addObject:cube];
        }
    }
}

#pragma mark - Update Delegate

- (void)update {
    [super update];
    GLKVector3 eyePosition = GLKVector3Make(2 * sin(self.elapsedTime), 2, 2 * cos(self.elapsedTime));
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
