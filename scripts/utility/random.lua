---@generic T
---@param list T[]
---@param rng RNG
---@return T
function TheGauntlet.Utility.RandomItemFromList(rng, list)
    return list[rng:RandomInt(#list) + 1]
end