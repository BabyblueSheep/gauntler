---@param inputTable table
---@return table
function TheGauntlet.Utility.CopyTable(inputTable)
    local tableCopy = {}
    for i = 1, #inputTable do
        tableCopy[i] = inputTable[i]
    end
    return tableCopy
end