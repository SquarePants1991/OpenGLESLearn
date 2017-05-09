//
//  GLUtil.h
//  OpenGLESLearn
//
//  Created by wangyang on 2017/5/9.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface GLContext : NSObject
@property (assign, nonatomic) GLuint program;
+ (id)contextWithVertexShaderPath:(NSString *)vertexShaderPath fragmentShaderPath:(NSString *)fragmentShaderPath;
- (id)initWithVertexShader:(NSString *)vertexShader fragmentShader:(NSString *)fragmentShader;
- (void)active;

/// draw functions
- (void)drawTriangles:(GLfloat *)triangleData vertexCount:(GLint)vertexCount;

/// uniform setters
- (void)setUniform1i:(NSString *)uniformName value:(GLint)value;
- (void)setUniform1f:(NSString *)uniformName value:(GLfloat)value;
- (void)setUniform3fv:(NSString *)uniformName value:(GLKVector3)value;
- (void)setUniformMatrix4fv:(NSString *)uniformName value:(GLKMatrix4)value;

/// texture
- (void)bindTexture:(GLKTextureInfo *)textureInfo to:(GLenum)textureChannel uniformName:(NSString *)uniformName;

@end
