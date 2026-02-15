TheGauntlet.Items.Hera = {}
TheGauntlet.Items.Hera.CollectibleType = Isaac.GetItemIdByName("Hera")

local pregnantIcon = Sprite()
pregnantIcon:Load("gfx/gauntlet/status_effects.anm2", true)
pregnantIcon:Play("Pregnant", true)

StatusEffectLibrary.RegisterStatusEffect
(
    "Pregnant", pregnantIcon
)

TheGauntlet:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function (_)
    local enemiesToImpregnante = {}

    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if not entity:IsActiveEnemy() then return end

        table.insert(enemiesToImpregnante, entity)
    end
end)