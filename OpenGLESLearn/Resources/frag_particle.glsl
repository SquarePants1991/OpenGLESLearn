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

uniform vec3 particleColor;

void main(void) {
    vec4 diffuseColor = texture2D(diffuseMap, fragUV);
    gl_FragColor = diffuseColor * vec4(particleColor, 1.0);
}



