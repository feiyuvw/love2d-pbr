local vector3 = {}
local vector3_meta = {}

function vector3.new(a, b, c)
    local vec = {x = a or 0, y = b or 0, z = c or 0}
    return setmetatable(vec, vector3_meta)
end

setmetatable(vector3, {__call = function(_, a, b, c) return vector3.new(a, b, c) end})

function vector3.toString(v) return "vector3(" .. v.x .. "," .. v.y .. "," .. v.z .. ")" end

function vector3.add(v1, v2)
    local vec = {x = v1.x + v2.x, y = v1.y + v2.y, z = v1.z + v2.z}
    return setmetatable(vec, vector3_meta)
end

function vector3.subtract(v1, v2)
    local vec = {x = v1.x - v2.x, y = v1.y - v2.y, z = v1.z - v2.z}
    return setmetatable(vec, vector3_meta)
end

function vector3.mulNum(v, num)
    local vec = {x = v.x * num, y = v.y * num, z = v.z * num}
    return setmetatable(vec, vector3_meta)
end

function vector3.dev(v, num) return v * (1 / num) end

function vector3.len(v) return math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z) end

function vector3.normalize(v)
    local mag = vector3.len(v)
    local vec = {x = v.x, y = v.y, z = v.z}
    if mag > 0 then
        vec.x = vec.x / mag
        vec.y = vec.y / mag
        vec.z = vec.z / mag
    end
    return setmetatable(vec, vector3_meta)
end

function vector3.dot(v1, v2)
    local rst = v1.x * v2.x + v1.y * v2.y + v1.z * v2.z
    return rst
end

function vector3.cross(v1, v2)
    local vec = {x = v1.y * v2.z - v1.z * v2.y, y = v1.z * v2.x - v1.x * v2.z, z = v1.x * v2.y - v1.y * v2.x}
    return setmetatable(vec, vector3_meta)
end

function vector3.array(v) return {v.x, v.y, v.z} end

function vector3.unpack(v) return v.x, v.y, v.z end

vector3_meta.__tostring = vector3.toString
vector3_meta.__add = vector3.add
vector3_meta.__sub = vector3.subtract
vector3_meta.__mul = function(v1, v2)
    if getmetatable(v1) ~= vector3_meta then
        return vector3.mulNum(v2, v1)
    elseif getmetatable(v2) ~= vector3_meta then
        return vector3.mulNum(v1, v2)
    end
    return vector3.dot(v1, v2)
end
vector3_meta.__div = vector3.dev
vector3_meta.__unm = function(v) return vector3.mulNum(v, -1) end

vector3_meta.__index = {}
for k, v in pairs(vector3) do
    vector3_meta.__index[k] = v
end

return vector3
