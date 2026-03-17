---Clamps a value to a minimum and maximum value.
---@param x number
---@param min number
---@param max number
---@return number
function TheGauntlet.Utility.Clamp(x, min, max)
    return math.max(min, math.min(x, max))
end

---Does linear interpolation between a and b, based on the t.
---@generic T : integer|Vector
---@param a T
---@param b T
---@param t number
---@return T
function TheGauntlet.Utility.Lerp(a, b, t)
    local result = a + (b - a) * t
    return result
end

---Does linear interpolation between a and b, based on the t.<br>
---In addition, the returned value is clamped between a and b.
---@param a number
---@param b number
---@param t number
---@return number
function TheGauntlet.Utility.LerpClamp(a, b, t)
    t = TheGauntlet.Utility.Clamp(t, 0, 1)
    local result = a + (b - a) * t
    return result
end

---Determines where t lies between a and b.
---@param a number
---@param b number
---@param t number
---@param clamp boolean? Whether to cland the returned value between 0 and 1.
function TheGauntlet.Utility.InverseLerp(a, b, t, clamp)
    local result = (t - a) / (b - a)
    if clamp == true or clamp == nil then
        return TheGauntlet.Utility.Clamp(result, 0, 1)
    end
    return result
end

---Returns the difference between 2 angles.
---@param a number
---@param b number
---@return number
function TheGauntlet.Utility.AngleDifference(a, b)
    local difference = math.fmod(b - a, math.pi * 2)
    return math.fmod(2.0 * difference, math.pi * 2) - difference;
end

---Does linear interpolation between a and b, based on the t.<br>
---Treats a and b as angles, meaning interpolation can happen in reverse if the angle difference is closer in that way.
---https://github.com/godotengine/godot/blob/29d2c7ece514127cc449ce37994ef4b369a3a9c6/core/math/math_funcs.h#L490
---@param a number
---@param b number
---@param t number
---@return number
function TheGauntlet.Utility.LerpAngle(a, b, t)
    return a + TheGauntlet.Utility.AngleDifference(a, b) * t
end

local CARDINAL_DIRECTIONS = {
    Vector(1, 0),
    Vector(-1, 0),
    Vector(0, 1),
    Vector(0, -1)
}

---Returns a random [Vector](lua://Vector) that faces in a cardinal direction.
---@param rng RNG
---@return Vector
function TheGauntlet.Utility.RandomCardinalVector(rng)
    return TheGauntlet.Utility.RandomItemFromList(CARDINAL_DIRECTIONS, rng)
end

---Determines whether a number is an integer or not.
---@param number number
---@return boolean
function TheGauntlet.Utility.IsInteger(number)
    return tonumber(tostring(number), 10) ~= nil
end