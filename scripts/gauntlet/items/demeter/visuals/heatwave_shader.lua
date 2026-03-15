local summerFadeTimer = 0

local waveTimer = 0

---@param isContinued boolean
TheGauntlet:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function (_, isContinued)
    summerFadeTimer = 0
end)

TheGauntlet:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, function (_, shaderName)
    if TheGauntlet.Items.Demeter.GetSeason() == TheGauntlet.Items.Demeter.Season.SUMMER then
        summerFadeTimer = summerFadeTimer + 0.02
        if summerFadeTimer > 1 then
            summerFadeTimer = 1
        end
    else
        summerFadeTimer = summerFadeTimer - 0.02
        if summerFadeTimer < 0 then
            summerFadeTimer = 0

            waveTimer = 0
        end
    end

    local waveAmplitude = TheGauntlet.Utility.Lerp(0, 0.001, summerFadeTimer)
    local waveFrequency = 64--TheGauntlet.Utility.Lerp(0, 32, summerFadeTimer) Frequency doesn't change to avoid weirdly fast transitions

    local waveSpeed = TheGauntlet.Utility.Lerp(0, 0.01, summerFadeTimer)
    waveTimer = waveTimer + waveSpeed

    if shaderName ~= "TheGauntlet Heat Wave" then return end

    return {
        Timer = waveTimer,
        Amplitude = waveAmplitude,
        Frequency = waveFrequency
    }
end)