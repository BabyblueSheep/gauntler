TheGauntlet.Items.Demeter = {}
TheGauntlet.Items.Demeter.CollectibleType = Isaac.GetItemIdByName("Demeter")

local SUMMER_NPC_DAMAGE_PER_TICK = 2

local test = 0

local function IsRoomWinter()
    local level = Game():GetLevel()
    local roomIndex = level:GetCurrentRoomIndex()

    return roomIndex % 2 == 0
end

---@param npc EntityNPC
TheGauntlet:AddPriorityCallback(ModCallbacks.MC_PRE_NPC_UPDATE, CallbackPriority.EARLY, function (_, npc)
    if not PlayerManager.AnyoneHasCollectible(TheGauntlet.Items.Demeter.CollectibleType) then return end

    local owner = PlayerManager.FirstCollectibleOwner(TheGauntlet.Items.Demeter.CollectibleType)
    if IsRoomWinter() then
        npc:AddIce(EntityRef(owner), 30)
    else
        npc:AddBurn(EntityRef(owner), 30, SUMMER_NPC_DAMAGE_PER_TICK)
    end
end)

TheGauntlet:AddCallback(ModCallbacks.MC_POST_UPDATE, function (_)
    if not PlayerManager.AnyoneHasCollectible(TheGauntlet.Items.Demeter.CollectibleType) then return end

    
end)