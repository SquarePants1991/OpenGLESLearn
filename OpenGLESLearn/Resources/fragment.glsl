precision highp float;

// 平行光
struct Directionlight {
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

uniform float elapsedTime;
uniform Directionlight light;
uniform Material material;
uniform vec3 eyePosition;
uniform mat4 normalMatrix;
uniform mat4 modelMatrix;

uniform sampler2D diffuseMap;

void main(void) {
    vec3 normalizedLightDirection = normalize(-light.direction);
    vec3 transformedNormal = normalize((normalMatrix * vec4(fragNormal, 1.0)).xyz);
    
    // 计算漫反射
    float diffuseStrength = dot(normalizedLightDirection, transformedNormal);
    diffuseStrength = clamp(diffuseStrength, 0.0, 1.0);
    vec3 diffuse = diffuseStrength * light.color * material.diffuseColor * light.indensity;
    
    // 计算环境光
    vec3 ambient = vec3(light.ambientIndensity) * material.ambientColor;
    
    // 计算高光
    vec4 worldVertexPosition = modelMatrix * vec4(fragPosition, 1.0);
    vec3 eyeVector = normalize(eyePosition - worldVertexPosition.xyz);
    vec3 halfVector = normalize(normalizedLightDirection + eyeVector);
    float specularStrength = dot(halfVector, transformedNormal);
    specularStrength = pow(specularStrength, material.smoothness);
    vec3 specular = specularStrength * material.specularColor * light.color * light.indensity;
    
    // 最终颜色计算
    vec3 finalColor = diffuse + ambient + specular;
    
    gl_FragColor = vec4(finalColor, 1.0);
}
