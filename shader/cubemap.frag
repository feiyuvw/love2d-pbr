varying vec3 localPos;
uniform sampler2D equirectangularMap;
const vec2 invAtan = vec2(0.1591, 0.3183);

vec2 SampleSphericalMap(vec3 v) {
    vec2 uv = vec2(atan(v.z, v.x), asin(v.y));
    uv *= invAtan;
    uv += 0.5;
    return uv;
}

vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
{
    vec2 uv = SampleSphericalMap(normalize(localPos)); // make sure to normalize localPos
    // uv.x = 1.0 - uv.x;
    // uv.y = 1.0 - uv.y;
    vec3 _color = Texel(equirectangularMap, uv).rgb;
    return vec4(_color, 1.0);
}