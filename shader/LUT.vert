#pragma language glsl3

vec4 position(mat4 transformProjection, vec4 vertexPosition) {
    vec3 WorldPos = vec3(vertexPosition);
	return vec4(WorldPos, 1.0);
}