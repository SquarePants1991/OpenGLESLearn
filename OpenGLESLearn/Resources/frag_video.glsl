precision highp float;

varying vec3 fragNormal;
varying vec2 fragUV;

uniform float elapsedTime;
uniform mat4 normalMatrix;
uniform sampler2D yMap;
uniform sampler2D uvMap;

void main(void) {
    vec4 Y_planeColor = texture2D(yMap, fragUV);
    vec4 CbCr_planeColor = texture2D(uvMap, fragUV);
    
    float Cb, Cr, Y;
    float R ,G, B;
    Y = Y_planeColor.r * 255.0;
    Cb = CbCr_planeColor.r * 255.0 - 128.0;
    Cr = CbCr_planeColor.a * 255.0 - 128.0;
    
    R = 1.402 * Cr + Y;
    G = -0.344 * Cb - 0.714 * Cr + Y;
    B = 1.772 * Cb + Y;
    
    
    vec4 videoColor = vec4(R / 255.0, G / 255.0, B / 255.0, 1.0);
    gl_FragColor = videoColor;
}

