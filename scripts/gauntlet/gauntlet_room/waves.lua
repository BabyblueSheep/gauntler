local WAVE_CONFIGURATIONS_NORMAL_MODE = {
    { RoomSubtype = RoomSubType.CHALLENGE_WAVE,      MinDifficulty = 5,  MaxDifficulty = 5 },
    { RoomSubtype = RoomSubType.CHALLENGE_WAVE,      MinDifficulty = 10, MaxDifficulty = 10 },
    { RoomSubtype = RoomSubType.CHALLENGE_WAVE,      MinDifficulty = 10, MaxDifficulty = 10 },
    { RoomSubtype = RoomSubType.CHALLENGE_WAVE,      MinDifficulty = 15, MaxDifficulty = 15 },
    { RoomSubtype = RoomSubType.CHALLENGE_WAVE_BOSS, MinDifficulty = 1,  MaxDifficulty = 1 },
}
local WAVE_CONFIGURATIONS_HARD_MODE = {
    { RoomSubtype = RoomSubType.CHALLENGE_WAVE,      MinDifficulty = 10, MaxDifficulty = 10 },
    { RoomSubtype = RoomSubType.CHALLENGE_WAVE,      MinDifficulty = 15, MaxDifficulty = 15 },
    { RoomSubtype = RoomSubType.CHALLENGE_WAVE,      MinDifficulty = 15, MaxDifficulty = 15 },
    { RoomSubtype = RoomSubType.CHALLENGE_WAVE_BOSS, MinDifficulty = 1,  MaxDifficulty = 1 },
    { RoomSubtype = RoomSubType.CHALLENGE_WAVE_BOSS, MinDifficulty = 5,  MaxDifficulty = 5 },
}

local TIME_BEFORE_DOORS_CLOSE = 10



local game = Game()
local sfxManager = SFXManager()
local musicManager = MusicManager()

local FAKE_PENTAGRAM_VARIANT = Isaac.GetEntityVariantByName("TheGauntlet A Replication and Recreation of a Spawn Pentagram added in Repentance Plus")
local FAKE_PENTAGRAM_SUBTYPE = Isaac.GetEntitySubTypeByName("TheGauntlet A Replication and Recreation of a Spawn Pentagram added in Repentance Plus")

TheGauntlet.GauntletRoom.ItemPool = Isaac.GetPoolIdByName("TheGauntlet gauntletRoom")

TheGauntlet.GauntletRoom.ShadowSpellSoundEffect = Isaac.GetSoundIdByName("TheGauntlet Shadow Spell")

local TIME_BETWEEN_WAVES = 30 --TODO: seems to be correct after verifying, but proper confirmation would be nice

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

--TODO: see if the sprite is accurate to normal ambush indicators
---@param type EntityType
---@param variant integer
---@param subtype integer
---@param position Vector
local function SpawnEnemyIndicator(type, variant, subtype, position)
    local entityConfig = EntityConfig.GetEntity(type, variant, subtype)
    if entityConfig == nil then return end

    local effect = TheGauntlet.Utility.SpawnEffect
    (
        EntityType.ENTITY_EFFECT, FAKE_PENTAGRAM_VARIANT, FAKE_PENTAGRAM_SUBTYPE,
        position, Vector.Zero, nil
    )

    effect:GetData().FakeAmbush = {
        Type = type,
        Variant = variant,
        SubType = subtype
    }

    if entityConfig:IsBoss() then
        effect:GetSprite():Play("Boss Summon", true)
    end

    ---@diagnostic disable-next-line param-type-mismatch
    sfxManager:Play(871)
end

---@param effect EntityEffect
TheGauntlet:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, effect)
    local sprite = effect:GetSprite()
    if sprite:IsFinished() then
        local enemyData = effect:GetData().FakeAmbush

        local entity = TheGauntlet.Utility.SpawnEntity
        (
            enemyData.Type, enemyData.Variant, enemyData.SubType,
            effect.Position, Vector.Zero,
            nil
        )
        effect:Remove()

        entity:AddEntityFlags(EntityFlag.FLAG_AMBUSH)

        ---@diagnostic disable-next-line param-type-mismatch
        sfxManager:Play(872) --SoundEffect.SOUND_SUMMON_WAVE
    end
end, FAKE_PENTAGRAM_VARIANT)

---@param type integer
---@param minDifficulty integer
---@param maxDifficulty integer
local function SpawnAmbush(type, minDifficulty, maxDifficulty)
    local roomSave = TheGauntlet.SaveManager.GetRoomSave()
    local rng = RNG(roomSave.WaveSeed)
    roomSave.WaveSeed = rng:Next()

    local ambushWave = RoomConfig.GetRandomRoom
    (
        roomSave.WaveSeed,
        true,
        Isaac.GetCurrentStageConfigId(), RoomType.ROOM_CHALLENGE, nil,
        nil, nil,
        minDifficulty, maxDifficulty,
        0,
        type
    )

    local room = game:GetRoom()

    for i = 0, #ambushWave.Spawns - 1 do
        local enemySpawn = ambushWave.Spawns:Get(i)
        local enemySpawnEntry = enemySpawn:PickEntry(rng:RandomFloat())

        local gridIndex = enemySpawn.X + 1 + (enemySpawn.Y + 1) * room:GetGridWidth()

        SpawnEnemyIndicator(enemySpawnEntry.Type, enemySpawnEntry.Variant, enemySpawnEntry.Subtype, room:GetGridPosition(gridIndex))
    end
end

TheGauntlet:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function (_)
    if not TheGauntlet.GauntletRoom.IsCurrentRoomGauntletRoom() then return end

    local room = game:GetRoom()

    room:SetItemPool(TheGauntlet.GauntletRoom.ItemPool)

    local roomSave = TheGauntlet.SaveManager.GetRoomSave()
    local tempSave = TheGauntlet.SaveManager.GetTempSave()

    if not tempSave.Init then
        tempSave.WaveDelay = 0
        tempSave.WaveNumber = 0

        tempSave.ProperChallengeStartDelay = TIME_BEFORE_DOORS_CLOSE

        tempSave.DidHostileEnemiesExist = false

        tempSave.Init = true
    end

    if not roomSave.Init then
        roomSave.TeleportSeed = room:GetAwardSeed()
        roomSave.WaveSeed = room:GetAwardSeed()

        roomSave.Init = true
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

    if level:GetDimension() == Dimension.MIRROR then return end
    if room:IsAmbushDone() then return end

    local roomSave = TheGauntlet.SaveManager.GetRoomSave()
    local tempSave = TheGauntlet.SaveManager.GetTempSave()

    if not roomSave.Init then
        roomSave.WaveSeed = room:GetAwardSeed()

        roomSave.Init = true
    end

    if tempSave.ProperChallengeStartDelay > 0 then
        tempSave.ProperChallengeStartDelay = tempSave.ProperChallengeStartDelay - 1

        return
    elseif tempSave.ProperChallengeStartDelay == 0 then
        tempSave.ProperChallengeStartDelay = -1

        for _, doorSlot in pairs(DoorSlot) do
            local door = room:GetDoor(doorSlot)
            if door == nil then goto continue end

            door:Close(true)

            ::continue::
        end
    end

    room:KeepDoorsClosed()

    local doHostileEnemiesExist = false

    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if (entity:IsActiveEnemy(true) and entity:CanShutDoors()) or (entity.Type == EntityType.ENTITY_EFFECT and entity.Variant == FAKE_PENTAGRAM_VARIANT and entity.SubType == FAKE_PENTAGRAM_SUBTYPE) then
            doHostileEnemiesExist = true
            break
        end
    end

    if doHostileEnemiesExist then
        tempSave.WaveDelay = 0
    else
        tempSave.WaveDelay = tempSave.WaveDelay + 1
    end

    if not doHostileEnemiesExist and tempSave.DidHostileEnemiesExist then
        for _, entity in ipairs(Isaac.GetRoomEntities()) do
            if entity:ToPlayer() ~= nil then
                entity:ToPlayer():TriggerRoomClear()
            end
            if entity:ToFamiliar() ~= nil then
                entity:ToFamiliar():TriggerRoomClear()
            end
        end
    end

    if tempSave.WaveDelay > TIME_BETWEEN_WAVES then
        tempSave.WaveDelay = 0

        tempSave.WaveNumber = tempSave.WaveNumber + 1
        local waveConfigurations = Game().Difficulty == Difficulty.DIFFICULTY_HARD and WAVE_CONFIGURATIONS_HARD_MODE or WAVE_CONFIGURATIONS_NORMAL_MODE

        if tempSave.WaveNumber > #waveConfigurations then
            room:SetClear(true)
            room:SetAmbushDone(true)

            musicManager:Play(Music.MUSIC_JINGLE_CHALLENGE_OUTRO, Options.MusicVolume)
            musicManager:UpdateVolume()
            musicManager:Queue(Music.MUSIC_BOSS_OVER)

            OnFinishGauntletRoom()
        else
            if musicManager:GetCurrentMusicID() ~= Music.MUSIC_CHALLENGE_FIGHT then
                musicManager:Play(Music.MUSIC_CHALLENGE_FIGHT, Options.MusicVolume)
                musicManager:UpdateVolume()
            end

            local waveConfiguration = waveConfigurations[tempSave.WaveNumber]
            SpawnAmbush(waveConfiguration.RoomSubtype, waveConfiguration.MinDifficulty, waveConfiguration.MaxDifficulty)
        end
    end

    tempSave.DidHostileEnemiesExist = doHostileEnemiesExist
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
    ---@type EntityPlayer
    ---@diagnostic disable-next-line assign-type-mismatch
    local player = entity:ToPlayer()

    local roomSave = TheGauntlet.SaveManager.GetRoomSave()
    local teleportRNG = RNG(roomSave.TeleportSeed)
    roomSave.TeleportSeed = teleportRNG:Next()

    local currentRoomDescriptor = level:GetCurrentRoomDesc()

    local adjacentRooms = {}
    for _, neighborDescriptor in pairs(currentRoomDescriptor:GetNeighboringRooms()) do
        if neighborDescriptor.Data ~= nil then
            table.insert(adjacentRooms, neighborDescriptor.GridIndex)
        end
    end

    local randomRoomIndex = TheGauntlet.Utility.RandomItemFromList(adjacentRooms, teleportRNG)
    Game():StartRoomTransition(randomRoomIndex, -1, RoomTransitionAnim.TELEPORT)

    sfxManager:Play(TheGauntlet.GauntletRoom.ShadowSpellSoundEffect)
end)
