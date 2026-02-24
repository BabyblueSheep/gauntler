TheGauntlet.Items.Hephaestus = {}
TheGauntlet.Items.Hephaestus.CollectibleType = Isaac.GetItemIdByName("Hephaestus")

TheGauntlet.Items.Hephaestus.GoldenPickups = {
    {
        Type = EntityType.ENTITY_PICKUP,
        Variant = PickupVariant.PICKUP_BOMB,
        SubType = BombSubType.BOMB_GOLDEN,
        Condition = function() return Isaac.GetPersistentGameData():Unlocked(Achievement.GOLDEN_BOMBS) end
    },
    {
        Type = EntityType.ENTITY_PICKUP,
        Variant = PickupVariant.PICKUP_KEY,
        SubType = KeySubType.KEY_GOLDEN,
        Condition = function() return true end
    },
    {
        Type = EntityType.ENTITY_PICKUP,
        Variant = PickupVariant.PICKUP_HEART,
        SubType = HeartSubType.HEART_GOLDEN,
        Condition = function() return Isaac.GetPersistentGameData():Unlocked(Achievement.GOLDEN_HEARTS) end
    },
    {
        Type = EntityType.ENTITY_PICKUP,
        Variant = PickupVariant.PICKUP_COIN,
        SubType = CoinSubType.COIN_GOLDEN,
        Condition = function() return Isaac.GetPersistentGameData():Unlocked(Achievement.GOLDEN_PENNY) end
    },
    {
        Type = EntityType.ENTITY_PICKUP,
        Variant = PickupVariant.PICKUP_LIL_BATTERY,
        SubType = BatterySubType.BATTERY_GOLDEN,
        Condition = function() return Isaac.GetPersistentGameData():Unlocked(Achievement.GOLDEN_BATTERY) end
    },
    {
        Type = EntityType.ENTITY_PICKUP,
        Variant = PickupVariant.PICKUP_PILL,
        SubType = PillColor.PILL_GOLD,
        Condition = function() return Isaac.GetPersistentGameData():Unlocked(Achievement.GOLDEN_PILLS) end
    },
}

---@param collectibleType CollectibleType
---@param charge integer
---@param firstTime boolean
---@param slot integer
---@param varData integer
---@param player EntityPlayer
TheGauntlet:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, function (_, collectibleType, charge, firstTime, slot, varData, player)
    local room = Game():GetRoom()

    local spawnPosition = room:FindFreePickupSpawnPosition(player.Position, 0, true)

    ---@type EntityPickup
    ---@diagnostic disable-next-line assign-type-mismatch
    local trinket = Isaac.Spawn
    (
        EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, 0,
        spawnPosition, Vector.Zero, nil
    ):ToPickup()

    if Isaac.GetPersistentGameData():Unlocked(Achievement.GOLDEN_TRINKET) then
        trinket:Morph(
            EntityType.ENTITY_PICKUP,
            PickupVariant.PICKUP_TRINKET,
            trinket.SubType | TrinketType.TRINKET_GOLDEN_FLAG,
            true,
            true
        )
    end
end, TheGauntlet.Items.Hephaestus.CollectibleType)

TheGauntlet:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function (_)
    if not PlayerManager.AnyoneHasCollectible(TheGauntlet.Items.Hephaestus.CollectibleType) then return end
    
    local room = Game():GetRoom()

    local spawnPosition = room:FindFreePickupSpawnPosition(room:GetCenterPos(), nil, true)

    local rng = Isaac.GetPlayer(0):GetCollectibleRNG(TheGauntlet.Items.Hephaestus.CollectibleType)

    local goldenPickupEntry = nil
    while goldenPickupEntry == nil do
        local randomGoldenPickupEntry = TheGauntlet.Utility.RandomItemFromList(TheGauntlet.Items.Hephaestus.GoldenPickups, rng)
        if randomGoldenPickupEntry.Condition() then
            goldenPickupEntry = randomGoldenPickupEntry
        end
    end

    Isaac.Spawn
    (
        goldenPickupEntry.Type, goldenPickupEntry.Variant, goldenPickupEntry.SubType,
        spawnPosition, Vector.Zero, nil
    )
end)
