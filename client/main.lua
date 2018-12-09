local E_KEY = 38

local isOnDuty = false
local isRouteFinished = false
local activeRoute = nil
local stopNumber = 1
local bus = nil
local pedsOnBus = {}
local pedsAtNextStop = {}

local playerPosition = nil
local playerPed = nil

Markers.StartMarkers()
Blips.StartBlips()

Citizen.CreateThread(function ()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

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
            Blips.SetBlipAndWaypoint(activeRoute.Name, activeRoute.SpawnPoint.y, activeRoute.SpawnPoint.z)
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
        Peds.LeaveVehicle(pedsOnBus[i], bus)
    end

    waitUntilPedsOffBus()
    pedsOnBus = {}
    
    Citizen.Wait(3000)

    for i = 1, #pedsAtNextStop do
        Peds.EnterVehicle(pedsOnBus[i], bus, i+2)
    end

    waitUntilPedsOnBus()
    pedsOnBus = pedsAtNextStop
    pedsAtNextStop = {}

    SetVehicleDoorsShut(bus, false)
end

function waitUntilPedsOffBus()
    local stop = activeRoute.Stops[stopNumber]

    if #pedsOnBus == 0 then
        return
    end

    while onCount < #pedsOnBus do
        onCount = 0
        for i = 1, #pedsOnBus do
            if Peds.IsPedInVehicleOrDead(pedsOnBus[i], stop) then
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

    while onCount < #pedsAtNextStop do
        onCount = 0
        for i = 1, #pedsAtNextStop do
            if Peds.IsPedInVehicleDeadOrTooFarAway(pedsOnBus[i], stop) then
                onCount = onCount + 1
            end
            Citizen.Wait(200)
        end
    end
end

function setUpNextStop()
    local nextStop = activeRoute.Stops[stopNumber + 1]

    Markers.SetPositions({nextStop})

    if stopNumber + 1 < #activeRoute.Stops then
        for i = 1, math.random(activeRoute.Capacity) do
            local ped = Peds.CreateRandomPedInArea(nextStop.x, nextStop.y, nextStop.z)
            table.insert(pedsAtNextStop, ped)
        end
    else
        pedsAtNextStop = {}
    end
    
    Blips.SetBlipAndWaypoint(activeRoute.Name, nextStop.x, nextStop.y, nextStop.z)
end