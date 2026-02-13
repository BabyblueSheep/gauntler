---@param door GridEntityDoor
TheGauntlet:AddPriorityCallback(ModCallbacks.MC_PRE_GRID_ENTITY_DOOR_UPDATE, CallbackPriority.IMPORTANT, function (_, door)
    local targetRoom = Game():GetLevel():GetCurrentRoomDesc():GetNeighboringRooms()[door.Slot]
    if targetRoom == nil then return end
    if not TheGauntlet.GauntletRoom.IsRoomGauntletRoom(targetRoom) then return end

    local gridSave = TheGauntlet.SaveManager.GetRoomSave(door:GetGridIndex())
    local sprite = door:GetSprite()

    if not gridSave.Init then
        sprite:Play("Closed", true)

        door.State = DoorState.STATE_CLOSED

        gridSave.FedHeart = false

        gridSave.Init = true
    end

    if gridSave.FedHeart == false then
        door.State = DoorState.STATE_CLOSED
        sprite:Play("Closed", true)
    end
end)

---@param door GridEntityDoor
TheGauntlet:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_DOOR_UPDATE, function (_, door)
    local targetRoom = Game():GetLevel():GetCurrentRoomDesc():GetNeighboringRooms()[door.Slot]
    if targetRoom == nil then return end
    if not TheGauntlet.GauntletRoom.IsRoomGauntletRoom(targetRoom) then return end

    local sprite = door:GetSprite()
    local gridSave = TheGauntlet.SaveManager.GetRoomSave(door:GetGridIndex())

    if sprite:GetFilename() ~= "gfx/grid/door_mausoleum.anm2" then
        local animation = sprite:GetAnimation()
        sprite:Load("gfx/grid/door_mausoleum.anm2", true)
        sprite:Play(animation, true)
    end

    for _, entity in ipairs(Isaac.FindInRadius(door.Position, 32, EntityPartition.PLAYER)) do
        gridSave.FedHeart = true
    end

    --[[
    if pressurePlate:GetSprite():IsEventTriggered("Click") then
        SFXManager():Play(SoundEffect.SOUND_BUTTON_PRESS)
    end

    if pressurePlate:GetSprite():IsPlaying("SwitchedOn") then return end
    if pressurePlate:GetSprite():IsPlaying("SwitchedOff") then return end

    local nearbyPlayers = Isaac.FindInRadius(pressurePlate.Position, 12, EntityPartition.PLAYER)
    local hasNearbyPlayer = false
    for _, player in ipairs(nearbyPlayers) do
        if player:ToPlayer() then
            hasNearbyPlayer = true
            break
        end
    end

    if pressurePlate.State > PRESSURE_PLATE_DEFAULT_STATE + 1 then
        pressurePlate.State = pressurePlate.State - 1
    end
    if hasNearbyPlayer then
        if pressurePlate.State == PRESSURE_PLATE_DEFAULT_STATE then
            pressurePlate.State = PRESSURE_PLATE_DEFAULT_STATE + pressurePlate.VarData
            pressurePlate:GetSprite():Play("SwitchedOn", true)
            SFXManager():Play(SoundEffect.SOUND_BUTTON_PRESS)

            for _, leadVesselGasRenderer in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, SecondaryFloorsMod.Ashpit.Toxic.LeadVessel.GasRenderer.Variant)) do
                local leadVessel = leadVesselGasRenderer.SpawnerEntity
                if leadVessel ~= nil then
                    ---@type EntityNPC
                    ---@diagnostic disable-next-line assign-type-mismatch
                    local leadVesselNpc = leadVessel:ToNPC()
                    leadVesselNpc.I1 = 0
                    leadVesselNpc.I2 = PAUSE_LEAD_VESSEL_TIME

                    ---@type EntityEffect
                    ---@diagnostic disable-next-line assign-type-mismatch
                    local effect = Isaac.Spawn
                    (
                        EntityType.ENTITY_EFFECT, SecondaryFloorsMod.Ashpit.Toxic.LeadVessel.GasRenderer.Variant, leadVesselNpc.SubType,
                        leadVesselNpc.Position, Vector.Zero, leadVesselNpc
                    )
                    effect:Update()
                end
                leadVesselGasRenderer.SpawnerEntity = nil
            end
        end
    else
        if pressurePlate.State == PRESSURE_PLATE_DEFAULT_STATE + 1 then
            pressurePlate.State = PRESSURE_PLATE_DEFAULT_STATE
            pressurePlate:GetSprite():Play("SwitchedOff", true)
        end
    end]]
end)