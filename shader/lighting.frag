varying vec3 WorldPos;
varying vec3 Normal;
// material parameters
uniform vec3 albedo;
uniform float metallic;
uniform float roughness;
uniform float ao;
// lights
uniform vec3  lightPositions[4];
uniform vec3 lightColors[4];
uniform vec3 camPos;
const float PI = 3.14159265359;
// ----------------------------------------------------------------------------
float DistributionGGX(vec3 N, vec3 H, float roughness) {
    float a = roughness*roughness;
    float a2 = a*a;
    float NdotH = max(dot(N, H), 0.0);
    float NdotH2 = NdotH*NdotH;

    float nom   = a2;
    float denom = (NdotH2 * (a2 - 1.0) + 1.0);
    denom = PI * denom * denom;

    return nom / denom;
}
// ----------------------------------------------------------------------------
float GeometrySchlickGGX(float NdotV, float roughness) {
    float r = (roughness + 1.0);
    float k = (r*r) / 8.0;

    float nom   = NdotV;
    float denom = NdotV * (1.0 - k) + k;

    return nom / denom;
}
// ----------------------------------------------------------------------------
float GeometrySmith(vec3 N, vec3 V, vec3 L, float roughness) {
    float NdotV = max(dot(N, V), 0.0);
    float NdotL = max(dot(N, L), 0.0);
    float ggx2 = GeometrySchlickGGX(NdotV, roughness);
    float ggx1 = GeometrySchlickGGX(NdotL, roughness);

    return ggx1 * ggx2;
}
// ----------------------------------------------------------------------------
vec3 fresnelSchlick(float cosTheta, vec3 F0) {
    return F0 + (1.0 - F0) * pow(clamp(1.0 - cosTheta, 0.0, 1.0), 5.0);
}
// ----------------------------------------------------------------------------
vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords ) {
    vec3 N = normalize(Normal);
    vec3 V = normalize(camPos - WorldPos);
    // 材质基础反射率
    vec3 F0 = vec3(0.04); 
    F0 = mix(F0, albedo, metallic);
    // 反射率公式
    vec3 Lo = vec3(0.0);
    for(int i = 0; i < 4; ++i) {
        vec3 L = normalize(lightPositions[i] - WorldPos); // 光线方向
        vec3 H = normalize(V + L); // 半程向量
        float distance = length(lightPositions[i] - WorldPos);
        float attenuation = 1.0 / (distance * distance); // 光线衰减系数

        // BRDF：基于表面材质属性来对入射光辐射率进行缩放或者加权
        float D = DistributionGGX(N, H, roughness);   
        vec3  F = fresnelSchlick(clamp(dot(H, V), 0.0, 1.0), F0);
        float G = GeometrySmith(N, V, L, roughness);      
        float denominator = 4.0 * max(dot(N, V), 0.0) * max(dot(N, L), 0.0) + 0.0001; // + 0.0001 防止为0
        vec3 specular = D * G * F / denominator;
        
        vec3 kS = F; // 反射部分比率等于菲涅尔系数
        vec3 kD = vec3(1.0) - kS; // 能量守恒，漫反射部分比率 = 1 - 反射部分比率
        kD *= 1.0 - metallic; // 将kD乘以金属度的逆值，只有非金属才具有漫射照明，部分金属线性混合,纯金属没有漫射光

        vec3 radiance = lightColors[i] * attenuation; // 入射光辐射率！
        float NdotL = max(dot(N, L), 0.0);
        // 最终形式,(kD * albedo / PI + specular)即是BRDF,可以看到,它对入射光辐射率进行了放缩
        Lo += (kD * albedo / PI + specular) * radiance * NdotL;
    }   
    vec3 ambient = vec3(0.03) * albedo * ao; // 环境光
    vec3 _color = ambient + Lo;
    _color = _color / (_color + vec3(1.0)); // HDR 色调映射
    _color = pow(_color, vec3(1.0/2.2)); // gamma矫正
    return vec4(_color, 1.0);
}