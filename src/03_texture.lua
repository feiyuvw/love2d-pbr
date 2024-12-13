-- ball_shader  // ------------------------------------------
local ball_shader = love.graphics.newShader("shader/texture.frag", "shader/texture.vert")
-- local lightPositions = {{-10, 10, 10}, {10, 10, 10}, {-10, -10, 10}, {10, -10, 10}}
-- local ls = 300 -- 光线强度就是300,是普通颜色的300倍
-- local lightColors = {{ls, ls, ls}, {ls, ls, ls}, {ls, ls, ls}, {ls, ls, ls}}
ball_shader:send("albedoMap", love.graphics.newImage("assets/pbr/rusted_iron/albedo.png"))
ball_shader:send("metallicMap", love.graphics.newImage("assets/pbr/rusted_iron/metallic.png"))
ball_shader:send("normalMap", love.graphics.newImage("assets/pbr/rusted_iron/normal.png"))
ball_shader:send("roughnessMap", love.graphics.newImage("assets/pbr/rusted_iron/roughness.png"))
ball_shader:send("aoMap", love.graphics.newImage("assets/pbr/rusted_iron/ao.png"))
ball_shader:send("lightPositions", {0, 0, 10})
ball_shader:send("lightColors", {150, 150, 150})
-- // ------------------------------------------
local nrRows = 7
local nrColumns = 7
local spacing = 2.5
local balls = {}
for row = 0, nrRows - 1, 1 do -- 从零开始,与opengl教程尽量保持一直
    balls[row] = {}
    for col = 0, nrColumns - 1, 1 do
        local sphere = newModel(obj.sphere, nil, vector3((col - 3) * spacing, (row - 3) * spacing, 0))
        balls[row][col] = sphere
    end
end
-- // ------------------------------------------
function love.draw()
    love.graphics.clear(0.1, 0.1, 0.1)
    ball_shader:send("camPos", camera.position:array())
    for row = 0, nrRows - 1, 1 do
        -- ball_shader:send("metallic", row / nrRows)
        for col = 0, nrColumns - 1, 1 do
            -- ball_shader:send("roughness", clamp(col / nrColumns, 0.05, 1))
            balls[row][col]:draw(ball_shader)
        end
    end
end
