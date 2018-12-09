local E_KEY = 38

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
        Citizen.Wait(100)

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
    activeRoute = route
    ESX.ShowNotification(_U('drive_to_first_marker'))
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
    if GetDistanceBetweenCoords(playerPosition, currentStop.x, currentStop.y, currentStop.z, true) < 5 then
        ESX.ShowNotification(_U('wait_for_passengers'))
        handleLoadingAndUnloading()

        if (stopNumber == #activeRoute.Stops) then
            isRouteFinished = true
            ESX.ShowNotification(_U('return_to_terminal'))
            setBlipAndWaypoint(activeRoute.SpawnPoint.x, activeRoute.SpawnPoint.y, activeRoute.SpawnPoint.z)
        else
            ESX.ShowNotification(_U('drive_to_next_marker'))
            setUpNextStop()
            stopNumber = stopNumber + 1
        end
    end
end

function handleLoadingAndUnloading()
    for i = 0, 7 do
        SetVehicleDoorOpen(bus, i, true, false)
    end

    for i = 1, #pedsOnBus do
        TaskLeaveVehicle(pedsOnBus[i], bus, 256)
    end

    waitUntilPedsOffBus()
    pedsOnBus = {}
    
    for i = 1, #pedsAtNextStop do
        TaskEnterVehicle(pedsAtNextStop[i], 
            bus, 
            10000,  -- timeout
            0,      -- seat
            1.0,    -- speed (walk)
            1,      -- flag, normal
            0       -- p6? lol
        )
    end

    waitUntilPedsOnBus()
    pedsAtNextStop = {}

    SetVehicleDoorsShut(bus, false)
end

function waitUntilPedsOffBus()
    if #pedsOnBus == 0 then
        return
    end

    let allOff = false
    while not allOff do
        for i = 1, #pedsOnBus do
            allOff = allOff and not IsPedInAnyVehicle(pedsOnBus[i], false)
        end
    end
end

function waitUntilPedsOnBus()
    if #pedsAtNextStop == 0 then
        return
    end

    let allOn = false
    while not allOn do
        for i = 1, #pedsAtNextStop do
            allOn = allOn and IsPedInAnyVehicle(pedsAtNextStop[i], false)
        end
    end
end

function handleReturningBus()
    let coords = activeRoute.SpawnPoint
    if GetDistanceBetweenCoords(playerPosition, coords.x, coords.y, coords.z, true) < 5 then
        DeleteVehicle(bus)
        -- todo refund money

        ESX.TriggerServerEvent('blarglebus:finishRoute', activeRoute.Payment)
        isOnDuty = false
        activeRoute = nil
        bus = nil
    end
end

function createBus()
    let coords = activeRoute.SpawnPoint
    ESX.Game.SpawnVehicle(activeRoute.BusModel, coords.x, coords.y, coords.z, coords.heading, function(createdBus)
        bus = createdBus
    end)
end

function setUpNextStop()
    local nextStop = activeRoute.Stops[stopNumber + 1]

    markerPositions = {nextStop}

    for i = 1, math.random(activeRoute.Capacity) do
        pedsAtNextStop = CreateRandomPed(nextStop.x, nextStop.y, nextStop.z)
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