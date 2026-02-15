TheGauntlet.Items.Hera = {}
TheGauntlet.Items.Hera.CollectibleType = Isaac.GetItemIdByName("Hera")

local AMOUNT_OF_ENEMIES_TO_IMPREGNATE = 2

local MINISAAC_MINIMUM_AMOUNT = 1
local MINISAAC_MAXIMUM_AMOUNT = 2

TheGauntlet:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function (_)
    if not PlayerManager.AnyoneHasCollectible(TheGauntlet.Items.Hera.CollectibleType) then return end

    local enemiesToImpregnante = {}

    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity.Type == EntityType.ENTITY_FAMILIAR and entity.Variant == FamiliarVariant.MINISAAC then
            if entity:GetData().HeraTemporary then
                entity:Kill()
                goto continue
            end
        end

        if not entity:IsActiveEnemy() then goto continue end
        if entity.FrameCount > 0 then goto continue end

        table.insert(enemiesToImpregnante, entity)

        ::continue::
    end

    if #enemiesToImpregnante == 0 then return end

    local rng = RNG(Game():GetRoom():GetSpawnSeed())
    TheGauntlet.Utility.ShuffleListInPlace(enemiesToImpregnante, rng)

    local amountOfEnemiesToImpregnante = math.min(#enemiesToImpregnante, AMOUNT_OF_ENEMIES_TO_IMPREGNATE)
    for i = 1, amountOfEnemiesToImpregnante do
        local enemy = enemiesToImpregnante[i]
        enemy:GetData().HeraPregnant = true
    end
end)

local pregnantIcon = Sprite()
pregnantIcon:Load("gfx/gauntlet/statuseffects.anm2", true)
pregnantIcon:Play("Pregnant", true)

local PREGNANT_ICON_RENDER_OFFSET = Vector(0, -5)

---@param npc EntityNPC
---@param offset Vector
TheGauntlet:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, function (_, npc, offset)
    if not npc:GetData().HeraPregnant then return end

    if Game():GetRoom():GetRenderMode() == RenderMode.RENDER_WATER_REFLECT then return end

    local renderPosition = Isaac.WorldToScreen(npc.Position + npc.PositionOffset + npc:GetNullOffset("OverlayEffect") + PREGNANT_ICON_RENDER_OFFSET)

    pregnantIcon:Render(renderPosition)
end)

TheGauntlet:AddCallback(ModCallbacks.MC_POST_UPDATE, function (_)
    pregnantIcon:Update()
end)

---@param entity Entity
---@param killSource EntityRef
TheGauntlet:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function (_, entity, killSource)
    if not entity:GetData().HeraPregnant then return end

    entity:GetData().HeraPregnant = false

    local player = killSource.Entity and TheGauntlet.Utility.GetPlayerFromEntity(killSource.Entity)
    if not player then
        player = Isaac.GetPlayer(0)
    end

    local rng = player:GetCollectibleRNG(TheGauntlet.Items.Hera.CollectibleType)
    local minisaacAmount = rng:RandomInt(MINISAAC_MINIMUM_AMOUNT, MINISAAC_MAXIMUM_AMOUNT)

    for i = 1, minisaacAmount do
        local familiar = player:AddMinisaac(entity.Position)
        familiar.Velocity = rng:RandomVector() * TheGauntlet.Utility.RandomFloat(0, 5, rng)

        familiar:GetData().HeraTemporary = true
        TheGauntlet.SaveManager.GetRunSave(familiar).HeraTemporary = true
    end
end)

---@param familiar EntityFamiliar
TheGauntlet:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function (_, familiar)
    if TheGauntlet.SaveManager.GetRunSave(familiar).HeraTemporary then
        if not familiar:GetData().HeraTemporary then
            familiar:Remove()
        end
    end
end)