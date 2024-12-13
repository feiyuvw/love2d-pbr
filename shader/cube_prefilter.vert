#pragma language glsl3

uniform mat4 projection; 
uniform mat4 view;       

varying vec3 WorldPos;

vec4 position(mat4 transformProjection, vec4 vertexPosition) {
    WorldPos = vec3(vertexPosition);
	return projection * view * vec4(WorldPos, 1.0);
}