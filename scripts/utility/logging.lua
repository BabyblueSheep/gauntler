---@param message string
function TheGauntlet.Utility.Print(message)
    print("["..TheGauntlet.Name.."] "..message)
end

---@param message string
function TheGauntlet.Utility.LogWarning(message)
    Console.PrintWarning("["..TheGauntlet.Name.."] "..message)
    Isaac.DebugString("["..TheGauntlet.Name.."] "..message)
end

---@param message string
function TheGauntlet.Utility.LogError(message)
    Console.PrintError("["..TheGauntlet.Name.."] "..message)
    Isaac.DebugString("["..TheGauntlet.Name.."] "..message)
end