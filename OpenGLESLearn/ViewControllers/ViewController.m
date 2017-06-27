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

typedef struct  {
    GLKVector3 direction;
    GLKVector3 color;
    GLfloat indensity;
    GLfloat ambientIndensity;
} Directionlight;

typedef struct {
    GLKVector3 diffuseColor;
    GLKVector3 ambientColor;
    GLKVector3 specularColor;
    GLfloat smoothness; // 0 ~ 1000 越高显得越光滑
} Material;

@interface ViewController ()
@property (assign, nonatomic) GLKMatrix4 projectionMatrix; // 投影矩阵
@property (assign, nonatomic) GLKMatrix4 cameraMatrix; // 观察矩阵
@property (assign, nonatomic) Directionlight light;
@property (assign, nonatomic) Material material;
@property (assign, nonatomic) GLKVector3 eyePosition;

@property (strong, nonatomic) WavefrontOBJ *carModel;
@property (strong, nonatomic) NSMutableArray<GLObject *> * objects;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 使用透视投影矩阵
    float aspect = self.view.frame.size.width / self.view.frame.size.height;
    self.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), aspect, 0.1, 1000.0);
    
    self.cameraMatrix = GLKMatrix4MakeLookAt(0, 1, 6.5, 0, 0, 0, 0, 1, 0);
    
    Directionlight defaultLight;
    defaultLight.color = GLKVector3Make(1, 1, 1); // 白色的灯
    defaultLight.direction = GLKVector3Make(1, -1, 0);
    defaultLight.indensity = 1.0;
    defaultLight.ambientIndensity = 0.1;
    self.light = defaultLight;
    
    Material material;
    material.ambientColor = GLKVector3Make(1, 1, 1);
    material.diffuseColor = GLKVector3Make(0.1, 0.1, 0.1);
    material.specularColor = GLKVector3Make(1, 1, 1);
    material.smoothness = 300;
    self.material = material;
    
    self.objects = [NSMutableArray new];
    [self createMonkeyFromObj];
}

- (void)createMonkeyFromObj {
    NSString *objFilePath = [[NSBundle mainBundle] pathForResource:@"car" ofType:@"obj"];
    self.carModel = [[WavefrontOBJ alloc] initWithGLContext:self.glContext objFile:objFilePath];
    self.carModel.modelMatrix = GLKMatrix4MakeRotation(- M_PI / 2.0, 0, 1, 0);
    [self.objects addObject:self.carModel];
}

#pragma mark - Update Delegate

- (void)update {
    [super update];
    self.eyePosition = GLKVector3Make(60, 100, 200);
    GLKVector3 lookAtPosition = GLKVector3Make(0, 0, 0);
    self.cameraMatrix = GLKMatrix4MakeLookAt(self.eyePosition.x, self.eyePosition.y, self.eyePosition.z, lookAtPosition.x, lookAtPosition.y, lookAtPosition.z, 0, 1, 0);
    
    self.carModel.modelMatrix = GLKMatrix4MakeRotation(- M_PI / 2.0 * self.elapsedTime / 4.0, 0, 1, 0);
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
        [obj.context setUniform3fv:@"eyePosition" value:self.eyePosition];
        [obj.context setUniform3fv:@"light.direction" value:self.light.direction];
        [obj.context setUniform3fv:@"light.color" value:self.light.color];
        [obj.context setUniform1f:@"light.indensity" value:self.light.indensity];
        [obj.context setUniform1f:@"light.ambientIndensity" value:self.light.ambientIndensity];
        [obj.context setUniform3fv:@"material.diffuseColor" value:self.material.diffuseColor];
        [obj.context setUniform3fv:@"material.ambientColor" value:self.material.ambientColor];
        [obj.context setUniform3fv:@"material.specularColor" value:self.material.specularColor];
        [obj.context setUniform1f:@"material.smoothness" value:self.material.smoothness];
        
        
        [obj draw:obj.context];
    }];
}

#pragma mark - Arguments Adjust

- (IBAction)smoothnessAdjust:(UISlider *)sender {
    Material _material = self.material;
    _material.smoothness = sender.value;
    self.material = _material;
}

- (IBAction)indensityAdjust:(UISlider *)sender {
    Directionlight _light = self.light;
    _light.indensity = sender.value;
    self.light = _light;
    
}

- (IBAction)lightColorAdjust:(UISlider *)sender {
    GLKVector3 yuv = GLKVector3Make(1.0, (cos(sender.value) + 1.0) / 2.0, (sin(sender.value) + 1.0) / 2.0);
    Directionlight _light = self.light;
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

