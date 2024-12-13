#pragma language glsl3

varying  vec3 WorldPos;
varying  vec3 Normal;

attribute vec3 VertexNormal;

uniform mat4 projectionMatrix; 
uniform mat4 viewMatrix;       
uniform mat4 modelMatrix;     
uniform mat3 normalMatrix;

vec4 position(mat4 transformProjection, vec4 vertexPosition) {
    WorldPos = vec3(modelMatrix * vertexPosition);
    Normal = normalMatrix * VertexNormal;   
    return projectionMatrix * viewMatrix * vec4(WorldPos,1.0);
}