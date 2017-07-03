attribute vec4 position;
attribute vec3 normal;
attribute vec2 uv;
attribute vec3 tangent;
attribute vec3 bitangent;

uniform float elapsedTime;
uniform mat4 projectionMatrix;
uniform mat4 cameraMatrix;
uniform mat4 modelMatrix;

varying vec3 fragPosition;
varying vec3 fragNormal;
varying vec2 fragUV;
varying vec3 fragTangent;
varying vec3 fragBitangent;

void main(void) {
    mat4 mvp = projectionMatrix * cameraMatrix * modelMatrix;
    fragNormal = normal;
    fragUV = uv;
    fragPosition = position.xyz;
    fragTangent = tangent;
    fragBitangent = bitangent;
    gl_Position = mvp * position;
}
