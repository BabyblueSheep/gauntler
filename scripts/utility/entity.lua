local TEAR_COPYING_FAMILIARS = {
    [FamiliarVariant.INCUBUS] = true,
    [FamiliarVariant.TWISTED_BABY] = true,
    [FamiliarVariant.BLOOD_BABY] = true,
    [FamiliarVariant.SPRINKLER] = true,
    [FamiliarVariant.UMBILICAL_BABY] = true,
    [FamiliarVariant.CAINS_OTHER_EYE] = true,
    [FamiliarVariant.FATES_REWARD] = true
}

---@param entity Entity
---@param tearCopyingFamiliarsOnly boolean?
---@return EntityPlayer?
function TheGauntlet.Utility.GetPlayerFromEntity(entity, tearCopyingFamiliarsOnly)
    if tearCopyingFamiliarsOnly == nil then
        tearCopyingFamiliarsOnly = false
    end

    local player entity:ToPlayer()
    if player then return player end

    player = entity.SpawnerEntity and entity.SpawnerEntity:ToPlayer()
    if player then return player end

    local familiar = entity.SpawnerEntity and entity.SpawnerEntity:ToFamiliar()
    if familiar then
        local familiarCounts = (not tearCopyingFamiliarsOnly) or (TEAR_COPYING_FAMILIARS[familiar.Variant] == true)
        if familiarCounts then
            player = familiar.Player
            if player then return player end
        end 
    end

    return nil
end