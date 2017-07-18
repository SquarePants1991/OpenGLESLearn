precision highp float;

// 平行光
struct DirectionLight {
    vec3 direction;
    vec3 color;
    float indensity;
    float ambientIndensity;
};

struct Material {
    vec3 diffuseColor;
    vec3 ambientColor;
    vec3 specularColor;
    float smoothness; // 0 ~ 1000 越高显得越光滑
};

varying vec3 fragNormal;
varying vec2 fragUV;
varying vec3 fragPosition;
varying vec3 fragTangent;
varying vec3 fragBitangent;

uniform float elapsedTime;
uniform DirectionLight light;
uniform Material material;
uniform vec3 eyePosition;
uniform mat4 normalMatrix;
uniform mat4 modelMatrix;

uniform sampler2D diffuseMap;
uniform sampler2D normalMap;
uniform bool useNormalMap;

// shadow
uniform mat4 lightMatrix;
uniform sampler2D shadowMap;

void main(void) {
    vec4 worldVertexPosition = modelMatrix * vec4(fragPosition, 1.0);
    
    vec3 normalizedLightDirection = normalize(-light.direction);
    vec3 transformedNormal = normalize((normalMatrix * vec4(fragNormal, 1.0)).xyz);
    vec3 transformedTangent = normalize((normalMatrix * vec4(fragTangent, 1.0)).xyz);
    vec3 transformedBitangent = normalize((normalMatrix * vec4(fragBitangent, 1.0)).xyz);
    mat3 TBN = mat3(
                              transformedTangent,
                              transformedBitangent,
                              transformedNormal
                              );
    if (useNormalMap) {
        vec3 normalFromMap = (texture2D(normalMap, fragUV).rgb * 2.0 - 1.0);
        transformedNormal = TBN * normalFromMap;
    }
    
    float bias = 0.005*tan(acos(dot(transformedNormal, normalizedLightDirection)));
    bias = clamp(bias, 0.0, 0.01);
    float shadow = 0.0;
    vec4 positionInLightSpace = lightMatrix * modelMatrix * vec4(fragPosition, 1.0);
    positionInLightSpace /= positionInLightSpace.w;
    positionInLightSpace = (positionInLightSpace + 1.0) * 0.5;
    vec2 shadowUV = positionInLightSpace.xy;
    
    if (shadowUV.x >= 0.0 && shadowUV.x <=1.0 && shadowUV.y >= 0.0 && shadowUV.y <=1.0) {
        vec4 shadowColor = texture2D(shadowMap, shadowUV);
        if (shadowColor.r + bias < positionInLightSpace.z) {
            shadow = 0.1;
        } else {
            shadow = 1.0;
        }
    }
    
    // 计算漫反射
    float diffuseStrength = dot(normalizedLightDirection, transformedNormal);
    diffuseStrength = clamp(diffuseStrength, 0.0, 1.0);
    vec3 diffuse = diffuseStrength * light.color * texture2D(diffuseMap, fragUV).rgb * light.indensity * shadow;
    
    // 计算环境光
    vec3 ambient = vec3(light.ambientIndensity) * material.ambientColor;
    
    // 计算高光
    vec3 eyeVector = normalize(eyePosition - worldVertexPosition.xyz);
    vec3 halfVector = normalize(normalizedLightDirection + eyeVector);
    float specularStrength = dot(halfVector, transformedNormal);
    specularStrength = pow(specularStrength, material.smoothness);
    vec3 specular = specularStrength * material.specularColor * light.color * light.indensity * shadow;
    
    // 最终颜色计算
    vec3 finalColor = diffuse + ambient + specular;
    
    gl_FragColor = vec4(finalColor, 1.0);
}
