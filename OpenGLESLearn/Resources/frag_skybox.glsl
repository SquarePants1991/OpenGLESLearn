precision highp float;

varying vec2 fragUV;
varying vec3 fragPosition;

uniform samplerCube envMap;
uniform mat4 modelMatrix;
void main(void) {
    vec3 sampleVector = normalize(modelMatrix * vec4(fragPosition, 1.0)).xyz;
    gl_FragColor = textureCube(envMap, sampleVector);
}


