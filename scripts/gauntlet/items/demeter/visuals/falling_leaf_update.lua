local rng = RNG()

---@param instance ParticleInstance
return function (instance)
    instance.Position = instance.Position + instance.Speed
    instance.Speed.X = instance.Speed.X + instance.AccelerationX

    if instance.Type == TheGauntlet.Items.Demeter.Season.SPRING then
        if instance.Speed.X > 1 or instance.Speed.X < 0 then
            instance.AccelerationX = TheGauntlet.Utility.RandomFloat(0, 0.025, rng) * (instance.AccelerationX < 0 and 1 or -1)
        end

        instance.Speed.X = TheGauntlet.Utility.Clamp(instance.Speed.X, 0, 1)
    else
        if instance.Speed.X > 0 or instance.Speed.X < -1 then
            instance.AccelerationX = TheGauntlet.Utility.RandomFloat(-0.025, 0, rng) * (instance.AccelerationX < 0 and 1 or -1)
        end

        instance.Speed.X = TheGauntlet.Utility.Clamp(instance.Speed.X, -1, 0)
    end
end