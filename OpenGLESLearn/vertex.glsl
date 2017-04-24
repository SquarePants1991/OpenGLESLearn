attribute vec4 position;
attribute vec4 color;

uniform float elapsedTime;

varying vec4 fragColor;

void main(void) {
    fragColor = color;
    float angle = elapsedTime * 1.0;
    float xPos = position.x * cos(angle) - position.y * sin(angle);
    float yPos = position.x * sin(angle) + position.y * cos(angle);
    gl_Position = position;//vec4(xPos, yPos, position.z, 1.0);
    gl_PointSize = 25.0;
}
