//
//  Building.m
//  OpenGLESLearn
//
//  Created by ocean on 2018/2/28.
//  Copyright © 2018年 wangyang. All rights reserved.
//

#import "Building.h"
#import "GLGeometry.h"

@interface Building()
@property (strong, nonatomic) GLGeometry *topShape; // 顶部多边形
@property (strong, nonatomic) GLGeometry *bottomShape; // 底部多边形
@property (strong, nonatomic) GLGeometry *middleCylinder; // 中间柱ti部分

@property (strong, nonatomic) GLKTextureInfo *diffuseTexture;
@end

@implementation Building
- (instancetype)initWithGLContext:(GLContext *)context shape:(NSArray *)shape height:(GLfloat)height texture:(GLKTextureInfo *)texture
{
    self = [super initWithGLContext:context];
    if (self) {
        self.modelMatrix = GLKMatrix4Identity;
        self.shape = shape;
        self.height = height;
        self.diffuseTexture = texture;
    }
    return self;
}

- (GLGeometry *)topShape {
    if (_topShape == nil) {
        _topShape = [[GLGeometry alloc] initWithGeometryType:GLGeometryTypeTriangleFan];
        
        float y = self.height / 2.0;
        // 中心点
        GLKVector3 shapePoints[self.shape.count + 1];
        GLKVector3 centerPoint = GLKVector3Make(0, 0, 0);
        int index = 0;
        for (NSValue * value in self.shape) {
            GLKVector3 point;
            CGPoint cgPoint = [value CGPointValue];
            point.x = cgPoint.x;
            point.z = cgPoint.y;
            point.y = 0;
            shapePoints[index] = point;
            centerPoint = GLKVector3Add(centerPoint, point);
            index++;
        }
        shapePoints[self.shape.count] = shapePoints[0];
        centerPoint = GLKVector3DivideScalar(centerPoint, self.shape.count);
        GLVertex centerVertex = GLVertexMake(centerPoint.x, y, centerPoint.z, 0, 1, 0, 0.5, 0.5);
        [_topShape appendVertex:centerVertex];
        NSUInteger sideCount = self.shape.count;
        for (NSInteger i = sideCount; i >= 0; --i) {
            GLKVector3 currentPoint = shapePoints[i];
            GLVertex vertex = GLVertexMake(currentPoint.x, y, currentPoint.z, 0, 1, 0, 0, 0);
            [_topShape appendVertex:vertex];
        }
    }
    return _topShape;
}

- (GLGeometry *)bottomShape {
    if (_bottomShape == nil) {
        _bottomShape = [[GLGeometry alloc] initWithGeometryType:GLGeometryTypeTriangleFan];
        
        float y = -self.height / 2.0;
        // 中心点
        GLKVector3 shapePoints[self.shape.count + 1];
        GLKVector3 centerPoint = GLKVector3Make(0, 0, 0);
        int index = 0;
        for (NSValue * value in self.shape) {
            GLKVector3 point;
            CGPoint cgPoint = [value CGPointValue];
            point.x = cgPoint.x;
            point.z = cgPoint.y;
            point.y = 0;
            shapePoints[index] = point;
            centerPoint = GLKVector3Add(centerPoint, point);
            index++;
        }
        shapePoints[self.shape.count] = shapePoints[0];
        centerPoint = GLKVector3DivideScalar(centerPoint, self.shape.count);
        GLVertex centerVertex = GLVertexMake(centerPoint.x, y, centerPoint.z, 0, 1, 0, 0.5, 0.5);
        [_bottomShape appendVertex:centerVertex];
        NSUInteger sideCount = self.shape.count;
        for (NSInteger i = 0; i <= sideCount; ++i) {
            GLKVector3 currentPoint = shapePoints[i];
            GLVertex vertex = GLVertexMake(currentPoint.x, y, currentPoint.z, 0, -1, 0, 0, 0);
            [_bottomShape appendVertex:vertex];
        }
    }
    return _bottomShape;
}

- (GLGeometry *)middleCylinder {
    if (_middleCylinder == nil) {
        _middleCylinder = [[GLGeometry alloc] initWithGeometryType:GLGeometryTypeTriangleStrip];
        
        float yUP = self.height / 2.0;
        float yDOWN = -self.height / 2.0;
        
        GLKVector3 shapePoints[self.shape.count + 1];
        GLKVector3 centerPoint = GLKVector3Make(0, 0, 0);
        int index = 0;
        for (NSValue * value in self.shape) {
            GLKVector3 point;
            CGPoint cgPoint = [value CGPointValue];
            point.x = cgPoint.x;
            point.z = cgPoint.y;
            point.y = 0;
            shapePoints[index] = point;
            centerPoint = GLKVector3Add(centerPoint, point);
            index++;
        }
        shapePoints[self.shape.count] = shapePoints[0];
        centerPoint = GLKVector3DivideScalar(centerPoint, self.shape.count);
        NSUInteger sideCount = self.shape.count;
        
        for (int i = 0; i <= sideCount; ++i) {
            GLKVector3 vertexNormal = GLKVector3Normalize(GLKVector3Subtract(shapePoints[i], centerPoint));
            GLVertex vertexUp = GLVertexMake(shapePoints[i].x, yUP, shapePoints[i].z, vertexNormal.x, vertexNormal.y, vertexNormal.z, 0, 0);
            GLVertex vertexDown = GLVertexMake(shapePoints[i].x, yDOWN, shapePoints[i].z, vertexNormal.x, vertexNormal.y, vertexNormal.z, 0, 1);
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
    [glContext drawGeometry:self.topShape];
    [glContext drawGeometry:self.bottomShape];
    [glContext drawGeometry:self.middleCylinder];
}
@end
