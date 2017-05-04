attribute vec4 position;
attribute vec3 normal;

uniform float elapsedTime;
uniform mat4 projectionMatrix;
uniform mat4 cameraMatrix;
uniform mat4 modelMatrix;

varying vec3 fragNormal;

void main(void) {
    mat4 mvp = projectionMatrix * cameraMatrix * modelMatrix;
    fragNormal = normal;
    gl_Position = mvp * position;
}
