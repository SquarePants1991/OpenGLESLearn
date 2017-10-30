attribute vec4 position;
attribute vec3 normal;
attribute vec2 uv;
attribute vec3 tangent;
attribute vec3 bitangent;

uniform float elapsedTime;
uniform mat4 projectionMatrix;
uniform mat4 cameraMatrix;
uniform mat4 modelMatrix;
uniform vec2 billboardSize;
uniform vec3 billboardCenterPosition;
uniform bool lockToYAxis;

varying vec3 fragPosition;
varying vec3 fragNormal;
varying vec2 fragUV;
varying vec3 fragTangent;
varying vec3 fragBitangent;

void main(void) {
    mat4 vp = projectionMatrix * cameraMatrix;
    fragNormal = normal;
    fragUV = uv;
    fragTangent = tangent;
    fragBitangent = bitangent;
    vec3 cameraRightInWorldspace = vec3(cameraMatrix[0][0], cameraMatrix[1][0], cameraMatrix[2][0]);
    vec3 cameraUpInWorldspace = vec3(0.0, 1.0, 0.0);
    if (lockToYAxis == false) {
        cameraUpInWorldspace = vec3(cameraMatrix[0][1], cameraMatrix[1][1], cameraMatrix[2][1]);
    }
    vec3 vertexPositionInWorldspace = billboardCenterPosition + cameraRightInWorldspace * position.x * billboardSize.x + cameraUpInWorldspace * position.y * billboardSize.y;
    fragPosition = vertexPositionInWorldspace;
    gl_Position = vp * vec4(vertexPositionInWorldspace, 1.0);
}
