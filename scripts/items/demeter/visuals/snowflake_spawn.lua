local snowflakeGeneralRng = RNG()

return function (topLeft, bottomRight)
    local startTimer = snowflakeGeneralRng:RandomInt(60 * 3, 60 * 4)
        
    return {
        Type = TheGauntlet.Items.Demeter.GetSeason(),
        Variant = 0,

        Position = Vector
        (
            TheGauntlet.Utility.RandomFloat(topLeft.X, bottomRight.X, snowflakeGeneralRng),
            TheGauntlet.Utility.RandomFloat(topLeft.Y, topLeft.Y + 60, snowflakeGeneralRng) - 120
        ),

        Speed = Vector
        (
            TheGauntlet.Utility.RandomFloat(-0.2, 0.2, snowflakeGeneralRng),
            TheGauntlet.Utility.RandomFloat(0, 3, snowflakeGeneralRng)
        ),
        AccelerationX = TheGauntlet.Utility.RandomFloat(-0.01, 0.01, snowflakeGeneralRng),

        Size = TheGauntlet.Utility.RandomFloat(1, 2, snowflakeGeneralRng),

        TimeLeft = startTimer,
        StartingTime = startTimer
    }
end