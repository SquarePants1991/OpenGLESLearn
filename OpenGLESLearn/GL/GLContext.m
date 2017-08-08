//
//  GLUtil.m
//  OpenGLESLearn
//
//  Created by wangyang on 2017/5/9.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "GLContext.h"
#import "GLGeometry.h"
#import <GLKit/GLKit.h>

@implementation GLContext
@synthesize program;

+ (id)contextWithVertexShaderPath:(NSString *)vertexShaderPath fragmentShaderPath:(NSString *)fragmentShaderPath {
    NSString *vertexShaderContent = [NSString stringWithContentsOfFile:vertexShaderPath encoding:NSUTF8StringEncoding error:nil];
    NSString *fragmentShaderContent = [NSString stringWithContentsOfFile:fragmentShaderPath encoding:NSUTF8StringEncoding error:nil];
    return [[GLContext alloc] initWithVertexShader:vertexShaderContent fragmentShader:fragmentShaderContent];
}
- (id)initWithVertexShader:(NSString *)vertexShader fragmentShader:(NSString *)fragmentShader {
    self = [super init];
    if (self) {
        [self setupShader:vertexShader fragmentShaderContent:fragmentShader];
    }
    return self;
}

- (void)active {
    glUseProgram(self.program);
}

- (void)bindAttribs:(GLfloat *)triangleData {
    // 启用Shader中的两个属性
    // attribute vec4 position;
    // attribute vec4 color;
    GLuint positionAttribLocation = glGetAttribLocation(program, "position");
    glEnableVertexAttribArray(positionAttribLocation);
    GLuint colorAttribLocation = glGetAttribLocation(program, "normal");
    glEnableVertexAttribArray(colorAttribLocation);
    GLuint uvAttribLocation = glGetAttribLocation(program, "uv");
    glEnableVertexAttribArray(uvAttribLocation);
    
    // 为shader中的position和color赋值
    // glVertexAttribPointer (GLuint indx, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const GLvoid* ptr)
    // indx: 上面Get到的Location
    // size: 有几个类型为type的数据，比如位置有x,y,z三个GLfloat元素，值就为3
    // type: 一般就是数组里元素数据的类型
    // normalized: 暂时用不上
    // stride: 每一个点包含几个byte，本例中就是6个GLfloat，x,y,z,r,g,b
    // ptr: 数据开始的指针，位置就是从头开始，颜色则跳过3个GLFloat的大小
    glVertexAttribPointer(positionAttribLocation, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), (char *)triangleData);
    glVertexAttribPointer(colorAttribLocation, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), (char *)triangleData + 3 * sizeof(GLfloat));
    glVertexAttribPointer(uvAttribLocation, 2, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), (char *)triangleData + 6 * sizeof(GLfloat));
}

- (void)drawTriangles:(GLfloat *)triangleData vertexCount:(GLint)vertexCount {
    [self bindAttribs:triangleData];
    glDrawArrays(GL_TRIANGLES, 0, vertexCount);
}

- (void)drawTrianglesWithVBO:(GLuint)vbo vertexCount:(GLint)vertexCount {
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    [self bindAttribs:NULL];
    glDrawArrays(GL_TRIANGLES, 0, vertexCount);
}

- (void)drawTrianglesWithVAO:(GLuint)vao vertexCount:(GLint)vertexCount {
    glBindVertexArrayOES(vao);
    glDrawArrays(GL_TRIANGLES, 0, vertexCount);
    glBindVertexArrayOES(0);
}

- (void)drawGeometry:(GLGeometry *)geometry {
    glBindBuffer(GL_ARRAY_BUFFER, [geometry getVBO]);
    [self bindAttribs:NULL];
    if (geometry.geometryType == GLGeometryTypeTriangleFan) {
        glDrawArrays(GL_TRIANGLE_FAN, 0, [geometry vertexCount]);
    } else if (geometry.geometryType == GLGeometryTypeTriangles) {
        glDrawArrays(GL_TRIANGLES, 0, [geometry vertexCount]);
    } else if (geometry.geometryType == GLGeometryTypeTriangleStrip) {
        glDrawArrays(GL_TRIANGLE_STRIP, 0, [geometry vertexCount]);
    }
}

#pragma mark - Uniform Setter
- (void)setUniform1i:(NSString *)uniformName value:(GLint)value {
    GLuint location = glGetUniformLocation(self.program, uniformName.UTF8String);
    glUniform1i(location, value);
}

- (void)setUniform1f:(NSString *)uniformName value:(GLfloat)value {
    GLuint location = glGetUniformLocation(self.program, uniformName.UTF8String);
    glUniform1f(location, value);
}

- (void)setUniform3fv:(NSString *)uniformName value:(GLKVector3)value {
    GLuint location = glGetUniformLocation(self.program, uniformName.UTF8String);
    glUniform3fv(location, 1, value.v);
}

- (void)setUniform4fv:(NSString *)uniformName value:(GLKVector4)value {
    GLuint location = glGetUniformLocation(self.program, uniformName.UTF8String);
    glUniform4fv(location, 1, value.v);
}

- (void)setUniformMatrix4fv:(NSString *)uniformName value:(GLKMatrix4)value {
    GLuint location = glGetUniformLocation(self.program, uniformName.UTF8String);
    glUniformMatrix4fv(location, 1, 0, value.m);
}

#pragma mark - Texture
- (void)bindTexture:(GLKTextureInfo *)textureInfo to:(GLenum)textureChannel uniformName:(NSString *)uniformName {
    glActiveTexture(textureChannel);
    glBindTexture(GL_TEXTURE_2D, textureInfo.name);
    GLuint textureID = (GLuint)textureChannel - (GLuint)GL_TEXTURE0;
    [self setUniform1i:uniformName value:textureID];
}

- (void)bindCubeTexture:(GLKTextureInfo *)textureInfo to:(GLenum)textureChannel uniformName:(NSString *)uniformName {
    glActiveTexture(textureChannel);
    glBindTexture(GL_TEXTURE_CUBE_MAP, textureInfo.name);
    GLuint textureID = (GLuint)textureChannel - (GLuint)GL_TEXTURE0;
    [self setUniform1i:uniformName value:textureID];
}

- (void)bindTextureName:(GLuint)textureName to:(GLenum)textureChannel uniformName:(NSString *)uniformName {
    glActiveTexture(textureChannel);
    glBindTexture(GL_TEXTURE_2D, textureName);
    GLuint textureID = (GLuint)textureChannel - (GLuint)GL_TEXTURE0;
    [self setUniform1i:uniformName value:textureID];
}

#pragma mark - Prepare Shader
bool createProgram(const char *vertexShader, const char *fragmentShader, GLuint *pProgram) {
    GLuint program, vertShader, fragShader;
    // Create shader program.
    program = glCreateProgram();

    const GLchar *vssource = (GLchar *)vertexShader;
    const GLchar *fssource = (GLchar *)fragmentShader;

    if (!compileShader(&vertShader,GL_VERTEX_SHADER, vssource)) {
        printf("Failed to compile vertex shader");
        return false;
    }

    if (!compileShader(&fragShader,GL_FRAGMENT_SHADER, fssource)) {
        printf("Failed to compile fragment shader");
        return false;
    }

    // Attach vertex shader to program.
    glAttachShader(program, vertShader);

    // Attach fragment shader to program.
    glAttachShader(program, fragShader);

    // Link program.
    if (!linkProgram(program)) {
        printf("Failed to link program: %d", program);

        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (program) {
            glDeleteProgram(program);
            program = 0;
        }
        return false;
    }

    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(program, fragShader);
        glDeleteShader(fragShader);
    }

    *pProgram = program;
    printf("Effect build success => %d \n", program);
    return true;
}


bool compileShader(GLuint *shader, GLenum type, const GLchar *source) {
    GLint status;

    if (!source) {
        printf("Failed to load vertex shader");
        return false;
    }

    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);

    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);

#if DEBUG
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        printf("Shader compile log:\n%s", log);
        printf("Shader: \n %s\n", source);
        free(log);
    }
#endif

    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return false;
    }

    return true;
}

bool linkProgram(GLuint prog) {
    GLint status;
    glLinkProgram(prog);

#if DEBUG
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        printf("Program link log:\n%s", log);
        free(log);
    }
#endif

    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return false;
    }

    return true;
}

bool validateProgram(GLuint prog) {
    GLint logLength, status;

    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        printf("Program validate log:\n%s", log);
        free(log);
    }

    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return false;
    }

    return true;
}

- (void)setupShader:(NSString *)vertexShaderContent fragmentShaderContent:(NSString *)fragmentShaderContent {
    createProgram(vertexShaderContent.UTF8String, fragmentShaderContent.UTF8String, &program);
}

@end
