local function createRandomPedInArea(x, y, z)
    local model = Config.PedModels[math.random(#Config.PedModels)]
    loadModel(model)

    local x = nextStop.x + math.random() * 4 - 2
    local y = nextStop.y + math.random() * 4 - 2
    local heading = math.random() * 360
    
    local ped = CreatePed(4, model, x, y, nextStop.z, heading, true, false)
    FreezeEntityPosition(ped, true)
    return ped
end

local function leaveVehicle(ped, vehicle)
    if IsPedDeadOrDying(ped) then
        RemovePedElegantly(ped)
    else
        ClearPedTasksImmediately(ped, true)
        TaskLeaveVehicle(ped, bus, 64)
    end
end

local function enterVehicle(ped, vehicle, seatNumber)
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

local function isPedInVehicleOrDead(ped, position)
    return GetVehiclePedIsIn(ped, false) or IsPedDeadOrDying(ped, 1)
end

local function isPedInVehicleDeadOrTooFarAway(ped, position)
    if IsPedInAnyVehicle(ped, false) or IsPedDeadOrDying(ped, 1) then
        return true
    end

    return GetDistanceBetweenCoords(GetEntityCoords(ped), position.x, position.y, position.z) > 15
end

local function loadModel(model)
    RequestModel(GetHashKey(model))
    while not HasModelLoaded(GetHashKey(model)) do
        RequestModel(GetHashKey(model))
        Citizen.Wait(10)
    end
end

Peds = {
    CreateRandomPedInArea = createRandomPedInArea,
    LeaveVehicle = leaveVehicle,
    EnterVehicle = enterVehicle,
    IsPedInVehicleOrDead = isPedInVehicleOrDead,
    IsPedInVehicleDeadOrTooFarAway = isPedInVehicleDeadOrTooFarAway
}