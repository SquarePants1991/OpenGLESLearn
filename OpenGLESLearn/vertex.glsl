attribute vec4 position;
attribute vec4 color;

uniform float elapsedTime;
uniform mat4 projectionMatrix;
uniform mat4 cameraMatrix;
uniform mat4 modelMatrix;

varying vec4 fragColor;

void main(void) {
    fragColor = color;
    mat4 mvp = projectionMatrix * cameraMatrix * modelMatrix;
    gl_Position = mvp * position;
}
