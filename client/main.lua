local E_KEY = 38
--local model = "s_f_y_hooker_01"

local routeBlips = {}

local isOnDuty = false
local isRouteFinished = false
local activeRoute = nil
local stopNumber = 1
local bus = nil
local pedsOnBus = {}
local pedsAtNextStop = {}

local playerPosition = nil
local playerPed = nil

local markerPositions = {}

Citizen.CreateThread(function ()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    initBlips()
    initNotOnDutyMarkers()

    while true do
        Citizen.Wait(30)

        playerPed = PlayerPedId()
        playerPosition = GetEntityCoords(playerPed)

        if not isOnDuty then
            for i = 1, #Config.Routes do
                handleSpawnPoint(i)
            end
        else
            handleActiveRoute()
        end
    end
end)

Citizen.CreateThread(function ()
    while true do
        Citizen.Wait(10)

        for i = 1, #markerPositions do
            drawCircle(markerPositions[i])
        end
    end
end)

function initBlips()
    for i = 1, #Config.Routes do
        local coords = Config.Routes[i].SpawnPoint
        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(blip, 513)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(_U(Config.Routes[i].Name))
        EndTextCommandSetBlipName(blip)
        routeBlips[Config.Routes[i].Name] = blip
    end
end

function initNotOnDutyMarkers()
    for i = 1, #Config.Routes do
        table.insert(markerPositions, Config.Routes[i].SpawnPoint)
    end
end

function handleSpawnPoint(locationIndex)
    local route = Config.Routes[locationIndex]
    local coords = route.SpawnPoint;
    
    if GetDistanceBetweenCoords(playerPosition, coords.x, coords.y, coords.z, true) < Config.Marker.Size then
        ESX.ShowHelpNotification(_U('start_'..route.Name))

        if IsControlJustPressed(1, E_KEY) then
            startRoute(locationIndex)
        end
    end
end

function startRoute(route)
    isOnDuty = true
    isRouteFinished = false
    activeRoute = Config.Routes[route]
    ESX.ShowNotification(_U('drive_to_first_marker', activeRoute.Stops[1].name))
    createBus()

    -- TODO charge player for bus rental

    stopNumber = 0
    setUpNextStop()
    stopNumber = 1
end

function handleActiveRoute()
    if isRouteFinished then
        handleReturningBus()
    else
        handleNormalStop()
    end
end

function handleNormalStop()
    local currentStop = activeRoute.Stops[stopNumber]
    if GetDistanceBetweenCoords(playerPosition, currentStop.x, currentStop.y, currentStop.z, true) < Config.Marker.Size then
        ESX.ShowNotification(_U('wait_for_passengers'))
        handleLoadingAndUnloading()

        if (stopNumber == #activeRoute.Stops) then
            isRouteFinished = true
            ESX.ShowNotification(_U('return_to_terminal'))
            setBlipAndWaypoint(activeRoute.SpawnPoint.x, activeRoute.SpawnPoint.y, activeRoute.SpawnPoint.z)
        else
            ESX.ShowNotification(_U('drive_to_next_marker', activeRoute.Stops[stopNumber + 1].name))
            setUpNextStop()
            stopNumber = stopNumber + 1
        end
    end
end

function handleLoadingAndUnloading()
    while not IsVehicleStopped(bus) do
        ESX.ShowNotification(_U('wait_for_passengers'))
        Citizen.Wait(500)
    end

    for i = 2, 3 do
        SetVehicleDoorOpen(bus, i, false, false)
    end

    Citizen.Wait(3000)

    for i = 1, #pedsOnBus do
        ClearPedTasksImmediately(pedsOnBus[i], true)
        TaskLeaveVehicle(pedsOnBus[i], bus, 64)
    end

    waitUntilPedsOffBus()
    pedsOnBus = {}
    
    Citizen.Wait(3000)

    for i = 1, #pedsAtNextStop do
        FreezeEntityPosition(pedsAtNextStop[i], false)
        Citizen.Wait(10)
        TaskEnterVehicle(pedsAtNextStop[i], 
            bus, 
            5000,   -- timeout
            i + 2,  -- seat
            1.0,    -- speed (walk)
            1,      -- flag, normal
            0       -- p6? lol
        )
    end

    waitUntilPedsOnBus()
    pedsOnBus = pedsAtNextStop
    pedsAtNextStop = {}

    SetVehicleDoorsShut(bus, false)
end

function waitUntilPedsOffBus()
    if #pedsOnBus == 0 then
        return
    end

    local onCount = 0
    while onCount < #pedsOnBus do
        onCount = 0
        for i = 1, #pedsOnBus do
            if GetVehiclePedIsIn(pedsOnBus[i], false) or IsPedDeadOrDying(pedsAtNextStop[i], 1) then
                onCount = onCount + 1
            end
            Citizen.Wait(200)
        end
    end
end

function waitUntilPedsOnBus()
    local stop = activeRoute.Stops[stopNumber]

    if #pedsAtNextStop == 0 then
        return
    end

    local onCount = 0
    while onCount < #pedsAtNextStop do
        onCount = 0
        for i = 1, #pedsAtNextStop do
            local pedPosition  = GetEntityCoords(pedsAtNextStop[i])
            local distance = GetDistanceBetweenCoords(pedPosition, stop.x, stop.y, stop.z)
            if IsPedInAnyVehicle(pedsAtNextStop[i], false) or IsPedDeadOrDying(pedsAtNextStop[i], 1) or distance > 15 then
                onCount = onCount + 1
            end
            Citizen.Wait(100)
        end
    end
end

function handleReturningBus()
    local coords = activeRoute.SpawnPoint
    markerPositions = {coords}
    if GetDistanceBetweenCoords(playerPosition, coords.x, coords.y, coords.z, true) < Config.Marker.Size then
        DeleteVehicle(bus)
        -- todo refund money

        TriggerServerEvent('blarglebus:finishRoute', activeRoute.Payment)
        isOnDuty = false
        activeRoute = nil
        bus = nil
    end
end

function createBus()
    local coords = activeRoute.SpawnPoint
    ESX.Game.SpawnVehicle(activeRoute.BusModel, coords, coords.heading, function(createdBus)
        bus = createdBus
        SetVehicleFuelLevel(bus, 100.0)
    end)
end

function setUpNextStop()
    local nextStop = activeRoute.Stops[stopNumber + 1]

    markerPositions = {nextStop}

    if stopNumber + 1 < #activeRoute.Stops then
        for i = 1, math.random(activeRoute.Capacity) do
            local model = Config.PedModels[math.random(#Config.PedModels)]
            local ped = createPed(model, nextStop.x + math.random() * 5 - 2.5, nextStop.y + math.random() * 5 - 2.5, nextStop.z, math.random(365))
            FreezeEntityPosition(ped, true)
            table.insert(pedsAtNextStop, ped)
        end
    else
        pedsAtNextStop = {}
    end
    
    setBlipAndWaypoint(nextStop.x, nextStop.y, nextStop.z)
end

function setBlipAndWaypoint(x, y, z)
    SetBlipCoords(routeBlips[activeRoute.Name], x, y, z)
    SetNewWaypoint(x, y)
end

function drawCircle(coords)
    local markerSize = Config.Marker.Size
    DrawMarker(1, coords.x, coords.y, coords.z, 0, 0, 0, 0, 0, 0, markerSize, markerSize, markerSize, 20, 200, 20, 100, 0, 0, 2, 0, 0, 0, 0)
end

function createPed(model, x, y, z, heading)
    loadModel(model)
    return CreatePed(4, model, x, y, z, heading, true, false)
end

function loadModel(model)
    RequestModel(GetHashKey(model))
    while not HasModelLoaded(GetHashKey(model)) do
        RequestModel(GetHashKey(model))
        Citizen.Wait(10)
    end
end

