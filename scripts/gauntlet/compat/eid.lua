local eidIcons = Sprite()
eidIcons:Load("gfx/gauntlet/ui/eid_inline_icons.anm2", true)

EID:addIcon("GauntletDemeterWinter", "Idle", 0, 9, 9, -1, 0, eidIcons)
EID:addIcon("GauntletDemeterSpring", "Idle", 1, 7, 9, -1, 0, eidIcons)
EID:addIcon("GauntletDemeterSummer", "Idle", 2, 9, 9, -1, 0, eidIcons)
EID:addIcon("GauntletDemeterAutumn", "Idle", 3, 7, 9, -1, 0, eidIcons)



local apolloMultishotCooldownSeconds = tonumber(XMLData.GetEntryByName(XMLNode.ITEM, "Apollo Multishot").cooldown) // 30

local aresChallengeRoomDamage = XMLData.GetEntryByName(XMLNode.ITEM, "Ares Challenge Room Stats").damage
local aresBossChallengeRoomDamage = XMLData.GetEntryByName(XMLNode.ITEM, "Ares Boss Challenge Room Stats").damage

local itemDescriptions = {
    [TheGauntlet.Items.Aphrodite] = {
        ["en"] = {
            "Aphrodite",
            "{{Friendly}} Taking damage from an enemy converts it to a friendly companion"
        }
    },

    [TheGauntlet.Items.Apollo] = {
        ["en"] = {
            "Apollo",
            "Blocks projectiles#When hit, "..TheGauntlet.Items.Apollo.Constants.CHANCE_TO_GIVE_BOOST.."% chance to grant triple shot for "..apolloMultishotCooldownSeconds.." seconds"
        }
    },

    [TheGauntlet.Items.Ares] = {
        ["en"] = {
            "Ares",
            "{{ChallengeRoom}} Spawns an additional Challenge Room each evenly numbered floor#{{BossChallengeRoom}} Spawns an additional Boss Challenge Room each evenly numbered floor# Clearing a {{ChallengeRoom}} Challenge Room grants ↑ {{Damage}} +"..aresChallengeRoomDamage.." Damage for the floor# Clearing a {{BossChallengeRoom}} Boss Challenge Room grants ↑ {{Damage}} +"..aresBossChallengeRoomDamage.." Damage for the floor"
        }
    },

    [TheGauntlet.Items.Artemis] = {
        ["en"] = {
            "Artemis",
            "An arrow facing a cardinal direction appears above Isaac that periodically rotates# Tears shot in the arrow's direction piece and gain a shot speed + "..TheGauntlet.Items.Artemis.Constants.ARROW_DAMAGE_MULTIPLIER.."x damage boost"
        }
    },

    [TheGauntlet.Items.Athena] = {
        ["en"] = {
            "Athena",
            "Grants 5 rotating shields around Isaac# Shields reflect projectiles and knock enemies back#{{Timer}} Shields go on a "..TheGauntlet.Items.Athena.Constants.SHIELD_DISABLE_TIME.." second cooldown after deflecting"
        }
    },

    [TheGauntlet.Items.Demeter] = {
        ["en"] = {
            "Demeter",
            "Causes a room-wide effect that cycles every room: #{{GauntletDemeterWinter}} Enemies are frozen on death #{{GauntletDemeterSpring}} "
        }
    },
}