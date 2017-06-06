//
//  Cylinder.m
//  OpenGLESLearn
//
//  Created by wangyang on 2017/6/6.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "Cylinder.h"
#import "GLGeometry.h"


@interface Cylinder ()
@property (strong, nonatomic) GLGeometry *topCircle; // 顶部圆形
@property (strong, nonatomic) GLGeometry *bottomCircle; // 底部圆形
@property (strong, nonatomic) GLGeometry *middleCylinder; // 中间圆柱部分

@property (strong, nonatomic) GLKTextureInfo *diffuseTexture;
@end

@implementation Cylinder
- (instancetype)initWithGLContext:(GLContext *)context sides:(int)sides radius:(GLfloat)radius height:(GLfloat)height texture:(GLKTextureInfo *)texture
{
    self = [super initWithGLContext:context];
    if (self) {
        self.modelMatrix = GLKMatrix4Identity;
        self.sideCount = sides;
        self.radius = radius;
        self.height = height;
        self.diffuseTexture = texture;
    }
    return self;
}

- (GLGeometry *)topCircle {
    if (_topCircle == nil) {
        _topCircle = [[GLGeometry alloc] initWithGeometryType:GLGeometryTypeTriangleFan];
    
        float y = self.height / 2.0;
        // 中心点
        GLVertex centerVertex = GLVertexMake(0, y, 0, 0, 1, 0, 0.5, 0.5);
        [_topCircle appendVertex:centerVertex];
        for (int i = self.sideCount; i >= 0; --i) {
            GLfloat angle = i / (float)self.sideCount * M_PI * 2;
            GLVertex vertex = GLVertexMake(cos(angle) * self.radius, y, sin(angle) * self.radius, 0, 1, 0, (cos(angle) + 1 ) / 2.0, (sin(angle) + 1 ) / 2.0);
            [_topCircle appendVertex:vertex];
        }
    }
    return _topCircle;
}

- (GLGeometry *)bottomCircle {
    if (_bottomCircle == nil) {
        _bottomCircle = [[GLGeometry alloc] initWithGeometryType:GLGeometryTypeTriangleFan];
        
        float y = -self.height / 2.0;
        // 中心点
        GLVertex centerVertex = GLVertexMake(0, y, 0, 0, -1, 0, 0.5, 0.5);
        [_bottomCircle appendVertex:centerVertex];
        for (int i = 0; i <= self.sideCount; ++i) {
            GLfloat angle = i / (float)self.sideCount * M_PI * 2;
            GLVertex vertex = GLVertexMake(cos(angle) * self.radius, y, sin(angle) * self.radius, 0, -1, 0, (cos(angle) + 1 ) / 2.0, (sin(angle) + 1 ) / 2.0);
            [_bottomCircle appendVertex:vertex];
        }
    }
    return _bottomCircle;
}

- (GLGeometry *)middleCylinder {
    if (_middleCylinder == nil) {
        _middleCylinder = [[GLGeometry alloc] initWithGeometryType:GLGeometryTypeTriangleStrip];
        
        float yUP = self.height / 2.0;
        float yDOWN = -self.height / 2.0;
        for (int i = 0; i <= self.sideCount; ++i) {
            GLfloat angle = i / (float)self.sideCount * M_PI * 2;
            GLKVector3 vertexNormal = GLKVector3Normalize(GLKVector3Make(cos(angle) * self.radius, 0, sin(angle) * self.radius));
            GLVertex vertexUp = GLVertexMake(cos(angle) * self.radius, yUP, sin(angle) * self.radius, vertexNormal.x, vertexNormal.y, vertexNormal.z, i / (float)self.sideCount, 0);
            GLVertex vertexDown = GLVertexMake(cos(angle) * self.radius, yDOWN, sin(angle) * self.radius, vertexNormal.x, vertexNormal.y, vertexNormal.z, i / (float)self.sideCount, 1);
            [_middleCylinder appendVertex:vertexDown];
            [_middleCylinder appendVertex:vertexUp];
        }
    }
    return _middleCylinder;
}

- (void)update:(NSTimeInterval)timeSinceLastUpdate {
    
}

- (void)draw:(GLContext *)glContext {
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);
    glFrontFace(GL_CCW);
    [glContext setUniformMatrix4fv:@"modelMatrix" value:self.modelMatrix];
    bool canInvert;
    GLKMatrix4 normalMatrix = GLKMatrix4InvertAndTranspose(self.modelMatrix, &canInvert);
    [glContext setUniformMatrix4fv:@"normalMatrix" value:canInvert ? normalMatrix : GLKMatrix4Identity];
    [glContext bindTexture:self.diffuseTexture to:GL_TEXTURE0 uniformName:@"diffuseMap"];
    [glContext drawGeometry:self.topCircle];
    [glContext drawGeometry:self.bottomCircle];
    [glContext drawGeometry:self.middleCylinder];
}
@end
