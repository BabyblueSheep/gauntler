if EID == nil then return end



EID:assignItemPoolMarkup(TheGauntlet.GauntletRoom.ITEM_POOL_ID, "{{GauntletGauntletRoomPool}}")



EID.CarBatteryNoSynergy[TheGauntlet.Items.Zeus.CollectibleType] = true

EID.BFFSNoSynergy[TheGauntlet.Items.Apollo.CollectibleType] = true

EID.HealthUpData["5.100."..TheGauntlet.Items.Dionysus.CollectibleType] = 1
EID.HealingItemData["5.100."..TheGauntlet.Items.Dionysus.CollectibleType] = true
EID.BloodUpData[TheGauntlet.Items.Dionysus.CollectibleType] = 4
EID:AddPlayerConditional(TheGauntlet.Items.Dionysus.CollectibleType, PlayerType.PLAYER_BETHANY_B, "Health Up Blood Charges", {variableText = 4})



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
    TheGauntlet.Items.Zeus.CollectibleTypeActive,
}

---@param xmlData table
---@param item string
---@param default number
local function ReadNumberFromXMLData(xmlData, item, default)
    local value = default
    if xmlData[item] ~= nil then
        ---@diagnostic disable-next-line: cast-local-type
        value = tonumber(xmlData[item])
    end

    return value
end

---@param xmlData table
---@param item string
local function ReadListFromXMLData(xmlData, item)
    local value = {-1}
    if xmlData[item] ~= nil then
        value = {}
        for substring in string.gmatch(xmlData[item], "%S+") do
            table.insert(value, tonumber(substring))
        end
    end

    return value
end

for _, itemId in ipairs(locustIds) do
    local xmlData = XMLData.GetEntryById(XMLNode.LOCUST, itemId)

    local amount = ReadNumberFromXMLData(xmlData, "count", 1)
    local scale = ReadNumberFromXMLData(xmlData, "scale", 1)
    local speed = ReadNumberFromXMLData(xmlData, "speed", 1)
    local locustFlags1 = ReadListFromXMLData(xmlData, "locustflags")
    local locustFlags2 = ReadListFromXMLData(xmlData, "locustflags2")
    local locustFlags3 = ReadListFromXMLData(xmlData, "locustflags3")
    local tearFlags1 = ReadListFromXMLData(xmlData, "tearflags")
    local tearFlags2 = ReadListFromXMLData(xmlData, "tearflags2")
    local tearFlags3 = ReadListFromXMLData(xmlData, "tearflags3")
    local procChance1 = ReadNumberFromXMLData(xmlData, "procchance", 1)
    local procChance2 = ReadNumberFromXMLData(xmlData, "procchance2", 1)
    local procChance3 = ReadNumberFromXMLData(xmlData, "procchance3", 1)
    local damageMultiplier1 = ReadNumberFromXMLData(xmlData, "damagemultiplier", 1)
    local damageMultiplier2 = ReadNumberFromXMLData(xmlData, "damagemultiplier2", 1)

    EID.XMLLocusts[itemId] = { amount, scale, speed, locustFlags1, locustFlags2, locustFlags3, tearFlags1, tearFlags2, tearFlags3, procChance1, procChance2, procChance3, damageMultiplier1, damageMultiplier2 }
end

EID.XMLLocusts[TheGauntlet.Items.Hera.CollectibleType][1] = 3
EID.XMLLocusts[TheGauntlet.Items.Hera.CollectibleType][2] = 1

--Surely this is a terrible way to do this
EID.XMLLocusts[TheGauntlet.Items.Zeus.CollectibleType][5] = { "Gauntlet Zeus Bolt" }
EID.XMLLocusts[TheGauntlet.Items.Zeus.CollectibleType][11] = TheGauntlet.Items.Zeus.Constants.LOCUST_CHANCE_TO_SUMMON_BOLT

EID.XMLLocusts[TheGauntlet.Items.Zeus.CollectibleTypeActive][5] = { "Gauntlet Zeus Bolt" }
EID.XMLLocusts[TheGauntlet.Items.Zeus.CollectibleTypeActive][11] = TheGauntlet.Items.Zeus.Constants.LOCUST_CHANCE_TO_SUMMON_BOLT

EID.XMLLocusts[TheGauntlet.Items.Poseidon.CollectibleType][4] = { "Gauntlet Poseidon Push" }

EID.XMLLocusts[TheGauntlet.Items.Hades.CollectibleType][4] = { "Gauntlet Hades Status" }
EID.XMLLocusts[TheGauntlet.Items.Hades.CollectibleType][10] = TheGauntlet.Items.Hades.Constants.LOCUST_CHANCE_TO_APPLY_STATUS_EFFECT

EID.XMLLocusts[TheGauntlet.Items.Demeter.CollectibleType][4] = { "Gauntlet Demeter Booger" }

EID.XMLLocusts[TheGauntlet.Items.Dionysus.CollectibleType][7] = { 10 } --lol.