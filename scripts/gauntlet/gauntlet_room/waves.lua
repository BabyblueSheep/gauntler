TheGauntlet.GauntletRoom.Constants.WAVE_CONFIGURATIONS_NORMAL_MODE = {
    { RoomSubtype = RoomSubType.CHALLENGE_WAVE,      MinDifficulty = 1,  MaxDifficulty = 1  },
    { RoomSubtype = RoomSubType.CHALLENGE_WAVE,      MinDifficulty = 5,  MaxDifficulty = 5  },
    { RoomSubtype = RoomSubType.CHALLENGE_WAVE,      MinDifficulty = 5,  MaxDifficulty = 5  },
    { RoomSubtype = RoomSubType.CHALLENGE_WAVE_BOSS, MinDifficulty = 1,  MaxDifficulty = 1  },
    { RoomSubtype = RoomSubType.CHALLENGE_WAVE_BOSS, MinDifficulty = 5,  MaxDifficulty = 5  },
}
TheGauntlet.GauntletRoom.Constants.WAVE_CONFIGURATIONS_HARD_MODE = {
    { RoomSubtype = RoomSubType.CHALLENGE_WAVE,      MinDifficulty = 5,  MaxDifficulty = 5  },
    { RoomSubtype = RoomSubType.CHALLENGE_WAVE,      MinDifficulty = 10, MaxDifficulty = 10 },
    { RoomSubtype = RoomSubType.CHALLENGE_WAVE,      MinDifficulty = 10, MaxDifficulty = 10 },
    { RoomSubtype = RoomSubType.CHALLENGE_WAVE_BOSS, MinDifficulty = 5,  MaxDifficulty = 5  },
    { RoomSubtype = RoomSubType.CHALLENGE_WAVE_BOSS, MinDifficulty = 10, MaxDifficulty = 10 },
}

local TIME_BETWEEN_WAVES = 30
local TIME_BEFORE_DOORS_CLOSE = 10



local game = Game()
local sfxManager = SFXManager()
local musicManager = MusicManager()

local FAKE_PENTAGRAM_VARIANT = Isaac.GetEntityVariantByName("TheGauntlet A Replication and Recreation of a Spawn Pentagram added in Repentance Plus")

TheGauntlet.GauntletRoom.ITEM_POOL_ID = Isaac.GetPoolIdByName("TheGauntlet gauntletRoom")

TheGauntlet.GauntletRoom.SHADOW_SPELL_SOUND_EFFECT = Isaac.GetSoundIdByName("TheGauntlet Shadow Spell")

---Gets the current wave number in the Gauntlet Room.
---@return integer | nil
function TheGauntlet.GauntletRoom.GetCurrentWaveNumber()
    local tempSave = TheGauntlet.DataHolder.GetTemporaryNoHourglassData()
    if tempSave.GauntletRoom == nil then return -1 end
    return tempSave.GauntletRoom.WaveNumber
end

---Gets the current wave configuration set.
---@return table
function TheGauntlet.GauntletRoom.GetDefaultWaveConfigurations()
    local waveConfiguration = TheGauntlet.GauntletRoom.Constants.WAVE_CONFIGURATIONS_NORMAL_MODE

    if game.Difficulty == Difficulty.DIFFICULTY_HARD or game.Difficulty == Difficulty.DIFFICULTY_GREEDIER then
        waveConfiguration = TheGauntlet.GauntletRoom.Constants.WAVE_CONFIGURATIONS_HARD_MODE
    end

    return waveConfiguration
end

local function OnFinishGauntletRoom()
    local room = game:GetRoom()

    local collectibleSpawnPosition = room:FindFreePickupSpawnPosition(room:GetCenterPos())

    TheGauntlet.Utility.SpawnPickup
    (
        EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, 0,
        collectibleSpawnPosition, Vector.Zero,
        nil
    )

    --This is where I would put Temporary Tattoo's effect, but it already spawns a chest (the intended effect) so it works out. lol
    room:TriggerClear(true)
end

---@param type EntityType
---@param variant integer
---@param subtype integer
---@param position Vector
local function SpawnEnemyIndicator(type, variant, subtype, position)
    local entityConfig = EntityConfig.GetEntity(type, variant, subtype)
    if entityConfig == nil then return end

    local effect = TheGauntlet.Utility.SpawnEffect
    (
        EntityType.ENTITY_EFFECT, FAKE_PENTAGRAM_VARIANT, 0,
        position, Vector.Zero, nil
    )
    local data = TheGauntlet.DataHolder.GetTemporaryNoHourglassData(effect)

    data.FakeAmbush = {
        Type = type,
        Variant = variant,
        SubType = subtype
    }

    --This seems to be correct, but who knows
    effect.SpriteScale = Vector.One * entityConfig:GetCollisionRadius() / 16

    effect.SortingLayer = SortingLayer.SORTING_BACKGROUND

    sfxManager:Play(871) --SoundEffect.SOUND_SUMMON_PENTA
end

---@param effect EntityEffect
TheGauntlet:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, effect)
    local sprite = effect:GetSprite()
    if sprite:IsFinished() then
        local data = TheGauntlet.DataHolder.GetTemporaryNoHourglassData(effect)
        local enemyData = data.FakeAmbush

        local entity = TheGauntlet.Utility.SpawnEntity
        (
            enemyData.Type, enemyData.Variant, enemyData.SubType,
            effect.Position, Vector.Zero,
            nil
        )
        effect:Remove()

        entity:AddEntityFlags(EntityFlag.FLAG_AMBUSH)

        sfxManager:Play(872) --SoundEffect.SOUND_SUMMON_WAVE
    end
end, FAKE_PENTAGRAM_VARIANT)

---@param roomType integer
---@param minDifficulty integer
---@param maxDifficulty integer
local function SpawnAmbush(roomType, minDifficulty, maxDifficulty)
    local roomSave = TheGauntlet.SaveManager.GetRoomSave()
    local rng = RNG(roomSave.GauntletRoom.WaveSeed)
    roomSave.GauntletRoom.WaveSeed = rng:Next()

    local ambushWave = RoomConfig.GetRandomRoom
    (
        roomSave.GauntletRoom.WaveSeed,
        true,
        Isaac.GetCurrentStageConfigId(), RoomType.ROOM_CHALLENGE, nil,
        nil, nil,
        minDifficulty, maxDifficulty,
        nil,
        roomType
    )
    local ambushWaveStageAPI

    local returnedValue = Isaac.RunCallback(TheGauntlet.Utility.Callbacks.PRE_SELECT_GAUNTLET_ROOM_WAVE, ambushWave)
    if type(returnedValue) == "userdata" and getmetatable(returnedValue).__type == "RoomConfigRoom" then
        ambushWave = returnedValue
    elseif type(returnedValue) == "table" then
        ambushWaveStageAPI = returnedValue
    end

    local room = game:GetRoom()

    if ambushWaveStageAPI and StageAPI then
        local spawnEntities = StageAPI.ObtainSpawnObjects(returnedValue, roomSave.GauntletRoom.WaveSeed, true)

        for gridIndex, entityData in pairs(spawnEntities) do
            SpawnEnemyIndicator(entityData[1].Data.Type, entityData[1].Data.Variant, entityData[1].Data.SubType, room:GetGridPosition(gridIndex))
        end
    else
        for i = 0, #ambushWave.Spawns - 1 do
            local enemySpawn = ambushWave.Spawns:Get(i)
            local enemySpawnEntry = enemySpawn:PickEntry(rng:RandomFloat())

            local gridIndex = enemySpawn.X + 1 + (enemySpawn.Y + 1) * room:GetGridWidth()

            SpawnEnemyIndicator(enemySpawnEntry.Type, enemySpawnEntry.Variant, enemySpawnEntry.Subtype, room:GetGridPosition(gridIndex))
        end
    end
end

TheGauntlet:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function (_)
    if not TheGauntlet.GauntletRoom.IsCurrentRoomGauntletRoom() then return end

    local room = game:GetRoom()

    room:SetItemPool(TheGauntlet.GauntletRoom.ITEM_POOL_ID)

    local roomSave = TheGauntlet.SaveManager.GetRoomSave()
    local tempSave = TheGauntlet.DataHolder.GetTemporaryNoHourglassData()

    tempSave.GauntletRoom = {
        WaveDelay = 0,
        WaveNumber = 0,

        ProperChallengeStartDelay = TIME_BEFORE_DOORS_CLOSE,

        DidHostileEnemiesExist = false,
        IsGauntletAmbushOngoing = false,
    }

    if not roomSave.GauntletRoom then
        roomSave.GauntletRoom = {
            TeleportSeed = room:GetAwardSeed(),
            WaveSeed = room:GetAwardSeed()
        }
    end

    if room:IsAmbushDone() then
        musicManager:Play(Music.MUSIC_BOSS_OVER, Options.MusicVolume)
        musicManager:UpdateVolume()
    end
end)

TheGauntlet:AddCallback(ModCallbacks.MC_POST_UPDATE, function (_)
    if not TheGauntlet.GauntletRoom.IsCurrentRoomGauntletRoom() then return end

    local level = game:GetLevel()
    local room = game:GetRoom()

    local tempSave = TheGauntlet.DataHolder.GetTemporaryNoHourglassData()

    if level:GetDimension() == Dimension.MIRROR then return end
    if room:IsAmbushDone() then
        tempSave.GauntletRoom.IsGauntletAmbushOngoing = false
        return
    end

    if tempSave.GauntletRoom.ProperChallengeStartDelay > 0 then
        tempSave.GauntletRoom.ProperChallengeStartDelay = tempSave.GauntletRoom.ProperChallengeStartDelay - 1

        return
    elseif tempSave.GauntletRoom.ProperChallengeStartDelay == 0 then
        tempSave.GauntletRoom.ProperChallengeStartDelay = -1

        for _, doorSlot in pairs(DoorSlot) do
            local door = room:GetDoor(doorSlot)
            if door == nil then goto continue end

            door:Close(true)

            musicManager:Play(Music.MUSIC_CHALLENGE_FIGHT, Options.MusicVolume)
            musicManager:UpdateVolume()

            ::continue::
        end
    end

    room:KeepDoorsClosed()

    tempSave.GauntletRoom.IsGauntletAmbushOngoing = true

    local doHostileEnemiesExist = false

    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if (entity:IsActiveEnemy(true) and entity:CanShutDoors()) or (entity.Type == EntityType.ENTITY_EFFECT and entity.Variant == FAKE_PENTAGRAM_VARIANT) then
            doHostileEnemiesExist = true
            break
        end
    end

    if doHostileEnemiesExist then
        tempSave.GauntletRoom.WaveDelay = 0
    else
        tempSave.GauntletRoom.WaveDelay = tempSave.GauntletRoom.WaveDelay + 1
    end

    if not doHostileEnemiesExist and tempSave.GauntletRoom.DidHostileEnemiesExist then
        for _, entity in ipairs(Isaac.GetRoomEntities()) do
            if entity:ToPlayer() ~= nil then
                entity:ToPlayer():TriggerRoomClear()
            end
            if entity:ToFamiliar() ~= nil then
                entity:ToFamiliar():TriggerRoomClear()
            end
        end
    end

    if tempSave.GauntletRoom.WaveDelay > TIME_BETWEEN_WAVES then
        tempSave.GauntletRoom.WaveDelay = 0

        tempSave.GauntletRoom.WaveNumber = tempSave.GauntletRoom.WaveNumber + 1
        local waveConfigurations = TheGauntlet.GauntletRoom.GetDefaultWaveConfigurations()

        if tempSave.GauntletRoom.WaveNumber > #waveConfigurations then
            room:SetClear(true)
            room:SetAmbushDone(true)

            tempSave.GauntletRoom.IsGauntletAmbushOngoing = false

            musicManager:Play(Music.MUSIC_JINGLE_CHALLENGE_OUTRO, Options.MusicVolume)
            musicManager:UpdateVolume()
            musicManager:Queue(Music.MUSIC_BOSS_OVER)

            OnFinishGauntletRoom()
        else
            local waveConfiguration = waveConfigurations[tempSave.GauntletRoom.WaveNumber]
            SpawnAmbush(waveConfiguration.RoomSubtype, waveConfiguration.MinDifficulty, waveConfiguration.MaxDifficulty)
        end
    end

    tempSave.GauntletRoom.DidHostileEnemiesExist = doHostileEnemiesExist
end)

---@param entity Entity
---@param damage number
---@param damageFlags DamageFlag
---@param source EntityRef
---@param damageCooldown integer
TheGauntlet:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, function (_, entity, damage, damageFlags, source, damageCooldown)
    if not TheGauntlet.GauntletRoom.IsCurrentRoomGauntletRoom() then return end

    local level = game:GetLevel()
    local room = game:GetRoom()

    if level:GetDimension() == Dimension.MIRROR then return end
    if room:IsAmbushDone() then return end

    if damageFlags & DamageFlag.DAMAGE_FAKE == DamageFlag.DAMAGE_FAKE then return end
    if damageFlags & DamageFlag.DAMAGE_NO_PENALTIES == DamageFlag.DAMAGE_NO_PENALTIES then return end

    if entity.Type ~= EntityType.ENTITY_PLAYER then return end

    local roomSave = TheGauntlet.SaveManager.GetRoomSave()
    local teleportRNG = RNG(roomSave.GauntletRoom.TeleportSeed)
    roomSave.GauntletRoom.TeleportSeed = teleportRNG:Next()

    local currentRoomDescriptor = level:GetCurrentRoomDesc()

    local adjacentRooms = {}
    for _, neighborDescriptor in pairs(currentRoomDescriptor:GetNeighboringRooms()) do
        if neighborDescriptor.Data ~= nil then
            table.insert(adjacentRooms, neighborDescriptor.GridIndex)
        end
    end

    local randomRoomIndex = TheGauntlet.Utility.RandomItemFromList(adjacentRooms, teleportRNG)
    game:StartRoomTransition(randomRoomIndex, -1, RoomTransitionAnim.TELEPORT)

    sfxManager:Play(TheGauntlet.GauntletRoom.SHADOW_SPELL_SOUND_EFFECT)
end)
