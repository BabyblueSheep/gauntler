---@param instance ParticleInstance
return function (instance)
    instance.Position = instance.Position + instance.Speed
    instance.Speed.X = instance.Speed.X + instance.AccelerationX
    instance.Speed.X = TheGauntlet.Utility.Clamp(instance.Speed.X, -0.2, 0.2)
end