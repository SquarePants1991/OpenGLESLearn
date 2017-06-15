//
//  ARGLBaseViewController.m
//  OpenGLESLearn
//
//  Created by wang yang on 2017/6/15.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "ARGLBaseViewController.h"
#import "VideoPlane.h"
@import SceneKit;
@import ARKit;

@interface ARGLBaseViewController() <ARSessionDelegate>
@property (assign, nonatomic) GLKMatrix4 videoPlaneProjectionMatrix;

@property (strong, nonatomic) VideoPlane *videoPlane;
@property (strong, nonatomic) GLContext *videoPlaneContext;
@property (strong, nonatomic) GLKTextureInfo *yTexture;
@property (strong, nonatomic) GLKTextureInfo *uvTexture;

@property (strong, nonatomic) ARSession *arSession;
@end

@implementation ARGLBaseViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 使用透视投影矩阵
    self.videoPlaneProjectionMatrix = GLKMatrix4MakeOrtho(-0.5, 0.5, 0.5, -0.5, -100, 100);
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"vertex" ofType:@".glsl"];
    NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"frag_video" ofType:@".glsl"];
    self.videoPlaneContext = [GLContext contextWithVertexShaderPath:vertexShaderPath fragmentShaderPath:fragmentShaderPath];
    self.videoPlane = [[VideoPlane alloc] initWithGLContext:self.videoPlaneContext];
    GLKMatrix4 rotationMatrix = GLKMatrix4MakeRotation(M_PI / 2, 0, 0, 1);
    GLKMatrix4 scaleMatrix = GLKMatrix4MakeScale(1, -1, 1);
    self.videoPlane.modelMatrix = GLKMatrix4Multiply(rotationMatrix, scaleMatrix);
    
    [self setupAR];
    self.yTexture = [GLKTextureLoader textureWithCGImage:[UIImage imageNamed:@"grass_01.jpg"].CGImage options:nil error:nil];
    self.uvTexture = [GLKTextureLoader textureWithCGImage:[UIImage imageNamed:@"grass_01.jpg"].CGImage options:nil error:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self runAR];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self pauseAR];
}

#pragma mark - Update Delegate
- (void)update {
    [super update];
    [self.videoPlane update:self.timeSinceLastUpdate];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [super glkView:view drawInRect:rect];
    
    glDepthMask(GL_FALSE);
    [self.videoPlane.context active];
    [self.videoPlane.context setUniform1f:@"elapsedTime" value:(GLfloat)self.elapsedTime];
    [self.videoPlane.context setUniformMatrix4fv:@"projectionMatrix" value:self.videoPlaneProjectionMatrix];
    [self.videoPlane.context setUniformMatrix4fv:@"cameraMatrix" value:GLKMatrix4Identity];
    [self.videoPlane draw:self.videoPlane.context];
    glDepthMask(GL_TRUE);
}

#pragma make - AR Session
- (void)setupAR {
    if (@available(iOS 11.0, *)) {
        self.arSession = [ARSession new];
        self.arSession.delegate = self;
    }
}

- (void)runAR {
    if (@available(iOS 11.0, *)) {
        ARWorldTrackingSessionConfiguration *config = [ARWorldTrackingSessionConfiguration new];
        config.planeDetection = ARPlaneDetectionHorizontal;
        [self.arSession runWithConfiguration:config];
    }
}

- (void)pauseAR {
    if (@available(iOS 11.0, *)) {
        [self.arSession pause];
    }
}

- (void)session:(ARSession *)session didUpdateFrame:(ARFrame *)frame {
    CVPixelBufferRef pixelBuffer = frame.capturedImage;
    GLsizei imageWidth = (GLsizei)CVPixelBufferGetWidthOfPlane(pixelBuffer, 0);
    GLsizei imageHeight = (GLsizei)CVPixelBufferGetHeightOfPlane(pixelBuffer, 0);
    void * baseAddress = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    
    glBindTexture(GL_TEXTURE_2D, self.yTexture.name);
    glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
    glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
    glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, imageWidth, imageHeight, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, baseAddress);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    imageWidth = (GLsizei)CVPixelBufferGetWidthOfPlane(pixelBuffer, 1);
    imageHeight = (GLsizei)CVPixelBufferGetHeightOfPlane(pixelBuffer, 1);
    void *laAddress = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
    glBindTexture(GL_TEXTURE_2D, self.uvTexture.name);
    glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
    glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
    glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE_ALPHA, imageWidth, imageHeight, 0, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, laAddress);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    self.videoPlane.yuv_yTexture = self.yTexture.name;
    self.videoPlane.yuv_uvTexture = self.uvTexture.name;
    
    matrix_float4x4 cameraMatrix = matrix_invert([frame.ca transform]);
    for (int col = 0; col < 4; ++col) {
        for (int row = 0; row < 4; ++row) {
            //            self.worldProjectionMatrix.m[row * 4 + col] = projectionMatrix.columns[col][row];
            self.cameraMatrix.m[row * 4 + col] = cameraMatrix.columns[col][row];
        }
    }
}

- (void)session:(ARSession *)session cameraDidChangeTrackingState:(ARCamera *)camera {
    matrix_float4x4 projectionMatrix = [camera projectionMatrixWithViewportSize:self.view.bounds.size orientation:UIInterfaceOrientationPortrait zNear:0.1 zFar:1000];
    matrix_float4x4 cameraMatrix = matrix_invert([camera transform]);
    
    for (int col = 0; col < 4; ++col) {
        for (int row = 0; row < 4; ++row) {
//            self.worldProjectionMatrix.m[row * 4 + col] = projectionMatrix.columns[col][row];
            self.cameraMatrix.m[row * 4 + col] = cameraMatrix.columns[col][row];
        }
    }
}
@end
