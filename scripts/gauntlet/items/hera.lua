TheGauntlet.Items.Hera = {}

TheGauntlet.Items.Hera.Constants = {
    PREGNANT_STATUS_DURATION_FRAMES = 30 * 15,

    AMOUNT_OF_ENEMIES_TO_IMPREGNATE = 2,

    SPAWNED_MINISAAC_MINIMUM_AMOUNT = 1,
    SPAWNED_MINISAAC_MAXIMUM_AMOUNT = 2,
}



local game = Game()

TheGauntlet.Items.Hera.COLLECTIBLE_TYPE = Isaac.GetItemIdByName("Hera")

TheGauntlet.Items.Hera.STATUS_EFFECT_ID = "TheGauntlet_HeraPregnant"

local pregnantStatusEffectSprite = Sprite("gfx/gauntlet/statuseffects.anm2", true)
pregnantStatusEffectSprite:Play("Pregnant", true)

StatusEffectLibrary.RegisterStatusEffect(
	TheGauntlet.Items.Hera.STATUS_EFFECT_ID,
	pregnantStatusEffectSprite,
    nil, nil, true
)

---Whether the given entity can be inflicted with Pregnant or not.
---@param entity Entity
function TheGauntlet.Items.Hera.CanEntityBeImpregnanted(entity)
    local returnValue = Isaac.RunCallback(TheGauntlet.Utility.Callbacks.HERA_CAN_ENTITY_BE_IMPREGNANTED, entity)
    if type(returnValue) == "boolean" then return returnValue end

    if not entity:IsActiveEnemy(false) then return false end
    if not entity:IsVulnerableEnemy() then return false end

    if entity.Type == EntityType.ENTITY_DUMMY then return false end
    if entity.FrameCount > 0 then return false end
    if entity:IsBoss() then return false end

    return true
end

TheGauntlet:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function (_)
    if not PlayerManager.AnyoneHasCollectible(TheGauntlet.Items.Hera.COLLECTIBLE_TYPE) then return end

    local enemiesToImpregnante = {}

    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity.Type == EntityType.ENTITY_FAMILIAR and entity.Variant == FamiliarVariant.MINISAAC then
            if TheGauntlet.CustomSaveManager.GetTemporaryNoHourglassData(entity).Hera == nil then
                goto continue
            end

            if TheGauntlet.CustomSaveManager.GetTemporaryNoHourglassData(entity).Hera.Minisaac then
                entity:Remove()
                goto continue
            end
        end

        if TheGauntlet.Items.Hera.CanEntityBeImpregnanted(entity) == false then goto continue end

        table.insert(enemiesToImpregnante, entity)

        ::continue::
    end

    if #enemiesToImpregnante == 0 then return end

    local rng = RNG(game:GetRoom():GetSpawnSeed())
    TheGauntlet.Utility.ShuffleListInPlace(enemiesToImpregnante, rng)

    local amountOfEnemiesToImpregnante = math.min(#enemiesToImpregnante, TheGauntlet.Items.Hera.Constants.AMOUNT_OF_ENEMIES_TO_IMPREGNATE)
    for i = 1, amountOfEnemiesToImpregnante do
        local enemy = enemiesToImpregnante[i]
        
        StatusEffectLibrary:AddStatusEffect
        (
            enemy,
            StatusEffectLibrary.StatusFlag[TheGauntlet.Items.Hera.STATUS_EFFECT_ID],
            TheGauntlet.Items.Hera.Constants.PREGNANT_STATUS_DURATION_FRAMES,
            EntityRef(nil)
        )
    end
end)

---@param entity Entity
---@param killSource EntityRef
TheGauntlet:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function (_, entity, killSource)
    if not StatusEffectLibrary:HasStatusEffect(entity, StatusEffectLibrary.StatusFlag[TheGauntlet.Items.Hera.STATUS_EFFECT_ID]) then return end

    local player = killSource.Entity and TheGauntlet.Utility.GetPlayerFromEntity(killSource.Entity.SpawnerEntity)
    if not player then
        player = Isaac.GetPlayer(0)
    end

    local rng = player:GetCollectibleRNG(TheGauntlet.Items.Hera.COLLECTIBLE_TYPE)
    local minisaacAmount = rng:RandomInt(TheGauntlet.Items.Hera.Constants.SPAWNED_MINISAAC_MINIMUM_AMOUNT, TheGauntlet.Items.Hera.Constants.SPAWNED_MINISAAC_MAXIMUM_AMOUNT)

    local isPersistent = entity:HasEntityFlags(EntityFlag.FLAG_PERSISTENT)

    Isaac.CreateTimer(function ()
        if entity:IsDead() then
            for i = 1, minisaacAmount do
                local familiar = player:AddMinisaac(entity.Position)
                familiar.Velocity = rng:RandomVector() * TheGauntlet.Utility.RandomFloat(0, 5, rng)

                local familiarData = TheGauntlet.CustomSaveManager.GetTemporaryNoHourglassData(familiar)
                familiarData.Hera = {
                    Minisaac = true
                }
                local familiarPersistentData = TheGauntlet.CustomSaveManager.GetPersistentData(familiar)
                familiarPersistentData.Hera = {
                    Minisaac = true
                }
            end
        end
    end, 1, 1, isPersistent)
end)

--Hack to make Hera Minisaacs not persist between exit-continuing
---@param familiar EntityFamiliar
TheGauntlet:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function (_, familiar)
    local familiarData = TheGauntlet.CustomSaveManager.GetTemporaryNoHourglassData(familiar)
    local familiarPersistentData = TheGauntlet.CustomSaveManager.GetPersistentData(familiar)

    if familiarPersistentData.Hera == nil then return end

    if familiarPersistentData.Hera.Minisaac then
        if not familiarData.Hera then
            familiar:Remove()
        end
    end
end)