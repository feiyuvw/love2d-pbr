uniform mat4 projectionMatrix; 
uniform mat4 viewMatrix;       
uniform mat4 modelMatrix;     
uniform bool isCanvasEnabled;  

varying vec3 WorldPos;

vec4 position(mat4 transformProjection, vec4 vertexPosition) {
    WorldPos = vec3(vertexPosition);
    mat4 rotView = mat4(mat3(viewMatrix));
	vec4 clipPos = projectionMatrix * rotView * vec4(WorldPos, 1.0);
    vec4 screenPosition = clipPos.xyww;
    return screenPosition;
}