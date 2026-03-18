local PREGNANT_STATUS_DURATION = 30 * 15

local AMOUNT_OF_ENEMIES_TO_IMPREGNATE = 2

local SPAWNED_MINISAAC_MINIMUM_AMOUNT = 1
local SPAWNED_MINISAAC_MAXIMUM_AMOUNT = 2



local game = Game()

TheGauntlet.Items.Hera = {}
TheGauntlet.Items.Hera.CollectibleType = Isaac.GetItemIdByName("Hera")

local pregnantStatusEffectSprite = Sprite("gfx/gauntlet/statuseffects.anm2", true)
pregnantStatusEffectSprite:Play("Pregnant", true)

StatusEffectLibrary.RegisterStatusEffect(
	"TheGauntlet_HeraPregnant",
	pregnantStatusEffectSprite,
    nil, nil, true
)

---@param entity Entity
function TheGauntlet.Items.Hera.CanEntityBeImpregnanted(entity)
    local returnValue = Isaac.RunCallback(TheGauntlet.Utility.Callbacks.HERA_CAN_ENTITY_BE_IMPREGNANTED, entity)
    if type(returnValue) == "boolean" then return returnValue end

    if entity.Type == EntityType.ENTITY_DUMMY then return false end
    if not (entity:IsActiveEnemy(false) or entity:ToNPC().CanShutDoors) then return false end
    if entity.FrameCount > 0 then return false end
    if entity:IsBoss() then return false end

    return true
end

TheGauntlet:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function (_)
    if not PlayerManager.AnyoneHasCollectible(TheGauntlet.Items.Hera.CollectibleType) then return end

    local enemiesToImpregnante = {}

    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity.Type == EntityType.ENTITY_FAMILIAR and entity.Variant == FamiliarVariant.MINISAAC then
            if entity:GetData().HeraTemporary then
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

    local amountOfEnemiesToImpregnante = math.min(#enemiesToImpregnante, AMOUNT_OF_ENEMIES_TO_IMPREGNATE)
    for i = 1, amountOfEnemiesToImpregnante do
        local enemy = enemiesToImpregnante[i]
        
        StatusEffectLibrary:AddStatusEffect
        (
            enemy,
            StatusEffectLibrary.StatusFlag.TheGauntlet_HeraPregnant,
            PREGNANT_STATUS_DURATION,
            EntityRef(nil)
        )
    end
end)

---@param entity Entity
---@param killSource EntityRef
TheGauntlet:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function (_, entity, killSource)
    if not StatusEffectLibrary:HasStatusEffect(entity, StatusEffectLibrary.StatusFlag.TheGauntlet_HeraPregnant) then return end

    local player = killSource.Entity and TheGauntlet.Utility.GetPlayerFromEntity(killSource.Entity.SpawnerEntity)
    if not player then
        player = Isaac.GetPlayer(0)
    end

    local rng = player:GetCollectibleRNG(TheGauntlet.Items.Hera.CollectibleType)
    local minisaacAmount = rng:RandomInt(SPAWNED_MINISAAC_MINIMUM_AMOUNT, SPAWNED_MINISAAC_MAXIMUM_AMOUNT)

    local isPersistent = entity:HasEntityFlags(EntityFlag.FLAG_PERSISTENT)

    Isaac.CreateTimer(function ()
        if entity:IsDead() then
            for i = 1, minisaacAmount do
                local familiar = player:AddMinisaac(entity.Position)
                familiar.Velocity = rng:RandomVector() * TheGauntlet.Utility.RandomFloat(0, 5, rng)

                familiar:GetData().HeraTemporary = true
                TheGauntlet.SaveManager.GetRunSave(familiar).HeraTemporary = true
            end
        end
    end, 1, 1, isPersistent)
end)

--Hack to make Hera Minisaacs not persist between exit-continuing
---@param familiar EntityFamiliar
TheGauntlet:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function (_, familiar)
    if TheGauntlet.SaveManager.GetRunSave(familiar).HeraTemporary then
        if not familiar:GetData().HeraTemporary then
            familiar:Remove()
        end
    end
end)