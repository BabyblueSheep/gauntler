TheGauntlet.Items.Poseidon.Constants.LOCUST_ENEMY_FLOW_SPEED_BASE = 1
TheGauntlet.Items.Poseidon.Constants.LOCUST_ENEMY_FLOW_SPEED_STAGE = 0.05



local game = Game()

---@param familiar EntityFamiliar
TheGauntlet:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function (_, familiar)
    if familiar.SubType ~= TheGauntlet.Items.Poseidon.COLLECTIBLE_TYPE then return end

    if familiar.State == TheGauntlet.Utility.LocustState.CHARGING and familiar.FireCooldown == -1 then


        for _, entity in ipairs(Isaac.FindInRadius(familiar.Position, 48, EntityPartition.ENEMY)) do
            if entity.Mass >= 100 then goto continue end
            if entity:IsFlying() then goto continue end
            if entity:IsBoss() then goto continue end

            local proximity = TheGauntlet.Utility.InverseLerp(entity.Size + 48, entity.Size, entity.Position:Distance(familiar.Position))
            local pushSpeed = (TheGauntlet.Items.Poseidon.Constants.LOCUST_ENEMY_FLOW_SPEED_BASE + game:GetLevel():GetStage() * TheGauntlet.Items.Poseidon.Constants.LOCUST_ENEMY_FLOW_SPEED_STAGE)

            entity:AddVelocity(familiar.Velocity:Normalized() * pushSpeed * proximity, true)

            ::continue::
        end
        
    end
end, FamiliarVariant.ABYSS_LOCUST)