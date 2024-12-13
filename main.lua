clamp = function(x, min, max)
    return math.max(min, math.min(max, x))
end
sin = math.sin
cos = math.cos
-- // ------------------------------------------
vector3 = require "common.vector3"
matrix = require "common.matrix"
newModel = require "common.model"
obj = require "common.obj"
-- // ------------------------------------------
camera = require "common.camera"
camera.updateProjectionMatrix()
camera.updateViewMatrix()
-- // ------------------------------------------
love.graphics.setDepthMode("lequal", true)
-- // ------------------------------------------
local cube_skybox_shader
local cube_skybox
cubemap_imags = {"assets/cubemap/cubemap_1.png", "assets/cubemap/cubemap_2.png", "assets/cubemap/cubemap_4.png",
                 "assets/cubemap/cubemap_3.png", "assets/cubemap/cubemap_5.png", "assets/cubemap/cubemap_6.png"}
showSkybox = function()
    -- //
    if not cube_skybox_shader then
        cube_skybox = newModel(obj.cube)
        cube_skybox_shader = love.graphics.newShader("shader/cube_skybox.frag", "shader/cube_skybox.vert")
        local cubemap = love.graphics.newCubeImage(cubemap_imags)
        cube_skybox_shader:send("environmentMap", cubemap)
        return true
    end
    cube_skybox:draw(cube_skybox_shader)
    return true
end
-- // ------------------------------------------
function love.update(dt)
    if love.keyboard.isDown "escape" then
        love.event.push "quit"
    end
    camera.update_keydown(dt)
end

if love.mouse then
    -- 设置为true时，the cursor is hidden and doesn't move when the mouse does, but relative mouse motion events are still generated 
    love.mouse.setRelativeMode(true)
end

function love.mousemoved(x, y, dx, dy)
    camera.update_mousemove(dx, dy)
end
-- // ------------------------------------------
local runIndex = 6
run = function(index)
    local parts = {
        [1] = "src/01_cubemap",
        [2] = "src/02_lighting",
        [3] = "src/03_texture",
        [4] = "src/04_irradiance",
        [5] = "src/05_prefilter",
        [6] = "src/06_ibl_texture"
    }
    require(parts[index])
end
run(runIndex)

