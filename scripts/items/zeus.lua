TheGauntlet.Items.Zeus = {}
TheGauntlet.Items.Zeus.CollectibleType = Isaac.GetItemIdByName("Zeus")
TheGauntlet.Items.Zeus.CollectibleTypeActive = Isaac.GetItemIdByName(" Zeus ")

-- Delay for charges between 2 and 12 will be interpolated based on values below
local DELAY_BETWEEN_LIGHTNING_STRIKES_2_CHARGES = 15
local DELAY_BETWEEN_LIGHTNING_STRIKES_12_CHARGES = 5

--If Isaac has no active items, always give a custom active one
--To prevent said active being dropped when picking up another active, also give Schoolbag without the costume
local function TryGiveZeusActiveItem(player, firstTime)
    if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == 0 then
        player:AddCollectible(TheGauntlet.Items.Zeus.CollectibleTypeActive, 0, firstTime)

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
end

---@param collectibleType CollectibleType
---@param charge integer
---@param firstTime boolean
---@param slot integer
---@param varData integer
---@param player EntityPlayer
TheGauntlet:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, function (_, collectibleType, charge, firstTime, slot, varData, player)
    if not player:HasCollectible(TheGauntlet.Items.Zeus.CollectibleType) then return end

    local itemConfig = Isaac.GetItemConfig():GetCollectible(collectibleType)
    local pickedUpZeus = collectibleType == TheGauntlet.Items.Zeus.CollectibleType
    local pickedUpActive = itemConfig.Type == ItemType.ITEM_ACTIVE
    if (pickedUpZeus or pickedUpActive) and firstTime then
        player:AddActiveCharge(99, slot, true, true)
    end

    --Prevent redundant double calls from these items being added; reasoning for adding below
    if collectibleType == CollectibleType.COLLECTIBLE_SCHOOLBAG then return end
    if collectibleType == TheGauntlet.Items.Zeus.CollectibleTypeActive then return end

    local hasActiveThatIsntZeusInPrimarySlot = player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) ~= 0 and player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) ~= TheGauntlet.Items.Zeus.CollectibleTypeActive
    local hasActiveThatIsntZeusInSecondarySlot = player:GetActiveItem(ActiveSlot.SLOT_SECONDARY) ~= 0 and player:GetActiveItem(ActiveSlot.SLOT_SECONDARY) ~= TheGauntlet.Items.Zeus.CollectibleTypeActive
    local hasActiveThatIsntZeus = hasActiveThatIsntZeusInPrimarySlot or hasActiveThatIsntZeusInSecondarySlot

    TryGiveZeusActiveItem(player, true)

    if hasActiveThatIsntZeus then
        player:RemoveCollectible(TheGauntlet.Items.Zeus.CollectibleTypeActive)
        player:AddInnateCollectible(CollectibleType.COLLECTIBLE_SCHOOLBAG, -1)
    end
end)

---@param player EntityPlayer
---@param collectibleType CollectibleType
---@param removeFromPlayerForm boolean
---@param wisp boolean
TheGauntlet:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, function (_, player, collectibleType, removeFromPlayerForm, wisp)
    if collectibleType == TheGauntlet.Items.Zeus.CollectibleType then
        if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == TheGauntlet.Items.Zeus.CollectibleTypeActive then
            player:RemoveCollectible(TheGauntlet.Items.Zeus.CollectibleTypeActive)
        end
    end

    if not player:HasCollectible(TheGauntlet.Items.Zeus.CollectibleType) then return end

    TryGiveZeusActiveItem(player, false)
end)

---@param collectibleType CollectibleType
---@param rng RNG
---@param player EntityPlayer
---@param useFlags UseFlag
---@param slot ActiveSlot
---@param varData integer
TheGauntlet:AddCallback(ModCallbacks.MC_USE_ITEM, function (_, collectibleType, rng, player, useFlags, slot, varData)
    --Zeus the active item does nothing by itself; lightning strikes are handled by the passive item
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
    for i = 1, (player:GetActiveCharge(slot) + 2) do
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