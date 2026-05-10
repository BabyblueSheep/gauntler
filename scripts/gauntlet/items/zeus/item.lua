TheGauntlet.Items.Zeus.COLLECTIBLE_TYPE = Isaac.GetItemIdByName("Zeus")
TheGauntlet.Items.Zeus.COLLECTIBLE_TYPE_ACTIVE = Isaac.GetItemIdByName(" Zeus ")

local activeItemBoltAmountSpecialCases = {}

---@param collectibleType integer
---@param number fun(configItem: ItemConfigItem, player: EntityPlayer, slot: ActiveSlot): integer
function TheGauntlet.Items.Zeus.RegisterBoltAmountForItem(collectibleType, number)
    activeItemBoltAmountSpecialCases[collectibleType] = number
end

local boltAmountDefaultCase = include("scripts.gauntlet.items.zeus.cases.default")

TheGauntlet.SaveManager.Utility.AddDefaultRunData(TheGauntlet.SaveManager.DefaultSaveKeys.PLAYER, {
    Zeus = TheGauntlet.Items.Demeter.Season.NO_SEASON,
    DemeterTempSavedSeason = TheGauntlet.Items.Demeter.Season.NO_SEASON,
})

--If Isaac has no active items, always give a custom active one
--To prevent said active being dropped when picking up another active, also give Schoolbag without the costume
---@param player EntityPlayer
local function TryGiveZeusActiveItem(player, firstTime)
    if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == 0 or player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES then
        player:AddCollectible(TheGauntlet.Items.Zeus.COLLECTIBLE_TYPE_ACTIVE, 0, firstTime)

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
    if not player:HasCollectible(TheGauntlet.Items.Zeus.COLLECTIBLE_TYPE) then return end

    local itemConfig = Isaac.GetItemConfig():GetCollectible(collectibleType)
    local pickedUpZeus = collectibleType == TheGauntlet.Items.Zeus.COLLECTIBLE_TYPE
    local pickedUpActive = itemConfig.Type == ItemType.ITEM_ACTIVE
    if (pickedUpZeus or pickedUpActive) and firstTime then
        player:AddActiveCharge(99, slot, true, true)
    end

    --Prevent redundant double calls from these items being added; reasoning for adding below
    if collectibleType == CollectibleType.COLLECTIBLE_SCHOOLBAG then return end
    if collectibleType == TheGauntlet.Items.Zeus.COLLECTIBLE_TYPE_ACTIVE then return end

    local notCountedActives = {
        [0] = true,
        [CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES] = true,
        [TheGauntlet.Items.Zeus.COLLECTIBLE_TYPE_ACTIVE] = true,
    }
    local hasActiveThatIsntZeusInPrimarySlot = notCountedActives[player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)] ~= true
    local hasActiveThatIsntZeusInSecondarySlot = notCountedActives[player:GetActiveItem(ActiveSlot.SLOT_SECONDARY)] ~= true
    local hasActiveThatIsntZeus = hasActiveThatIsntZeusInPrimarySlot or hasActiveThatIsntZeusInSecondarySlot

    TryGiveZeusActiveItem(player, true)

    if hasActiveThatIsntZeus then
        player:RemoveCollectible(TheGauntlet.Items.Zeus.COLLECTIBLE_TYPE_ACTIVE)
        player:AddInnateCollectible(CollectibleType.COLLECTIBLE_SCHOOLBAG, -1)
    end
end)

---@param player EntityPlayer
---@param collectibleType CollectibleType
---@param removeFromPlayerForm boolean
---@param wispOrInnate boolean
TheGauntlet:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, function (_, player, collectibleType, removeFromPlayerForm, wispOrInnate)
    if collectibleType == TheGauntlet.Items.Zeus.COLLECTIBLE_TYPE then
        if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == TheGauntlet.Items.Zeus.COLLECTIBLE_TYPE_ACTIVE then
            player:RemoveCollectible(TheGauntlet.Items.Zeus.COLLECTIBLE_TYPE_ACTIVE)
        end
    end

    if not player:HasCollectible(TheGauntlet.Items.Zeus.COLLECTIBLE_TYPE) then return end

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
    if collectibleType == TheGauntlet.Items.Zeus.COLLECTIBLE_TYPE_ACTIVE then
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
    if not player:HasCollectible(TheGauntlet.Items.Zeus.COLLECTIBLE_TYPE) then return end

    local doesntOwnItem = (useFlags & UseFlag.USE_OWNED == 0) or (useFlags & UseFlag.USE_MIMIC ~= 0) or (slot == -1)
    if doesntOwnItem then return end

    local boltAmount = 0

    local itemConfig = Isaac.GetItemConfig():GetCollectible(collectibleType)

    local playerSave = TheGauntlet.SaveManager.GetRunSave(player)
    playerSave.Zeus.PreviousChargeAmount = player:GetActiveCharge(slot)
    playerSave.Zeus.PreviousTotalChargeAmount = player:GetTotalActiveCharge(slot)

    Isaac.CreateTimer(function ()
        boltAmount = boltAmountDefaultCase(itemConfig, player, slot)
        if activeItemBoltAmountSpecialCases[collectibleType] ~= nil then
            boltAmount = activeItemBoltAmountSpecialCases[collectibleType](itemConfig, player, slot)
        end

        for i = 1, boltAmount do
            TheGauntlet.Items.Zeus.ScheduleLightningBolt(TheGauntlet.Items.Zeus.TargetType.RANDOM_TYPE, player)
        end
    end, 1, 1, false)
end)

---@param entity Entity
---@param damage number
---@param damageFlags DamageFlag
---@param source EntityRef
---@param damageCooldown integer
TheGauntlet:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, function (_, entity, damage, damageFlags, source, damageCooldown)
    if entity.Type ~= EntityType.ENTITY_FAMILIAR then return end
    if entity.Variant ~= FamiliarVariant.WISP then return end

    if not entity:HasMortalDamage() then return end

    local player = entity:ToFamiliar().Player

    if not player:HasCollectible(TheGauntlet.Items.Zeus.COLLECTIBLE_TYPE) then return end
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then return end --So that wisps from other sources (i.e. Jar of Wisps) don't spawn bolts on death

    TheGauntlet.Items.Zeus.ScheduleLightningBolt(TheGauntlet.Items.Zeus.TargetType.RANDOM_TYPE, player)
end)
