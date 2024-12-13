local sin = math.sin
local cos = math.cos
local rad = math.rad

local YAW = -90
local PITCH = 0
local SPEED = 2.5
local SENSITIVITY = 0.1
local FOV = 45

local camera = {fov = FOV, nearClip = 0.1, farClip = 100, aspectRatio = 1280 / 720, -- 
position = vector3(0, 0, 3), front = vector3(0, 0, -1), up = vector3(0, 1, 0), right = vector3(1, 0, 0), yaw = YAW,
                pitch = PITCH, worldup = vector3(0, 1, 0), viewMatrix = matrix(), projectionMatrix = matrix()}

function camera.onWindowResize()
    camera.aspectRatio = love.graphics.getWidth()/love.graphics.getHeight()
    camera.updateProjectionMatrix()
end

function camera.updateViewMatrix()
    camera.viewMatrix = matrix.lookat(camera.position, camera.position + camera.front, camera.up)
end

function camera.updateProjectionMatrix()
    camera.projectionMatrix = matrix.project(camera.fov, camera.aspectRatio, camera.nearClip, camera.farClip)
end

function camera.update_keydown(dt)
    local velocity = SPEED * dt
    if love.keyboard.isDown "w" then
        camera.position = camera.position + camera.front * velocity
    end
    if love.keyboard.isDown "s" then
        camera.position = camera.position - camera.front * velocity
    end
    if love.keyboard.isDown "a" then
        camera.position = camera.position - camera.right * velocity
    end
    if love.keyboard.isDown "d" then
        camera.position = camera.position + camera.right * velocity
    end
    camera.updateViewMatrix()
end

function camera.update_mousemove(dx, dy)
    dx = dx * SENSITIVITY
    dy = dy * SENSITIVITY
    camera.yaw = camera.yaw + dx
    camera.pitch = camera.pitch - dy
    -- make sure that when pitch is out of bounds, screen doesn't get flipped
    if true then
        if camera.pitch > 89 then
            camera.pitch = 89
        end
        if camera.pitch < -89 then
            camera.pitch = -89
        end
    end
    camera.update_vector()
    camera.updateViewMatrix()
end

function camera.update_vector()
    local x = cos(rad(camera.pitch)) * cos(rad(camera.yaw))
    local y = sin(rad(camera.pitch))
    local z = cos(rad(camera.pitch)) * sin(rad(camera.yaw))
    camera.front = vector3(x, y, z):normalize()
    camera.right = vector3.cross(camera.front, camera.worldup)
    camera.right = camera.right:normalize()
    camera.up = vector3.cross(camera.right, camera.front)
    camera.up = camera.up:normalize()
end

return camera
