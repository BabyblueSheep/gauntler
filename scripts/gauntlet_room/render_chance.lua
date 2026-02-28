local chanceToDisplay = 0

local hudStatSprite = Sprite("gfx/gauntlet/ui/gauntlet_stat_icon.anm2", true)

---@param isContinued boolean
TheGauntlet:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function (_, isContinued)
    chanceToDisplay = TheGauntlet.GauntletRoom.GetGenerationChance()
end)

TheGauntlet:AddCallback(ModCallbacks.MC_HUD_POST_UPDATE, function (_)
    chanceToDisplay = TheGauntlet.GauntletRoom.GetGenerationChance()
end)

TheGauntlet:AddCallback(ModCallbacks.MC_POST_HUD_RENDER, function (_)

end)