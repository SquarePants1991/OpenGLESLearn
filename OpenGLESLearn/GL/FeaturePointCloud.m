//
//  FeaturePointCloud.m
//  OpenGLESLearn
//
//  Created by wang yang on 2017/6/21.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "FeaturePointCloud.h"
#import <ARKit/ARKit.h>

@interface FeaturePointCloud () {
    GLuint vbo;
}
@property (strong, nonatomic) ARPointCloud *pointCloud;
@end

@implementation FeaturePointCloud

- (id)initWithGLContext:(GLContext *)context {
    self = [super initWithGLContext:context];
    if (self) {
        glGenBuffers(1, &vbo);
        [self updateVBO];
    }
    return self;
}

- (void)dealloc {
    glDeleteBuffers(1, &vbo);
}

- (void)setCloudData:(ARPointCloud *)pointCloud {
    self.pointCloud = pointCloud;
    [self updateVBO];
}

- (void)updateVBO {
    if (self.pointCloud) {
        NSInteger bytesCount = self.pointCloud.count * sizeof(vector_float3);
        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glBufferData(GL_ARRAY_BUFFER, bytesCount, self.pointCloud.points, GL_DYNAMIC_DRAW);
    }
}

- (void)update:(NSTimeInterval)timeSinceLastUpdate {
    
}

- (void)draw:(GLContext *)glContext {
    if (self.pointCloud) {
        [glContext setUniformMatrix4fv:@"modelMatrix" value:self.modelMatrix];
        bool canInvert;
        GLKMatrix4 normalMatrix = GLKMatrix4InvertAndTranspose(self.modelMatrix, &canInvert);
        [glContext setUniformMatrix4fv:@"normalMatrix" value:canInvert ? normalMatrix : GLKMatrix4Identity];
        
        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        GLuint positionAttribLocation = glGetAttribLocation(self.context.program, "position");
        glEnableVertexAttribArray(positionAttribLocation);
        glVertexAttribPointer(positionAttribLocation, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GLfloat), (char *)NULL);
        
        glDrawArrays(GL_POINTS, 0, (GLsizei)self.pointCloud.count);
    }
}
@end
