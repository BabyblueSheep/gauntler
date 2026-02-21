local sfxManager = SFXManager()

TheGauntlet.Items.Poseidon = {}
TheGauntlet.Items.Poseidon.CollectibleType = Isaac.GetItemIdByName("Poseidon")

local FLOW_SOUND = Isaac.GetSoundIdByName("TheGauntlet Custom Water Flow")

local DEFAULT_CURRENT_SPEED = 0.5
local PLAYER_CURRENT_SPEED = 1

local roomTargetCurrent = Vector.Zero
local waterUpdates = 0
local targetCurrentVolume = 0

TheGauntlet:AddCallback(ModCallbacks.MC_PRE_NEW_ROOM, function (_)
    if not PlayerManager.AnyoneHasCollectible(TheGauntlet.Items.Poseidon.CollectibleType) then return end

    sfxManager:StopLoopingSounds()
    sfxManager:Stop(SoundEffect.SOUND_WATER_FLOW_LOOP)
    sfxManager:Stop(SoundEffect.SOUND_WATER_FLOW_LARGE)
end)

TheGauntlet:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function (_)
    local room = Game():GetRoom()

    if not PlayerManager.AnyoneHasCollectible(TheGauntlet.Items.Poseidon.CollectibleType) then return end

    roomTargetCurrent = TheGauntlet.Utility.RandomCardinalVector(Isaac.GetPlayer():GetCollectibleRNG(TheGauntlet.Items.Poseidon.CollectibleType)) * DEFAULT_CURRENT_SPEED

    room:SetWaterAmount(1)
    room:SetWaterCurrent(roomTargetCurrent)
    targetCurrentVolume = 0

    sfxManager:StopLoopingSounds()
    sfxManager:Stop(SoundEffect.SOUND_WATER_FLOW_LOOP)
    sfxManager:Stop(SoundEffect.SOUND_WATER_FLOW_LARGE)

    sfxManager:SetAmbientSound(FLOW_SOUND, 0, 1)
end)

---@param player EntityPlayer 
TheGauntlet:AddCallback(ModCallbacks.MC_PRE_PLAYER_UPDATE, function (_, player)
    --player:GetData().TheGauntletPoseidonSavedCurrent = Game():GetRoom():GetWaterCurrent()
    if player:HasCollectible(TheGauntlet.Items.Poseidon.CollectibleType) then
        
    end
end)

---@param player EntityPlayer 
TheGauntlet:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function (_, player)
    if player:HasCollectible(TheGauntlet.Items.Poseidon.CollectibleType) then
        
    end
end)

TheGauntlet:AddCallback(ModCallbacks.MC_POST_UPDATE, function (_)
    local room = Game():GetRoom()

    if waterUpdates > 0 then
        waterUpdates = waterUpdates - 1

        local waterAmount = room:GetWaterAmount()
        room:SetWaterAmount(TheGauntlet.Utility.Lerp(waterAmount, 1, 0.25))
    end

    if not PlayerManager.AnyoneHasCollectible(TheGauntlet.Items.Poseidon.CollectibleType) then return end

    local targetCurrent = Vector.Zero

    for _, player in ipairs(PlayerManager.GetPlayers()) do
        if not player:HasCollectible(TheGauntlet.Items.Poseidon.CollectibleType) then goto continue end

        local direction = player:GetAimDirection()
        targetCurrent = targetCurrent + direction * PLAYER_CURRENT_SPEED

        ::continue::
    end

    local shouldBeLoud = true
    if targetCurrent:Length() < 0.01 then
        targetCurrent = roomTargetCurrent
        shouldBeLoud = false
    end

    local currentCurrent = room:GetWaterCurrent()
    room:SetWaterCurrent(currentCurrent:Lerp(targetCurrent, 0.25))

    if shouldBeLoud then
        targetCurrentVolume = targetCurrentVolume + 0.02
    else
        targetCurrentVolume = targetCurrentVolume - 0.02
    end
    targetCurrentVolume = math.min(0.2, math.max(0, targetCurrentVolume))

    sfxManager:SetAmbientSound(FLOW_SOUND, targetCurrentVolume, 1)

    sfxManager:Stop(SoundEffect.SOUND_WATER_FLOW_LOOP)
    sfxManager:Stop(SoundEffect.SOUND_WATER_FLOW_LARGE)
end)

TheGauntlet:AddCallback(ModCallbacks.MC_POST_RENDER, function (_)
    if not PlayerManager.AnyoneHasCollectible(TheGauntlet.Items.Poseidon.CollectibleType) then return end

    sfxManager:Stop(SoundEffect.SOUND_WATER_FLOW_LOOP)
    sfxManager:Stop(SoundEffect.SOUND_WATER_FLOW_LARGE)
end)

---@param collectibleType CollectibleType
---@param charge integer
---@param firstTime boolean
---@param slot integer
---@param varData integer
---@param player EntityPlayer
TheGauntlet:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, function (_, collectibleType, charge, firstTime, slot, varData, player)
    if collectibleType ~= TheGauntlet.Items.Poseidon.CollectibleType then return end

    waterUpdates = 15
end)