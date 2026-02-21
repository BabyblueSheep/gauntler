local sfxManager = SFXManager()

TheGauntlet.Items.Poseidon = {}
TheGauntlet.Items.Poseidon.CollectibleType = Isaac.GetItemIdByName("Poseidon")

local FLOW_SOUND = Isaac.GetSoundIdByName("TheGauntlet Custom Water Flow")

local EPSILON = 0.01

local ENEMY_FLOW_SPEED = 10
local PICKUP_FLOW_SPEED = 0.5

local actualWaterCurrent = Vector.Zero
local targetCurrent = Vector.Zero
local fakeCurrentWaterCurrent = Vector.Zero

local waterUpdates = 0
local targetCurrentVolume = 0

TheGauntlet:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function (_)
    if Game():GetLevel():GetCurrentRoomDesc().Data.Type == RoomType.ROOM_DUNGEON then return end
    
    local room = Game():GetRoom()

    if not PlayerManager.AnyoneHasCollectible(TheGauntlet.Items.Poseidon.CollectibleType) then return end

    fakeCurrentWaterCurrent = Vector(EPSILON, EPSILON)

    room:SetWaterAmount(1)
    room:SetWaterCurrent(Vector.Zero)
    targetCurrentVolume = 0

    sfxManager:SetAmbientSound(FLOW_SOUND, 0, 1)
end)

TheGauntlet:AddCallback(ModCallbacks.MC_POST_UPDATE, function (_)
    if Game():GetLevel():GetCurrentRoomDesc().Data.Type == RoomType.ROOM_DUNGEON then return end
    
    local room = Game():GetRoom()

    if waterUpdates > 0 then
        waterUpdates = waterUpdates - 1

        local waterAmount = room:GetWaterAmount()
        room:SetWaterAmount(TheGauntlet.Utility.Lerp(waterAmount, 1, 0.25))
    end

    if not PlayerManager.AnyoneHasCollectible(TheGauntlet.Items.Poseidon.CollectibleType) then return end

    targetCurrent = Vector.Zero

    for _, player in ipairs(PlayerManager.GetPlayers()) do
        if not player:HasCollectible(TheGauntlet.Items.Poseidon.CollectibleType) then goto continue end

        local direction = Isaac.GetAxisAlignedUnitVectorFromDir(player:GetFireDirection())
        targetCurrent = targetCurrent + direction

        ::continue::
    end

    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity.Mass >= 100 then goto continue end

        if entity:IsEnemy() then
            if entity:IsFlying() then goto continue end

            entity:AddVelocity(targetCurrent * ENEMY_FLOW_SPEED / entity.Mass)
        elseif entity.Type == EntityType.ENTITY_PICKUP then
            entity:AddVelocity(targetCurrent * PICKUP_FLOW_SPEED)
        end

        ::continue::
    end

    local shouldBeLoud = true
    if targetCurrent:Length() < EPSILON then
        shouldBeLoud = false
    end

    if shouldBeLoud then
        targetCurrentVolume = targetCurrentVolume + 0.02
    else
        targetCurrentVolume = targetCurrentVolume - 0.02
    end
    targetCurrentVolume = math.min(0.2, math.max(0, targetCurrentVolume))

    sfxManager:SetAmbientSound(FLOW_SOUND, targetCurrentVolume, 1)
end)


TheGauntlet:AddCallback(ModCallbacks.MC_PRE_RENDER, function (_)
    if Game():GetLevel():GetCurrentRoomDesc().Data.Type == RoomType.ROOM_DUNGEON then return end

    if not PlayerManager.AnyoneHasCollectible(TheGauntlet.Items.Poseidon.CollectibleType) then return end

    local room = Game():GetRoom()
    actualWaterCurrent = room:GetWaterCurrent()

    fakeCurrentWaterCurrent = fakeCurrentWaterCurrent:Lerp(targetCurrent, 0.25)
    if fakeCurrentWaterCurrent:Length() < EPSILON then
        fakeCurrentWaterCurrent = Vector(EPSILON, EPSILON)
    end
    room:SetWaterCurrent(fakeCurrentWaterCurrent)
end)

TheGauntlet:AddCallback(ModCallbacks.MC_POST_RENDER, function (_)
    if Game():GetLevel():GetCurrentRoomDesc().Data.Type == RoomType.ROOM_DUNGEON then return end

    if not PlayerManager.AnyoneHasCollectible(TheGauntlet.Items.Poseidon.CollectibleType) then return end

    local room = Game():GetRoom()
    room:SetWaterCurrent(actualWaterCurrent)
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