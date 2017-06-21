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
#import "FeaturePointCloud.h"

@interface ARViewController ()
@property (strong, nonatomic) NSMutableDictionary<ARAnchor *, GLObject *> * objects;
@property (assign, nonatomic) GLKVector3 lightDirection;
@property (strong, nonatomic) FeaturePointCloud *pointCloud;
@end

@implementation ARViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 设置平行光方向
    self.lightDirection = GLKVector3Make(1, -1, 0);
    self.objects = [NSMutableDictionary new];
    
    
    [self createPointCloud];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)createPointCloud {
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"vertex" ofType:@".glsl"];
    NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"frag_point_cloud" ofType:@".glsl"];
    GLContext *pointCloudContext = [GLContext contextWithVertexShaderPath:vertexShaderPath fragmentShaderPath:fragmentShaderPath];
    self.pointCloud = [[FeaturePointCloud alloc] initWithGLContext:pointCloudContext];
    self.pointCloud.modelMatrix = GLKMatrix4Identity;
}

- (void)createCubeWithAnchor:(ARAnchor *)anchor {
    Cube * cube = [[Cube alloc] initWithGLContext:self.glContext];
    GLKMatrix4 glkTransform = GLKMatrix4Identity;
    for (int col = 0; col < 4; ++col) {
        for (int row = 0; row < 4; ++row) {
            glkTransform.m[col * 4 + row] = anchor.transform.columns[col][row];
        }
    }
    GLKMatrix4 scaleMatrix = GLKMatrix4MakeScale(0.075, 0.075, 0.075);
    cube.modelMatrix = GLKMatrix4Multiply(glkTransform, scaleMatrix);
    [self.objects setObject:cube forKey:anchor];
}

- (void)updateCubeWithAnchor:(ARAnchor *)anchor {
    Cube * cube = (Cube *)self.objects[anchor];
    GLKMatrix4 glkTransform = GLKMatrix4Identity;
    for (int col = 0; col < 4; ++col) {
        for (int row = 0; row < 4; ++row) {
            glkTransform.m[col * 4 + row] = anchor.transform.columns[col][row];
        }
    }
    GLKMatrix4 scaleMatrix = GLKMatrix4MakeScale(0.075, 0.075, 0.075);
    cube.modelMatrix = GLKMatrix4Multiply(glkTransform, scaleMatrix);
}

- (void)update {
    [super update];
    [self.objects.allValues enumerateObjectsUsingBlock:^(GLObject *obj, NSUInteger idx, BOOL *stop) {
        [obj update:self.timeSinceLastUpdate];
    }];
    [self.pointCloud update:self.timeSinceLastUpdate];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [super glkView:view drawInRect:rect];
    
    [self.objects.allValues enumerateObjectsUsingBlock:^(GLObject *obj, NSUInteger idx, BOOL *stop) {
        [obj.context active];
        [obj.context setUniform1f:@"elapsedTime" value:(GLfloat)self.elapsedTime];
        [obj.context setUniformMatrix4fv:@"projectionMatrix" value:self.worldProjectionMatrix];
        [obj.context setUniformMatrix4fv:@"cameraMatrix" value: self.cameraMatrix];
        
        [obj.context setUniform3fv:@"lightDirection" value:self.lightDirection];
        [obj draw:obj.context];
    }];
    
    [self.pointCloud.context active];
    [self.pointCloud.context setUniform1f:@"elapsedTime" value:(GLfloat)self.elapsedTime];
    [self.pointCloud.context setUniformMatrix4fv:@"projectionMatrix" value:self.worldProjectionMatrix];
    [self.pointCloud.context setUniformMatrix4fv:@"cameraMatrix" value: self.cameraMatrix];
    [self.pointCloud draw:self.pointCloud.context];
}

#pragma mark - Handle Tap & Create Cube
- (void)handleTap:(UIGestureRecognizer *)gesture {
    ARFrame *currentFrame = [self.arSession currentFrame];
    matrix_float4x4 translation = matrix_identity_float4x4;
    translation.columns[3][2] = -0.2;
    matrix_float4x4 transform = simd_mul(currentFrame.camera.transform, translation);
    
    ARAnchor *anchor = [[ARAnchor alloc] initWithTransform:transform];
    [self.arSession addAnchor:anchor];
}

#pragma mark - AR Session Delegate

- (void)session:(ARSession *)session didUpdateFrame:(ARFrame *)frame {
    [super session:session didUpdateFrame:frame];
    for (ARAnchor *anchor in [frame anchors]) {
        [self updateCubeWithAnchor: anchor];
    }
    [self.pointCloud setCloudData:frame.rawFeaturePoints];
}

- (void)session:(ARSession *)session didAddAnchors:(NSArray<ARAnchor*>*)anchors {
    for (ARAnchor *anchor in anchors) {
        [self createCubeWithAnchor:anchor];
    }
}

- (void)session:(ARSession *)session didUpdateAnchors:(NSArray<ARAnchor *> *)anchors {
    for (ARAnchor *anchor in anchors) {
        [self updateCubeWithAnchor: anchor];
    }
}

- (void)session:(ARSession *)session didRemoveAnchors:(NSArray<ARAnchor *> *)anchors {
    for (ARAnchor *anchor in anchors) {
        [self.objects removeObjectForKey:anchor];
    }
}
@end
