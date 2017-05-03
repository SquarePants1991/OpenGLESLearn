varying lowp vec4 fragColor;
varying lowp vec2 fragUV;

uniform highp float elapsedTime;
uniform sampler2D diffuseMap;
uniform int useDiffuseMap;

void main(void) {
    if (useDiffuseMap == 1) {
        gl_FragColor = texture2D(diffuseMap, fragUV);
    } else {
        gl_FragColor = fragColor;
    }
}
