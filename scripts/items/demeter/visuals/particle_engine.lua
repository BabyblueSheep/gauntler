local game = Game()

---@class ParticleInstance
---@field Type Season
---@field Variant integer
---@field Position Vector
---@field Speed Vector
---@field AccelerationX number
---@field Size number
---@field TimeLeft integer
---@field StartingTime integer

local particleSpawnRoutines = {
    [TheGauntlet.Items.Demeter.Season.WINTER] = include("scripts.items.demeter.visuals.snowflake_spawn"),
    [TheGauntlet.Items.Demeter.Season.SPRING] = include("scripts.items.demeter.visuals.falling_leaf_spawn"),
    [TheGauntlet.Items.Demeter.Season.AUTUMN] = include("scripts.items.demeter.visuals.falling_leaf_spawn"),
}

local particleUpdateRoutines = {
    [TheGauntlet.Items.Demeter.Season.WINTER] = include("scripts.items.demeter.visuals.snowflake_update"),
    [TheGauntlet.Items.Demeter.Season.SPRING] = include("scripts.items.demeter.visuals.falling_leaf_update"),
    [TheGauntlet.Items.Demeter.Season.AUTUMN] = include("scripts.items.demeter.visuals.falling_leaf_update"),
}

local particleRenderRoutines = {
    [TheGauntlet.Items.Demeter.Season.WINTER] = include("scripts.items.demeter.visuals.snowflake_render"),
    [TheGauntlet.Items.Demeter.Season.SPRING] = include("scripts.items.demeter.visuals.falling_leaf_render"),
    [TheGauntlet.Items.Demeter.Season.AUTUMN] = include("scripts.items.demeter.visuals.falling_leaf_render"),
}

---@type ParticleInstance[]
local particleInstances = {}

local particleGeneralRng = RNG()
local timeUntilNextParticle = 0

TheGauntlet:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function (_)
    particleInstances = {}
end)

TheGauntlet:AddCallback(ModCallbacks.MC_POST_ROOM_RENDER_ENTITIES, function (_)
    local season = TheGauntlet.Items.Demeter.GetSeason()

    if season == TheGauntlet.Items.Demeter.Season.NO_SEASON then return end
    if season == TheGauntlet.Items.Demeter.Season.SUMMER then return end

    local room = game:GetRoom()

    local isPaused = game:IsPaused()

    local topLeft = room:GetTopLeftPos()
    local bottomRight = room:GetBottomRightPos()
    local renderOffset = room:GetRenderScrollOffset()

    timeUntilNextParticle = timeUntilNextParticle - 1

    if not isPaused and timeUntilNextParticle <= 0 then
        timeUntilNextParticle = particleGeneralRng:RandomInt(5, 15)

        table.insert(particleInstances, particleSpawnRoutines[season](topLeft, bottomRight)
    )
    end

    for i = #particleInstances, 1, -1 do
        local instance = particleInstances[i]
        if not isPaused then
            particleUpdateRoutines[instance.Type](instance)

            instance.TimeLeft = instance.TimeLeft - 1
            if instance.TimeLeft < 0 then
                table.remove(particleInstances, i)
            end
        end
        
        particleRenderRoutines[instance.Type](instance, renderOffset)
    end
end)