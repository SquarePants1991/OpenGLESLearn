//
//  GLGeometry.h
//  OpenGLESLearn
//
//  Created by wangyang on 2017/6/6.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "GLObject.h"

typedef enum : NSUInteger {
    GLGeometryTypeTriangles,
    GLGeometryTypeTriangleStrip,
    GLGeometryTypeTriangleFan,
} GLGeometryType;

typedef struct {
    GLfloat x;
    GLfloat y;
    GLfloat z;
    GLfloat normalX;
    GLfloat normalY;
    GLfloat normalZ;
    GLfloat u;
    GLfloat v;
} GLVertex;

static inline GLVertex GLVertexMake( GLfloat x,
                         GLfloat y,
                         GLfloat z,
                         GLfloat normalX,
                         GLfloat normalY,
                         GLfloat normalZ,
                         GLfloat u,
                         GLfloat v) {
    GLVertex vertex;
    vertex.x = x;
    vertex.y = y;
    vertex.z = z;
    vertex.normalX = normalX;
    vertex.normalY = normalY;
    vertex.normalZ = normalZ;
    vertex.u = u;
    vertex.v = v;
    return vertex;
}

@interface GLGeometry : GLObject
@property (assign, nonatomic) GLGeometryType geometryType;
- (instancetype)initWithGeometryType:(GLGeometryType)geometryType;
- (void)appendVertex:(GLVertex)vertex;
- (GLuint)getVBO;
- (int)vertexCount;
@end
