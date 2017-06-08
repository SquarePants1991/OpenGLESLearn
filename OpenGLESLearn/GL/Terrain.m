//
//  Terrain.m
//  OpenGLESLearn
//
//  Created by wangyang on 2017/6/8.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "Terrain.h"
#import "GLGeometry.h"

@interface Terrain()
@property (strong, nonatomic) UIImage *heightMap;
@property (assign, nonatomic) CGSize terrainSize;
@property (assign, nonatomic) CGFloat terrainHeight;
@property (strong, nonatomic) GLKTextureInfo * grassTexture;
@property (strong, nonatomic) GLKTextureInfo * dirtTexture;
@property (strong, nonatomic) NSMutableArray<GLGeometry *> * terrainMeshStrips;
@end

@implementation Terrain
- (id)initWithGLContext:(GLContext *)context heightMap:(UIImage *)image size:(CGSize)terrainSize height:(CGFloat)terrainHeight grass:(GLKTextureInfo *)grassTexture dirt:(GLKTextureInfo *)dirtTexture {
    self = [super initWithGLContext:context];
    if (self) {
        self.heightMap = image;
        self.terrainSize = terrainSize;
        self.terrainHeight = terrainHeight;
        self.terrainMeshStrips = [NSMutableArray new];
        self.grassTexture = grassTexture;
        self.dirtTexture = dirtTexture;
        [self buildGeometry];
    }
    return self;
}

- (GLKVector3)vertexPosition:(int)col row:(int)row buffer:(unsigned char *)buffer bytesPerRow:(size_t)bytesPerRow bytesPerPixel:(size_t)bytesPerPixel {
    long long offset = (int)(row / self.terrainSize.height * self.heightMap.size.height) * bytesPerRow + (int)(col / self.terrainSize.width * self.heightMap.size.width) * bytesPerPixel;
    unsigned char r = buffer[offset];
    GLfloat x = col;
    GLfloat y = r / 255.0 * self.terrainHeight;
    GLfloat z = row;
    return GLKVector3Make(x, y, z);
}

- (GLKVector3)vertexNormal:(GLKVector3)position col:(int)col row:(int)row buffer:(unsigned char *)buffer bytesPerRow:(size_t)bytesPerRow bytesPerPixel:(size_t)bytesPerPixel {
    GLKVector3 sides[4]; // 最多四条共享边
    int sideCount = 0;
    // 统计顶点有几条共享边，从而计算法线
    if (col >= 1) {
        //左边有共享边
        GLKVector3 leftPosition = [self vertexPosition:col - 1 row:row buffer:buffer bytesPerRow:bytesPerRow bytesPerPixel:bytesPerPixel];
        GLKVector3 vectorLeft = GLKVector3Subtract(leftPosition, position);
        sides[sideCount] = vectorLeft;
        sideCount++;
    }
    if (row >= 1) {
        //前面有共享边
        GLKVector3 frontPosition = [self vertexPosition:col row:row - 1 buffer:buffer bytesPerRow:bytesPerRow bytesPerPixel:bytesPerPixel];
        GLKVector3 vectorFront = GLKVector3Subtract(frontPosition, position);
        sides[sideCount] = vectorFront;
        sideCount++;
    }
    if (col <= self.terrainSize.width - 1) {
        //右边有共享边
        GLKVector3 rightPosition = [self vertexPosition:col + 1 row:row buffer:buffer bytesPerRow:bytesPerRow bytesPerPixel:bytesPerPixel];
        GLKVector3 vectorRight = GLKVector3Subtract(rightPosition, position);
        sides[sideCount] = vectorRight;
        sideCount++;
    }
    if (row <= self.terrainSize.width - 1) {
        //后面有共享边
        GLKVector3 backPosition = [self vertexPosition:col row:row + 1 buffer:buffer bytesPerRow:bytesPerRow bytesPerPixel:bytesPerPixel];
        GLKVector3 vectorBack = GLKVector3Subtract(backPosition, position);
        sides[sideCount] = vectorBack;
        sideCount++;
    }
    
    GLKVector3 normal = GLKVector3Make(0, 0, 0);
    for (int i = 0; i < sideCount; ++i) {
        GLKVector3 vec = sides[i];
        if (i == sideCount - 1 && i != 3) {
            continue;
        }
        GLKVector3 vec2 = i == sideCount - 1 ? sides[0] : sides[i + 1];
        normal = GLKVector3Add(normal, GLKVector3CrossProduct(vec2, vec));
    }
    return GLKVector3Normalize(normal);
}

- (void)buildGeometry {
    CGImageRef image = self.heightMap.CGImage;
    size_t bytesPerRow = CGImageGetBytesPerRow(image);
    size_t bitsPerComponent = CGImageGetBitsPerComponent(image);
    size_t bitesPerPixel = CGImageGetBitsPerPixel(image);
    size_t bytesPerPixel = bitesPerPixel / bitsPerComponent;
    UInt8 * buffer = [self dataFromImage:self.heightMap];
    for (int row = 0;row < self.terrainSize.height; ++row) {
        GLGeometry * terrainMeshStrip = [[GLGeometry alloc] initWithGeometryType:GLGeometryTypeTriangleStrip];
        for (int col = 0;col <= self.terrainSize.width; ++col) {
            GLKVector3 position1 = [self vertexPosition:col row:row buffer:buffer bytesPerRow:bytesPerRow bytesPerPixel:bytesPerPixel];
            GLKVector3 normal1 = [self vertexNormal:position1 col:col row:row buffer:buffer bytesPerRow:bytesPerRow bytesPerPixel:bytesPerPixel];
            GLVertex vertex1 = GLVertexMake(position1.x, position1.y, position1.z, normal1.x, normal1.y, normal1.z, col / (GLfloat)self.terrainSize.width * 2, row / (GLfloat)self.terrainSize.height * 2);
            [terrainMeshStrip appendVertex:vertex1];
            
            GLKVector3 position2 = [self vertexPosition:col row:row + 1 buffer:buffer bytesPerRow:bytesPerRow bytesPerPixel:bytesPerPixel];
            GLKVector3 normal2 = [self vertexNormal:position2 col:col row:row + 1 buffer:buffer bytesPerRow:bytesPerRow bytesPerPixel:bytesPerPixel];
            GLVertex vertex2 = GLVertexMake(position2.x, position2.y, position2.z, normal2.x, normal2.y, normal2.z, col / (GLfloat)self.terrainSize.width * 2, (row + 1) / (GLfloat)self.terrainSize.height * 2) ;
            [terrainMeshStrip appendVertex:vertex2];
        }
        [self.terrainMeshStrips addObject:terrainMeshStrip];
    }
    free(buffer);
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
    [glContext bindTexture:self.grassTexture to:GL_TEXTURE0 uniformName:@"grassMap"];
    [glContext bindTexture:self.dirtTexture to:GL_TEXTURE1 uniformName:@"dirtMap"];
    for (GLGeometry * geometry in self.terrainMeshStrips) {
        [glContext drawGeometry:geometry];
    }
}

- (GLubyte *)dataFromImage:(UIImage *)img {
    CGImageRef imageRef = [img CGImage];
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    GLubyte *textureData = (GLubyte *)malloc(width * height * 4);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    
    CGContextRef context = CGBitmapContextCreate(textureData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    return textureData;
}
@end
