---@param x number
---@param min number
---@param max number
---@return number
function TheGauntlet.Utility.Clamp(x, min, max)
    return math.max(min, math.min(x, max))
end

---@generic T : integer|Vector
---@param a T
---@param b T
---@param t number
---@return T
function TheGauntlet.Utility.Lerp(a, b, t)
    local result = a + (b - a) * t
    return result
end

---@param a number
---@param b number
---@param t number
---@return number
function TheGauntlet.Utility.LerpClamp(a, b, t)
    t = TheGauntlet.Utility.Clamp(t, 0, 1)
    local result = a + (b - a) * t
    return result
end

---@param a number
---@param b number
---@param t number
---@param clamp boolean?
function TheGauntlet.Utility.InverseLerp(a, b, t, clamp)
    local result = (t - a) / (b - a)
    if clamp == true or clamp == nil then
        return TheGauntlet.Utility.Clamp(result, 0, 1)
    end
    return result
end

local CARDINAL_DIRECTIONS = {
    Vector(1, 0),
    Vector(-1, 0),
    Vector(0, 1),
    Vector(0, -1)
}

---@param rng RNG
---@return Vector
function TheGauntlet.Utility.RandomCardinalVector(rng)
    return TheGauntlet.Utility.RandomItemFromList(CARDINAL_DIRECTIONS, rng)
end