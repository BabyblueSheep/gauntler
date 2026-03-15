---Generates a random decimal number within a range.
---@param min number
---@param max number
---@param rng RNG
---@return number
function TheGauntlet.Utility.RandomFloat(min, max, rng)
    return min + (max - min) * rng:RandomFloat()
end

---Returns a random item from a list.
---@generic T
---@param list T[]
---@param rng RNG
---@return T
function TheGauntlet.Utility.RandomItemFromList(list, rng)
    return list[rng:RandomInt(#list) + 1]
end

---Shuffles items in a list around.<br>
---Creates a copy of the list and returns it.<br>
---https://gist.github.com/Uradamus/10323382
---@generic T
---@param list T[]
---@param rng RNG
---@return table
function TheGauntlet.Utility.ShuffleList(list, rng)
    local listCopy = TheGauntlet.Utility.CopyListShallow(list)
    for i = #listCopy, 2, -1 do
        local j = rng:RandomInt(i) + 1
        listCopy[i], listCopy[j] = listCopy[j], listCopy[i]
    end
    return listCopy
end

---Shuffles items in a list around.<br>
---Modifies the table inputted as the argument.<br>
---https://gist.github.com/Uradamus/10323382
---@generic T
---@param list T[]
---@param rng RNG
function TheGauntlet.Utility.ShuffleListInPlace(list, rng)
    for i = #list, 2, -1 do
        local j = rng:RandomInt(i) + 1
        list[i], list[j] = list[j], list[i]
    end
end
