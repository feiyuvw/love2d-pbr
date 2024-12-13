varying vec3 WorldPos;
uniform samplerCube environmentMap;

vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
{

    // vec3 toOpengl = WorldPos * 0.5;
    // vec3 envColor = Texel(cubemap, toOpengl).rgb;
    // envColor = envColor / (envColor + vec3(1.0));
    // envColor = pow(envColor, vec3(1.0/2.2)); 
    // return vec4(envColor, 1.0);
    
    vec3 envColor = Texel(environmentMap, WorldPos).rgb;
    envColor = envColor / (envColor + vec3(1.0));
    envColor = pow(envColor, vec3(1.0/2.2)); 
    return vec4(envColor, 1.0);
}