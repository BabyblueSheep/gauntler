local musicManager = MusicManager()

TheGauntlet.Items.Dionysus = {}
TheGauntlet.Items.Dionysus.CollectibleType = Isaac.GetItemIdByName("Dionysus")

local DRUNK_MOVEMENT_TIME = 30 * 6

local currentDrunkAmount = 0
local previousDrunkAmount = 0
local shouldGetDrunk = false

local drunkTimerOne = 0
local drunkTimerTwo = 0
local drunkTimerThree = 0

TheGauntlet:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, function (_, shaderName)
    if shaderName ~= "TheGauntlet Drunk Distortion" then return end

    local pitchDifferenceTarget = TheGauntlet.Utility.Lerp(0, 0.1, currentDrunkAmount)
    if Isaac.GetFrameCount() % 30 == 0 then
        musicManager:PitchSlide(1 + math.random() * pitchDifferenceTarget)
    end
    if currentDrunkAmount == 0 and previousDrunkAmount ~= 0 then
        musicManager:PitchSlide(1)
    end


    local frequencyOne = TheGauntlet.Utility.Lerp(0, 1 / 40, currentDrunkAmount)
    local frequencyTwo = TheGauntlet.Utility.Lerp(0, 1 / 50, currentDrunkAmount)
    local frequencyThree = TheGauntlet.Utility.Lerp(0, 1 / 60, currentDrunkAmount)

    drunkTimerOne = drunkTimerOne + frequencyOne
    drunkTimerTwo = drunkTimerTwo + frequencyTwo
    drunkTimerThree = drunkTimerThree + frequencyThree



    local amplitudeOne = TheGauntlet.Utility.Lerp(0, 1 / 240, currentDrunkAmount)
    local amplitudeTwo = TheGauntlet.Utility.Lerp(0, 1 / 250, currentDrunkAmount)
    local amplitudeThree = TheGauntlet.Utility.Lerp(0, 1 / 230, currentDrunkAmount)

    previousDrunkAmount = currentDrunkAmount

    return {
        WaveAmplitudes = { amplitudeOne, amplitudeTwo, amplitudeThree, 0 },
        Timers = { drunkTimerOne, drunkTimerTwo + 41, drunkTimerThree + 12, 0 },
        WaveContributionWeights = { 0.4, 0.4, 0.2, 0 }
    }
end)

---@param isContinued boolean
TheGauntlet:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function (_, isContinued)
    currentDrunkAmount = 0
end)

TheGauntlet:AddCallback(ModCallbacks.MC_POST_UPDATE, function (_)
    if shouldGetDrunk then
        currentDrunkAmount = currentDrunkAmount + 0.05
        if currentDrunkAmount >= 1 then
            shouldGetDrunk = false
        end
    else
        currentDrunkAmount = currentDrunkAmount - 0.005
    end
    currentDrunkAmount = TheGauntlet.Utility.Clamp(currentDrunkAmount, 0, 1)
end)

---@param player EntityPlayer
TheGauntlet:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function (_, player)
    local data = player:GetData()
    if data.TheGauntletDionysusDrunkMovementTimer == nil then
        data.TheGauntletDionysusDrunkMovementTimer = 0
    end

    if data.TheGauntletDionysusDrunkMovementTimer > 0 then
        data.TheGauntletDionysusDrunkMovementTimer = data.TheGauntletDionysusDrunkMovementTimer - 1

        player.Velocity = TheGauntlet.Utility.Lerp(player.Velocity, data.TheGauntletDionysusPreviousVelocity, 0.75)
    end

    data.TheGauntletDionysusPreviousVelocity = player.Velocity
end)

---@param entity Entity
---@param damage number
---@param damageFlags DamageFlag
---@param source EntityRef
---@param damageCooldown integer
TheGauntlet:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, function (_, entity, damage, damageFlags, source, damageCooldown)
    local player = entity:ToPlayer()
    if player == nil then return end

    if not player:HasCollectible(TheGauntlet.Items.Dionysus.CollectibleType) then return end

    local data = player:GetData()
    if data.TheGauntletDionysusDrunkMovementTimer == nil then
        data.TheGauntletDionysusDrunkMovementTimer = 0
    end
    data.TheGauntletDionysusDrunkMovementTimer = DRUNK_MOVEMENT_TIME
    data.TheGauntletDionysusPreviousVelocity = player.Velocity

    shouldGetDrunk = true
end)