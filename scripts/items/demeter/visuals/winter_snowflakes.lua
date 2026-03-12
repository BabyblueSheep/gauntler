local game = Game()

---@class SnowflakeInstance
---@field Position Vector
---@field Speed Vector
---@field AccelerationX number
---@field Size number
---@field TimeLeft integer
---@field StartingTime integer

---@type SnowflakeInstance[]
local snowflakeInstances = {}

local snowflakeGeneralRng = RNG()
local timeUntilNextSnowflake = 0

local snowflakeSprite = Sprite("gfx/gauntlet/effects/snowflake.anm2", true)
snowflakeSprite:SetFrame("Idle", 0)

---@param instance SnowflakeInstance
local function UpdateSnowflake(instance)
    instance.Position = instance.Position + instance.Speed
    instance.Speed.X = instance.Speed.X + instance.AccelerationX
    instance.Speed.X = TheGauntlet.Utility.Clamp(instance.Speed.X, -0.2, 0.2)

    instance.TimeLeft = instance.TimeLeft - 1
end

---@param instance SnowflakeInstance
local function RenderSnowflake(instance)
    local fadeIn = TheGauntlet.Utility.InverseLerp(instance.StartingTime, instance.StartingTime - 30, instance.TimeLeft)
    local fadeOut = TheGauntlet.Utility.InverseLerp(0, 30, instance.TimeLeft)

    local alpha = fadeIn * fadeOut

    snowflakeSprite.Color.A = alpha
    snowflakeSprite.Scale.X = instance.Size
    snowflakeSprite.Scale.Y = instance.Size
    snowflakeSprite:Render(Isaac.WorldToRenderPosition(instance.Position) + snowflakeSprite.Offset)
end

TheGauntlet:AddCallback(ModCallbacks.MC_POST_ROOM_RENDER_ENTITIES, function (_)
    local season = TheGauntlet.Items.Demeter.GetSeason()

    local isPaused = game:IsPaused()

    timeUntilNextSnowflake = timeUntilNextSnowflake - 1

    if not isPaused and timeUntilNextSnowflake <= 0 and season == TheGauntlet.Items.Demeter.Season.WINTER then
        timeUntilNextSnowflake = snowflakeGeneralRng:RandomInt(10, 30)

        local startTimer = snowflakeGeneralRng:RandomInt(60 * 3, 60 * 4)

        table.insert(snowflakeInstances,
        {
            Position = Vector
            (
                TheGauntlet.Utility.RandomFloat(0, Isaac.GetScreenWidth(), snowflakeGeneralRng),
                TheGauntlet.Utility.RandomFloat(0, Isaac.GetScreenHeight() * 0.25, snowflakeGeneralRng)
            ),

            Speed = Vector
            (
                TheGauntlet.Utility.RandomFloat(-0.2, 0.2, snowflakeGeneralRng),
                TheGauntlet.Utility.RandomFloat(0, 3, snowflakeGeneralRng)
            ),
            AccelerationX = TheGauntlet.Utility.RandomFloat(-0.01, 0.01, snowflakeGeneralRng),

            Size = TheGauntlet.Utility.RandomFloat(0.2, 0.25, snowflakeGeneralRng),

            TimeLeft = startTimer,
            StartingTime = startTimer
        }
    )
    end

    for i = #snowflakeInstances, 1, -1 do
        local instance = snowflakeInstances[i]
        if not isPaused then
            UpdateSnowflake(instance)

            if instance.TimeLeft < 0 then
                table.remove(snowflakeInstances, i)
            end
        end
        
        RenderSnowflake(instance)
    end
end)