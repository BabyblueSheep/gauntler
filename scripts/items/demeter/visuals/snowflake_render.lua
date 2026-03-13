local snowflakeSprite = Sprite("gfx/gauntlet/effects/snowflake.anm2", true)
snowflakeSprite:SetFrame("Idle", 0)

---@param instance ParticleInstance
---@param offset Vector
return function (instance, offset)
    local fadeIn = TheGauntlet.Utility.InverseLerp(instance.StartingTime, instance.StartingTime - 30, instance.TimeLeft)
    local fadeOut = TheGauntlet.Utility.InverseLerp(0, 30, instance.TimeLeft)

    local alpha = fadeIn * fadeOut

    snowflakeSprite.Color.A = alpha
    snowflakeSprite.Scale.X = instance.Size
    snowflakeSprite.Scale.Y = instance.Size
    snowflakeSprite:Render(Isaac.WorldToRenderPosition(instance.Position) + snowflakeSprite.Offset + offset)
end