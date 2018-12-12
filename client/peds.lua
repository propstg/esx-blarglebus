function createRandomPedInArea(x, y, z)
    local modelName = loadModel(randomlySelectModel())

    x = x + math.random() * 4 - 2
    y = y + math.random() * 4 - 2
    local heading = math.random() * 360
    
    local ped = CreatePed(4, modelName, x, y, z, heading, true, false)
    FreezeEntityPosition(ped, true)
    return ped
end

function leaveVehicle(ped, vehicle)
    if IsPedDeadOrDying(ped) then
        RemovePedElegantly(ped)
    else
        ClearPedTasksImmediately(ped, true)
        TaskLeaveVehicle(ped, bus, 64)
    end
end

function enterVehicle(ped, vehicle, seatNumber)
    FreezeEntityPosition(ped, false)
    Citizen.Wait(10)
    TaskEnterVehicle(ped, 
        vehicle, 
        Config.EnterVehicleTimeout, -- timeout
        seatNumber,                 -- seat
        1.0,                        -- speed (walk)
        1,                          -- flag, normal
        0                           -- p6? lol
    )
end

function isPedInVehicleOrDead(ped, position)
    return GetVehiclePedIsIn(ped, false) or IsPedDeadOrDying(ped, 1)
end

function isPedInVehicleDeadOrTooFarAway(ped, position)
    if IsPedInAnyVehicle(ped, false) or IsPedDeadOrDying(ped, 1) then
        return true
    end

    return GetDistanceBetweenCoords(GetEntityCoords(ped), position.x, position.y, position.z) > 15
end

function loadModel(modelName)
    local loadAttempts = 0
    local hashKey = GetHashKey(modelName)

    RequestModel(hashKey)
    while not HasModelLoaded(hashKey) and loadAttempts < 10 do
        RequestModel(hashKey)
        loadAttempts = loadAttempts + 1
        Citizen.Wait(50)
    end

    if loadAttempts == 10 then
        print ('MODEL NOT LOADED AFTER TEN ATTEMPTS: ' .. modelName)
        return loadModel(randomlySelectModel())
    end

    print ('Successfully loaded model: ' .. modelName)
    return modelName
end

function randomlySelectModel()
    return Config.PedModels[math.random(#Config.PedModels)]
end

Peds = {
    CreateRandomPedInArea = createRandomPedInArea,
    LeaveVehicle = leaveVehicle,
    EnterVehicle = enterVehicle,
    IsPedInVehicleOrDead = isPedInVehicleOrDead,
    IsPedInVehicleDeadOrTooFarAway = isPedInVehicleDeadOrTooFarAway
}