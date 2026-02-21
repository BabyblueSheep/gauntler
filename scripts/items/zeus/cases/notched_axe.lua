---@param entity Entity
TheGauntlet:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function (_, entity)
    if entity.Type ~= EntityType.ENTITY_KNIFE then return end
    if entity.Variant ~= KnifeVariant.NOTCHED_AXE then return end
    if entity.SubType ~= 0 then return end

    if entity.Parent == nil then return end --Somehow, this callback can get called twice with the Parent being nil in the second call?

    local player = entity.Parent:ToPlayer()
    if not player then return end

    if not player:HasCollectible(TheGauntlet.Items.Zeus.CollectibleType) then return end

    if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) ~= CollectibleType.COLLECTIBLE_NOTCHED_AXE then return end

    if player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY) == 0 then
        local boltAmount = 8

        for i = 1, boltAmount do
            TheGauntlet.Items.Zeus.ScheduleLightningBolt(Game():GetRoom():GetRandomPosition(10), player)
        end
    end
end)