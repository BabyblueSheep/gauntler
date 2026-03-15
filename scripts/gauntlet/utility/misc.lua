---Creates a shallow copy of a table.
---The table must be in the form of a list (with integer keys and no gaps). 
---@param inputTable table
---@return table
function TheGauntlet.Utility.CopyListShallow(inputTable)
    local tableCopy = {}
    for i = 1, #inputTable do
        tableCopy[i] = inputTable[i]
    end
    return tableCopy
end

---Creates a shallow copy of a table.
---@param inputTable table
---@return table
function TheGauntlet.Utility.CopyTableShallow(inputTable)
    local tableCopy = {}
    for k, v in pairs(inputTable) do
        tableCopy[k] = v
    end
    return tableCopy
end