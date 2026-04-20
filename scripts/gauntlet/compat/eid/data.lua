if EID == nil then return end



EID:addItemPoolName(TheGauntlet.GauntletRoom.ITEM_POOL_ID, "en_us", "Gauntlet")
EID:assignItemPoolMarkup(TheGauntlet.GauntletRoom.ITEM_POOL_ID, "{{GauntletGauntletRoomPool}}")



EID.CarBatteryNoSynergy[TheGauntlet.Items.Zeus.CollectibleType] = true

EID.BFFSNoSynergy[TheGauntlet.Items.Apollo.CollectibleType] = true

EID.HealthUpData["5.100."..TheGauntlet.Items.Dionysus.CollectibleType] = 1
EID.HealingItemData["5.100."..TheGauntlet.Items.Dionysus.CollectibleType] = true
EID.BloodUpData[TheGauntlet.Items.Dionysus.CollectibleType] = 4
EID:AddPlayerConditional(TheGauntlet.Items.Dionysus.CollectibleType, PlayerType.PLAYER_BETHANY_B, "Health Up Blood Charges", {variableText = 4})