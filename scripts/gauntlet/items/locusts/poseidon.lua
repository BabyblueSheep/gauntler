local PUSH_STRENGTH = 10



---@param familiar EntityFamiliar
TheGauntlet:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function (_, familiar)
    if familiar.SubType ~= TheGauntlet.Items.Poseidon.CollectibleType then return end

    if familiar.State == TheGauntlet.Utility.LocustState.CHARGING and familiar.FireCooldown == -1 then


        for _, entity in ipairs(Isaac.FindInRadius(familiar.Position, 48, EntityPartition.ENEMY)) do
            if entity.Mass >= 100 then goto continue end
            if entity:IsFlying() then goto continue end

            local proximity = TheGauntlet.Utility.InverseLerp(64, 16, entity.Position:Distance(familiar.Position))

            local remappedMass = TheGauntlet.Utility.Lerp(1, 20, TheGauntlet.Utility.InverseLerp(1, 100, entity.Mass))

            entity:AddVelocity(familiar.Velocity:Normalized() * PUSH_STRENGTH * proximity / remappedMass)

            ::continue::
        end
        
    end
end, FamiliarVariant.ABYSS_LOCUST)