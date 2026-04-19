if EID == nil then return end


EID:setModIndicatorName("The Gauntlet")

local eidIcons = Sprite()
eidIcons:Load("gfx/gauntlet/ui/eid_inline_icons.anm2", true)

EID:addIcon("GauntletDemeterWinter", "Demeter", 0, 9, 9, -1, 0, eidIcons)
EID:addIcon("GauntletDemeterSpring", "Demeter", 1, 7, 9, -1, 0, eidIcons)
EID:addIcon("GauntletDemeterSummer", "Demeter", 2, 9, 9, -1, 0, eidIcons)
EID:addIcon("GauntletDemeterAutumn", "Demeter", 3, 7, 9, -1, 0, eidIcons)

EID:addIcon("GauntletHadesStatusEffect", "StatusEffects", 0, 9, 9, -1, 0, eidIcons)
EID:addIcon("GauntletHeraStatusEffect", "StatusEffects", 1, 8, 8, -1, 0, eidIcons)

---@param number number
---@return string
local function NumberToPresentableNumber(number)
    ---@diagnostic disable-next-line: cast-local-type
    number = tonumber(string.format("%.2f", number))
    if math.tointeger(number) == number then
    ---@diagnostic disable-next-line: cast-local-type
        number = math.tointeger(number)
    end
    return tostring(number)
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

local zeusChargeAmount = XMLData.GetEntryByName(XMLNode.ITEM, " Zeus ").maxcharges


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
            string.format("Spawns %s lightning bolts that have a %s%% chance to add 1 charge to the active item#", zeusChargeAmount, TheGauntlet.Items.Zeus.Constants.CHANCE_TO_GIVE_PIP_ON_KILL) ..
            "Can be combined with a second active item to spawn lightning bolts, with the amount scaling with the item's charge"
        }
    }
}

EID.descriptions["en_us"].ConditionalDescs["Gauntlet Hephaestus if no Golden then only Trinket"] = { "golden trinket", "trinket" }

local zeusDescriptions = {
    ["en_us"] = {
        ["Default"] = "Spawns %s lightning bolts when used",
        ["Default One"] = "Spawns %s lightning bolt when used"
    },
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
local function DefaultZeusBoltAmount(collectibleType)
    local configItem = Isaac.GetItemConfig():GetCollectible(collectibleType)

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


EID:AddConditional(TheGauntlet.Items.Hephaestus.CollectibleType, function ()
    return not Isaac.GetPersistentGameData():Unlocked(Achievement.GOLDEN_TRINKET)
end, "Gauntlet Hephaestus if no Golden then only Trinket")

EID:addDescriptionModifier("Gauntlet Zeus Bolt Amount When Zeus", function (descObj)
    if descObj.ObjType ~= EntityType.ENTITY_PICKUP then return false end
    if descObj.ObjVariant ~= PickupVariant.PICKUP_COLLECTIBLE then return false end
    if descObj.ObjSubType ~= TheGauntlet.Items.Zeus.CollectibleType then return false end

    return true
end, function (descObj)
    --if EID.InsideItemReminder then return descObj end

    for _, player in ipairs(PlayerManager.GetPlayers()) do
        local activeItemType = player:GetActiveItem()

        if activeItemType > 0 then
            local languageTable = zeusDescriptions[EID:getLanguage()] or zeusDescriptions["en_us"]

            local descriptionToUse = languageTable[activeItemType]
            if descriptionToUse == nil then
                local boltAmount = DefaultZeusBoltAmount(activeItemType)

                local originalDescriptionToUse = languageTable["Default"]
                if boltAmount == 1 then
                    originalDescriptionToUse = languageTable["Default One"]
                end

                descriptionToUse = "#{{Collectible"..activeItemType.."}} {{ColorLightYellow}}"..string.format(originalDescriptionToUse, boltAmount)
            end

            EID:appendToDescription(descObj, descriptionToUse)
        end
    end

    return descObj
end)