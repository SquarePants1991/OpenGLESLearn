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
    GLuint vertexIBO;
    
    GLuint vao;
}
@property (strong, nonatomic) NSMutableData *positionData;
@property (strong, nonatomic) NSMutableData *normalData;
@property (strong, nonatomic) NSMutableData *uvData;
@property (strong, nonatomic) NSMutableData *positionIndexData;
@property (strong, nonatomic) NSMutableData *normalIndexData;
@property (strong, nonatomic) NSMutableData *uvIndexData;

@property (strong, nonatomic) NSMutableData *vertexData;

@property (strong, nonatomic) GLKTextureInfo *normalMap;
@property (strong, nonatomic) GLKTextureInfo *diffuseMap;
@end

@implementation WavefrontOBJ

- (id)initWithGLContext:(GLContext *)context objFile:(NSString *)filePath {
    self = [super initWithGLContext:context];
    if (self) {
        self.positionData = [NSMutableData new];
        self.normalData = [NSMutableData new];
        self.uvData = [NSMutableData new];
        self.positionIndexData = [NSMutableData new];
        self.normalIndexData = [NSMutableData new];
        self.uvIndexData = [NSMutableData new];
        
        self.vertexData = [NSMutableData new];
    
        [self loadDataFromObj:filePath];
        [self decompressToVertexArray];
        [self genBufferObjects];
        [self genVAO];
    }
    return self;
}

+ (id)objWithGLContext:(GLContext *)context objFile:(NSString *)filePath diffuseMap:(GLKTextureInfo *)diffuseMap normalMap:(GLKTextureInfo *)normalMap {
    WavefrontOBJ *wavefrontObj = [[WavefrontOBJ alloc] initWithGLContext:context objFile:filePath];
    wavefrontObj.diffuseMap = diffuseMap;
    wavefrontObj.normalMap = normalMap;
    return wavefrontObj;
}

- (void)genBufferObjects {
    glGenBuffers(1, &vertexVBO);
    glBindBuffer(GL_ARRAY_BUFFER, vertexVBO);
    glBufferData(GL_ARRAY_BUFFER, self.vertexData.length, self.vertexData.bytes, GL_STATIC_DRAW);
}

- (void)genVAO {
    glGenVertexArraysOES(1, &vao);
    glBindVertexArrayOES(vao);
    
    glBindBuffer(GL_ARRAY_BUFFER, vertexVBO);
    
    GLuint positionAttribLocation = glGetAttribLocation(self.context.program, "position");
    glEnableVertexAttribArray(positionAttribLocation);
    GLuint colorAttribLocation = glGetAttribLocation(self.context.program, "normal");
    glEnableVertexAttribArray(colorAttribLocation);
    GLuint uvAttribLocation = glGetAttribLocation(self.context.program, "uv");
    glEnableVertexAttribArray(uvAttribLocation);
    GLuint tangentAttribLocation = glGetAttribLocation(self.context.program, "tangent");
    glEnableVertexAttribArray(tangentAttribLocation);
    GLuint bitangentAttribLocation = glGetAttribLocation(self.context.program, "bitangent");
    glEnableVertexAttribArray(bitangentAttribLocation);
    
    glVertexAttribPointer(positionAttribLocation, 3, GL_FLOAT, GL_FALSE, 14 * sizeof(GLfloat), (char *)NULL);
    glVertexAttribPointer(colorAttribLocation, 3, GL_FLOAT, GL_FALSE, 14 * sizeof(GLfloat), (char *)NULL + 3 * sizeof(GLfloat));
    glVertexAttribPointer(uvAttribLocation, 2, GL_FLOAT, GL_FALSE, 14 * sizeof(GLfloat), (char *)NULL + 6 * sizeof(GLfloat));
    glVertexAttribPointer(tangentAttribLocation, 3, GL_FLOAT, GL_FALSE, 14 * sizeof(GLfloat), (char *)NULL + 8 * sizeof(GLfloat));
    glVertexAttribPointer(bitangentAttribLocation, 3, GL_FLOAT, GL_FALSE, 14 * sizeof(GLfloat), (char *)NULL + 11 * sizeof(GLfloat));
    
    glBindVertexArrayOES(0);
}

- (void)update:(NSTimeInterval)timeSinceLastUpdate {
    
}

- (void)draw:(GLContext *)glContext {
    [glContext setUniformMatrix4fv:@"modelMatrix" value:self.modelMatrix];
    bool canInvert;
    GLKMatrix4 normalMatrix = GLKMatrix4InvertAndTranspose(self.modelMatrix, &canInvert);
    [glContext setUniformMatrix4fv:@"normalMatrix" value:canInvert ? normalMatrix : GLKMatrix4Identity];
    [glContext bindTexture:self.diffuseMap to:GL_TEXTURE0 uniformName:@"diffuseMap"];
    [glContext bindTexture:self.normalMap to:GL_TEXTURE1 uniformName:@"normalMap"];
    NSInteger vertexCount = self.positionIndexData.length / sizeof(GLuint);
    [self.context drawTrianglesWithVAO:vao vertexCount:(GLuint)vertexCount];
}

#pragma mark - 将数据压缩到一个顶点数组中

- (void)decompressToVertexArray {
    NSInteger vertexCount = self.positionIndexData.length / sizeof(GLuint);
    NSInteger triangleCount = vertexCount / 3;
    for (int triangleIndex = 0; triangleIndex < triangleCount; ++triangleIndex) {
        GLKVector3 positions[3];
        GLKVector2 uvs[3];
        GLKVector3 normals[3];
        for (int vertexIndex = triangleIndex * 3; vertexIndex < triangleIndex * 3 + 3; ++vertexIndex) {
            int positionIndex = 0;
            [self.positionIndexData getBytes:&positionIndex range:NSMakeRange(vertexIndex * sizeof(GLuint), sizeof(GLuint))];
            [self.positionData getBytes:&positions[vertexIndex % 3] range:NSMakeRange(positionIndex * 3 * sizeof(GLfloat), 3 * sizeof(GLfloat))];
            
            int normalIndex = 0;
            [self.normalIndexData getBytes:&normalIndex range:NSMakeRange(vertexIndex * sizeof(GLuint), sizeof(GLuint))];
            [self.normalData getBytes:&normals[vertexIndex % 3] range:NSMakeRange(normalIndex * 3 * sizeof(GLfloat), 3 * sizeof(GLfloat))];
            
            int uvIndex = 0;
            [self.uvIndexData getBytes:&uvIndex range:NSMakeRange(vertexIndex * sizeof(GLuint), sizeof(GLuint))];
            [self.uvData getBytes:&uvs[vertexIndex % 3] range:NSMakeRange(uvIndex * 2 * sizeof(GLfloat), 2 * sizeof(GLfloat))];
        }
        GLKVector3 deltaPos1 = GLKVector3Subtract(positions[1], positions[0]);
        GLKVector3 deltaPos2 = GLKVector3Subtract(positions[2], positions[0]);
        GLKVector2 deltaUV1 = GLKVector2Subtract(uvs[1], uvs[0]);
        GLKVector2 deltaUV2 = GLKVector2Subtract(uvs[2], uvs[0]);
        float r = 1.0f / (deltaUV1.x * deltaUV2.y - deltaUV1.y * deltaUV2.x);
        
        GLKVector3 tangent = GLKVector3MultiplyScalar(GLKVector3Subtract(GLKVector3MultiplyScalar(deltaPos1, deltaUV2.y), GLKVector3MultiplyScalar(deltaPos2, deltaUV1.y)), r);
        GLKVector3 bitangent = GLKVector3MultiplyScalar(GLKVector3Subtract(GLKVector3MultiplyScalar(deltaPos2, deltaUV1.x), GLKVector3MultiplyScalar(deltaPos1, deltaUV2.x)), r);
        
for (int i = 0; i< 3; ++i) {
    [self.vertexData appendBytes:&positions[i] length:sizeof(GLKVector3)];
    [self.vertexData appendBytes:&normals[i] length:sizeof(GLKVector3)];
    [self.vertexData appendBytes:&uvs[i] length:sizeof(GLKVector2)];
    [self.vertexData appendBytes:&tangent length:sizeof(GLKVector3)];
    [self.vertexData appendBytes:&bitangent length:sizeof(GLKVector3)];
}
    }
}

#pragma mark - 从OBJ文件中读取数据

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
            [self.positionData appendBytes:(void *)(&x) length:sizeof(GLfloat)];
            [self.positionData appendBytes:(void *)(&y) length:sizeof(GLfloat)];
            [self.positionData appendBytes:(void *)(&z) length:sizeof(GLfloat)];
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
            GLuint vertexIndex1 = [[line substringWithRange: [result rangeAtIndex:1]] intValue] - 1;
            GLuint vertexIndex2 = [[line substringWithRange: [result rangeAtIndex:4]] intValue] - 1;
            GLuint vertexIndex3 = [[line substringWithRange: [result rangeAtIndex:7]] intValue] - 1;
            [self.positionIndexData appendBytes:(void *)(&vertexIndex1) length:sizeof(GLuint)];
            [self.positionIndexData appendBytes:(void *)(&vertexIndex2) length:sizeof(GLuint)];
            [self.positionIndexData appendBytes:(void *)(&vertexIndex3) length:sizeof(GLuint)];
            
            GLuint uvIndex1 = [[line substringWithRange: [result rangeAtIndex:2]] intValue] - 1;
            GLuint uvIndex2 = [[line substringWithRange: [result rangeAtIndex:5]] intValue] - 1;
            GLuint uvIndex3 = [[line substringWithRange: [result rangeAtIndex:8]] intValue] - 1;
            [self.uvIndexData appendBytes:(void *)(&uvIndex1) length:sizeof(GLuint)];
            [self.uvIndexData appendBytes:(void *)(&uvIndex2) length:sizeof(GLuint)];
            [self.uvIndexData appendBytes:(void *)(&uvIndex3) length:sizeof(GLuint)];
            
            GLuint normalIndex1 = [[line substringWithRange: [result rangeAtIndex:3]] intValue] - 1;
            GLuint normalIndex2 = [[line substringWithRange: [result rangeAtIndex:6]] intValue] - 1;
            GLuint normalIndex3 = [[line substringWithRange: [result rangeAtIndex:9]] intValue] - 1;
            [self.normalIndexData appendBytes:(void *)(&normalIndex1) length:sizeof(GLuint)];
            [self.normalIndexData appendBytes:(void *)(&normalIndex2) length:sizeof(GLuint)];
            [self.normalIndexData appendBytes:(void *)(&normalIndex3) length:sizeof(GLuint)];
        }
    }
}
@end

