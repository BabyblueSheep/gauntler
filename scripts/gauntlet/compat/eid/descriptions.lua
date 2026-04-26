if EID == nil then return end





EID:AddConditional(TheGauntlet.Items.Hephaestus.COLLECTIBLE_TYPE, function ()
    return not Isaac.GetPersistentGameData():Unlocked(Achievement.GOLDEN_TRINKET)
end, "Gauntlet Hephaestus if no Golden then only Trinket")

EID:addDescriptionModifier("Gauntlet Zeus Active is Zeus Passive", function (descObj)
    if descObj.ObjType ~= EntityType.ENTITY_PICKUP then return false end
    if descObj.ObjVariant ~= PickupVariant.PICKUP_COLLECTIBLE then return false end
    if descObj.ObjSubType ~= TheGauntlet.Items.Zeus.COLLECTIBLE_TYPE_ACTIVE then return false end

    return true
end, function (descObj)
    return EID:getDescriptionObj(descObj.ObjType, descObj.ObjVariant, TheGauntlet.Items.Zeus.COLLECTIBLE_TYPE, descObj.Entity)
end, 1)

local itemsThatAreThrowable = {
    [CollectibleType.COLLECTIBLE_BOBS_ROTTEN_HEAD] = true,
    [CollectibleType.COLLECTIBLE_SHOOP_DA_WHOOP] = true,
    [CollectibleType.COLLECTIBLE_CANDLE] = true,
    [CollectibleType.COLLECTIBLE_RED_CANDLE] = true,
    [CollectibleType.COLLECTIBLE_BOOMERANG] = true,
    [CollectibleType.COLLECTIBLE_GLASS_CANNON] = true,
    [CollectibleType.COLLECTIBLE_FRIEND_BALL] = true,
    [CollectibleType.COLLECTIBLE_BLACK_HOLE] = true,
    [CollectibleType.COLLECTIBLE_SHARP_KEY] = true,
    [CollectibleType.COLLECTIBLE_ERASER] = true,
    [CollectibleType.COLLECTIBLE_DECAP_ATTACK] = true,
}

local itemsWithCustomStaticBoltAmount = {
    [CollectibleType.COLLECTIBLE_GENESIS] = 0,
    [CollectibleType.COLLECTIBLE_ISAACS_TEARS] = 1,
    [CollectibleType.COLLECTIBLE_SPIN_TO_WIN] = 0,
}

---@param collectibleType integer
function TheGauntlet.Compat.EID.RegisterItemThrowable(collectibleType)
    itemsThatAreThrowable[collectibleType] = true
end

---@param collectibleType integer
---@param chargeAmount integer
function TheGauntlet.Compat.EID.RegisterItemWithCustomStaticBoltAmount(collectibleType, chargeAmount)
    itemsWithCustomStaticBoltAmount[collectibleType] = chargeAmount
end

local customZeusDescriptions = {}

---@param collectibleType integer
---@param language string
---@param description string
function TheGauntlet.Compat.EID.RegisterZeusDescription(collectibleType, language, description)
    if customZeusDescriptions[collectibleType] == nil then
        customZeusDescriptions[collectibleType] = {}
    end

    customZeusDescriptions[collectibleType][language] = description
end



---@param collectibleType integer
local function DefaultZeusBoltAmount(collectibleType)
    local configItem = Isaac.GetItemConfig():GetCollectible(collectibleType)

    if configItem.Type ~= ItemType.ITEM_ACTIVE then
        return nil
    end

    if itemsWithCustomStaticBoltAmount[collectibleType] ~= nil then
        return itemsWithCustomStaticBoltAmount[collectibleType]
    end

    if EID.ItemData[collectibleType] ~= nil and EID.ItemData[collectibleType].SingleUseInfo == true then
        return 16
    end

    if itemsThatAreThrowable[collectibleType] == true then
        return 0
    end

    if configItem.ChargeType == 2 then
        return 0
    elseif configItem.ChargeType == 1 then
        return configItem.MaxCharges // 60
    else
        return configItem.MaxCharges
    end
end



---@param collectibleType integer
---@param iconType integer
local function AppendZeusBoltDescription(descObj, collectibleType, iconType)
    local descriptionTableToUse = customZeusDescriptions[collectibleType]
    local descriptionToUse = ""

    if descriptionTableToUse == nil then
        local boltAmount = DefaultZeusBoltAmount(collectibleType)

        if boltAmount == nil then
            return
        end

        local originalDescriptionToUse = customZeusDescriptions["Default"][EID:getLanguage()] or customZeusDescriptions["Default"]["en_us"]
        if boltAmount == 1 then
            originalDescriptionToUse = customZeusDescriptions["Default One"][EID:getLanguage()] or customZeusDescriptions["Default One"]["en_us"]
        end

        originalDescriptionToUse = string.gsub(originalDescriptionToUse, "%[1%]", boltAmount)

        descriptionToUse = "#"..string.format(originalDescriptionToUse, boltAmount)
    else
        descriptionToUse = descriptionTableToUse[EID:getLanguage()] or descriptionTableToUse["en_us"]
        descriptionToUse = "#"..descriptionToUse
    end

    descriptionToUse = descriptionToUse:gsub("#", "#{{Collectible"..iconType.."}} {{ColorLightYellow}}")

    EID:appendToDescription(descObj, descriptionToUse)
end

EID:addDescriptionModifier("Gauntlet Zeus Bolt Amount When Zeus", function (descObj)
    if descObj.ObjType ~= EntityType.ENTITY_PICKUP then return false end
    if descObj.ObjVariant ~= PickupVariant.PICKUP_COLLECTIBLE then return false end
    if descObj.ObjSubType ~= TheGauntlet.Items.Zeus.COLLECTIBLE_TYPE then return false end

    return true
end, function (descObj)
    if EID.InsideItemReminder then return descObj end

    local hasInsertedZeusOnItsOwn = false

    for _, player in ipairs(PlayerManager.GetPlayers()) do
        local activeItemType = player:GetActiveItem()

        if activeItemType == 0 then
            activeItemType = TheGauntlet.Items.Zeus.COLLECTIBLE_TYPE

            if hasInsertedZeusOnItsOwn then
                goto continue
            end
        end

        AppendZeusBoltDescription(descObj, activeItemType, activeItemType)

        if activeItemType == TheGauntlet.Items.Zeus.COLLECTIBLE_TYPE then
            hasInsertedZeusOnItsOwn = true
        end

        ::continue::
    end

    return descObj
end)

EID:addDescriptionModifier("Gauntlet Zeus Bolt Amount When Active", function (descObj)
    if descObj.ObjType ~= EntityType.ENTITY_PICKUP then return false end
    if descObj.ObjVariant ~= PickupVariant.PICKUP_COLLECTIBLE then return false end

    return PlayerManager.AnyoneHasCollectible(TheGauntlet.Items.Zeus.COLLECTIBLE_TYPE)
end, function (descObj)
    AppendZeusBoltDescription(descObj, descObj.ObjSubType, TheGauntlet.Items.Zeus.COLLECTIBLE_TYPE)

    return descObj
end)






local apolloMultishotCooldownSeconds = TheGauntlet.Utility.NumberToPresentableNumber(TheGauntlet.Items.Apollo.Constants.BOOST_DURATION_FRAMES / 30)
local apolloChanceToGiveBoost = TheGauntlet.Utility.NumberToPresentableNumber(TheGauntlet.Items.Apollo.Constants.CHANCE_TO_GIVE_BOOST * 100)

local aresChallengeRoomDamage = XMLData.GetEntryByName(XMLNode.NULLITEM, "Ares Challenge Room Stats").damage
local aresBossChallengeRoomDamage = XMLData.GetEntryByName(XMLNode.NULLITEM, "Ares Boss Challenge Room Stats").damage

local athenaShieldTimeDisableSeconds = TheGauntlet.Utility.NumberToPresentableNumber(TheGauntlet.Items.Athena.Constants.SHIELD_DISABLE_TIME_FRAMES / 30)

local dionysusHealthContainer = math.tointeger(XMLData.GetEntryByName(XMLNode.ITEM, "Dionysus").maxhearts) // 2
local dionysusHealthHeal = math.tointeger(XMLData.GetEntryByName(XMLNode.ITEM, "Dionysus").hearts) // 2 - dionysusHealthContainer
local dionysusSpeed = XMLData.GetEntryByName(XMLNode.ITEM, "Dionysus").speed
local dionysusTears = XMLData.GetEntryByName(XMLNode.ITEM, "Dionysus").tears
local dionysusDamage = XMLData.GetEntryByName(XMLNode.ITEM, "Dionysus").damage
local dionysusRange = XMLData.GetEntryByName(XMLNode.ITEM, "Dionysus").range
local dionysusLuck = XMLData.GetEntryByName(XMLNode.ITEM, "Dionysus").luck
local dionysusDrunkTimeSeconds = TheGauntlet.Utility.NumberToPresentableNumber(TheGauntlet.Items.Dionysus.Constants.DRUNK_DURATION_ON_HIT_FRAMES / 30)

local demeterBoogerChance = TheGauntlet.Utility.NumberToPresentableNumber(TheGauntlet.Items.Demeter.Constants.SPRING_BOOGER_CHANCE * 100)

local hadesSkullChance = TheGauntlet.Utility.NumberToPresentableNumber(TheGauntlet.Items.Hades.Constants.CHANCE_TO_APPLY_SKULL * 100)

local zeusBoltPipGiveChance = TheGauntlet.Utility.NumberToPresentableNumber(TheGauntlet.Items.Zeus.Constants.CHANCE_TO_GIVE_PIP_ON_KILL * 100)

local function RegisterLanguageKeys(language, localizationItems)
    EID:addItemPoolName(TheGauntlet.GauntletRoom.ITEM_POOL_ID, language, localizationItems["pool.gauntlet.name"])

    local collectibleTranslationItems = {
        {
            TheGauntlet.Items.Aphrodite.COLLECTIBLE_TYPE, "aphrodite",
            { }
        },
        {
            TheGauntlet.Items.Apollo.COLLECTIBLE_TYPE, "apollo",
            { apolloChanceToGiveBoost, apolloMultishotCooldownSeconds }
        },
        {
            TheGauntlet.Items.Ares.COLLECTIBLE_TYPE, "ares",
            { aresChallengeRoomDamage, aresBossChallengeRoomDamage }
        },
        {
            TheGauntlet.Items.Artemis.COLLECTIBLE_TYPE, "artemis",
            { TheGauntlet.Items.Artemis.Constants.ARROW_DAMAGE_MULTIPLIER }
        },
        {
            TheGauntlet.Items.Athena.COLLECTIBLE_TYPE, "athena",
            { TheGauntlet.Items.Athena.Constants.SHIELD_AMOUNT, athenaShieldTimeDisableSeconds }
        },
        {
            TheGauntlet.Items.Demeter.COLLECTIBLE_TYPE, "demeter",
            { demeterBoogerChance }
        },
        {
            TheGauntlet.Items.Dionysus.COLLECTIBLE_TYPE, "dionysus",
            { dionysusHealthContainer, dionysusHealthHeal, dionysusSpeed, dionysusTears, dionysusDamage, dionysusRange, dionysusLuck, dionysusDrunkTimeSeconds }
        },
        {
            TheGauntlet.Items.Hades.COLLECTIBLE_TYPE, "hades",
            { hadesSkullChance }
        },
        {
            TheGauntlet.Items.Hephaestus.COLLECTIBLE_TYPE, "hephaestus",
            { }
        },
        {
            TheGauntlet.Items.Hera.COLLECTIBLE_TYPE, "hera",
            { TheGauntlet.Items.Hera.Constants.AMOUNT_OF_ENEMIES_TO_IMPREGNATE, TheGauntlet.Items.Hera.Constants.SPAWNED_MINISAAC_MINIMUM_AMOUNT, TheGauntlet.Items.Hera.Constants.SPAWNED_MINISAAC_MAXIMUM_AMOUNT }
        },
        {
            TheGauntlet.Items.Poseidon.COLLECTIBLE_TYPE, "poseidon",
            { }
        },
        {
            TheGauntlet.Items.Zeus.COLLECTIBLE_TYPE, "zeus",
            { zeusBoltPipGiveChance }
        },
    }

    for _, item in ipairs(collectibleTranslationItems) do
        local collectibleType = item[1]
        local localizationKeyName = item[2]
        local placeholderValues = item[3]

        local collectibleName = localizationItems["item."..localizationKeyName..".name"]
        local collectibleDescription = localizationItems["item."..localizationKeyName..".description"]

        for placeholderNumber, placeholderValue in ipairs(placeholderValues) do
            collectibleDescription = string.gsub(collectibleDescription, "%["..tostring(placeholderNumber).."%]", placeholderValue)
        end

        EID:addCollectible(collectibleType, collectibleDescription, collectibleName, language)
    end


    EID.descriptions[language].ConditionalDescs["Gauntlet Hephaestus if no Golden then only Trinket"] = { localizationItems["item.hephaestus.description.without_golden_trinket"] }

    EID:addSynergyCondition(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES, TheGauntlet.Items.Zeus.COLLECTIBLE_TYPE, localizationItems["item.zeus.description.book_of_virtues"] , nil, language)
    EID:addBookOfBelialBuffsCondition(TheGauntlet.Items.Zeus.COLLECTIBLE_TYPE, localizationItems["item.zeus.description.judas_birthright"] , nil, nil, language)

    if customZeusDescriptions["Default"] == nil then
        customZeusDescriptions["Default"] = {}
        customZeusDescriptions["Default One"] = {}
    end
    customZeusDescriptions["Default"][language] = localizationItems["item.zeus.description.bolt_spawn.default"]
    customZeusDescriptions["Default One"][language] = localizationItems["item.zeus.description.bolt_spawn.default_one"]

    local zeusCaseTranslationItems = {
        {
            CollectibleType.COLLECTIBLE_BERSERK, "berserk",
            { TheGauntlet.Items.Zeus.Constants.BERSERK_TIME_INTERVAL_SECONDS }
        },
        {
            CollectibleType.COLLECTIBLE_ERASER, "eraser",
            { TheGauntlet.Items.Zeus.Constants.ERASER_BOLT_AMOUNT }
        },
        {
            CollectibleType.COLLECTIBLE_MAMA_MEGA, "mama_mega",
            { TheGauntlet.Items.Zeus.Constants.MAMA_MEGA_BOLT_AMOUNT }
        },
        {
            CollectibleType.COLLECTIBLE_NOTCHED_AXE, "notched_axe",
            { TheGauntlet.Items.Zeus.Constants.NOTCHED_AXE_BOLT_AMOUNT }
        },
        {
            CollectibleType.COLLECTIBLE_BLUE_BOX, "pandoras_box",
            { }
        },
    }

    for _, item in ipairs(zeusCaseTranslationItems) do
        local collectibleType = item[1]
        local localizationKeyName = item[2]
        local placeholderValues = item[3]

        local description = localizationItems["item.zeus.description.bolt_spawn."..localizationKeyName]

        for placeholderNumber, placeholderValue in ipairs(placeholderValues) do
            description = string.gsub(description, "%["..tostring(placeholderNumber).."%]", placeholderValue)
        end

        TheGauntlet.Compat.EID.RegisterZeusDescription(collectibleType, language, description)
    end

    EID.descriptions[language].AbyssLocustEffects["Gauntlet Demeter Booger"] = localizationItems["item.abyss.locust_effect.demeter"]
    EID.descriptions[language].AbyssLocustEffects["Gauntlet Hades Status"] = localizationItems["item.abyss.locust_effect.hades"]
    EID.descriptions[language].AbyssLocustEffects["Gauntlet Poseidon Push"] = localizationItems["item.abyss.locust_effect.poseidon"]
    EID.descriptions[language].AbyssLocustEffects["Gauntlet Zeus Bolt"] = localizationItems["item.abyss.locust_effect.zeus"]
end



RegisterLanguageKeys("en_us", include("scripts.gauntlet.compat.eid.descriptions.en_us"))