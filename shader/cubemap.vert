uniform mat4 projection; 
uniform mat4 view;       

varying vec3 localPos;

vec4 position(mat4 transformProjection, vec4 vertexPosition) {
    localPos = vec3(vertexPosition);
	return projection * view * vec4(localPos, 1.0);
}