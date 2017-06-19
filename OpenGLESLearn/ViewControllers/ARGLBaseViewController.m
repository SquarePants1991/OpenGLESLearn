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

@interface ARGLBaseViewController() 
@property (assign, nonatomic) GLKMatrix4 videoPlaneProjectionMatrix; // 用于显示视频的ortho投影矩阵

@property (strong, nonatomic) VideoPlane *videoPlane;
@property (strong, nonatomic) GLContext *videoPlaneContext;
@property (assign, nonatomic) GLuint yTexture;
@property (assign, nonatomic) GLuint uvTexture;

@property (assign, nonatomic) CGRect viewport; // 计算适当的viewport保持图片的比例
@end

@implementation ARGLBaseViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupVideoPlane];
    [self setupAR];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self runAR];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self pauseAR];
}

- (void)dealloc {
    glDeleteTextures(1, &_yTexture);
    glDeleteTextures(1, &_uvTexture);
}

- (void)setupVideoPlane {
    glGenTextures(1, &_yTexture);
    glBindTexture(GL_TEXTURE_2D, self.yTexture);
    glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
    glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    
    glGenTextures(1, &_uvTexture);
    glBindTexture(GL_TEXTURE_2D, self.uvTexture);
    glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
    glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    self.videoPlaneProjectionMatrix = GLKMatrix4MakeOrtho(-0.5, 0.5, 0.5, -0.5, -100, 100);
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"vertex" ofType:@".glsl"];
    NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"frag_video" ofType:@".glsl"];
    self.videoPlaneContext = [GLContext contextWithVertexShaderPath:vertexShaderPath fragmentShaderPath:fragmentShaderPath];
    self.videoPlane = [[VideoPlane alloc] initWithGLContext:self.videoPlaneContext];
    GLKMatrix4 rotationMatrix = GLKMatrix4MakeRotation(M_PI / 2, 0, 0, 1);
    GLKMatrix4 scaleMatrix = GLKMatrix4MakeScale(1, -1, 1);
    self.videoPlane.modelMatrix = GLKMatrix4Multiply(rotationMatrix, scaleMatrix);
}

#pragma mark - Update Delegate
- (void)update {
    [super update];
    [self.videoPlane update:self.timeSinceLastUpdate];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [super glkView:view drawInRect:rect];
    
    glViewport(self.viewport.origin.x, self.viewport.origin.y, self.viewport.size.width, self.viewport.size.height);
    
    glDepthMask(GL_FALSE);
    [self.videoPlane.context active];
    [self.videoPlane.context setUniform1f:@"elapsedTime" value:(GLfloat)self.elapsedTime];
    [self.videoPlane.context setUniformMatrix4fv:@"projectionMatrix" value:self.videoPlaneProjectionMatrix];
    [self.videoPlane.context setUniformMatrix4fv:@"cameraMatrix" value:GLKMatrix4Identity];
    [self.videoPlane draw:self.videoPlane.context];
    glDepthMask(GL_TRUE);
}

#pragma make - AR Control
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

#pragma make - AR Session Delegate

- (void)setupViewport:(CGSize)imageSize {
    CGFloat originViewportWidth = self.view.frame.size.width * [UIScreen mainScreen].scale;
    CGFloat originViewportHeight = self.view.frame.size.height * [UIScreen mainScreen].scale;
    CGFloat widthScale = originViewportWidth / imageSize.width;
    CGFloat heightScale =  originViewportHeight / imageSize.height;
    CGFloat scale = widthScale > heightScale ? widthScale : heightScale;
    
    CGFloat viewportWidth = imageSize.width * scale;
    CGFloat viewportHeight = imageSize.height * scale;
    CGFloat viewportX = (originViewportWidth - viewportWidth) / 2.0;
    CGFloat viewportY = (originViewportHeight - viewportHeight) / 2.0;
    self.viewport = CGRectMake(viewportX, viewportY, viewportWidth, viewportHeight);
}

- (void)session:(ARSession *)session didUpdateFrame:(ARFrame *)frame {
    // 同步YUV信息到 yTexture 和 uvTexture
    CVPixelBufferRef pixelBuffer = frame.capturedImage;
    GLsizei imageWidth = (GLsizei)CVPixelBufferGetWidthOfPlane(pixelBuffer, 0);
    GLsizei imageHeight = (GLsizei)CVPixelBufferGetHeightOfPlane(pixelBuffer, 0);
    void * baseAddress = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    
    glBindTexture(GL_TEXTURE_2D, self.yTexture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, imageWidth, imageHeight, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, baseAddress);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    imageWidth = (GLsizei)CVPixelBufferGetWidthOfPlane(pixelBuffer, 1);
    imageHeight = (GLsizei)CVPixelBufferGetHeightOfPlane(pixelBuffer, 1);
    void *laAddress = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
    glBindTexture(GL_TEXTURE_2D, self.uvTexture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE_ALPHA, imageWidth, imageHeight, 0, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, laAddress);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    self.videoPlane.yuv_yTexture = self.yTexture;
    self.videoPlane.yuv_uvTexture = self.uvTexture;
    [self setupViewport: CGSizeMake(imageHeight, imageWidth)];
    
    // 同步摄像机
    matrix_float4x4 cameraMatrix = matrix_invert([frame.camera transform]);
    GLKMatrix4 newCameraMatrix = GLKMatrix4Identity;
    for (int col = 0; col < 4; ++col) {
        for (int row = 0; row < 4; ++row) {
            newCameraMatrix.m[col * 4 + row] = cameraMatrix.columns[col][row];
        }
    }
    
    self.cameraMatrix = newCameraMatrix;
    GLKVector3 forward = GLKVector3Make(-self.cameraMatrix.m13, -self.cameraMatrix.m23, -self.cameraMatrix.m33);
    GLKMatrix4 rotationMatrix = GLKMatrix4MakeRotation(M_PI / 2, forward.x, forward.y, forward.z);
    self.cameraMatrix = GLKMatrix4Multiply(rotationMatrix, newCameraMatrix);
}

- (void)session:(ARSession *)session cameraDidChangeTrackingState:(ARCamera *)camera {
    matrix_float4x4 projectionMatrix = [camera projectionMatrixWithViewportSize:self.viewport.size orientation:UIInterfaceOrientationPortrait zNear:0.1 zFar:1000];
    GLKMatrix4 newWorldProjectionMatrix = GLKMatrix4Identity;
    for (int col = 0; col < 4; ++col) {
        for (int row = 0; row < 4; ++row) {
           newWorldProjectionMatrix.m[col * 4 + row] = projectionMatrix.columns[col][row];
        }
    }
    self.worldProjectionMatrix = newWorldProjectionMatrix;
}
@end
