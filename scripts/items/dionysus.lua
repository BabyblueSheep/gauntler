local musicManager = MusicManager()

TheGauntlet.Items.Dionysus = {}
TheGauntlet.Items.Dionysus.CollectibleType = Isaac.GetItemIdByName("Dionysus")

local currentDrunkAmount = 0
local previousDrunkAmount = 0

local drunkTimerOne = 0
local drunkTimerTwo = 0
local drunkTimerThree = 0

TheGauntlet:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, function (_, shaderName)
    if shaderName ~= "TheGauntlet Drunk Distortion" then return end

    if PlayerManager.AnyoneHasCollectible(TheGauntlet.Items.Dionysus.CollectibleType) then
        currentDrunkAmount = currentDrunkAmount + 0.01
    else
        currentDrunkAmount = currentDrunkAmount - 0.01
        if currentDrunkAmount < 0 then
            currentDrunkAmount = 0
        end
    end
    currentDrunkAmount = TheGauntlet.Utility.Clamp(currentDrunkAmount, 0, 1)


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