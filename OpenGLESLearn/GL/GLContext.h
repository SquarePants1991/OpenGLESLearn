//
//  GLUtil.h
//  OpenGLESLearn
//
//  Created by wangyang on 2017/5/9.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/glext.h>

@class GLGeometry;
@interface GLContext : NSObject
@property (assign, nonatomic) GLuint program;
+ (id)contextWithVertexShaderPath:(NSString *)vertexShaderPath fragmentShaderPath:(NSString *)fragmentShaderPath;
- (id)initWithVertexShader:(NSString *)vertexShader fragmentShader:(NSString *)fragmentShader;
- (void)active;

- (void)bindAttribs:(GLfloat *)triangleData;

/// draw functions
- (void)drawTriangles:(GLfloat *)triangleData vertexCount:(GLint)vertexCount;
- (void)drawTrianglesWithVBO:(GLuint)vbo vertexCount:(GLint)vertexCount;
- (void)drawTrianglesWithVAO:(GLuint)vao vertexCount:(GLint)vertexCount;
- (void)drawGeometry:(GLGeometry *)geometry;

/// uniform setters
- (void)setUniform1i:(NSString *)uniformName value:(GLint)value;
- (void)setUniform1f:(NSString *)uniformName value:(GLfloat)value;
- (void)setUniform3fv:(NSString *)uniformName value:(GLKVector3)value;
- (void)setUniform4fv:(NSString *)uniformName value:(GLKVector4)value;
- (void)setUniformMatrix4fv:(NSString *)uniformName value:(GLKMatrix4)value;

/// texture
- (void)bindTexture:(GLKTextureInfo *)textureInfo to:(GLenum)textureChannel uniformName:(NSString *)uniformName;
- (void)bindTextureName:(GLuint)textureName to:(GLenum)textureChannel uniformName:(NSString *)uniformName;
- (void)bindCubeTexture:(GLKTextureInfo *)textureInfo to:(GLenum)textureChannel uniformName:(NSString *)uniformName;
@end
