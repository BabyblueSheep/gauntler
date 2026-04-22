if EID == nil then return end



---@param number number
---@return string
local function NumberToPresentableNumber(number)
    local value = string.format("%.2f", tostring(number)):gsub("%.?0+$", "")
    return value
end

local apolloMultishotCooldownSeconds = NumberToPresentableNumber(tonumber(XMLData.GetEntryByName(XMLNode.NULLITEM, "Apollo Multishot").cooldown) / 30)

local aresChallengeRoomDamage = XMLData.GetEntryByName(XMLNode.NULLITEM, "Ares Challenge Room Stats").damage
local aresBossChallengeRoomDamage = XMLData.GetEntryByName(XMLNode.NULLITEM, "Ares Boss Challenge Room Stats").damage

local dionysusHealthContainer = math.tointeger(XMLData.GetEntryByName(XMLNode.ITEM, "Dionysus").maxhearts) // 2
local dionysusHealthHeal = math.tointeger(XMLData.GetEntryByName(XMLNode.ITEM, "Dionysus").hearts) // 2 - dionysusHealthContainer
local dionysusSpeed = XMLData.GetEntryByName(XMLNode.ITEM, "Dionysus").speed
local dionysusTears = XMLData.GetEntryByName(XMLNode.ITEM, "Dionysus").tears
local dionysusDamage = XMLData.GetEntryByName(XMLNode.ITEM, "Dionysus").damage
local dionysusRange = XMLData.GetEntryByName(XMLNode.ITEM, "Dionysus").range
local dionysusLuck = XMLData.GetEntryByName(XMLNode.ITEM, "Dionysus").luck
local dionysusDrunkTimeSeconds = NumberToPresentableNumber(TheGauntlet.Items.Dionysus.Constants.DRUNK_DURATION_ON_HIT_FRAMES / 30)



local function RegisterLanguageKeys(language, localizationItems)
    local collectibleTranslationItems = {
        {
            TheGauntlet.Items.Aphrodite.CollectibleType, "aphrodite",
            { apolloMultishotCooldownSeconds }
        },
        {
            TheGauntlet.Items.Apollo.CollectibleType, "apollo",
            { }
        },
        {
            TheGauntlet.Items.Ares.CollectibleType, "ares",
            { aresChallengeRoomDamage, aresBossChallengeRoomDamage }
        },
        {
            TheGauntlet.Items.Artemis.CollectibleType, "artemis",
            { TheGauntlet.Items.Artemis.Constants.ARROW_DAMAGE_MULTIPLIER }
        },
        {
            TheGauntlet.Items.Athena.CollectibleType, "athena",
            { TheGauntlet.Items.Athena.Constants.SHIELD_AMOUNT, TheGauntlet.Items.Athena.Constants.SHIELD_DISABLE_TIME_SECONDS }
        },
        {
            TheGauntlet.Items.Demeter.CollectibleType, "demeter",
            { TheGauntlet.Items.Demeter.Constants.SPRING_BOOGER_CHANCE }
        },
        {
            TheGauntlet.Items.Dionysus.CollectibleType, "dionysus",
            { dionysusHealthContainer, dionysusHealthHeal, dionysusSpeed, dionysusTears, dionysusDamage, dionysusRange, dionysusLuck, dionysusDrunkTimeSeconds }
        },
        {
            TheGauntlet.Items.Hades.CollectibleType, "hades",
            { TheGauntlet.Items.Hades.Constants.CHANCE_TO_APPLY_SKULL }
        },
        {
            TheGauntlet.Items.Hephaestus.CollectibleType, "hephaestus",
            { }
        },
        {
            TheGauntlet.Items.Hera.CollectibleType, "hera",
            { TheGauntlet.Items.Hera.Constants.AMOUNT_OF_ENEMIES_TO_IMPREGNATE, TheGauntlet.Items.Hera.Constants.SPAWNED_MINISAAC_MINIMUM_AMOUNT, TheGauntlet.Items.Hera.Constants.SPAWNED_MINISAAC_MAXIMUM_AMOUNT }
        },
        {
            TheGauntlet.Items.Poseidon.CollectibleType, "poseidon",
            { }
        },
        {
            TheGauntlet.Items.Zeus.CollectibleType, "zeus",
            { TheGauntlet.Items.Zeus.Constants.CHANCE_TO_GIVE_PIP_ON_KILL }
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


    EID.descriptions["en_us"].ConditionalDescs["Gauntlet Hephaestus if no Golden then only Trinket"] = { localizationItems["item.hephaestus.description.without_golden_trinket"] }
    
    EID:addSynergyCondition(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES, TheGauntlet.Items.Zeus.CollectibleType, localizationItems["item.zeus.description.book_of_virtues"] , nil, language)
    EID:addBookOfBelialBuffsCondition(TheGauntlet.Items.Zeus.CollectibleType, localizationItems["item.zeus.description.judas_birthright"] , nil, nil, language)

end



RegisterLanguageKeys("en_us", include("scripts.gauntlet.compat.eid.descriptions.en_us"))

EID:addDescriptionModifier("Zeus Active is Zeus Passive", function (descObj)
    if descObj.ObjType ~= EntityType.ENTITY_PICKUP then return false end
    if descObj.ObjVariant ~= PickupVariant.PICKUP_COLLECTIBLE then return false end
    if descObj.ObjSubType ~= TheGauntlet.Items.Zeus.CollectibleTypeActive then return false end

    return true
end, function (descObj)
    return EID:getDescriptionObj(descObj.ObjType, descObj.ObjVariant, TheGauntlet.Items.Zeus.CollectibleType, descObj.Entity)
end, 1)

--[[

---@param number number
---@return string
local function NumberToPresentableNumber(number)
    local value = string.format("%.2f", tostring(number)):gsub("%.?0+$", "")
    return value
end

local apolloMultishotCooldownSeconds = NumberToPresentableNumber(tonumber(XMLData.GetEntryByName(XMLNode.NULLITEM, "Apollo Multishot").cooldown) / 30)

local aresChallengeRoomDamage = XMLData.GetEntryByName(XMLNode.NULLITEM, "Ares Challenge Room Stats").damage
local aresBossChallengeRoomDamage = XMLData.GetEntryByName(XMLNode.NULLITEM, "Ares Boss Challenge Room Stats").damage

local dionysusHealth = math.tointeger(XMLData.GetEntryByName(XMLNode.ITEM, "Dionysus").maxhearts) // 2
local dionysusSpeed = XMLData.GetEntryByName(XMLNode.ITEM, "Dionysus").speed
local dionysusTears = XMLData.GetEntryByName(XMLNode.ITEM, "Dionysus").tears
local dionysusDamage = XMLData.GetEntryByName(XMLNode.ITEM, "Dionysus").damage
local dionysusRange = XMLData.GetEntryByName(XMLNode.ITEM, "Dionysus").range
local dionysusLuck = XMLData.GetEntryByName(XMLNode.ITEM, "Dionysus").luck

local dionysusDrunkTimeSeconds = NumberToPresentableNumber(TheGauntlet.Items.Dionysus.Constants.DRUNK_DURATION_ON_HIT_FRAMES / 30)



local collectibleDescriptions = {
    [TheGauntlet.Items.Aphrodite.CollectibleType] = {
        ["en_us"] = {
            "Aphrodite",
            "{{Friendly}} Taking damage from an enemy converts it to a friendly companion"
        }
    },

    [TheGauntlet.Items.Apollo.CollectibleType] = {
        ["en_us"] = {
            "Apollo",
            "Blocks projectiles#" ..
            string.format("When hit, %s%% chance to grant triple shot for %s seconds", TheGauntlet.Items.Apollo.Constants.CHANCE_TO_GIVE_BOOST, apolloMultishotCooldownSeconds)
        }
    },

    [TheGauntlet.Items.Ares.CollectibleType] = {
        ["en_us"] = {
            "Ares",
            "{{ChallengeRoom}} Spawns an additional Challenge Room each even numbered floor#" ..
            "{{BossRushRoom}} Spawns an additional Boss Challenge Room each odd numbered floor#" ..
            string.format("Clearing a {{ChallengeRoom}} Challenge Room grants ↑ {{Damage}} +%s Damage for the floor#", aresChallengeRoomDamage) ..
            string.format("Clearing a {{BossRushRoom}} Boss Challenge Room grants ↑ {{Damage}} +%s Damage for the floor", aresBossChallengeRoomDamage)
        }
    },

    [TheGauntlet.Items.Artemis.CollectibleType] = {
        ["en_us"] = {
            "Artemis",
            "An arrow facing a cardinal direction appears above Isaac that periodically rotates#" ..
            string.format("Tears shot in the arrow's direction piece and gain a shot speed + %sx damage boost", TheGauntlet.Items.Artemis.Constants.ARROW_DAMAGE_MULTIPLIER)
        }
    },

    [TheGauntlet.Items.Athena.CollectibleType] = {
        ["en_us"] = {
            "Athena",
            "Grants 5 rotating shields around Isaac#" ..
            "Shields reflect projectiles and knock enemies back#" ..
            string.format("{{Timer}} Shields go on a %s second cooldown after deflecting", TheGauntlet.Items.Athena.Constants.SHIELD_DISABLE_TIME_SECONDS)
        }
    },

    [TheGauntlet.Items.Demeter.CollectibleType] = {
        ["en_us"] = {
            "Demeter",
            "Causes a room-wide effect that cycles every room:#" ..
            "#{{GauntletDemeterWinter}} Enemies are frozen on death#" ..
            string.format("{{GauntletDemeterSpring}} %s%% chance to shoot a sticky booger#", TheGauntlet.Items.Demeter.Constants.SPRING_BOOGER_CHANCE) ..
            "{{GauntletDemeterSummer}} Enemies constantly burn#" ..
            "{{GauntletDemeterAutumn}} Enemies are permanently slowed down"
        }
    },

    [TheGauntlet.Items.Dionysus.CollectibleType] = {
        ["en_us"] = {
            "Dionysus",
            string.format("↑ {{Heart}} +%s Health#", dionysusHealth) ..
            string.format("↑ {{Speed}} +%s Speed#", dionysusSpeed) ..
            string.format("↑ {{Tears}} +%s Tears#", dionysusTears) ..
            string.format("↑ {{Damage}} +%s Damage#", dionysusDamage) ..
            string.format("↑ {{Range}} +%s Range#", dionysusRange) ..
            string.format("↑ {{Luck}} +%s Luck#", dionysusLuck) ..
            string.format("{{Timer}} Taking damage makes Isaac's movement slippery and distorts the screen for %s seconds", dionysusDrunkTimeSeconds)
        }
    },

    [TheGauntlet.Items.Hades.CollectibleType] = {
        ["en_us"] = {
            "Hades",
            string.format("{{GauntletHadesStatusEffect}} %s%% chance to shoot a bone tear that inflicts Calcified#", TheGauntlet.Items.Hades.Constants.CHANCE_TO_APPLY_SKULL) ..
            "{{Friendly}} Killing a Calcified enemy spawns a friendly Bony"
        }
    },

    [TheGauntlet.Items.Hephaestus.CollectibleType] = {
        ["en_us"] = {
            "Hephaestus",
            "{{Trinket}} Spawns 1 random golden trinket#" ..
            "Entering a new floor spawns a random golden pickup",
        }
    },

    [TheGauntlet.Items.Hera.CollectibleType] = {
        ["en_us"] = {
            "Hera",
            string.format("{{GauntletHeraStatusEffect}} Entering a room inflicts Pregnant on %s enemies#", TheGauntlet.Items.Hera.Constants.AMOUNT_OF_ENEMIES_TO_IMPREGNATE) ..
            string.format("Killing a Pregnant enemy spawns %s-%s Minisaacs", TheGauntlet.Items.Hera.Constants.SPAWNED_MINISAAC_MINIMUM_AMOUNT, TheGauntlet.Items.Hera.Constants.SPAWNED_MINISAAC_MAXIMUM_AMOUNT)
        }
    },

    [TheGauntlet.Items.Poseidon.CollectibleType] = {
        ["en_us"] = {
            "Poseidon",
            "All rooms are flooded#" ..
            "Holding the fire buttons causes water to flow in the direction held, pushing enemies and consumables back"
        }
    },

    [TheGauntlet.Items.Zeus.CollectibleType] = {
        ["en_us"] = {
            "Zeus",
            string.format("Spawns lightning bolts that have a %s%% chance to add 1 charge to the active item#", TheGauntlet.Items.Zeus.Constants.CHANCE_TO_GIVE_PIP_ON_KILL) ..
            "Can be combined with a second active item to spawn lightning bolts, with the amount scaling with the item's charge"
        }
    }
}

local conditionalSynergyDescriptions = {
    ["Zeus + Book of Virtues"] = {
        ["en_us"] = "Wisps spawn a lightning bolt when destroyed"
    },

    ["Zeus + Book of Belial"] = {
        ["en_us"] = "Lightning bolts burn enemies and leaves a fire behind"
    }


}

EID.descriptions["en_us"].ConditionalDescs["Gauntlet Hephaestus if no Golden then only Trinket"] = { "golden trinket", "trinket" }

local zeusDescriptions = {
    ["Default"] = {
        ["en_us"] = "Spawns %s lightning bolts when used"
    },
    ["Default One"] = {
        ["en_us"] = "Spawns %s lightning bolt when used"
    },

    [CollectibleType.COLLECTIBLE_BERSERK] = {
        ["en_us"] = "Spawns a lightning bolt every two seconds while active",
    },
    [CollectibleType.COLLECTIBLE_BREATH_OF_LIFE] = {
        ["en_us"] = "Spawns a lightning bolt after emptying the chargebar and every second while active",
    },
    [CollectibleType.COLLECTIBLE_ERASER] = {
        ["en_us"] = "Spawns 12 lightning bolts when erasing an enemy",
    },
    [CollectibleType.COLLECTIBLE_GENESIS] = {
        ["en_us"] = "Spawns 0 lightning bolts when used",
    },
    [CollectibleType.COLLECTIBLE_ISAACS_TEARS] = {
        ["en_us"] ="Spawns 1 lightning bolt when used",
    },
    [CollectibleType.COLLECTIBLE_MAMA_MEGA] = {
        ["en_us"] = "Spawns 6 lightning bolt when used and on room entry",
    },
    [CollectibleType.COLLECTIBLE_NOTCHED_AXE] = {
        ["en_us"] = "Spawns 8 lightning bolt when running out of charge",
    },
    [CollectibleType.COLLECTIBLE_BLUE_BOX] = {
        ["en_us"] = "Spawns lightning bolts, with the amount scaling with the current floor number",
    },
    [CollectibleType.COLLECTIBLE_SPIN_TO_WIN] = {
        ["en_us"] = "Spawns 0 lightning bolts when used",
    }
}

local miscDescriptions = {
    ["Temporary Tattoo"] = {
        ["en_us"] = "#{{Chest}} Clearing a {{GauntletGauntletRoomMap}} Gauntlet Room spawns a chest"
    }
}





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

---@param collectibleType integer
function TheGauntlet.Items.EID.RegisterItemThrowable(collectibleType)
    itemsThatAreThrowable[collectibleType] = true
end

---@param collectibleType integer
---@param language string
---@param description string
function TheGauntlet.Items.EID.RegisterZeusDescription(collectibleType, language, description)
    if zeusDescriptions[language] == nil then
        zeusDescriptions[language] = {}
    end

    zeusDescriptions[language][collectibleType] = description
end



---@param collectibleType integer
local function DefaultZeusBoltAmount(collectibleType)
    local configItem = Isaac.GetItemConfig():GetCollectible(collectibleType)

    if configItem.Type ~= ItemType.ITEM_ACTIVE then
        return nil
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



for itemID, table in pairs(collectibleDescriptions) do
    for lang, descs in pairs(table) do
        EID:addCollectible(itemID, descs[2], descs[1], lang)
    end
end


for language, description in pairs(conditionalSynergyDescriptions["Zeus + Book of Virtues"]) do
    EID:addSynergyCondition(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES, TheGauntlet.Items.Zeus.CollectibleType, description, nil, language)
end

for language, description in pairs(conditionalSynergyDescriptions["Zeus + Book of Belial"]) do
    EID:addBookOfBelialBuffsCondition(TheGauntlet.Items.Zeus.CollectibleType, description, nil, nil, language)
end



EID:AddConditional(TheGauntlet.Items.Hephaestus.CollectibleType, function ()
    return not Isaac.GetPersistentGameData():Unlocked(Achievement.GOLDEN_TRINKET)
end, "Gauntlet Hephaestus if no Golden then only Trinket")


EID:addDescriptionModifier("Zeus Active is Zeus Passive", function (descObj)
    if descObj.ObjType ~= EntityType.ENTITY_PICKUP then return false end
    if descObj.ObjVariant ~= PickupVariant.PICKUP_COLLECTIBLE then return false end
    if descObj.ObjSubType ~= TheGauntlet.Items.Zeus.CollectibleTypeActive then return false end

    return true
end, function (descObj)
    return EID:getDescriptionObj(descObj.ObjType, descObj.ObjVariant, TheGauntlet.Items.Zeus.CollectibleType, descObj.Entity)
end, 1)

---@param collectibleType integer
---@param iconType integer
local function AppendZeusBoltDescription(descObj, collectibleType, iconType)
    local descriptionTableToUse = zeusDescriptions[collectibleType]
    local descriptionToUse = ""

    if descriptionTableToUse == nil then
        local boltAmount = DefaultZeusBoltAmount(collectibleType)

        if boltAmount == nil then
            return
        end

        local originalDescriptionToUse = zeusDescriptions["Default"][EID:getLanguage()] or zeusDescriptions["Default"]["en_us"]
        if boltAmount == 1 then
            originalDescriptionToUse =zeusDescriptions["Default One"][EID:getLanguage()] or zeusDescriptions["Default One"]["en_us"]
        end

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
    if descObj.ObjSubType ~= TheGauntlet.Items.Zeus.CollectibleType then return false end

    return true
end, function (descObj)
    if EID.InsideItemReminder then return descObj end

    local hasInsertedZeusOnItsOwn = false

    for _, player in ipairs(PlayerManager.GetPlayers()) do
        local activeItemType = player:GetActiveItem()

        if activeItemType == 0 then
            activeItemType = TheGauntlet.Items.Zeus.CollectibleType

            if hasInsertedZeusOnItsOwn then
                goto continue
            end
        end

        AppendZeusBoltDescription(descObj, activeItemType, activeItemType)

        if activeItemType == TheGauntlet.Items.Zeus.CollectibleType then
            hasInsertedZeusOnItsOwn = true
        end

        ::continue::
    end

    return descObj
end)

EID:addDescriptionModifier("Gauntlet Zeus Bolt Amount When Active", function (descObj)
    if descObj.ObjType ~= EntityType.ENTITY_PICKUP then return false end
    if descObj.ObjVariant ~= PickupVariant.PICKUP_COLLECTIBLE then return false end

    return PlayerManager.AnyoneHasCollectible(TheGauntlet.Items.Zeus.CollectibleType)
end, function (descObj)
    AppendZeusBoltDescription(descObj, descObj.ObjSubType, TheGauntlet.Items.Zeus.CollectibleType)

    return descObj
end)

EID:addDescriptionModifier("Gauntlet Temporary Tattoo change", function (descObj)
    if descObj.ObjType ~= EntityType.ENTITY_PICKUP then return false end
    if descObj.ObjVariant ~= PickupVariant.PICKUP_TRINKET then return false end
    if descObj.ObjSubType ~= TrinketType.TRINKET_TEMPORARY_TATTOO then return false end

    return true
end, function (descObj)
    local description = miscDescriptions["Temporary Tattoo"][EID:getLanguage()] or miscDescriptions["Temporary Tattoo"]["en_us"]
    EID:appendToDescription(descObj, description)

    return descObj
end)
]]