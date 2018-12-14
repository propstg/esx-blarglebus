function createRandomPedInArea(coords)
    local modelName = loadModel(randomlySelectModel())

    local x = coords.x + math.random() * 4 - 2
    local y = coords.y + math.random() * 4 - 2
    local heading = math.random() * 360
    
    local ped = CreatePed(4, modelName, x, y, coords.z, heading, true, false)
    wanderInArea(ped, coords)
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

function wanderInArea(ped, stopCoords)
    --ClearPedTasksImmediately(ped, true)
    TaskWanderInArea(ped, 
        stopCoords.x,
        stopCoords.y,
        stopCoords.z,
        Config.Marker.Size / 2.0, -- radius
        Config.Marker.Size / 2.0, -- minimalLength
        5000                      -- timeBetweenWalks
    )
end

function enterVehicle(ped, vehicle, seatNumber)
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
        --RequestModel(hashKey)
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

function deletePed(ped)
    SetEntityAsNoLongerNeeded(ped)
    DeletePed(ped)
end

function randomlySelectModel()
    return Config.PedModels[math.random(#Config.PedModels)]
end

Peds = {
    CreateRandomPedInArea = createRandomPedInArea,
    LeaveVehicle = leaveVehicle,
    WanderInArea = wanderInArea,
    EnterVehicle = enterVehicle,
    IsPedInVehicleOrDead = isPedInVehicleOrDead,
    IsPedInVehicleDeadOrTooFarAway = isPedInVehicleDeadOrTooFarAway,
    DeletePed = deletePed
}
