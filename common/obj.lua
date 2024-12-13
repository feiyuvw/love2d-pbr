local cube_verts = { -- back face
    {-1, -1, -1, 0, 0, -1, 0, 0}, -- bottom-left
    {1, 1, -1, 0, 0, -1, 1, 1}, -- top-right
    {1, -1, -1, 0, 0, -1, 1, 0}, -- bottom-right         
    {1, 1, -1, 0, 0, -1, 1, 1}, -- top-right
    {-1, -1, -1, 0, 0, -1, 0, 0}, -- bottom-left
    {-1, 1, -1, 0, 0, -1, 0, 1}, -- top-left
    -- front face
    {-1, -1, 1, 0, 0, 1, 0, 0}, -- bottom-left
    {1, -1, 1, 0, 0, 1, 1, 0}, -- bottom-right
    {1, 1, 1, 0, 0, 1, 1, 1}, -- top-right
    {1, 1, 1, 0, 0, 1, 1, 1}, -- top-right
    {-1, 1, 1, 0, 0, 1, 0, 1}, -- top-left
    {-1, -1, 1, 0, 0, 1, 0, 0}, -- bottom-left
    -- left face
    {-1, 1, 1, -1, 0, 0, 1, 0}, -- top-right
    {-1, 1, -1, -1, 0, 0, 1, 1}, -- top-left
    {-1, -1, -1, -1, 0, 0, 0, 1}, -- bottom-left
    {-1, -1, -1, -1, 0, 0, 0, 1}, -- bottom-left
    {-1, -1, 1, -1, 0, 0, 0, 0}, -- bottom-right
    {-1, 1, 1, -1, 0, 0, 1, 0}, -- top-right
    -- right face
    {1, 1, 1, 1, 0, 0, 1, 0}, -- top-left
    {1, -1, -1, 1, 0, 0, 0, 1}, -- bottom-right
    {1, 1, -1, 1, 0, 0, 1, 1}, -- top-right         
    {1, -1, -1, 1, 0, 0, 0, 1}, -- bottom-right
    {1, 1, 1, 1, 0, 0, 1, 0}, -- top-left
    {1, -1, 1, 1, 0, 0, 0, 0}, -- bottom-left     
    -- bottom face
    {-1, -1, -1, 0, -1, 0, 0, 1}, -- top-right
    {1, -1, -1, 0, -1, 0, 1, 1}, -- top-left
    {1, -1, 1, 0, -1, 0, 1, 0}, -- bottom-left
    {1, -1, 1, 0, -1, 0, 1, 0}, -- bottom-left
    {-1, -1, 1, 0, -1, 0, 0, 0}, -- bottom-right
    {-1, -1, -1, 0, -1, 0, 0, 1}, -- top-right
    -- top face
    {-1, 1, -1, 0, 1, 0, 0, 1}, -- top-left
    {1, 1, 1, 0, 1, 0, 1, 0}, -- bottom-right
    {1, 1, -1, 0, 1, 0, 1, 1}, -- top-right     
    {1, 1, 1, 0, 1, 0, 1, 0}, -- bottom-right
    {-1, 1, -1, 0, 1, 0, 0, 1}, -- top-left
    {-1, 1, 1, 0, 1, 0, 0, 0} -- bottom-left        
}
-- //
local quad_raws = {{-1, 1, 0, 0, 1}, {-1, -1, 0, 0, 0}, {1, 1, 0, 1, 1}, {1, -1, 0, 1, 0}}
-- 为了保持统一，添加了法线数据
for i = 1, #quad_raws, 1 do
    local vert = quad_raws[i]
    table.insert(vert, 4, 2)
    table.insert(vert, 4, 2)
    table.insert(vert, 4, 2)
end
local quad_verts = {}
table.insert(quad_verts, quad_raws[1])
table.insert(quad_verts, quad_raws[2])
table.insert(quad_verts, quad_raws[3])
table.insert(quad_verts, quad_raws[3])
table.insert(quad_verts, quad_raws[2])
table.insert(quad_verts, quad_raws[4])
-- //
local sphere_verts = {}
local vertDatas = {}
local indices = {}
local pi = 3.14159265359
local X_SEGMENTS = 64
local Y_SEGMENTS = 64
for x = 0, X_SEGMENTS, 1 do
    for y = 0, Y_SEGMENTS, 1 do
        local xSegment = x / X_SEGMENTS
        local ySegment = y / Y_SEGMENTS
        local xPos = cos(xSegment * 2 * pi) * sin(ySegment * pi)
        local yPos = cos(ySegment * pi)
        local zPos = sin(xSegment * 2 * pi) * sin(ySegment * pi)
        table.insert(vertDatas, {xPos, yPos, zPos, xPos, yPos, zPos, xSegment, ySegment}) -- pos,normal,uv
    end
end
-- indices
local oddRow = false
for y = 0, Y_SEGMENTS - 1, 1 do
    if not oddRow then -- even rows: y == 0, y == 2; and so on
        for x = 0, X_SEGMENTS, 1 do
            table.insert(indices, y * (X_SEGMENTS + 1) + x)
            table.insert(indices, (y + 1) * (X_SEGMENTS + 1) + x)
        end
    else
        for x = X_SEGMENTS, 0, -1 do
            table.insert(indices, (y + 1) * (X_SEGMENTS + 1) + x)
            table.insert(indices, y * (X_SEGMENTS + 1) + x)
        end
    end
    oddRow = not oddRow
end
-- triangle
-- 这里我们使用的是GL_TRIANGLES模式，教程使用的是GL_TRIANGLE_STRIP模式，
-- 两者的区别在于，GL_TRIANGLE_STRIP会自动连接相邻的三角形，而GL_TRIANGLES则需要我们手动连接。
for i = 1, #indices - 2, 1 do
    local i1 = indices[i] + 1
    local i2 = indices[i + 1] + 1
    local i3 = indices[i + 2] + 1
    if (i3 - 1) % 2 == 0 then
        table.insert(sphere_verts, vertDatas[i1])
        table.insert(sphere_verts, vertDatas[i2])
        table.insert(sphere_verts, vertDatas[i3])
    else -- opengl中，顶点索引数为奇数是采用[n-1,n-2,n]顺序
        table.insert(sphere_verts, vertDatas[i2])
        table.insert(sphere_verts, vertDatas[i1])
        table.insert(sphere_verts, vertDatas[i3])
    end
end

return {
    quad = quad_verts,
    cube = cube_verts,
    sphere= sphere_verts
}