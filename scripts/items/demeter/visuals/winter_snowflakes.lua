local game = Game()

---@class SnowflakeInstances
---@field Position Vector
---@field Size number

---@type SnowflakeInstances[]
local snowflakeInstances = {}

local snowflakeGeneralRng = RNG()

TheGauntlet:AddCallback(ModCallbacks.MC_POST_ROOM_RENDER_ENTITIES, function (_)
    local isPaused = game:IsPaused()

    if snowflakeGeneralRng:RandomFloat() < 0.01 then
        table.insert(snowflakeInstances,
        {

        }
    )
    end

    for i = #snowflakeInstances, 1, -1 do
        if not isPaused then
            
        end
        
    end
end)