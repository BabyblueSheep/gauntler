if EID == nil then return end



local eidIcons = Sprite()
eidIcons:Load("gfx/gauntlet/ui/eid_inline_icons.anm2", true)

EID:addIcon("GauntletGauntletRoomStat",         "GauntletRoom", 0, 14, 14, 0, -1, eidIcons)
EID:addIcon("GauntletGauntletRoomMap",          "GauntletRoom", 1, 9, 9, 0, 3, eidIcons)
EID:addIcon("GauntletGauntletRoomStatSmall",    "GauntletRoom", 2, 9, 9, 0, 1, eidIcons)
EID:addIcon("GauntletGauntletRoomPool",         "GauntletRoom", 3, 9, 9, 0, 0, eidIcons)

EID:addIcon("GauntletDemeterWinter", "Demeter", 0, 9, 9, 0, 0, eidIcons)
EID:addIcon("GauntletDemeterSpring", "Demeter", 1, 7, 9, 0, 0, eidIcons)
EID:addIcon("GauntletDemeterSummer", "Demeter", 2, 9, 9, 0, 0, eidIcons)
EID:addIcon("GauntletDemeterAutumn", "Demeter", 3, 7, 9, 0, 0, eidIcons)

EID:addIcon("GauntletHadesStatusEffect",    "StatusEffects", 0, 9, 9, 0, 0, eidIcons)
EID:addIcon("GauntletHeraStatusEffect",     "StatusEffects", 1, 8, 8, 0, 0, eidIcons)



EID:setModIndicatorName("The Gauntlet")
EID:setModIndicatorIcon("GauntletGauntletRoomStat")



EID.MarkupSizeMap["{{GauntletGauntletRoomStat}}"] = "{{GauntletGauntletRoomStatSmall}}"
EID.StatPickupBulletpointBlacklist["{{GauntletGauntletRoomStat}}"] = true
EID.StatPickupBulletpointBlacklist["{{GauntletGauntletRoomStatSmall}}"] = true