local DRUNK_DURATION_ON_HIT = 30 * 6
local DRUNK_SLIPPERINESS = 0.75



TheGauntlet.Items.Dionysus.CollectibleType = Isaac.GetItemIdByName("Dionysus")

---@param player EntityPlayer
TheGauntlet:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function (_, player)
    local data = player:GetData()

    data.TheGauntletDionysusDrunkMovementTimer = 0
    data.TheGauntletDionysusPreviousVelocity = Vector.Zero
end)

---@param player EntityPlayer
TheGauntlet:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function (_, player)
    local data = player:GetData()

    if data.TheGauntletDionysusDrunkMovementTimer > 0 then
        data.TheGauntletDionysusDrunkMovementTimer = data.TheGauntletDionysusDrunkMovementTimer - 1

        player.Velocity = TheGauntlet.Utility.Lerp(player.Velocity, data.TheGauntletDionysusPreviousVelocity, DRUNK_SLIPPERINESS)
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
    data.TheGauntletDionysusDrunkMovementTimer = DRUNK_DURATION_ON_HIT
    data.TheGauntletDionysusPreviousVelocity = player.Velocity
end)