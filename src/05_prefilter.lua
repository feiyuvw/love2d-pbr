local ball_shader = love.graphics.newShader("shader/prefilter.frag", "shader/prefilter.vert")
local lightPositions = {{-10, 10, 10}, {10, 10, 10}, {-10, -10, 10}, {10, -10, 10}}
local ls = 300 -- 光线强度就是300,是普通颜色的300倍
local lightColors = {{ls, ls, ls}, {ls, ls, ls}, {ls, ls, ls}, {ls, ls, ls}}
ball_shader:send("lightPositions", lightPositions[1], lightPositions[2], lightPositions[3], lightPositions[4])
ball_shader:send("lightColors", lightColors[1], lightColors[2], lightColors[3], lightColors[4])
ball_shader:send("albedo", {0.5, 0, 0})
ball_shader:send("ao", 1)
-- IBL，这里不需要交换3、4的顺序
local irradianceMap = love.graphics.newCubeImage({"assets/cubemap/convolution_1.png",
                                                  "assets/cubemap/convolution_2.png",
                                                  "assets/cubemap/convolution_3.png",
                                                  "assets/cubemap/convolution_4.png",
                                                  "assets/cubemap/convolution_5.png", "assets/cubemap/convolution_6.png"})
ball_shader:send("irradianceMap", irradianceMap)

local mipLevel = 1
local mipImages = {}
for i = 1, 6, 1 do
    mipImages[i] = "assets/cubemap/prefilter_mip" .. mipLevel .. "_" .. i .. ".png"
end
local prefilterMap = love.graphics.newCubeImage(mipImages,{mipmaps=true}) -- love2d离屏渲染没学习；指定cubemap的mipmap图片的方法没用，但可以自动生成mipmap。

ball_shader:send("prefilterMap", prefilterMap)
local brdfLUT = love.graphics.newImage("assets/img/brdfLUT.png")
ball_shader:send("brdfLUT", brdfLUT) 
-- // ------------------------------------------
local nrRows = 7
local nrColumns = 7
local spacing = 2.5
local balls = {}
for row = 0, nrRows - 1, 1 do -- 从零开始,与opengl教程尽量保持一直
    balls[row] = {}
    for col = 0, nrColumns - 1, 1 do
        local sphere = newModel(obj.sphere, nil, vector3((col - 3) * spacing, (row - 3) * spacing, -2))
        balls[row][col] = sphere
    end
end
-- // ------------------------------------------
function love.draw()
    love.graphics.clear(0.2, 0.3, 0.3)
    ball_shader:send("camPos", camera.position:array())
    for row = 0, nrRows - 1, 1 do
        ball_shader:send("metallic", row / nrRows)
        for col = 0, nrColumns - 1, 1 do
            ball_shader:send("roughness", clamp(col / nrColumns, 0.05, 1))
            balls[row][col]:draw(ball_shader)
        end
    end
    showSkybox()
end
