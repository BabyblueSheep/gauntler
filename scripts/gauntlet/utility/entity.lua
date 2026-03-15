local TEAR_COPYING_FAMILIARS = {
    [FamiliarVariant.INCUBUS] = true,
    [FamiliarVariant.TWISTED_BABY] = true,
    [FamiliarVariant.BLOOD_BABY] = true,
    [FamiliarVariant.SPRINKLER] = true,
    [FamiliarVariant.UMBILICAL_BABY] = true,
    [FamiliarVariant.CAINS_OTHER_EYE] = true,
    [FamiliarVariant.FATES_REWARD] = true
}

---Attempts to get a player from an entity. Used in scenarios where an entity could have been spawned by a player or a player-owned familiar.
---@param entity Entity
---@param tearCopyingFamiliarsOnly boolean? Whether all familiars are considered, or only familiars that copy player tears.
---@return EntityPlayer?
function TheGauntlet.Utility.GetPlayerFromEntity(entity, tearCopyingFamiliarsOnly)
    if tearCopyingFamiliarsOnly == nil then
        tearCopyingFamiliarsOnly = false
    end

    if entity == nil then return nil end

    local player = entity:ToPlayer()
    if player then return player end
    
    local familiar = entity:ToFamiliar()
    if familiar then
        local familiarCounts = (not tearCopyingFamiliarsOnly) or (TEAR_COPYING_FAMILIARS[familiar.Variant] == true)
        if familiarCounts then
            player = familiar.Player
            if player then return player end
        end
    end

    return nil
end