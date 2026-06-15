--UUUUUUUUUUUGHHHHHHH

if FiendFolio == nil then return end



TheGauntlet.Compat.FiendFolio.GauntletDisc = {}
TheGauntlet.Compat.FiendFolio.GauntletDisc.Constants = {
    MINIMUM_ITEM_SPAWNED_FROM_DISC_COUNT = 3,
    MAXIMUM_ITEM_SPAWNED_FROM_DISC_COUNT = 5,

    ITEM_FROM_DISC_DURATION = 30 * 60
}
TheGauntlet.Compat.FiendFolio.GauntletDisc.Fallbacks = {
    TheGauntlet.Items.Aphrodite.COLLECTIBLE_TYPE,
    TheGauntlet.Items.Apollo.COLLECTIBLE_TYPE,
    TheGauntlet.Items.Dionysus.COLLECTIBLE_TYPE,
}



local itemConfig = Isaac.GetItemConfig()
local game = Game()
local sfxManager = SFXManager()

TheGauntlet.Compat.FiendFolio.GauntletDisc.PICKUP_SUBTYPE = Isaac.GetEntitySubTypeByName("Gauntlet Disc")
TheGauntlet.Compat.FiendFolio.GauntletDisc.CARD_ID = Isaac.GetCardIdByName("Gauntlet Type")
TheGauntlet.Compat.FiendFolio.GauntletDisc.USE_SOUND_EFFECT = FiendFolio.Sounds.TaintedTreasureDisc

TheGauntlet.SaveManager.Utility.AddDefaultRunData(TheGauntlet.SaveManager.DefaultSaveKeys.PLAYER , {
    GauntletDisc = {
		ItemsToNotifyAboutRemoval = {}
	},
})

FiendFolio.PocketObjectMimicCharges[TheGauntlet.Compat.FiendFolio.GauntletDisc.CARD_ID] = 6
table.insert(FiendFolio.ItemDiscs, TheGauntlet.Compat.FiendFolio.GauntletDisc.CARD_ID)
table.insert(FiendFolio.PocketObjects, TheGauntlet.Compat.FiendFolio.GauntletDisc.CARD_ID)
table.insert(FiendFolio.PocketObjectWeights, { TheGauntlet.Compat.FiendFolio.GauntletDisc.CARD_ID, 0.2 })

--Copied from FF
---@param player EntityPlayer
---@param itemConfigEntry ItemConfigItem
local function IsValidDiscItem(player, itemConfigEntry)
	return itemConfigEntry and itemConfigEntry.ID > 0
			and itemConfigEntry.Type ~= ItemType.ITEM_ACTIVE
			and (itemConfigEntry.Tags & ItemConfig.TAG_SUMMONABLE ~= 0)
			and (not player:HasCollectible(itemConfigEntry.ID, true) or FiendFolio:IsItemStackable(itemConfigEntry.ID, true))
end

---@param player EntityPlayer
---@param poolType ItemPoolType
---@param rng RNG
local function PickItemFromPool(player, poolType, rng)
	local itemPool = game:GetItemPool()

	local itemID
	local itemConfigEntry

	local attempts = 0

	while not IsValidDiscItem(player, itemConfigEntry) and attempts < 50 do
		itemID = itemPool:GetCollectible(poolType, false, rng:Next())

		itemConfigEntry = itemConfig:GetCollectible(itemID)

		attempts = attempts + 1
	end

	if IsValidDiscItem(player, itemConfigEntry) then
		return itemConfigEntry
	end
end

---@param cardId Card
---@param player EntityPlayer
---@param useFlags UseFlag
TheGauntlet:AddCallback(ModCallbacks.MC_USE_CARD, function (_, cardId, player, useFlags)
    local rng = player:GetCardRNG(cardId)
    local itemPoolIdToUse = TheGauntlet.GauntletRoom.ITEM_POOL_ID

    local itemCountToSpawn = rng:RandomInt(TheGauntlet.Compat.FiendFolio.GauntletDisc.Constants.MINIMUM_ITEM_SPAWNED_FROM_DISC_COUNT, TheGauntlet.Compat.FiendFolio.GauntletDisc.Constants.MAXIMUM_ITEM_SPAWNED_FROM_DISC_COUNT)
	local duration = TheGauntlet.Compat.FiendFolio.GauntletDisc.Constants.ITEM_FROM_DISC_DURATION

    local pickedItems = {}
	local amountOfFallbacksUsed = 0

    for i = 1, itemCountToSpawn do

        local itemConfigEntry = PickItemFromPool(player, itemPoolIdToUse, rng)
		if not itemConfigEntry then
			amountOfFallbacksUsed = amountOfFallbacksUsed + 1

			local fallbackItem = TheGauntlet.Compat.FiendFolio.GauntletDisc.Fallbacks[amountOfFallbacksUsed]
			if not fallbackItem then break end

			itemConfigEntry = itemConfig:GetCollectible(fallbackItem)
		end

		if itemConfigEntry then
			table.insert(pickedItems, itemConfigEntry)
		end

		if amountOfFallbacksUsed >= 3 then
			break
		end

    end

	local itemsToSave = {}
	for i, itemConfigEntry in ipairs(pickedItems) do
		local angle = 90
		if #pickedItems > 1 then
			local arc = 70
			if #pickedItems > 3 then
				arc = TheGauntlet.Utility.Lerp(70, 360 - (360 / #pickedItems), (#pickedItems - 3) / (TheGauntlet.Compat.FiendFolio.GauntletDisc.Constants.MAXIMUM_ITEM_SPAWNED_FROM_DISC_COUNT * 2 - 3))
			end
			angle = angle - arc * 0.5 + arc * ((i-1) / (#pickedItems-1))
		end
		TheGauntlet.Compat.FiendFolio.GauntletDisc.ShowItemIcon(player, itemConfigEntry.GfxFileName, angle, false)

		player:AddInnateCollectible(itemConfigEntry.ID, 1, "TheGauntletFFGauntletDisc", duration)

		table.insert(itemsToSave, itemConfigEntry.ID)
	end


    local playerSave = TheGauntlet.SaveManager.GetRunSave(player)
	table.insert(playerSave.GauntletDisc.ItemsToNotifyAboutRemoval, {
		Items = itemsToSave,
		Duration = duration
	})

    sfxManager:Play(SoundEffect.SOUND_THUMBSUP)
    sfxManager:Play(TheGauntlet.Compat.FiendFolio.GauntletDisc.USE_SOUND_EFFECT)
end, TheGauntlet.Compat.FiendFolio.GauntletDisc.CARD_ID)

---@param player EntityPlayer
TheGauntlet:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function (_, player)
	local playerSave = TheGauntlet.SaveManager.GetRunSave(player)

	for i = #playerSave.GauntletDisc.ItemsToNotifyAboutRemoval, 1, -1 do
		local items = playerSave.GauntletDisc.ItemsToNotifyAboutRemoval[i]
		items.Duration = items.Duration - 1
		if items.Duration <= 0 then
			table.remove(playerSave.GauntletDisc.ItemsToNotifyAboutRemoval, i)

			for _, itemID in ipairs(items.Items) do
				TheGauntlet.Compat.FiendFolio.GauntletDisc.ShowItemIcon(player, itemConfig:GetCollectible(itemID).GfxFileName, RandomVector():GetAngleDegrees(), true)
			end

			sfxManager:Play(SoundEffect.SOUND_THUMBS_DOWN)
			game:GetHUD():ShowItemText("Your free trial has expired")
		end
	end
end)