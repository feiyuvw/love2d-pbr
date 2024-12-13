local ball_shader = love.graphics.newShader("shader/ibl_texture.frag", "shader/ibl_texture.vert")
local lightPositions = {{-10, 10, 10}, {10, 10, 10}, {-10, -10, 10}, {10, -10, 10}}
local ls = 300 -- 光线强度就是300,是普通颜色的300倍
local lightColors = {{ls, ls, ls}, {ls, ls, ls}, {ls, ls, ls}, {ls, ls, ls}}
ball_shader:send("lightPositions", lightPositions[1], lightPositions[2], lightPositions[3], lightPositions[4])
ball_shader:send("lightColors", lightColors[1], lightColors[2], lightColors[3], lightColors[4])
-- 
local irradianceMap = love.graphics.newCubeImage({"assets/cubemap/convolution_1.png",
                                                  "assets/cubemap/convolution_2.png",
                                                  "assets/cubemap/convolution_3.png",
                                                  "assets/cubemap/convolution_4.png",
                                                  "assets/cubemap/convolution_5.png", "assets/cubemap/convolution_6.png"})
ball_shader:send("irradianceMap", irradianceMap)
local prefilterMap = love.graphics.newCubeImage({"assets/cubemap/prefilter_mip1_1.png",
                                                 "assets/cubemap/prefilter_mip1_2.png",
                                                 "assets/cubemap/prefilter_mip1_3.png",
                                                 "assets/cubemap/prefilter_mip1_4.png",
                                                 "assets/cubemap/prefilter_mip1_5.png",
                                                 "assets/cubemap/prefilter_mip1_6.png"}, {mipmaps = true})
ball_shader:send("prefilterMap", prefilterMap)
local brdfLUT = love.graphics.newImage("assets/img/brdfLUT.png")
ball_shader:send("brdfLUT", brdfLUT)
-- // ------------------------------------------
local nrRows = 7
local nrColumns = 7
local spacing = 2.5
local balls = {}
local ballNames = {"rusted_iron", "gold", "grass", "plastic", "wall"}
local ballImages = {}
for i = 1, #ballNames, 1 do
    local sphere = newModel(obj.sphere, nil, vector3(-7 + 2 * i, 0, 2))
    balls[i] = sphere
    local albedo = love.graphics.newImage("assets/pbr/" .. ballNames[i] .. "/albedo.png")
    local ao = love.graphics.newImage("assets/pbr/" .. ballNames[i] .. "/ao.png")
    local metallic = love.graphics.newImage("assets/pbr/" .. ballNames[i] .. "/metallic.png")
    local normal = love.graphics.newImage("assets/pbr/" .. ballNames[i] .. "/normal.png")
    local roughness = love.graphics.newImage("assets/pbr/" .. ballNames[i] .. "/roughness.png")
    ballImages[i] = {albedo, ao, metallic, normal, roughness}
end
-- // ------------------------------------------
function love.draw()
    love.graphics.clear(0.2, 0.3, 0.3)
    ball_shader:send("camPos", camera.position:array())
    for i = 1, #balls, 1 do
        ball_shader:send("albedoMap", ballImages[i][1])
        ball_shader:send("aoMap", ballImages[i][2])
        ball_shader:send("metallicMap", ballImages[i][3])
        ball_shader:send("normalMap", ballImages[i][4])
        ball_shader:send("roughnessMap", ballImages[i][5])
        balls[i]:draw(ball_shader)
    end
    showSkybox()
end

