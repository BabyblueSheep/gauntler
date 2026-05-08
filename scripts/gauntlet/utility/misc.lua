---Creates a shallow copy of a table.
---The table must be in the form of a list (with integer keys and no gaps). 
---@param inputTable table
---@return table
function TheGauntlet.Utility.CopyListShallow(inputTable)
    if type(inputTable) ~= "table" then
		return inputTable
	end

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
    if type(inputTable) ~= "table" then
		return inputTable
	end

    local tableCopy = {}
    for k, v in pairs(inputTable) do
        tableCopy[k] = v
    end
    return tableCopy
end

---Creates a deep copy of a table.
---@param inputTable table
---@return table
function TheGauntlet.Utility.CopyTableDeep(inputTable)
    if type(inputTable) ~= "table" then
		return inputTable
	end

	local tableCopy = {}
	for k, v in pairs(inputTable) do
		tableCopy[k] = TheGauntlet.Utility.CopyTableDeep(v)
	end

	return tableCopy
end

---@param number number
---@return string
function TheGauntlet.Utility.NumberToPresentableNumber(number)
    local value = string.format("%.2f", tostring(number)):gsub("%.?0+$", "")
    return value
end