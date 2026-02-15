---@param min number
---@param max number
---@param rng RNG
---@return number
function TheGauntlet.Utility.RandomFloat(min, max, rng)
    return min + (max - min) * rng:RandomFloat()
end

---@generic T
---@param list T[]
---@param rng RNG
---@return T
function TheGauntlet.Utility.RandomItemFromList(list, rng)
    return list[rng:RandomInt(#list) + 1]
end

--https://gist.github.com/Uradamus/10323382
---@generic T
---@param list T[]
---@param rng RNG
---@return table
function TheGauntlet.Utility.ShuffleList(list, rng)
    local listCopy = {}
    for i = 1, #list do
        listCopy[i] = list[i]
    end
    for i = #listCopy, 2, -1 do
        local j = rng:RandomInt(i) + 1
        listCopy[i], listCopy[j] = listCopy[j], listCopy[i]
    end
    return listCopy
end

---@generic T
---@param list T[]
---@param rng RNG
function TheGauntlet.Utility.ShuffleListInPlace(list, rng)
    for i = #list, 2, -1 do
        local j = rng:RandomInt(i) + 1
        list[i], list[j] = list[j], list[i]
    end
end
