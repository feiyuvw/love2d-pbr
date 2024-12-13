local matrix = {}
local matrix_meta = {}
matrix.__index = matrix

function matrix:new(rows)
    if rows and type(rows) == "table" then
        return setmetatable(rows, matrix_meta)
    end
    rows = rows or 4
    local mtx = {}
    for i = 1, rows do
        mtx[i] = {}
        for j = 1, rows do
            mtx[i][j] = i == j and 1 or 0
        end
    end
    return setmetatable(mtx, matrix_meta)
end

setmetatable(matrix, {__call = function(...) return matrix.new(...) end})

function matrix.add(m1, m2)
    local mtx = {}
    for i = 1, #m1 do
        local m3i = {}
        mtx[i] = m3i
        for j = 1, #m1[1] do
            m3i[j] = m1[i][j] + m2[i][j]
        end
    end
    return setmetatable(mtx, matrix_meta)
end

function matrix.sub(m1, m2)
    local mtx = {}
    for i = 1, #m1 do
        local m3i = {}
        mtx[i] = m3i
        for j = 1, #m1[1] do
            m3i[j] = m1[i][j] - m2[i][j]
        end
    end
    return setmetatable(mtx, matrix_meta)
end

function matrix.mul(m1, m2)
    local mtx = {}
    for i = 1, #m1 do
        mtx[i] = {}
        for j = 1, #m2[1] do
            local num = m1[i][1] * m2[1][j]
            for n = 2, #m1[1] do
                num = num + m1[i][n] * m2[n][j]
            end
            mtx[i][j] = num
        end
    end
    return setmetatable(mtx, matrix_meta)
end

function matrix.mulnum(m1, num)
    local mtx = {}
    for i = 1, #m1 do
        mtx[i] = {}
        for j = 1, #m1[1] do
            mtx[i][j] = m1[i][j] * num
        end
    end
    return setmetatable(mtx, matrix_meta)
end

function matrix.divnum(m1, num) return matrix.mulnum(m1, 1 / num) end

function matrix.translate(v)
    local mtx = matrix()
    mtx[1][4] = v.x
    mtx[2][4] = v.y
    mtx[3][4] = v.z
    return mtx
end

function matrix.scale(v)
    local mtx = matrix()
    mtx[1][1] = v.x
    mtx[2][2] = v.y
    mtx[3][3] = v.z
    return mtx
end

function matrix.rotate_x(angle)
    local mtx = matrix()
    mtx[2][2], mtx[2][3] = math.cos(angle), -math.sin(angle)
    mtx[3][2], mtx[3][3] = math.sin(angle), math.cos(angle)
    return mtx
end

function matrix.rotate_y(angle)
    local mtx = matrix()
    mtx[1][1], mtx[1][3] = math.cos(angle), math.sin(angle)
    mtx[3][1], mtx[3][3] = -math.sin(angle), math.cos(angle)
    return mtx
end

function matrix.rotate_z(angle)
    local mtx = matrix()
    mtx[1][1], mtx[1][2] = math.cos(angle), -math.sin(angle)
    mtx[2][1], mtx[2][2] = math.sin(angle), math.cos(angle)
    return mtx
end

function matrix.rotate(v) return matrix.rotate_z(v.z) * matrix.rotate_x(v.x) * matrix.rotate_y(v.y) end

function matrix.transpose(mt)
    local mtx = {}
    for i = 1, #mt[1] do
        mtx[i] = {}
        for j = 1, #mt do
            mtx[i][j] = mt[j][i]
        end
    end
    return setmetatable(mtx, matrix_meta)
end

function matrix.inverse(mtx)
    local n = #mtx
    local unit = {}
    for i = 1, n do
        unit[i] = {}
        for j = 1, n do
            if i == j then
                unit[i][j] = 1
            else
                unit[i][j] = 0
            end
        end
    end

    -- 计算行交换次数
    local row_swap = 0
    for i = 1, n do
        local max = mtx[i][i]
        local index = i
        for j = i + 1, n do
            if math.abs(mtx[j][i]) > math.abs(max) then
                max = mtx[j][i]
                index = j
            end
        end
        if index ~= i then
            row_swap = row_swap + 1
            for j = 1, n do
                mtx[index][j], mtx[i][j] = mtx[i][j], mtx[index][j]
                unit[index][j], unit[i][j] = unit[i][j], unit[index][j]
            end
        end
    end

    -- 计算逆矩阵
    for i = 1, n do
        if mtx[i][i] == 0 then
            error("矩阵不可逆")
        end
        for j = 1, n do
            if i ~= j then
                local factor = mtx[j][i] / mtx[i][i]
                for k = 1, n do
                    mtx[j][k] = mtx[j][k] - factor * mtx[i][k]
                    unit[j][k] = unit[j][k] - factor * unit[i][k]
                end
            end
        end
        for j = 1, n do
            mtx[i][j], unit[i][j] = mtx[i][j] / mtx[i][i], unit[i][j] / mtx[i][i]
        end
    end

    -- 如果行交换，需要交换单位矩阵的行
    if row_swap % 2 == 1 then
        for i = 1, n do
            for j = 1, n do
                unit[i][j] = -unit[i][j]
            end
        end
    end

    return setmetatable(unit, matrix_meta)
end

function matrix.lookat(eye, target, up)
    local forward = eye - target -- 注意opengl观察空间使用的是右手坐标系，z轴向外
    forward = forward:normalize()
    local up = up:normalize()
    local right = vector3.cross(up, forward) -- 注意右手坐标系,right=cross(up,forward),写反会导致x轴反向

    local mtx = matrix()
    mtx[1][1], mtx[1][2], mtx[1][3] = right.x, up.x, forward.x
    mtx[2][1], mtx[2][2], mtx[2][3] = right.y, up.y, forward.y
    mtx[3][1], mtx[3][2], mtx[3][3] = right.z, up.z, forward.z
    return mtx:transpose() * matrix.translate(-eye)
end

function matrix.project(fov, aspect, zNear, zFar)
    local PI = 3.14159265358979323
    local rad = fov * (PI / 180)
    local cothalf = 1 / math.tan(rad / 2)
    local mtx = matrix()
    mtx[1][1], mtx[1][2], mtx[1][3], mtx[1][4] = cothalf / aspect, 0, 0, 0
    mtx[2][1], mtx[2][2], mtx[2][3], mtx[2][4] = 0, cothalf, 0, 0
    mtx[3][1], mtx[3][2], mtx[3][3], mtx[3][4] = 0, 0, -(zFar + zNear) / (zFar - zNear),
        -2 * zFar * zNear / (zFar - zNear)
    mtx[4][1], mtx[4][2], mtx[4][3], mtx[4][4] = 0, 0, -1, 0
    return mtx
end

function matrix.tostring(mtx)
    local ts = {}
    for i = 1, #mtx do
        local tstr = {}
        for j = 1, #mtx[1] do
            tstr[j] = tostring(mtx[i][j])
        end
        ts[i] = table.concat(tstr, "\t")
    end
    return table.concat(ts, "\n")
end

function matrix.array(mtx)
    local arr = {}
    for i = 1, #mtx do
        for j = 1, #mtx[1] do
            arr[#arr + 1] = mtx[i][j]
        end
    end
    return arr
end

function matrix.mat3(mtx)
    local mtx3 = {}
    for i = 1, 3 do
        mtx3[i] = {}
        for j = 1, 3 do
            mtx3[i][j] = mtx[i][j]
        end
    end
    return setmetatable(mtx3, matrix_meta)
end

matrix_meta.__add = matrix.add
matrix_meta.__sub = matrix.sub
matrix_meta.__mul = function(m1, m2)
    if getmetatable(m1) ~= matrix_meta then
        return matrix.mulnum(m2, m1)
    elseif getmetatable(m2) ~= matrix_meta then
        return matrix.mulnum(m1, m2)
    end
    return matrix.mul(m1, m2)
end
matrix_meta.__unm = function(mtx) return matrix.mulnum(mtx, -1) end
matrix_meta.__tostring = matrix.tostring

matrix_meta.__index = {}
for k, v in pairs(matrix) do
    matrix_meta.__index[k] = v
end

return matrix
