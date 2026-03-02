--These functions all have the following purposes:
-- * Call Game():Spawn to avoid the bug where Isaac.Spawn can generate a seed of 0 and cause a crash (this should probably never happen, realistically speaking, but eh)
-- * Add some minor improvements to Game():Spawn relating to arguments (optional seed and reorganized arguments), since it is a little bit annoying
-- * Avoid needing to cast to a specific type (call :ToX) every time an entity is spawned without checking for nil even if it is guaranteed to be a valid cast

local game = Game()

---@param type EntityType
---@param variant integer
---@param subType integer
---@param position Vector
---@param velocity Vector
---@param spawner Entity?
---@param seed integer?
---@return EntityBomb
function TheGauntlet.Utility.SpawnEntity(type, variant, subType, position, velocity, spawner, seed)
    if seed == nil then
        seed = math.max(Random(), 1)
    end

    ---@type EntityBomb
    ---@diagnostic disable-next-line assign-type-mismatch
    return game:Spawn(type, variant, position, velocity, spawner, subType, seed)
end

---@param type EntityType
---@param variant integer
---@param subType integer
---@param position Vector
---@param velocity Vector
---@param spawner Entity?
---@param seed integer?
---@return EntityBomb
function TheGauntlet.Utility.SpawnBomb(type, variant, subType, position, velocity, spawner, seed)
    if seed == nil then
        seed = math.max(Random(), 1)
    end

    ---@type EntityBomb
    ---@diagnostic disable-next-line assign-type-mismatch
    return game:Spawn(type, variant, position, velocity, spawner, subType, seed):ToBomb()
end

---@param type EntityType
---@param variant integer
---@param subType integer
---@param position Vector
---@param velocity Vector
---@param spawner Entity?
---@param seed integer?
---@return EntityEffect
function TheGauntlet.Utility.SpawnEffect(type, variant, subType, position, velocity, spawner, seed)
    if seed == nil then
        seed = math.max(Random(), 1)
    end

    ---@type EntityEffect
    ---@diagnostic disable-next-line assign-type-mismatch
    return game:Spawn(type, variant, position, velocity, spawner, subType, seed):ToEffect()
end

---@param type EntityType
---@param variant integer
---@param subType integer
---@param position Vector
---@param velocity Vector
---@param spawner Entity?
---@param seed integer?
---@return EntityFamiliar
function TheGauntlet.Utility.SpawnFamiliar(type, variant, subType, position, velocity, spawner, seed)
    if seed == nil then
        seed = math.max(Random(), 1)
    end

    ---@type EntityFamiliar
    ---@diagnostic disable-next-line assign-type-mismatch
    return game:Spawn(type, variant, position, velocity, spawner, subType, seed):ToFamiliar()
end

---@param type EntityType
---@param variant integer
---@param subType integer
---@param position Vector
---@param velocity Vector
---@param spawner Entity?
---@param seed integer?
---@return EntityKnife
function TheGauntlet.Utility.SpawnKnife(type, variant, subType, position, velocity, spawner, seed)
    if seed == nil then
        seed = math.max(Random(), 1)
    end

    ---@type EntityKnife
    ---@diagnostic disable-next-line assign-type-mismatch
    return game:Spawn(type, variant, position, velocity, spawner, subType, seed):ToKnife()
end

---@param type EntityType
---@param variant integer
---@param subType integer
---@param position Vector
---@param velocity Vector
---@param spawner Entity?
---@param seed integer?
---@return EntityLaser
function TheGauntlet.Utility.SpawnLaser(type, variant, subType, position, velocity, spawner, seed)
    if seed == nil then
        seed = math.max(Random(), 1)
    end

    ---@type EntityLaser
    ---@diagnostic disable-next-line assign-type-mismatch
    return game:Spawn(type, variant, position, velocity, spawner, subType, seed):ToLaser()
end

---@param type EntityType
---@param variant integer
---@param subType integer
---@param position Vector
---@param velocity Vector
---@param spawner Entity?
---@param seed integer?
---@return EntityNPC
function TheGauntlet.Utility.SpawnNPC(type, variant, subType, position, velocity, spawner, seed)
    if seed == nil then
        seed = math.max(Random(), 1)
    end

    ---@type EntityNPC
    ---@diagnostic disable-next-line assign-type-mismatch
    return game:Spawn(type, variant, position, velocity, spawner, subType, seed):ToNPC()
end

---@param type EntityType
---@param variant integer
---@param subType integer
---@param position Vector
---@param velocity Vector
---@param spawner Entity?
---@param seed integer?
---@return EntityPickup
function TheGauntlet.Utility.SpawnPickup(type, variant, subType, position, velocity, spawner, seed)
    if seed == nil then
        seed = math.max(Random(), 1)
    end

    ---@type EntityPickup
    ---@diagnostic disable-next-line assign-type-mismatch
    return game:Spawn(type, variant, position, velocity, spawner, subType, seed):ToPickup()
end

---@param type EntityType
---@param variant integer
---@param subType integer
---@param position Vector
---@param velocity Vector
---@param spawner Entity?
---@param seed integer?
---@return EntityPlayer
function TheGauntlet.Utility.SpawnPlayer(type, variant, subType, position, velocity, spawner, seed)
    if seed == nil then
        seed = math.max(Random(), 1)
    end

    ---@type EntityPlayer
    ---@diagnostic disable-next-line assign-type-mismatch
    return game:Spawn(type, variant, position, velocity, spawner, subType, seed):ToPlayer()
end

---@param type EntityType
---@param variant integer
---@param subType integer
---@param position Vector
---@param velocity Vector
---@param spawner Entity?
---@param seed integer?
---@return EntityProjectile
function TheGauntlet.Utility.SpawnProjectile(type, variant, subType, position, velocity, spawner, seed)
    if seed == nil then
        seed = math.max(Random(), 1)
    end

    ---@type EntityProjectile
    ---@diagnostic disable-next-line assign-type-mismatch
    return game:Spawn(type, variant, position, velocity, spawner, subType, seed):ToProjectile()
end

---@param type EntityType
---@param variant integer
---@param subType integer
---@param position Vector
---@param velocity Vector
---@param spawner Entity?
---@param seed integer?
---@return EntityTear
function TheGauntlet.Utility.SpawnTear(type, variant, subType, position, velocity, spawner, seed)
    if seed == nil then
        seed = math.max(Random(), 1)
    end

    ---@type EntityTear
    ---@diagnostic disable-next-line assign-type-mismatch
    return game:Spawn(type, variant, position, velocity, spawner, subType, seed):ToTear()
end