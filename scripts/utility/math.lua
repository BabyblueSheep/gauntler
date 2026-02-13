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
    local result = a + (b - a) * t
    return math.max(math.min(a, b), math.min(math.max(a, b), result))
end

---@param a number
---@param b number
---@param t number
---@param clamp boolean?
function TheGauntlet.Utility.InverseLerp(a, b, t, clamp)
    local result = (t - a) / (b - a)
    if clamp == true or clamp == nil then
        return math.min(1, math.max(0, result))
    end
    return result
end