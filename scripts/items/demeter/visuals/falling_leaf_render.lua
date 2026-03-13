local fallingLeafSprite = Sprite("gfx/gauntlet/effects/falling_leaf.anm2", true)

local SPRING_LEAF_COLOR = Color(1, 0.7, 0.8, 1)
local AUTUMN_LEAF_COLOR = {
    Color(0.8, 0.3, 0.2, 1),
    Color(1, 0.6, 0.2, 1)
}

---@param instance ParticleInstance
---@param offset Vector
return function (instance, offset)
    local fadeIn = TheGauntlet.Utility.InverseLerp(instance.StartingTime, instance.StartingTime - 30, instance.TimeLeft)
    local fadeOut = TheGauntlet.Utility.InverseLerp(0, 30, instance.TimeLeft)

    local alpha = fadeIn * fadeOut

    fallingLeafSprite.Rotation = instance.Speed:GetAngleDegrees() + 90
    if instance.Type == TheGauntlet.Items.Demeter.Season.SPRING then
        fallingLeafSprite.Color = SPRING_LEAF_COLOR
    else
        fallingLeafSprite.Color = AUTUMN_LEAF_COLOR[instance.Variant // 2 + 1]
    end
    fallingLeafSprite.Color.A = alpha
    fallingLeafSprite.Scale.X = instance.Size
    fallingLeafSprite.Scale.Y = instance.Size

    fallingLeafSprite:SetFrame("Idle"..tostring(instance.Variant % 2 + 1), (instance.TimeLeft // 2) % 15)
    fallingLeafSprite:Render(Isaac.WorldToRenderPosition(instance.Position) + fallingLeafSprite.Offset + offset)
end