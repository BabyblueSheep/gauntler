---Helper function that prints messages to the console with a prefixed mod name.
---@param message string
function TheGauntlet.Utility.Print(message)
    print("["..TheGauntlet.Name.."] "..message)
end

---Helper function that prints warnings to the console and logs them with a prefixed mod name.
---@param message string
function TheGauntlet.Utility.LogWarning(message)
    Console.PrintWarning("["..TheGauntlet.Name.."] "..message)
    Isaac.DebugString("["..TheGauntlet.Name.."] "..message)
end

---Helper function that prints errors to the console and logs them with a prefixed mod name.
---@param message string
function TheGauntlet.Utility.LogError(message)
    Console.PrintError("["..TheGauntlet.Name.."] "..message)
    Isaac.DebugString("["..TheGauntlet.Name.."] "..message)
end