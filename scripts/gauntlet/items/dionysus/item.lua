TheGauntlet.Items.Dionysus.Constants = {
    DRUNK_DURATION_ON_HIT_FRAMES = 30 * 6,
    DRUNK_SLIPPERINESS = 0.75,
}



local game = Game()

TheGauntlet.Items.Dionysus.COLLECTIBLE_TYPE = Isaac.GetItemIdByName("Dionysus")

---Forces slippery physics for some duration.
---@param player EntityPlayer
---@param duration integer
---@param additive boolean?
function TheGauntlet.Items.Dionysus.ForcePlayerDrunk(player, duration, additive)
    local data = TheGauntlet.DataHolder.GetTemporaryData(player)
    if additive then
        data.Dionysus.DrunkMovementTimer = data.TheGauntletDionysusDrunkMovementTimer + duration
    else
        data.Dionysus.DrunkMovementTimer = duration
    end
    data.Dionysus.PreviousVelocity = player.Velocity
end

TheGauntlet:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    if TheGauntlet.Settings.RemoveDionysus() then
        game:GetItemPool():AddRoomBlacklist(TheGauntlet.Items.Dionysus.COLLECTIBLE_TYPE)
    end
end)

---@param player EntityPlayer
TheGauntlet:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function (_, player)
    local data = TheGauntlet.DataHolder.GetTemporaryData(player)
    data.Dionysus = {
        DrunkMovementTimer = 0,
        PreviousVelocity = Vector.Zero
    }
end)

---@param player EntityPlayer
TheGauntlet:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function (_, player)
    local data = TheGauntlet.DataHolder.GetTemporaryData(player)

    if data.Dionysus.DrunkMovementTimer > 0 then
        data.Dionysus.DrunkMovementTimer = data.Dionysus.DrunkMovementTimer - 1

        player.Velocity = TheGauntlet.Utility.Lerp(player.Velocity, data.Dionysus.PreviousVelocity, TheGauntlet.Items.Dionysus.Constants.DRUNK_SLIPPERINESS)
    end

    data.Dionysus.PreviousVelocity = player.Velocity
end)

---@param entity Entity
---@param damage number
---@param damageFlags DamageFlag
---@param source EntityRef
---@param damageCooldown integer
---@param extraSource EntityRef
TheGauntlet:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, function (_, entity, damage, damageFlags, source, damageCooldown, extraSource)
    local player = entity:ToPlayer()
    if player == nil then return end

    if not player:HasCollectible(TheGauntlet.Items.Dionysus.COLLECTIBLE_TYPE) then return end

    TheGauntlet.Items.Dionysus.ForcePlayerDrunk(player, TheGauntlet.Items.Dionysus.Constants.DRUNK_DURATION_ON_HIT_FRAMES)
end)