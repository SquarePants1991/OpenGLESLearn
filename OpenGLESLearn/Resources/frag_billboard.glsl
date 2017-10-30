precision highp float;

struct Fog {
    int fogType; // 0: 线性，1: exp 2: 2次exp
    float fogStart;
    float fogEnd;
    float fogIndensity;
    vec3 fogColor;
};

varying vec2 fragUV;
varying vec3 fragPosition;
uniform vec3 eyePosition;

uniform sampler2D diffuseMap;
uniform mat4 modelMatrix;
uniform Fog fog;

float linearFogFactor(float fogStart, float fogEnd) {
    vec4 worldVertexPosition = modelMatrix * vec4(fragPosition, 1.0);
    float distanceToEye = distance(eyePosition, worldVertexPosition.xyz);
    // linear
    float fogFactor = (fogEnd - distanceToEye) / (fogEnd - fogStart); // 1.0 ~ 0.0
    fogFactor = 1.0 - clamp(fogFactor, 0.0, 1.0);  // 0.0 ~ 1.0
    return fogFactor;
}

float exponentialFogFactor(float fogDensity) {
    vec4 worldVertexPosition = modelMatrix * vec4(fragPosition, 1.0);
    float distanceToEye = distance(eyePosition, worldVertexPosition.xyz);
    float fogFactor = 1.0 / exp(distanceToEye * fogDensity);
    fogFactor = 1.0 - clamp(fogFactor, 0.0, 1.0);  // 0.0 ~ 1.0
    return fogFactor;
}

float exponentialSquareFogFactor(float fogDensity) {
    vec4 worldVertexPosition = modelMatrix * vec4(fragPosition, 1.0);
    float distanceToEye = distance(eyePosition, worldVertexPosition.xyz);
    float fogFactor = 1.0 / exp(pow(distanceToEye * fogDensity, 2.0));
    fogFactor = 1.0 - clamp(fogFactor, 0.0, 1.0);  // 0.0 ~ 1.0
    return fogFactor;
}

vec3 colorWithFog(vec3 inputColor) {
    float fogFactor = 0.0;
    if (fog.fogType == 0) {
        fogFactor = linearFogFactor(fog.fogStart, fog.fogEnd);
    } else if (fog.fogType == 1) {
        fogFactor = exponentialFogFactor(fog.fogIndensity);
    } else if (fog.fogType == 2) {
        fogFactor = exponentialSquareFogFactor(fog.fogIndensity);
    }
    return mix(inputColor, fog.fogColor, fogFactor);
}

void main(void) {
    vec4 diffuseColor = texture2D(diffuseMap, fragUV);
    if (diffuseColor.a == 0.0) {
        discard;
    }
    vec3 finalColor = colorWithFog(diffuseColor.rgb);
    gl_FragColor = vec4(finalColor, 1.0);
}


