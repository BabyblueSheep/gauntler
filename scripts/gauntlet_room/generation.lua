local sfxManager = SFXManager()

---@param door GridEntityDoor
---@return boolean
local function DoesDoorLeadToGauntletRoom(door)
    local targetRoom = Game():GetLevel():GetCurrentRoomDesc():GetNeighboringRooms()[door.Slot]
    if targetRoom == nil then return false end
    return TheGauntlet.GauntletRoom.IsRoomGauntletRoom(targetRoom)
end

local function InitializeDoors()
    local room = Game():GetRoom()

    for _, doorSlot in pairs(DoorSlot) do
        local door = room:GetDoor(doorSlot)

        if door == nil then goto continue end
        if not DoesDoorLeadToGauntletRoom(door) then goto continue end
        
        local sprite = door:GetSprite()
        local gridSave = TheGauntlet.SaveManager.GetRoomSave(door:GetGridIndex())

        if sprite:GetFilename() ~= "gfx/gauntlet/grid/door_gauntlet_room.anm2" then
            local animation = sprite:GetAnimation()
            local frame = sprite:GetFrame()
            sprite:Load("gfx/gauntlet/grid/door_gauntlet_room.anm2", true)
            sprite:SetAnimation(animation, false)
            sprite:SetFrame(frame)
        end

        if gridSave.FedHeart == nil then
            gridSave.FedHeart = false
        end

        door.State = DoorState.STATE_OPEN

        gridSave.WasClear = room:IsClear()
        gridSave.IsOpen = room:IsClear()

        local forceOpen = false
        if PlayerManager.AnyoneHasTrinket(TrinketType.TRINKET_DOOR_STOP) and Game():GetLevel().EnterDoor == doorSlot then
            forceOpen = true
        end
        if forceOpen then
            gridSave.IsOpen = true
        end
        gridSave.WasOpen = gridSave.IsOpen

        if not gridSave.FedHeart then
            sprite:Play("KeyClosed", true)
        else
            if forceOpen or room:IsClear() then
                sprite:Play("Opened", true)
            else
                sprite:Play("Close", true)
                sfxManager:Play(SoundEffect.SOUND_METAL_DOOR_CLOSE)
            end
        end

        gridSave.PreviousAnimation = sprite:GetAnimation()

        ::continue::
    end
end

TheGauntlet:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function (_)
    InitializeDoors()

    if not TheGauntlet.GauntletRoom.IsCurrentRoomGauntletRoom() then return end

    local room = Game():GetRoom()

    for _, doorSlot in pairs(DoorSlot) do
        local door = room:GetDoor(doorSlot)

        if door == nil then goto continue end

        local targetRoom = Game():GetLevel():GetCurrentRoomDesc():GetNeighboringRooms()[door.Slot]
        if targetRoom == nil then goto continue end
        if targetRoom.Data.Type == RoomType.ROOM_SECRET or targetRoom.Data.Type == RoomType.ROOM_SUPERSECRET then goto continue end
        
        local sprite = door:GetSprite()

        if sprite:GetFilename() ~= "gfx/gauntlet/grid/door_gauntlet_room.anm2" then
            local animation = sprite:GetAnimation()
            local frame = sprite:GetFrame()
            sprite:Load("gfx/gauntlet/grid/door_gauntlet_room.anm2", true)
            sprite:SetAnimation(animation, false)
            sprite:SetFrame(frame)
        end

        ::continue::
    end
end)

---@param door GridEntityDoor
TheGauntlet:AddCallback(ModCallbacks.MC_PRE_GRID_ENTITY_DOOR_UPDATE, function (_, door)
    if not DoesDoorLeadToGauntletRoom(door) then return end
    
    local room = Game():GetRoom()
    local isClear = room:IsClear()

    local sprite = door:GetSprite()
    local gridSave = TheGauntlet.SaveManager.GetRoomSave(door:GetGridIndex())

    --I hope this can't happen outside using D7?
    if door.State ~= DoorState.STATE_OPEN then
        if sprite:GetAnimation() == "Close" and gridSave.PreviousAnimation == "Closed" and gridSave.IsOpen == false then
            sprite:Play("Closed", true)
        end
    end
    door.State = DoorState.STATE_OPEN

    --Wack scenario likely from the fact that the original door is a Challenge Door
    if sprite:GetAnimation() == "Open" and gridSave.PreviousAnimation == "Opened" then
        sprite:Play("Opened", true)
    end

    if isClear and not gridSave.WasClear then
        gridSave.IsOpen = true
    end
    if not isClear and gridSave.WasClear then
        gridSave.IsOpen = false
    end

    if not gridSave.FedHeart then
        door.CollisionClass = GridCollisionClass.COLLISION_WALL
    else
        local animation = sprite:GetAnimation()
        if gridSave.IsOpen then
            door.CollisionClass = GridCollisionClass.COLLISION_WALL_EXCEPT_PLAYER

            if animation ~= "Open" and animation ~= "Opened" and animation ~= "KeyOpen" then
                sprite:Play("Open", true)
            end
        else
            door.CollisionClass = GridCollisionClass.COLLISION_WALL

            if animation ~= "Close" and animation ~= "Closed" then
                sprite:Play("Close", true)
            end
        end
    end

    if sprite:IsFinished("KeyOpen") or sprite:IsFinished("Open") then
        sprite:Play("Opened", true)
    end
    if sprite:IsFinished("Close") then
        sprite:Play("Closed", true)
    end

    if sprite:IsEventTriggered("Sound") then
        sfxManager:Play(SoundEffect.SOUND_MEAT_FEET_SLOW0)
        sfxManager:Play(SoundEffect.SOUND_METAL_DOOR_OPEN)
    end
    if gridSave.FedHeart == true then
        if sprite:GetAnimation() == "Open" and gridSave.PreviousAnimation ~= "Open" then
            sfxManager:Play(SoundEffect.SOUND_METAL_DOOR_OPEN)
        end
        if sprite:GetAnimation() == "Close" and gridSave.PreviousAnimation ~= "Close" then
            sfxManager:Play(SoundEffect.SOUND_METAL_DOOR_CLOSE)
        end
    end

    sprite:Update()

    gridSave.WasOpen = gridSave.IsOpen
    gridSave.WasClear = isClear
    gridSave.PreviousAnimation = sprite:GetAnimation()

    return false
end)

---@param collectibleType CollectibleType
---@param rng RNG
---@param player EntityPlayer
---@param useFlags UseFlag
---@param slot ActiveSlot
---@param varData integer
TheGauntlet:AddPriorityCallback(ModCallbacks.MC_USE_ITEM, CallbackPriority.EARLY, function (_, collectibleType, rng, player, useFlags, slot, varData)
    if collectibleType ~= CollectibleType.COLLECTIBLE_D7 then return end

    local room = Game():GetRoom()
    if room:IsClear() then return end

    for _, doorSlot in pairs(DoorSlot) do
        local door = room:GetDoor(doorSlot)
        if door == nil then goto continue end
        if not DoesDoorLeadToGauntletRoom(door) then goto continue end

        local gridSave = TheGauntlet.SaveManager.GetRoomSave(door:GetGridIndex())
        gridSave.IsOpen = false

        ::continue::
    end
end)

---@param door GridEntityDoor
TheGauntlet:AddCallback(ModCallbacks.MC_PRE_GRID_ENTITY_DOOR_RENDER, function (_, door)
    if not DoesDoorLeadToGauntletRoom(door) then return end

    local sprite = door:GetSprite()
    local gridSave = TheGauntlet.SaveManager.GetRoomSave(door:GetGridIndex())

    if not gridSave.FedHeart then
        sprite:Play("KeyClosed", true)
    end
end)

--#region Unlocking the door normally

---@param player EntityPlayer
---@param gridIndex integer
---@param gridEntity GridEntity
TheGauntlet:AddCallback(ModCallbacks.MC_PLAYER_GRID_COLLISION, function (_, player, gridIndex, gridEntity)
    if not Game():GetRoom():IsClear() then return end

    if gridEntity == nil then return end

    if gridEntity:GetType() ~= GridEntityType.GRID_DOOR then return end
    local door = gridEntity:ToDoor()
    if not DoesDoorLeadToGauntletRoom(door) then return end

    local sprite = door:GetSprite()
    local gridSave = TheGauntlet.SaveManager.GetRoomSave(door:GetGridIndex())
    if gridSave.FedHeart == true then return end

    local tookDamage = false
    if player:GetHealthType() ~= HealthType.NO_HEALTH then
        local cooldown = (player:GetTrinketMultiplier(TrinketType.TRINKET_BLIND_RAGE) + 1) * 60
        tookDamage = player:TakeDamage(2, DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_NO_MODIFIERS, EntityRef(nil), cooldown)
    else
        tookDamage = true
    end
    
    if tookDamage then
        gridSave.FedHeart = true
        sprite:Play("KeyOpen", true)
        sfxManager:Play(SoundEffect.SOUND_MEAT_JUMPS)
    end
end)

--#endregion

--#region Unlocking with Sharp Key

---@param tear EntityTear
---@param gridIndex integer
---@param gridEntity GridEntity
TheGauntlet:AddCallback(ModCallbacks.MC_TEAR_GRID_COLLISION, function (_, tear, gridIndex, gridEntity)
    if tear.Variant ~= TearVariant.KEY and tear.Variant ~= TearVariant.KEY_BLOOD then return end

    if gridEntity == nil then return end

    if gridEntity:GetType() ~= GridEntityType.GRID_DOOR then return end
    local door = gridEntity:ToDoor()
    if not DoesDoorLeadToGauntletRoom(door) then return end

    local sprite = door:GetSprite()
    local gridSave = TheGauntlet.SaveManager.GetRoomSave(door:GetGridIndex())

    if not gridSave.FedHeart then
        gridSave.FedHeart = true
        sprite:Play("KeyOpen", true)
        sfxManager:Play(SoundEffect.SOUND_MEAT_JUMPS)
    end
    gridSave.IsOpen = true
end)

--#endregion

--#region Unlocking with Dad's Key

---@param collectibleType CollectibleType
---@param rng RNG
---@param player EntityPlayer
---@param useFlags UseFlag
---@param slot ActiveSlot
---@param varData integer
TheGauntlet:AddPriorityCallback(ModCallbacks.MC_USE_ITEM, CallbackPriority.EARLY, function (_, collectibleType, rng, player, useFlags, slot, varData)
    if collectibleType ~= CollectibleType.COLLECTIBLE_DADS_KEY then return end

    local room = Game():GetRoom()

    for _, doorSlot in pairs(DoorSlot) do
        local door = room:GetDoor(doorSlot)
        if door == nil then goto continue end
        if not DoesDoorLeadToGauntletRoom(door) then goto continue end

        local sprite = door:GetSprite()
        local gridSave = TheGauntlet.SaveManager.GetRoomSave(door:GetGridIndex())

        if not gridSave.FedHeart then
            gridSave.FedHeart = true
            sprite:Play("KeyOpen", true)
            sfxManager:Play(SoundEffect.SOUND_MEAT_JUMPS)
        end
        gridSave.IsOpen = true

        ::continue::
    end
end)

--#endregion

--#region Unlocking with Soul of Cain or Get out of Jail Free Card

---@param card Card
---@param player EntityPlayer
---@param useFlags UseFlag
TheGauntlet:AddPriorityCallback(ModCallbacks.MC_USE_CARD, CallbackPriority.EARLY, function (_, card, player, useFlags)
    if card ~= Card.CARD_GET_OUT_OF_JAIL and card ~= Card.CARD_SOUL_CAIN then return end

    local room = Game():GetRoom()

    for _, doorSlot in pairs(DoorSlot) do
        local door = room:GetDoor(doorSlot)
        if door == nil then goto continue end
        if not DoesDoorLeadToGauntletRoom(door) then goto continue end

        local sprite = door:GetSprite()
        local gridSave = TheGauntlet.SaveManager.GetRoomSave(door:GetGridIndex())

        if not gridSave.FedHeart then
            gridSave.FedHeart = true
            sprite:Play("KeyOpen", true)
            sfxManager:Play(SoundEffect.SOUND_MEAT_JUMPS)
        end
        gridSave.IsOpen = true

        ::continue::
    end
end)

--#endregion

--#region Unlocking with Cracked Orb

---@param entity Entity
---@param damage number
---@param damageFlags DamageFlag
---@param source EntityRef
---@param damageCooldown integer
TheGauntlet:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, function (_, entity, damage, damageFlags, source, damageCooldown)
    if entity.Type ~= EntityType.ENTITY_PLAYER then return end
    ---@type EntityPlayer
    ---@diagnostic disable-next-line assign-type-mismatch
    local player = entity:ToPlayer()

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_CRACKED_ORB) then return end

    local room = Game():GetRoom()

    for _, doorSlot in pairs(DoorSlot) do
        local door = room:GetDoor(doorSlot)
        if door == nil then goto continue end
        if not DoesDoorLeadToGauntletRoom(door) then goto continue end

        local sprite = door:GetSprite()
        local gridSave = TheGauntlet.SaveManager.GetRoomSave(door:GetGridIndex())

        if not gridSave.FedHeart then
            gridSave.FedHeart = true
            sprite:Play("KeyOpen", true)
            sfxManager:Play(SoundEffect.SOUND_MEAT_JUMPS)
        end
        gridSave.IsOpen = true

        local doorPosition = room:GetDoorSlotPosition(doorSlot)
        Isaac.Spawn
        (
            EntityType.ENTITY_EFFECT, EffectVariant.CRACKED_ORB_POOF, 0,
            doorPosition, Vector.Zero,
            nil
        )

        ::continue::
    end
end)

--#endregion

TheGauntlet:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function (_, player)
    local level = Game():GetLevel()

    local rng = RNG(level:GetDungeonPlacementSeed())

    --if rng:RandomFloat() > TheGauntlet.GauntletRoom.GetGenerationChance() then return end

    local entranceRoomConfigToPlace = RoomConfig.GetRandomRoom
    (
        rng:Next(),
        true,
        StbType.SPECIAL_ROOMS, RoomType.ROOM_CHALLENGE, nil,
        nil, nil,
        nil, nil,
        0,
        TheGauntlet.GauntletRoom.CHALLENGE_ROOM_GAUNTLET_SUBTYPE
    )

    local entranceRoomValidPlacementIndexes = level:FindValidRoomPlacementLocations
    (
        entranceRoomConfigToPlace, nil,
        false, false
    )

    if #entranceRoomValidPlacementIndexes == 0 then return end

    level:TryPlaceRoom(entranceRoomConfigToPlace, entranceRoomValidPlacementIndexes[1], nil, rng:Next(), false)

    level:UpdateVisibility()

    InitializeDoors()
end)