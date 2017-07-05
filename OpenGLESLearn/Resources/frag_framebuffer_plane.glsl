precision highp float;

varying vec2 fragUV;

uniform sampler2D diffuseMap;

void main(void) {
    gl_FragColor = texture2D(diffuseMap, fragUV);
}

