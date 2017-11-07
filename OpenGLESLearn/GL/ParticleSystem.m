//
//  ParticleSystem.m
//  OpenGLESLearn
//
//  Created by wang yang on 2017/11/7.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "ParticleSystem.h"

@interface Particle()
@property (assign, nonatomic) float originLife;
@end

@implementation Particle

- (void)setLife:(float)life {
    _life = life;
    if (_originLife == 0) {
        _originLife = life;
    }
}

- (void)update:(NSTimeInterval)timeSinceLastUpdate {
    self.life -= timeSinceLastUpdate;
    float lifePercent = self.life / self.originLife;
    self.billboardSize = GLKVector2Make(self.size * lifePercent, self.size * lifePercent);
    self.billboardCenterPosition = self.position;
    
    self.speed = GLKVector3Make(self.speed.x, self.speed.y + timeSinceLastUpdate * -9.8, self.speed.z);
    self.position = GLKVector3Add(GLKVector3MultiplyScalar(self.speed, timeSinceLastUpdate), self.position);
}

- (void)draw:(GLContext *)glContext {
    [glContext setUniform3fv:@"particleColor" value:self.color];
    [super draw:glContext];
}

@end

@implementation ParticleSystem
@synthesize config;

- (instancetype)initWithGLContext:(GLContext *)context config:(ParticleSystemConfig)config particleTexture:(GLKTextureInfo *)particleTexture
{
    self = [super initWithGLContext:context];
    if (self) {
        self.config = config;
        self.particleTexture = particleTexture;
        self.activeParticles = [NSMutableArray new];
        self.inactiveParticles = [NSMutableArray new];
        [self fillParticles];
    }
    return self;
}

- (void)fillParticles {
    for (int i = 0; i < self.config.maxParticles; ++i) {
        [self newParticle];
    }
}

- (void)newParticle {
    Particle *particle = [[Particle alloc] initWithGLContext:self.context texture:self.particleTexture];
    [self resetParticle:particle];
    [self.inactiveParticles addObject:particle];
}

- (void)resetParticle:(Particle *)particle {
    particle.life = [self randFloat:config.startLife end:config.endLife];
    GLKVector4 newPos = GLKMatrix4MultiplyVector4(config.emissionBoxTransform, GLKVector4Make(0, 0, 0, 1));
    particle.position = [self randInBox:config.emissionBoxExtends center: GLKVector3Make(newPos.x, newPos.y, newPos.z)];
    particle.speed = [self randVector3:config.startSpeed end:config.endSpeed];
    particle.size = [self randFloat:config.startSize end:config.endSize];
    particle.color = [self randVector3:config.startColor end:config.endColor];
}

- (void)recycleInactiveParticle {
    for (int index = 0; index < self.activeParticles.count; ++index) {
        Particle *particle = self.activeParticles[index];
        if (particle.life <= 0) {
            [self.inactiveParticles addObject:particle];
            [self.activeParticles removeObjectAtIndex:index];
            index--;
        }
    }
}

- (Particle *)pickParticle {
    if (self.inactiveParticles.count > 0) {
        Particle *particle = self.inactiveParticles[0];
        [self.inactiveParticles removeObjectAtIndex:0];
        [self resetParticle:particle];
        return particle;
    }
    return nil;
}


#pragma mark - GL Object
- (void)update:(NSTimeInterval)timeSinceLastUpdate {
    [self recycleInactiveParticle];
    int birthParicleCount = self.config.birthRate * timeSinceLastUpdate * self.config.maxParticles;
    for (int i = 0; i < birthParicleCount; ++i) {
        Particle *particle = [self pickParticle];
        if (particle) {
            [self.activeParticles addObject:particle];
        }
    }
    for (Particle *particle in self.activeParticles) {
        [particle update:timeSinceLastUpdate];
    }
}

- (void)draw:(GLContext *)glContext {
    glDepthMask(GL_FALSE);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_DST_ALPHA);
    for (Particle *particle in self.activeParticles) {
        [particle draw:glContext];
    }
    glDepthMask(GL_TRUE);
}

#pragma mark - Utils
- (float)randFloat:(float)begin end:(float)end {
    float seed = arc4random_uniform(100) / 100.0;
    return begin + (end - begin) * seed;
}

- (GLKVector3)randVector3:(GLKVector3)begin end:(GLKVector3)end {
    GLKVector3 result;
    result.x = [self randFloat:begin.x end:end.x];
    result.y = [self randFloat:begin.y end:end.y];
    result.z = [self randFloat:begin.z end:end.z];
    return result;
}

- (GLKVector3)randInBox:(GLKVector3)extends center:(GLKVector3)center {
    GLKVector3 result;
    result.x = [self randFloat:center.x - extends.x end:center.x + extends.x];
    result.y = [self randFloat:center.y - extends.y end:center.y + extends.y];
    result.z = [self randFloat:center.z - extends.z end:center.z + extends.z];
    return result;
}
@end
