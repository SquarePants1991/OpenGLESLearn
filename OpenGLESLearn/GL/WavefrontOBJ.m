//
//  WavefrontOBJ.m
//  OpenGLESLearn
//
//  Created by wang yang on 2017/6/20.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "WavefrontOBJ.h"

@interface WavefrontOBJ() {
    GLuint vertexVBO;
    GLuint normalVBO;
    GLuint uvVBO;
    GLuint vertexIBO;
    GLuint normalIBO;
    GLuint uvIBO;
    
    GLuint vao;
}
@property (strong, nonatomic) NSMutableData *vertexData;
@property (strong, nonatomic) NSMutableData *normalData;
@property (strong, nonatomic) NSMutableData *uvData;
@property (strong, nonatomic) NSMutableData *vertexIndexData;
@property (strong, nonatomic) NSMutableData *normalIndexData;
@property (strong, nonatomic) NSMutableData *uvIndexData;
@end

@implementation WavefrontOBJ

- (id)initWithGLContext:(GLContext *)context objFile:(NSString *)filePath {
    self = [super initWithGLContext:context];
    if (self) {
        self.vertexData = [NSMutableData new];
        self.normalData = [NSMutableData new];
        self.uvData = [NSMutableData new];
        self.vertexIndexData = [NSMutableData new];
        self.normalIndexData = [NSMutableData new];
        self.uvIndexData = [NSMutableData new];
        [self loadDataFromObj:filePath];
        [self genBufferObjects];
        [self genVAO];
    }
    return self;
}

- (void)genBufferObjects {
    glGenBuffers(1, &vertexVBO);
    glBindBuffer(GL_ARRAY_BUFFER, vertexVBO);
    glBufferData(GL_ARRAY_BUFFER, self.vertexData.length, self.vertexData.bytes, GL_STATIC_DRAW);
    
    glGenBuffers(1, &normalVBO);
    glBindBuffer(GL_ARRAY_BUFFER, normalVBO);
    glBufferData(GL_ARRAY_BUFFER, self.normalData.length, self.normalData.bytes, GL_STATIC_DRAW);
    
    glGenBuffers(1, &uvVBO);
    glBindBuffer(GL_ARRAY_BUFFER, uvVBO);
    glBufferData(GL_ARRAY_BUFFER, self.uvData.length, self.uvData.bytes, GL_STATIC_DRAW);
    
    glGenBuffers(1, &vertexIBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vertexIBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, self.vertexIndexData.length, self.vertexIndexData.bytes, GL_STATIC_DRAW);
    
    glGenBuffers(1, &normalIBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, normalIBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, self.normalIndexData.length, self.normalIndexData.bytes, GL_STATIC_DRAW);
    
    glGenBuffers(1, &uvIBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, uvIBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, self.uvIndexData.length, self.uvIndexData.bytes, GL_STATIC_DRAW);
}

- (void)genVAO {
    glGenVertexArraysOES(1, &vao);
    glBindVertexArrayOES(vao);
    
    glBindBuffer(GL_ARRAY_BUFFER, vertexVBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vertexIBO);
    GLuint positionAttribLocation = glGetAttribLocation(self.context.program, "position");
    glEnableVertexAttribArray(positionAttribLocation);
    glVertexAttribPointer(positionAttribLocation, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GLfloat), (char *)NULL);
    
//    glBindBuffer(GL_ARRAY_BUFFER, normalVBO);
//    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, normalIBO);
//    GLuint normalAttribLocation = glGetAttribLocation(self.context.program, "normal");
//    glEnableVertexAttribArray(normalAttribLocation);
//    glVertexAttribPointer(normalAttribLocation, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GLfloat), (char *)NULL);
//    
//    glBindBuffer(GL_ARRAY_BUFFER, uvVBO);
//    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, uvIBO);
//    GLuint uvAttribLocation = glGetAttribLocation(self.context.program, "uv");
//    glEnableVertexAttribArray(uvAttribLocation);
//    glVertexAttribPointer(uvAttribLocation, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(GLfloat), (char *)NULL);
    
    glBindVertexArrayOES(0);
}

- (void)update:(NSTimeInterval)timeSinceLastUpdate {
    
}

- (void)draw:(GLContext *)glContext {
    [glContext setUniformMatrix4fv:@"modelMatrix" value:self.modelMatrix];
    bool canInvert;
    GLKMatrix4 normalMatrix = GLKMatrix4InvertAndTranspose(self.modelMatrix, &canInvert);
    [glContext setUniformMatrix4fv:@"normalMatrix" value:canInvert ? normalMatrix : GLKMatrix4Identity];
    NSInteger vertexCount = self.uvIndexData.length / sizeof(GLuint);
    glBindVertexArrayOES(vao);
    glDrawElements(GL_TRIANGLES, (GLsizei)vertexCount, GL_UNSIGNED_INT, NULL);
}

#pragma mark - Load Data From Obj
- (void)loadDataFromObj:(NSString *)filePath {
    NSString *fileContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSArray<NSString *> *lines = [fileContent componentsSeparatedByString:@"\n"];
    for (NSString *line in lines) {
        if (line.length >= 2) {
            if ([line characterAtIndex:0] == 'v' && [line characterAtIndex:1] == ' ') {
                [self processVertexLine:line];
            } else if ([line characterAtIndex:0] == 'v' && [line characterAtIndex:1] == 'n') {
                [self processNormalLine:line];
            } else if ([line characterAtIndex:0] == 'v' && [line characterAtIndex:1] == 't') {
                [self processUVLine:line];
            } else if ([line characterAtIndex:0] == 'f' && [line characterAtIndex:1] == ' ') {
                [self processFaceIndexLine:line];
            }
        }
    }
}

- (void)processVertexLine:(NSString *)line {
    static NSString *pattern = @"v\\s*([\\-0-9]*\\.[\\-0-9]*)\\s*([\\-0-9]*\\.[\\-0-9]*)\\s*([\\-0-9]*\\.[\\-0-9]*)";
    static NSRegularExpression *regexExp = nil;
    if (regexExp == nil) {
        regexExp = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    }
    NSArray * matchResults = [regexExp matchesInString:line options:0 range:NSMakeRange(0, line.length)];
    for (NSTextCheckingResult *result in matchResults) {
        NSUInteger rangeCount = result.numberOfRanges;
        if (rangeCount == 4) {
            GLfloat x = [[line substringWithRange: [result rangeAtIndex:1]] floatValue];
            GLfloat y = [[line substringWithRange: [result rangeAtIndex:2]] floatValue];
            GLfloat z = [[line substringWithRange: [result rangeAtIndex:3]] floatValue];
            [self.vertexData appendBytes:(void *)(&x) length:sizeof(GLfloat)];
            [self.vertexData appendBytes:(void *)(&y) length:sizeof(GLfloat)];
            [self.vertexData appendBytes:(void *)(&z) length:sizeof(GLfloat)];
        }
    }
}

- (void)processNormalLine:(NSString *)line {
    static NSString *pattern = @"vn\\s*([\\-0-9]*\\.[\\-0-9]*)\\s*([\\-0-9]*\\.[\\-0-9]*)\\s*([\\-0-9]*\\.[\\-0-9]*)";
    static NSRegularExpression *regexExp = nil;
    if (regexExp == nil) {
        regexExp = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    }
    NSArray * matchResults = [regexExp matchesInString:line options:0 range:NSMakeRange(0, line.length)];
    for (NSTextCheckingResult *result in matchResults) {
        NSUInteger rangeCount = result.numberOfRanges;
        if (rangeCount == 4) {
            GLfloat x = [[line substringWithRange: [result rangeAtIndex:1]] floatValue];
            GLfloat y = [[line substringWithRange: [result rangeAtIndex:2]] floatValue];
            GLfloat z = [[line substringWithRange: [result rangeAtIndex:3]] floatValue];
            [self.normalData appendBytes:(void *)(&x) length:sizeof(GLfloat)];
            [self.normalData appendBytes:(void *)(&y) length:sizeof(GLfloat)];
            [self.normalData appendBytes:(void *)(&z) length:sizeof(GLfloat)];
        }
    }
}

- (void)processUVLine:(NSString *)line {
    static NSString *pattern = @"vt\\s*([\\-0-9]*\\.[\\-0-9]*)\\s*([\\-0-9]*\\.[\\-0-9]*)";
    static NSRegularExpression *regexExp = nil;
    if (regexExp == nil) {
        regexExp = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    }
    NSArray * matchResults = [regexExp matchesInString:line options:0 range:NSMakeRange(0, line.length)];
    for (NSTextCheckingResult *result in matchResults) {
        NSUInteger rangeCount = result.numberOfRanges;
        if (rangeCount == 3) {
            GLfloat x = [[line substringWithRange: [result rangeAtIndex:1]] floatValue];
            GLfloat y = [[line substringWithRange: [result rangeAtIndex:2]] floatValue];
            [self.uvData appendBytes:(void *)(&x) length:sizeof(GLfloat)];
            [self.uvData appendBytes:(void *)(&y) length:sizeof(GLfloat)];
        }
    }
}

- (void)processFaceIndexLine:(NSString *)line {
    static NSString *pattern = @"f\\s*([0-9]*)/([0-9]*)/([0-9]*)\\s*([0-9]*)/([0-9]*)/([0-9]*)\\s*([0-9]*)/([0-9]*)/([0-9]*)";
    static NSRegularExpression *regexExp = nil;
    if (regexExp == nil) {
        regexExp = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    }
    NSArray * matchResults = [regexExp matchesInString:line options:0 range:NSMakeRange(0, line.length)];
    for (NSTextCheckingResult *result in matchResults) {
        NSUInteger rangeCount = result.numberOfRanges;
        if (rangeCount == 10) {
            // f 顶点/UV/法线 顶点/UV/法线 顶点/UV/法线
            GLuint vertexIndex1 = [[line substringWithRange: [result rangeAtIndex:1]] intValue];
            GLuint vertexIndex2 = [[line substringWithRange: [result rangeAtIndex:4]] intValue];
            GLuint vertexIndex3 = [[line substringWithRange: [result rangeAtIndex:7]] intValue];
            [self.vertexIndexData appendBytes:(void *)(&vertexIndex1) length:sizeof(GLuint)];
            [self.vertexIndexData appendBytes:(void *)(&vertexIndex2) length:sizeof(GLuint)];
            [self.vertexIndexData appendBytes:(void *)(&vertexIndex3) length:sizeof(GLuint)];
            
            GLuint uvIndex1 = [[line substringWithRange: [result rangeAtIndex:2]] intValue];
            GLuint uvIndex2 = [[line substringWithRange: [result rangeAtIndex:5]] intValue];
            GLuint uvIndex3 = [[line substringWithRange: [result rangeAtIndex:8]] intValue];
            [self.uvIndexData appendBytes:(void *)(&uvIndex1) length:sizeof(GLuint)];
            [self.uvIndexData appendBytes:(void *)(&uvIndex2) length:sizeof(GLuint)];
            [self.uvIndexData appendBytes:(void *)(&uvIndex3) length:sizeof(GLuint)];
            
            GLuint normalIndex1 = [[line substringWithRange: [result rangeAtIndex:3]] intValue];
            GLuint normalIndex2 = [[line substringWithRange: [result rangeAtIndex:6]] intValue];
            GLuint normalIndex3 = [[line substringWithRange: [result rangeAtIndex:9]] intValue];
            [self.normalIndexData appendBytes:(void *)(&normalIndex1) length:sizeof(GLuint)];
            [self.normalIndexData appendBytes:(void *)(&normalIndex2) length:sizeof(GLuint)];
            [self.normalIndexData appendBytes:(void *)(&normalIndex3) length:sizeof(GLuint)];
        }
    }
}
@end

