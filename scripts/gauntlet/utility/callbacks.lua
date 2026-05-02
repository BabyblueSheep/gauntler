TheGauntlet.Utility.Callbacks = {
    ---Called during Gauntlet Room chance calculation, while applying the stage penalty (to not spawn them in Chapters 1 & 6+).
    ---Use this to override the check for stages, i.e. if you're making a custom stage mod.
    ---
    ---Returns:
    --- - Return a boolean to override applying the penalty. If anything else is returned, default behavior is used.
    PRE_GAUNTLET_ROOM_GENERATION_CHANCE_APPLY_STAGE_PENALTY = "TheGauntlet PRE_GAUNTLET_ROOM_GENERATION_CHANCE_APPLY_STAGE_PENALTY",

    ---Called during Gauntlet Room chance calculation, after ensuring that Gauntlet Rooms can generate.
    ---Use this to override or change the base chance.
    ---
    ---Parameters:
    --- - [number](lua://number) - the current chance;
    ---
    ---Returns:
    --- - Return a number to set the new chance.
    PRE_GAUNTLET_ROOM_GENERATION_CHANCE_GET_DEFAULT_CHANCE = "TheGauntlet PRE_GAUNTLET_ROOM_GENERATION_CHANCE_GET_DEFAULT_CHANCE",

    ---Called during Gauntlet Room chance calculation, before forcing the chance to its base value if a Gauntlet Room has been completed.
    ---Use this to continue Gauntlet Room generation even after a Gauntlet Room has been completed.
    ---
    ---Returns:
    --- - Return a boolean to override applying the penalty. If anything else is returned, default behavior is used.
    PRE_GAUNTLET_ROOM_GENERATION_CHANCE_APPLY_GAUNTLET_PENALTY = "TheGauntlet PRE_GAUNTLET_ROOM_GENERATION_CHANCE_APPLY_GAUNTLET_PENALTY",

    ---Called during Gauntlet Room chance calculation, before applying boosts for completing Challenge rooms and having items.
    ---Use this to apply boosts before anything else (potentially, any additive boosts).
    ---
    ---Parameters:
    --- - [number](lua://number) - the current chance;
    ---
    ---Returns:
    --- - Return a number to set the new chance.
    PRE_GAUNTLET_ROOM_GENERATION_CHANCE_APPLY_BOOSTS = "TheGauntlet PRE_GAUNTLET_ROOM_GENERATION_CHANCE_APPLY_BOOSTS",

    ---Called during Gauntlet Room chance calculation, after applying boosts for completing Challenge rooms and having items.
    ---Use this to apply boosts before anything else (potentially, any multiplicative boosts).
    ---
    ---Parameters:
    --- - [number](lua://number) - the current chance;
    ---
    ---Returns:
    --- - Return a number to set the new chance.
    POST_GAUNTLET_ROOM_GENERATION_CHANCE_APPLY_BOOSTS = "TheGauntlet POST_GAUNTLET_ROOM_GENERATION_CHANCE_APPLY_BOOSTS",

    ---Called during Gauntlet Room chance calculation, after all calculations have been done.
    ---Use this to do fully custom chance calculation.
    ---
    ---Parameters:
    --- - [number](lua://number) - the current chance;
    ---
    ---Returns:
    --- - Return a number to set the new chance.
    POST_GAUNTLET_ROOM_GENERATION_CHANCE_CALCULATE = "TheGauntlet POST_GAUNTLET_ROOM_GENERATION_CHANCE_CALCULATE",

    ---Called when finishing all waves of a challenge room.
    ---
    ---Parameters:
    --- - [ChallengeRoomType](lua://ChallengeRoomType) - the type of the current challenge room;
    ---
    ---Optional Parameter:
    --- - [ChallengeRoomType](lua://ChallengeRoomType) - the type of the current challenge room;
    POST_CHALLENGE_ROOM_TRIGGER_CLEARED = "TheGauntlet POST_CHALLENGE_ROOM_TRIGGER_CLEARED",

    ---Called when selecting a room layout for a Gauntlet wave.
    ---
    ---Parameters:
    --- - [RoomConfigRoom](lua://RoomConfigRoom) - the default room layout selected for the wave;
    --- 
    --- Returns:
    ---  - Return either a [RoomConfigRoom](lua://RoomConfigRoom) or a table (assumed to be a Lua Room) to use that for the wave.
    PRE_SELECT_GAUNTLET_ROOM_WAVE = "TheGauntlet PRE_SELECT_GAUNTLET_ROOM_WAVE",

    ---Called before a Gauntlet Room is placed on the floor. Can be used to change the room layout before placing it.
    ---
    ---Parameters:
    --- - [integer](lua://integer) - the index the room will be located at;
    --- - [RoomConfigRoom](lua://RoomConfigRoom) - the RoomConfig to place;
    --- - [Dimension](lua://Dimension) - the dimension the room wiil be placed in;
    ---
    ---Returns:
    --- - Return a [RoomConfigRoom](lua://RoomConfigRoom) to place a different room layout.
    PRE_PLACE_GAUNTLET_ROOM = "TheGauntlet PRE_PLACE_GAUNTLET_ROOM",

    ---Called after a Gauntlet Room is placed on the floor.
    ---
    ---Parameters:
    --- - [integer](lua://integer) - the index the room is located at;
    --- - [integer](lua://integer) - the dimension the room was placed in;
    POST_PLACE_GAUNTLET_ROOM = "TheGauntlet POST_PLACE_GAUNTLET_ROOM",

    ---Called when Hera checks if an enemy can be impregnated. Can be used to force an enemy not to be impregnatable.
    ---
    ---Parameters:
    --- - [Entity](lua://Entity) - the entity to check;
    ---
    ---Returns:
    --- - Return a boolean to force the enemy to be impregnatable. Otherwise, return nil to use default checks.
    HERA_CAN_ENTITY_BE_IMPREGNANTED = "TheGauntlet HERA_CAN_ENTITY_BE_IMPREGNANTED"
}

---@enum ChallengeRoomType
TheGauntlet.Utility.ChallengeRoomType = {
    NORMAL = 0,
    BOSS = 1,
    GAUNTLET = 2,
}

TheGauntlet:AddCallback(ModCallbacks.MC_POST_UPDATE, function (_)
    local room = Game():GetRoom()
    local level = Game():GetLevel()

    if level:GetCurrentRoomDesc().Data.Type ~= RoomType.ROOM_CHALLENGE then return end

    local roomSave = TheGauntlet.SaveManager.GetRoomSave()

    if roomSave.WasAmbushDone == nil then
        roomSave.WasAmbushDone = room:IsAmbushDone()
    end
    
    if room:IsAmbushDone() and not roomSave.WasAmbushDone then
        local roomType = TheGauntlet.Utility.ChallengeRoomType.NORMAL
        if level:GetCurrentRoomDesc().Data.Subtype == TheGauntlet.GauntletRoom.CHALLENGE_ROOM_GAUNTLET_SUBTYPE then
            roomType = TheGauntlet.Utility.ChallengeRoomType.GAUNTLET
        elseif level:GetCurrentRoomDesc().Data.Subtype == RoomSubType.CHALLENGE_BOSS then
            roomType = TheGauntlet.Utility.ChallengeRoomType.BOSS
        end

        Isaac.RunCallbackWithParam(TheGauntlet.Utility.Callbacks.POST_CHALLENGE_ROOM_TRIGGER_CLEARED, roomType, roomType)
    end

    roomSave.WasAmbushDone = room:IsAmbushDone()
end)