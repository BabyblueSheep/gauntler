TheGauntlet.Items.Zeus = {}
TheGauntlet.Items.Zeus.CollectibleType = Isaac.GetItemIdByName("Zeus")
TheGauntlet.Items.Zeus.CollectibleTypeActive = Isaac.GetItemIdByName(" Zeus ")

-- Delay for charges between 2 and 12 will be interpolated based on values below
local DELAY_BETWEEN_LIGHTNING_STRIKES_2_CHARGES = 15
local DELAY_BETWEEN_LIGHTNING_STRIKES_12_CHARGES = 5

---@param collectibleType CollectibleType
---@param charge integer
---@param firstTime boolean
---@param slot integer
---@param varData integer
---@param player EntityPlayer
TheGauntlet:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, function (_, collectibleType, charge, firstTime, slot, varData, player)
    if not player:HasCollectible(TheGauntlet.Items.Zeus.CollectibleType) then return end

    local itemConfig = Isaac.GetItemConfig():GetCollectible(collectibleType)
    if itemConfig.Type == ItemType.ITEM_ACTIVE and itemConfig.InitCharge == -1 and firstTime then
        player:AddActiveCharge(99, slot, true, true)
    end

    if collectibleType == CollectibleType.COLLECTIBLE_SCHOOLBAG then return end
    if collectibleType == TheGauntlet.Items.Zeus.CollectibleTypeActive then return end

    local hasNotZeusInPrimarySlot = player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) ~= 0 and player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) ~= TheGauntlet.Items.Zeus.CollectibleTypeActive
    local hasNotZeusInSecondarySlot = player:GetActiveItem(ActiveSlot.SLOT_SECONDARY) ~= 0 and player:GetActiveItem(ActiveSlot.SLOT_SECONDARY) ~= TheGauntlet.Items.Zeus.CollectibleTypeActive
    local hasNotZeus = hasNotZeusInPrimarySlot or hasNotZeusInSecondarySlot

    if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == 0 then
        player:AddCollectible(TheGauntlet.Items.Zeus.CollectibleTypeActive)

        local hasSchoolbagCostume = false
        for _, costume in ipairs(player:GetCostumeSpriteDescs()) do
            if costume:GetItemConfig().ID == CollectibleType.COLLECTIBLE_SCHOOLBAG then
                hasSchoolbagCostume = true
                break
            end
        end

        player:AddInnateCollectible(CollectibleType.COLLECTIBLE_SCHOOLBAG, 1)
        if not hasSchoolbagCostume then
            player:RemoveCostume(Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_SCHOOLBAG))
        end
    end

    if hasNotZeus then
        player:RemoveCollectible(TheGauntlet.Items.Zeus.CollectibleTypeActive)
        player:AddInnateCollectible(CollectibleType.COLLECTIBLE_SCHOOLBAG, -1)
    end
end)

---@param player EntityPlayer
---@param collectibleType CollectibleType
---@param removeFromPlayerForm boolean
---@param wisp boolean
TheGauntlet:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, function (_, player, collectibleType, removeFromPlayerForm, wisp)
    if not player:HasCollectible(TheGauntlet.Items.Zeus.CollectibleType) then return end

    if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == 0 then
        player:AddCollectible(TheGauntlet.Items.Zeus.CollectibleTypeActive)

        local hasSchoolbagCostume = false
        for _, costume in ipairs(player:GetCostumeSpriteDescs()) do
            if costume:GetItemConfig().ID == CollectibleType.COLLECTIBLE_SCHOOLBAG then
                hasSchoolbagCostume = true
                break
            end
        end

        player:AddInnateCollectible(CollectibleType.COLLECTIBLE_SCHOOLBAG, 1)
        if not hasSchoolbagCostume then
            player:RemoveCostume(Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_SCHOOLBAG))
        end
    end
end)

---@param collectibleType CollectibleType
---@param rng RNG
---@param player EntityPlayer
---@param useFlags UseFlag
---@param slot ActiveSlot
---@param varData integer
TheGauntlet:AddCallback(ModCallbacks.MC_USE_ITEM, function (_, collectibleType, rng, player, useFlags, slot, varData)
    if collectibleType == TheGauntlet.Items.Zeus.CollectibleTypeActive then
        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true
        }
    end
end)

---@param collectibleType CollectibleType
---@param rng RNG
---@param player EntityPlayer
---@param useFlags UseFlag
---@param slot ActiveSlot
---@param varData integer
TheGauntlet:AddPriorityCallback(ModCallbacks.MC_USE_ITEM, CallbackPriority.EARLY, function (_, collectibleType, rng, player, useFlags, slot, varData)
    if not player:HasCollectible(TheGauntlet.Items.Zeus.CollectibleType) then return end

    local ownsItem = (useFlags & UseFlag.USE_OWNED == UseFlag.USE_OWNED) or (useFlags & UseFlag.USE_MIMIC == 0) or (slot == -1)
    if not ownsItem then return end

    local delayBetweenLightningBolts = TheGauntlet.Utility.LerpClamp(DELAY_BETWEEN_LIGHTNING_STRIKES_2_CHARGES, DELAY_BETWEEN_LIGHTNING_STRIKES_12_CHARGES, TheGauntlet.Utility.InverseLerp(2, 12, player:GetTotalActiveCharge(slot)))
    delayBetweenLightningBolts = math.ceil(delayBetweenLightningBolts)
    for i = 1, player:GetActiveCharge(slot) do
        local cooldown = (i - 1) * delayBetweenLightningBolts
        Isaac.CreateTimer(function ()
            Isaac.Spawn
            (
                EntityType.ENTITY_EFFECT, EffectVariant.CRACK_THE_SKY, 0,
                Game():GetRoom():GetRandomPosition(10), Vector.Zero,
                player
            )
        end, cooldown, 1, true)
    end
end)