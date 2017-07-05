//
//  GLBaseViewController.m
//  OpenGLESLearn
//
//  Created by wangyang on 2017/4/24.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "GLBaseViewController.h"
#import "GLContext.h"

@interface GLBaseViewController ()
@property (strong, nonatomic) EAGLContext *context;
@end

@implementation GLBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupContext];
    [self setupGLContext];
}

#pragma mark - Setup Context
- (void)setupContext {
    // 使用OpenGL ES2, ES2之后都采用Shader来管理渲染管线
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    // 设置帧率为60fps
    self.preferredFramesPerSecond = 60;
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    view.drawableMultisample = GLKViewDrawableMultisample4X;
    [EAGLContext setCurrentContext:self.context];
    
    // 设置OpenGL状态
    glEnable(GL_DEPTH_TEST);
}

- (void)setupGLContext {
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"vertex" ofType:@".glsl"];
    NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"fragment" ofType:@".glsl"];
    self.glContext = [GLContext contextWithVertexShaderPath:vertexShaderPath fragmentShaderPath:fragmentShaderPath];
}

#pragma mark - Update Delegate

- (void)update {
    // 距离上一次调用update过了多长时间，比如一个游戏物体速度是3m/s,那么每一次调用update，
    // 他就会行走3m/s * deltaTime，这样做就可以让游戏物体的行走实际速度与update调用频次无关
    NSTimeInterval deltaTime = self.timeSinceLastUpdate;
    self.elapsedTime += deltaTime;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    // 清空之前的绘制
    glClearColor(0.7, 0.7, 0.7, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    [self.glContext active];
    // 设置shader中的 uniform elapsedTime 的值
    [self.glContext setUniform1f:@"elapsedTime" value:(GLfloat)self.elapsedTime];
}

@end
