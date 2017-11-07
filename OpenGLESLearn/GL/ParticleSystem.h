//
//  ParticleSystem.h
//  OpenGLESLearn
//
//  Created by wang yang on 2017/11/7.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLObject.h"
#import "Billboard.h"

typedef struct {
    int maxParticles;
    float birthRate;
    float startLife;
    float endLife;
    GLKVector3 startSpeed;
    GLKVector3 endSpeed;
    float startSize;
    float endSize;
    GLKVector3 startColor;
    GLKVector3 endColor;
    GLKVector3 emissionBoxExtends;
    GLKMatrix4 emissionBoxTransform; // translate & rotate only
} ParticleSystemConfig;

@interface Particle: Billboard
@property (assign, nonatomic) float life;
@property (assign, nonatomic) GLKVector3 position;
@property (assign, nonatomic) GLKVector3 speed;
@property (assign, nonatomic) float size;
@property (assign, nonatomic) GLKVector3 color;
@end

@interface ParticleSystem : GLObject
@property (assign, nonatomic) ParticleSystemConfig config;
@property (strong, nonatomic) GLKTextureInfo * particleTexture;
@property (strong, nonatomic) NSMutableArray *activeParticles;
@property (strong, nonatomic) NSMutableArray *inactiveParticles;

- (instancetype)initWithGLContext:(GLContext *)context config:(ParticleSystemConfig)config particleTexture:(GLKTextureInfo *)particleTexture;
@end
