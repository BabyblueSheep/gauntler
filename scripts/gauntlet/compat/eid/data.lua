if EID == nil then return end



EID:addItemPoolName(TheGauntlet.GauntletRoom.ITEM_POOL_ID, "en_us", "Gauntlet")
EID:assignItemPoolMarkup(TheGauntlet.GauntletRoom.ITEM_POOL_ID, "{{GauntletGauntletRoomPool}}")



EID.CarBatteryNoSynergy[TheGauntlet.Items.Zeus.CollectibleType] = true

EID.BFFSNoSynergy[TheGauntlet.Items.Apollo.CollectibleType] = true

EID.HealthUpData["5.100."..TheGauntlet.Items.Dionysus.CollectibleType] = 1
EID.HealingItemData["5.100."..TheGauntlet.Items.Dionysus.CollectibleType] = true
EID.BloodUpData[TheGauntlet.Items.Dionysus.CollectibleType] = 4
EID:AddPlayerConditional(TheGauntlet.Items.Dionysus.CollectibleType, PlayerType.PLAYER_BETHANY_B, "Health Up Blood Charges", {variableText = 4})

		--[[local descriptionText = ""
		local amount = locustData[1]
		local scale = locustData[2]
		local speed = locustData[3]
		local locustFlags1 = locustData[4] -- array
		local locustFlags2 = locustData[5] -- array
		local locustFlags3 = locustData[6] -- array
		local tearFlags1 = locustData[7] -- array
		local tearFlags2 = locustData[8] -- array
		local tearFlags3 = locustData[9] -- array
		local procChance1 = locustData[10]
		local procChance2 = locustData[11]
		local procChance3 = locustData[12]
		local damageMultiplier1 = locustData[13]
		local damageMultiplier2 = locustData[14]]
-- amount, scale, speed, locustFlags1, locustFlags2, locustFlags3, tearFlags1, tearFlags2, tearFlags3, procChance1, procChance2, procChance3, damageMultiplier1, damageMultiplier2

local locustIds = {
    TheGauntlet.Items.Aphrodite.CollectibleType,
    TheGauntlet.Items.Apollo.CollectibleType,
    TheGauntlet.Items.Ares.CollectibleType,
    TheGauntlet.Items.Artemis.CollectibleType,
    TheGauntlet.Items.Athena.CollectibleType,
    TheGauntlet.Items.Demeter.CollectibleType,
    TheGauntlet.Items.Dionysus.CollectibleType,
    TheGauntlet.Items.Hades.CollectibleType,
    TheGauntlet.Items.Hephaestus.CollectibleType,
    TheGauntlet.Items.Hera.CollectibleType,
    TheGauntlet.Items.Poseidon.CollectibleType,
    TheGauntlet.Items.Zeus.CollectibleType,
}

for _, itemId in ipairs(locustIds) do
    local xmlData = XMLData.GetEntryById(XMLNode.LOCUST, itemId)

    local amount = 1
    if xmlData.count ~= nil then
        ---@diagnostic disable-next-line: cast-local-type
        amount = math.tointeger(xmlData.count)
    end

    local scale = 1
    if xmlData.scale ~= nil then
        ---@diagnostic disable-next-line: cast-local-type
        scale = math.tointeger(xmlData.scale)
    end

    local speed = 1
    if xmlData.speed ~= nil then
        ---@diagnostic disable-next-line: cast-local-type
        speed = math.tointeger(xmlData.speed)
    end

    local locustFlags1 = {-1}
    if xmlData.locustFlags1 ~= nil then
        ---@diagnostic disable-next-line: cast-local-type
        locustFlags1 = math.tointeger(xmlData.locustFlags1)
    end
end