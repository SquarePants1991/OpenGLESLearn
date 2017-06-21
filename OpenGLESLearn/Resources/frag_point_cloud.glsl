precision highp float;

varying vec3 fragNormal;
varying vec2 fragUV;

uniform float elapsedTime;
uniform mat4 normalMatrix;

void main(void) {
    // 为了绘制圆形的点
    float distance = sqrt(pow(gl_PointCoord.x - 0.5, 2.0) + pow(gl_PointCoord.y - 0.5, 2.0));
    if (distance > 0.5) {
        discard;
    }
    gl_FragColor = vec4(0.0, 1.0, 0.0, 1.0);
}


