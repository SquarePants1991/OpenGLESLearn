//
//  ARViewController.m
//  OpenGLESLearn
//
//  Created by wang yang on 2017/6/15.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "ARViewController.h"
#import "VideoPlane.h"
#import "Cube.h"

@interface ARViewController ()
@property (strong, nonatomic) NSMutableArray<GLObject *> * objects;
@property (assign, nonatomic) GLKVector3 lightDirection;
@end

@implementation ARViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置平行光方向
    self.lightDirection = GLKVector3Make(1, -1, 0);
    
    self.objects = [NSMutableArray new];
    [self createCube];
}

- (void)createCube {
    Cube * cube = [[Cube alloc] initWithGLContext:self.glContext];
    cube.modelMatrix = GLKMatrix4MakeTranslation(0, 0, -4);
    [self.objects addObject:cube];
}

- (void)update {
    [super update];
    [self.objects enumerateObjectsUsingBlock:^(GLObject *obj, NSUInteger idx, BOOL *stop) {
        [obj update:self.timeSinceLastUpdate];
    }];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [super glkView:view drawInRect:rect];
    
    [self.objects enumerateObjectsUsingBlock:^(GLObject *obj, NSUInteger idx, BOOL *stop) {
        [obj.context active];
        [obj.context setUniform1f:@"elapsedTime" value:(GLfloat)self.elapsedTime];
        [obj.context setUniformMatrix4fv:@"projectionMatrix" value:self.worldProjectionMatrix];
        [obj.context setUniformMatrix4fv:@"cameraMatrix" value:self.cameraMatrix];
        
        [obj.context setUniform3fv:@"lightDirection" value:self.lightDirection];
        [obj draw:obj.context];
    }];
}

#pragma mark - AR Session Delegate
- (void)session:(ARSession *)session didAddAnchors:(NSArray<ARAnchor*>*)anchors {
    
}
@end
