TheGauntlet.Items.Zeus.CollectibleType = Isaac.GetItemIdByName("Zeus")
TheGauntlet.Items.Zeus.CollectibleTypeActive = Isaac.GetItemIdByName(" Zeus ")

local CHANCE_TO_STRIKE_ENEMY = 0.75

local activeItemBoltAmountSpecialCases = {
    [CollectibleType.COLLECTIBLE_NOTCHED_AXE] = 0,
    [CollectibleType.COLLECTIBLE_ISAACS_TEARS] = 1
}

include("scripts.items.zeus.cases.notched_axe")

local boltAmountDefaultCase = include("scripts.items.zeus.cases.default")

--If Isaac has no active items, always give a custom active one
--To prevent said active being dropped when picking up another active, also give Schoolbag without the costume
---@param player EntityPlayer
local function TryGiveZeusActiveItem(player, firstTime)
    if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == 0 or player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES then
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

    local notCountedActives = {
        [0] = true,
        [CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES] = true,
        [TheGauntlet.Items.Zeus.CollectibleTypeActive] = true,
    }
    local hasActiveThatIsntZeusInPrimarySlot = notCountedActives[player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)] ~= true
    local hasActiveThatIsntZeusInSecondarySlot = notCountedActives[player:GetActiveItem(ActiveSlot.SLOT_SECONDARY)] ~= true
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

    local doesntOwnItem = (useFlags & UseFlag.USE_OWNED == 0) or (useFlags & UseFlag.USE_MIMIC ~= 0) or (slot == -1)
    if doesntOwnItem then return end

    local boltAmount = 0

    local itemConfig = Isaac.GetItemConfig():GetCollectible(collectibleType)

    local playerSave = TheGauntlet.SaveManager.GetRunSave(player)
    playerSave.PreviousChargeAmount = player:GetActiveCharge(slot)
    playerSave.PreviousTotalChargeAmount = player:GetTotalActiveCharge(slot)
    
    Isaac.CreateTimer(function ()
        boltAmount = boltAmountDefaultCase(collectibleType, itemConfig, player, slot)
        if activeItemBoltAmountSpecialCases[collectibleType] ~= nil then
            boltAmount = activeItemBoltAmountSpecialCases[collectibleType]
        end

        for i = 1, boltAmount do
            local targetType = 0
            if rng:RandomFloat() < CHANCE_TO_STRIKE_ENEMY then
                targetType = TheGauntlet.Items.Zeus.TargetType.ENEMY
            else
                targetType = TheGauntlet.Items.Zeus.TargetType.RANDOM
            end

            TheGauntlet.Items.Zeus.ScheduleLightningBolt(targetType, player)
        end
    end, 1, 1, false)
end)