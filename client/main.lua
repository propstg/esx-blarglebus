local E_KEY = 38

local isOnDuty = false
local isRouteFinished = false
local activeRoute = nil
local stopNumber = 1
local bus = nil
local pedsOnBus = {}
local pedsAtNextStop = {}
local numberDepartingPedsNextStop = 0

local lastStopCoords = {}
local pedsToDelete = {}

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
        playerPed = PlayerPedId()
        playerPosition = GetEntityCoords(playerPed)

        if not isOnDuty then
            for i = 1, #Config.Routes do
                handleSpawnPoint(i)
            end
            Citizen.Wait(5)
        else
            handleActiveRoute()
            Citizen.Wait(100)
        end
    end
end)

Citizen.CreateThread(function ()
    while true do
        if #pedsToDelete > 0 and (not isOnDuty or playerDistanceFromCoords(lastStopCoords) > Config.DeleteDistance) then
            print('deleting peds')
            while #pedsToDelete > 0 do
                Peds.DeletePed(table.remove(pedsToDelete))
                Citizen.Wait(10)
            end
        end

        Citizen.Wait(5000)
    end
end)

function handleSpawnPoint(locationIndex)
    local route = Config.Routes[locationIndex]
    local coords = route.SpawnPoint;
    
    if playerDistanceFromCoords(coords) < Config.Marker.Size then
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

function handleReturningBus()
    local coords = activeRoute.SpawnPoint

    if playerDistanceFromCoords(coords) < Config.Marker.Size then
        while not IsVehicleStopped(bus) do
            ESX.ShowNotification(_U('stop_bus'))
            Citizen.Wait(500)
        end

        DeleteVehicle(bus)

        -- TODO refund money for bus rental

        TriggerServerEvent('blarglebus:finishRoute', activeRoute.Payment)
        isOnDuty = false
        activeRoute = nil
        bus = nil

        Markers.ResetMarkers()
    end
end

function handleNormalStop()
    local currentStop = activeRoute.Stops[stopNumber]

    if playerDistanceFromCoords(currentStop) < Config.Marker.Size then
        lastStopCoords = currentStop
        handleUnloading(currentStop)
        handleLoading()

        if (stopNumber == #activeRoute.Stops) then
            local coords = activeRoute.SpawnPoint
            isRouteFinished = true
            Markers.SetMarkers({coords})
            ESX.ShowNotification(_U('return_to_terminal'))
            Blips.SetBlipAndWaypoint(activeRoute.Name, coords.x, coords.y, coords.z)
        else
            ESX.ShowNotification(_U('drive_to_next_marker', activeRoute.Stops[stopNumber + 1].name))
            setUpNextStop()
            stopNumber = stopNumber + 1
        end
    end
end

function handleUnloading(stopCoords)
    displayWaitMessageUntilStopped()
    SetVehicleIndicatorLights(bus, 0, true)
    SetVehicleIndicatorLights(bus, 1, true)
    openBusDoors()

    local departingPeds = {}
    for i = 1, numberDepartingPedsNextStop do
        local ped = table.remove(pedsOnBus)
        table.insert(departingPeds, ped)
        table.insert(pedsToDelete, ped)
        Peds.LeaveVehicle(ped, bus)
    end

    waitUntilPedsOffBus(departingPeds)

    for i = 1, #departingPeds do
        TaskGoToCoordAnyMeans(departingPeds[i], stopCoords.x, stopCoords.y, stopCoords.z, 1.0, 0, 0, 786603, 0.0);
    end
end

function displayWaitMessageUntilStopped()
    local notificationMessage = determineWaitForPassengersMessage()

    while not IsVehicleStopped(bus) do
        ESX.ShowNotification(notificationMessage)
        Citizen.Wait(500)
    end
end

function determineWaitForPassengersMessage()
    local notificationMessage = _U('wait_for_passengers')

    if numberDepartingPedsNextStop == 0 and #pedsAtNextStop == 0 then
        notificationMessage = _U('no_passengers_loading_or_unloading')
    elseif numberDepartingPedsNextStop == 0 then
        notificationMessage = _U('no_passengers_unloading')
    elseif #pedsAtNextStop == 0 then
        notificationMessage = _U('no_passengers_loading')
    end

    return notificationMessage
end

function openBusDoors()
    for i = 1, #activeRoute.Doors do
        SetVehicleDoorOpen(bus, activeRoute.Doors[i], false, false)
    end

    Citizen.Wait(Config.DelayBetweenChanges)
end

function waitUntilPedsOffBus(departingPeds)
    local stop = activeRoute.Stops[stopNumber]

    if #departingPeds == 0 then
        return
    end

    local onCount = 0
    while onCount < #departingPeds do
        onCount = 0
        for i = 1, #departingPeds do
            if Peds.IsPedInVehicleOrDead(departingPeds[i], stop) then
                onCount = onCount + 1
            end
            Citizen.Wait(200)
        end
    end
end

function handleLoading()
    Citizen.Wait(Config.DelayBetweenChanges)

    if #pedsAtNextStop == 0 then
        SetVehicleDoorsShut(bus, false)
        return
    end

    local freeSeats = findFreeSeats()

    for i = 1, #pedsAtNextStop do
        Peds.EnterVehicle(pedsAtNextStop[i], bus, freeSeats[i])
        table.insert(pedsOnBus, pedsAtNextStop[i])
    end

    waitUntilPedsOnBus()
    SetVehicleDoorsShut(bus, false)
    SetVehicleIndicatorLights(bus, 0, false)
    SetVehicleIndicatorLights(bus, 1, false)
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
            if Peds.IsPedInVehicleDeadOrTooFarAway(pedsAtNextStop[i], stop) then
                onCount = onCount + 1
            end
            Citizen.Wait(200)
        end
    end
end

function findFreeSeats()
    local freeSeats = {}

    for i = activeRoute.FirstSeat, activeRoute.Capacity + 2 do
        local result = 'taken'
        if IsVehicleSeatFree(bus, i) then
            result = 'free'
            table.insert(freeSeats, i)
        end
        print ('seat ' .. i .. ' is...' .. result)
    end

    return freeSeats
end

function setUpNextStop()
    local nextStop = activeRoute.Stops[stopNumber + 1]
    local numberOfPedsToSpawn = 0
    local freeSeats = activeRoute.Capacity - #pedsOnBus
    
    pedsAtNextStop = {}
    numberDepartingPedsNextStop = 0

    if isLastStop(stopNumber + 1) then
        print ('next stop is last, all peds should depart')
        numberDepartingPedsNextStop = #pedsOnBus
    elseif nextStop.unloadType == Config.UnloadType.All then
        print ('next stop is All, all peds should unload, should spawn peds equal to capacity')
        numberOfPedsToSpawn = activeRoute.Capacity
        numberDepartingPedsNextStop = #pedsOnBus
    elseif nextStop.unloadType == Config.UnloadType.Some then
        numberOfPedsToSpawn = math.random(1, activeRoute.Capacity)

        local minimumDepartingPeds = 1

        if numberOfPedsToSpawn > freeSeats then
            minimumDepartingPeds = numberOfPedsToSpawn - freeSeats
        end

        numberDepartingPedsNextStop = math.random(minimumDepartingPeds, #pedsOnBus)

        print ('next stop is Some, randomly decided to spawn ' .. numberOfPedsToSpawn .. ' peds and depart ' .. numberDepartingPedsNextStop)
    elseif nextStop.unloadType == Config.UnloadType.None and freeSeats > 0 then
        numberOfPedsToSpawn = math.random(1, freeSeats)
        print ('next stop is None, randomly deciding to spawn ' .. numberOfPedsToSpawn .. 'peds')
    end

    Citizen.CreateThread(function()
        for i = 1, numberOfPedsToSpawn do
            table.insert(pedsAtNextStop, Peds.CreateRandomPedInArea(nextStop))
            Citizen.Wait(100)
        end
    end)
    
    Markers.SetMarkers({nextStop})
    Blips.SetBlipAndWaypoint(activeRoute.Name, nextStop.x, nextStop.y, nextStop.z)
end

function isLastStop(stopNumber) return stopNumber == #activeRoute.Stops end

function createBus()
    local coords = activeRoute.SpawnPoint
    ESX.Game.SpawnVehicle(activeRoute.BusModel, coords, coords.heading, function(createdBus)
        bus = createdBus
        SetVehicleFuelLevel(bus, 100.0)
    end)
end

function playerDistanceFromCoords(coords)
    return GetDistanceBetweenCoords(playerPosition, coords.x, coords.y, coords.z, true)
end
