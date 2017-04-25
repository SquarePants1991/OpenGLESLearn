attribute vec4 position;
attribute vec4 color;

uniform float elapsedTime;
uniform mat4 transform;

varying vec4 fragColor;

void main(void) {
    fragColor = color;
    gl_Position = transform * position;
}
