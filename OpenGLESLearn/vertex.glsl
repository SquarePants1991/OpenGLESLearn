attribute vec4 position;
attribute vec4 color;
attribute vec2 uv;

uniform float elapsedTime;
uniform mat4 projectionMatrix;
uniform mat4 cameraMatrix;
uniform mat4 modelMatrix;

varying vec4 fragColor;
varying vec2 fragUV;

void main(void) {
    fragColor = color;
    fragUV = uv;
    mat4 mvp = projectionMatrix * cameraMatrix * modelMatrix;
    gl_Position = mvp * position;
}
