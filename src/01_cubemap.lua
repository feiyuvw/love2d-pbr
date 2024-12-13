local hasSetWindowThisFrame = false
-- 
local cube = newModel(obj.cube)
local cube_perspective = matrix.project(90, 1, 0.1, 10)
local views = {matrix.lookat(vector3(0, 0, 0), vector3(1, 0, 0), vector3(0, -1, 0)),
               matrix.lookat(vector3(0, 0, 0), vector3(-1, 0, 0), vector3(0, -1, 0)),
               matrix.lookat(vector3(0, 0, 0), vector3(0, 1, 0), vector3(0, 0, 1)),
               matrix.lookat(vector3(0, 0, 0), vector3(0, -1, 0), vector3(0, 0, -1)),
               matrix.lookat(vector3(0, 0, 0), vector3(0, 0, 1), vector3(0, -1, 0)),
               matrix.lookat(vector3(0, 0, 0), vector3(0, 0, -1), vector3(0, -1, 0))}

-- // cubemap
local cubemap_imgIndex = 1
local cube_cubemap_shader
local function create_cubemap()
    if not hasSetWindowThisFrame then
        love.window.setMode(500, 500)
        camera.onWindowResize()
        hasSetWindowThisFrame = true
        return true
    end
    -- 
    if not cube_cubemap_shader then
        cube_cubemap_shader = love.graphics.newShader("shader/cubemap.frag", "shader/cubemap.vert")
        local equirectangularMap = love.graphics.newImage("assets/img/newport_loft.hdr")
        cube_cubemap_shader:send("equirectangularMap", equirectangularMap)
        cube_cubemap_shader:send("projection", cube_perspective)
        return true
    end
    local index = cubemap_imgIndex
    cube_cubemap_shader:send("view", views[index])
    cube:draw(cube_cubemap_shader)
    love.graphics.captureScreenshot("cubemap_" .. index .. ".png")
    cubemap_imgIndex = cubemap_imgIndex + 1
    return cubemap_imgIndex <= 6
end
-- // convolution
local cube_convolution_imgIndex = 1
local cube_convolution_shader
local function create_convolution()
    if not hasSetWindowThisFrame then
        love.window.setMode(32, 32)
        camera.onWindowResize()
        hasSetWindowThisFrame = true
        return true
    end
    -- 
    if not cube_convolution_shader then
        cube_convolution_shader = love.graphics
                                      .newShader("shader/cube_convolution.frag", "shader/cube_convolution.vert")
        local cubemap = love.graphics.newCubeImage(cubemap_imags)
        cube_convolution_shader:send("environmentMap", cubemap)
        cube_convolution_shader:send("projection", cube_perspective)
        return true
    end
    local index = cube_convolution_imgIndex
    cube_convolution_shader:send("view", views[index])
    cube:draw(cube_convolution_shader)
    love.graphics.captureScreenshot("convolution_" .. index .. ".png")
    cube_convolution_imgIndex = cube_convolution_imgIndex + 1
    return cube_convolution_imgIndex <= 6
end
-- // prefilter
local cube_prefilter_imgIndex = 1
local cube_prefilter_shader
local cube_prefilter_maxMipLevels = 5
local mip = 0
local function create_prefilter()
    if not hasSetWindowThisFrame then
        love.window.setMode(128 * math.pow(0.5, mip), 128 * math.pow(0.5, mip))
        camera.onWindowResize()
        hasSetWindowThisFrame = true
        return true
    end
    -- //   
    if not cube_prefilter_shader then
        cube_prefilter_shader = love.graphics.newShader("shader/cube_prefilter.frag", "shader/cube_prefilter.vert")
        local cubemap = love.graphics.newCubeImage(cubemap_imags)
        cube_prefilter_shader:send("environmentMap", cubemap)
        cube_prefilter_shader:send("projection", cube_perspective)
        return true
    end
    -- //
    local roughness = mip / (cube_prefilter_maxMipLevels - 1)
    cube_prefilter_shader:send("roughness", roughness)
    -- //
    local index = cube_prefilter_imgIndex - 1
    cube_prefilter_shader:send("view",views[index + 1])
    cube:draw(cube_prefilter_shader)
    love.graphics.captureScreenshot("prefilter_mip" .. mip + 1 .. "_" .. index + 1 .. ".png")
    -- //
    cube_prefilter_imgIndex = cube_prefilter_imgIndex + 1
    return cube_prefilter_imgIndex <= 6
end
-- // LUT 
local function create_LUT()
    if not hasSetWindowThisFrame then
        love.window.setMode(512,512)
        camera.onWindowResize()
        hasSetWindowThisFrame = true
        return true
    end
    -- //
    local quad = newModel(obj.quad)
    local quad_shader = love.graphics.newShader("shader/LUT.frag", "shader/LUT.vert")
    love.graphics.captureScreenshot("brdfLUT.png")
    quad:draw(quad_shader)
    return false
end
-- // skybox
local function showSkybox_run()
    if not hasSetWindowThisFrame then
        love.window.setMode(1280,720)
        camera.onWindowResize()
        hasSetWindowThisFrame = true
        return true
    end
    -- //
    showSkybox()
    return true
end

-- // ------------------------------------------
local funs = {create_cubemap, create_convolution,create_prefilter,create_LUT,showSkybox_run}
local funIndex = 1
local function excute()
    if funIndex > #funs then
        if funIndex == #funs+1 then
            print("finish!!!!!!!!!!!!!!!!!!!!!")
            print("path:",love.filesystem.getSaveDirectory())
        end
        return
    end

    if funs[funIndex]() then
    else
        funIndex = funIndex + 1
        hasSetWindowThisFrame = false
    end
end

function love.draw() excute() end
