precision highp float;

varying vec2 fragUV;
varying vec3 fragPosition;

uniform mat4 mirrorPVMatrix;
uniform mat4 modelMatrix;
uniform sampler2D diffuseMap;

void main(void) {
    vec4 positionInWordCoord = mirrorPVMatrix * modelMatrix * vec4(fragPosition, 1.0);
    positionInWordCoord = positionInWordCoord / positionInWordCoord.w;
    positionInWordCoord = (positionInWordCoord + 1.0) * 0.5;
    gl_FragColor = texture2D(diffuseMap, positionInWordCoord.st);
}

