TheGauntlet.Items.Poseidon = {}

TheGauntlet.Items.Poseidon.Constants = {
    FLOW_STRENGTH_DAMP_IF_ABOVE_BASE_LENGTH = 0.5,

    ENEMY_FLOW_SPEED_BASE = 1,
    ENEMY_FLOW_SPEED_STAGE = 0.05,
    PICKUP_FLOW_SPEED = 0.5,
}



local game = Game()
local sfxManager = SFXManager()

TheGauntlet.Items.Poseidon.COLLECTIBLE_TYPE = Isaac.GetItemIdByName("Poseidon")

local FLOW_SOUND = Isaac.GetSoundIdByName("TheGauntlet Custom Water Flow")

--The water shader usedHourglass has transition between flowing and still water.
--So, an epsilon is used to force there to technically always be a current.
local EPSILON = 0.01

local actualWaterCurrent = Vector.Zero
local targetCurrent = Vector.Zero
local fakeCurrentWaterCurrent = Vector.Zero

local didAnyoneHavePoseidonThisRoom = false
local framesLeftToUpdateVisualWater = 0
local targetCurrentVolume = 0



TheGauntlet:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function (_)
    if game:GetLevel():GetCurrentRoomDesc().Data.Type == RoomType.ROOM_DUNGEON then return end

    local room = game:GetRoom()

    didAnyoneHavePoseidonThisRoom = PlayerManager.AnyoneHasCollectible(TheGauntlet.Items.Poseidon.COLLECTIBLE_TYPE)

    if not didAnyoneHavePoseidonThisRoom then return end

    fakeCurrentWaterCurrent = Vector(EPSILON, EPSILON)

    room:SetWaterAmount(1)
    room:SetWaterCurrent(fakeCurrentWaterCurrent)
    targetCurrentVolume = 0

    sfxManager:SetAmbientSound(FLOW_SOUND, 0, 1)
end)

TheGauntlet:AddCallback(ModCallbacks.MC_POST_UPDATE, function (_)
    if game:GetLevel():GetCurrentRoomDesc().Data.Type == RoomType.ROOM_DUNGEON then return end

    if PlayerManager.AnyoneHasCollectible(TheGauntlet.Items.Poseidon.COLLECTIBLE_TYPE) then
        didAnyoneHavePoseidonThisRoom = true
    end

    local room = game:GetRoom()

    if framesLeftToUpdateVisualWater > 0 then
        framesLeftToUpdateVisualWater = framesLeftToUpdateVisualWater - 1

        local waterAmount = room:GetWaterAmount()
        room:SetWaterAmount(TheGauntlet.Utility.Lerp(waterAmount, 1, 0.25))
        room:SetWaterCurrent(Vector.Zero)
        targetCurrentVolume = 0

        if framesLeftToUpdateVisualWater == 0 then
            room:SetWaterAmount(1)
            room:SetWaterCurrent(Vector.Zero)
            targetCurrentVolume = 0
        end
    end

    if didAnyoneHavePoseidonThisRoom then
        room:SetWaterCurrent(Vector.Zero)
    end

    targetCurrent = Vector.Zero

    for _, player in ipairs(PlayerManager.GetPlayers()) do
        if not player:HasCollectible(TheGauntlet.Items.Poseidon.COLLECTIBLE_TYPE) then goto continue end

        local direction = Isaac.GetAxisAlignedUnitVectorFromDir(player:GetFireDirection())
        targetCurrent = targetCurrent + direction * player:GetCollectibleNum(TheGauntlet.Items.Poseidon.COLLECTIBLE_TYPE)

        ::continue::
    end

    if targetCurrent:Length() > 1 then
        targetCurrent = targetCurrent:Resized(1 + (targetCurrent:Length() - 1) * TheGauntlet.Items.Poseidon.Constants.FLOW_STRENGTH_DAMP_IF_ABOVE_BASE_LENGTH)
    end

    if targetCurrent:Length() > EPSILON then
        for _, entity in ipairs(Isaac.GetRoomEntities()) do
            if entity.Mass >= 100 then goto continue end

            if entity:IsEnemy() then
                if entity:IsFlying() then goto continue end
                if entity:IsBoss() then goto continue end

                local pushSpeed = (TheGauntlet.Items.Poseidon.Constants.ENEMY_FLOW_SPEED_BASE + game:GetLevel():GetStage() * TheGauntlet.Items.Poseidon.Constants.ENEMY_FLOW_SPEED_STAGE)
                entity:AddVelocity(targetCurrent * pushSpeed, true)
            elseif entity.Type == EntityType.ENTITY_PICKUP or entity.Type == EntityType.ENTITY_BOMB then
                if entity.Type == EntityType.ENTITY_BOMB then
                    if entity.Variant == BombVariant.BOMB_ROCKET or entity.Variant == BombVariant.BOMB_ROCKET_GIGA then goto continue end
                end

                entity:AddVelocity(targetCurrent * TheGauntlet.Items.Poseidon.Constants.PICKUP_FLOW_SPEED, true)
            end

            ::continue::
        end
    end

    targetCurrent = targetCurrent:Normalized()

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
    if not Isaac.IsInGame() then return end

    if game:GetLevel():GetCurrentRoomDesc().Data.Type == RoomType.ROOM_DUNGEON then return end

    local room = game:GetRoom()
    actualWaterCurrent = room:GetWaterCurrent()

    if not didAnyoneHavePoseidonThisRoom then return end

    fakeCurrentWaterCurrent = fakeCurrentWaterCurrent:Lerp(targetCurrent, 0.25)
    if fakeCurrentWaterCurrent:Length() < EPSILON then
        fakeCurrentWaterCurrent = Vector(EPSILON, EPSILON)
    end
    room:SetWaterCurrent(fakeCurrentWaterCurrent)
end)

TheGauntlet:AddCallback(ModCallbacks.MC_POST_RENDER, function (_)
    if game:GetLevel():GetCurrentRoomDesc().Data.Type == RoomType.ROOM_DUNGEON then return end

    if not didAnyoneHavePoseidonThisRoom then return end

    local room = game:GetRoom()
    room:SetWaterCurrent(actualWaterCurrent)
end)

---@param player EntityPlayer
---@param collectibleType CollectibleType
---@param firstTime boolean
---@param wispOrInnate boolean
TheGauntlet:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_ADDED, function (_, player, collectibleType, firstTime, wispOrInnate)
    framesLeftToUpdateVisualWater = 15
end, TheGauntlet.Items.Poseidon.COLLECTIBLE_TYPE)