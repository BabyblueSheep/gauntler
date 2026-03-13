local leafGeneralRng = RNG()

return function (topLeft, bottomRight)
    local startTimer = leafGeneralRng:RandomInt(60 * 3, 60 * 4)

    local season = TheGauntlet.Items.Demeter.GetSeason()
    local spawnOffset = 60
    local speedDirection = -1

    if season == TheGauntlet.Items.Demeter.Season.SPRING then
        spawnOffset = -60
        speedDirection = 1
    end
 
    return {
        Type = season,
        Variant = leafGeneralRng:RandomInt(4),

        Position = Vector
        (
            TheGauntlet.Utility.RandomFloat(topLeft.X, bottomRight.X, leafGeneralRng) + spawnOffset,
            TheGauntlet.Utility.RandomFloat(topLeft.Y, topLeft.Y + 60, leafGeneralRng) - 120
        ),

        Speed = Vector
        (
            TheGauntlet.Utility.RandomFloat(0, 0.5, leafGeneralRng) * speedDirection,
            TheGauntlet.Utility.RandomFloat(0, 2, leafGeneralRng)
        ),
        AccelerationX = TheGauntlet.Utility.RandomFloat(0, 0.025, leafGeneralRng) * speedDirection,

        Size = TheGauntlet.Utility.RandomFloat(0.5, 1.5, leafGeneralRng),

        TimeLeft = startTimer,
        StartingTime = startTimer
    }
end