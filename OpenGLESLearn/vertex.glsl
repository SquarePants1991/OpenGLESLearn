attribute vec4 position;
attribute vec4 color;

varying vec4 fragColor;

void main(void) {
    fragColor = color;
    gl_Position = position;
}
