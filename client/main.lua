local E_KEY = 38

local playerPosition = nil
local playerPed = nil

local isBusDriver = false
local isOnDuty = false
local isRouteFinished = false

local activeRoute = nil
local activeRouteStops = nil
local stopNumber = 1
local lastStopCoords = {}

local pedsOnBus = {}
local pedsAtNextStop = {}
local pedsToDelete = {}
local numberDepartingPedsNextStop = 0

Citizen.CreateThread(function ()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    while true do
        local playerData = ESX.GetPlayerData()
        if playerData.job ~= nil then
            handleJobChange(playerData.job)
            break
        end
        Citizen.Wait(10)
    end

    RegisterNetEvent('esx:setJob')
    AddEventHandler('esx:setJob', handleJobChange)

    while true do
        if isBusDriver then
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
        else
            Citizen.Wait(1000)
        end
    end
end)

Citizen.CreateThread(function ()
    while true do
        if #pedsToDelete > 0 and (not isOnDuty or playerDistanceFromCoords(lastStopCoords) > Config.DeleteDistance) then
            while #pedsToDelete > 0 do
                Peds.DeletePed(table.remove(pedsToDelete))
                Citizen.Wait(10)
            end
        end

        Citizen.Wait(5000)
    end
end)

function handleJobChange(job)
    local wasBusDriver = isBusDriver
    isBusDriver = job.name == 'busdriver'

    if isBusDriver ~= wasBusDriver then
        if isBusDriver then
            handleNowBusDriver()
        else
            handleNoLongerBusDriver()
        end
    end
end

function handleNowBusDriver()
    Markers.StartMarkers()
    Blips.StartBlips()
end

function handleNoLongerBusDriver()
    isOnDuty = false
    activeRoute = nil
    activeRouteStops = nil
    deletePeds(pedsToDelete)
    deletePeds(pedsAtNextStop)
    deletePeds(pedsOnBus)
    Bus.DeleteBus()

    Markers.StopMarkers()
    Blips.StopBlips()
end

function deletePeds(peds)
    while #peds > 0 do
        Peds.DeletePed(table.remove(peds))
        Citizen.Wait(10)
    end
end

function handleSpawnPoint(locationIndex)
    local route = Config.Routes[locationIndex]
    local coords = route.SpawnPoint;
    
    if playerDistanceFromCoords(coords) < Config.Marker.Size then
        ESX.ShowHelpNotification(_U('start_route', route.Name))

        if IsControlJustPressed(1, E_KEY) then
            startRoute(locationIndex)
        end
    end
end

function startRoute(route)
    isOnDuty = true
    isRouteFinished = false
    activeRoute = Config.Routes[route]
    activeRouteStops = activeRoutes.Stops[math.random(1, #activeRoute.Stops)]
    ESX.ShowNotification(_U('drive_to_first_marker', activeRouteStops[1].name))
    Bus.CreateBus(activeRoute.SpawnPoint, activeRoute.BusModel)

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
        Bus.DisplayMessageAndWaitUntilBusStopped(_U('stop_bus'))

        TriggerServerEvent('blarglebus:finishRoute', activeRoute.Payment)
        isOnDuty = false
        activeRoute = nil
        activeRouteStops = nil
        Bus.DeleteBus()

        Markers.ResetMarkers()
    end
end

function handleNormalStop()
    local currentStop = activeRouteStops[stopNumber]

    if playerDistanceFromCoords(currentStop) < Config.Marker.Size then
        lastStopCoords = currentStop
        handleUnloading(currentStop)
        handleLoading()
        payForEachPedLoaded(#pedsAtNextStop)

        if (isLastStop(stopNumber)) then
            local coords = activeRoute.SpawnPoint
            isRouteFinished = true
            Markers.SetMarkers({coords})
            ESX.ShowNotification(_U('return_to_terminal'))
            Blips.SetBlipAndWaypoint(activeRoute.Name, coords.x, coords.y, coords.z)
        else
            ESX.ShowNotification(_U('drive_to_next_marker', activeRouteStops[stopNumber + 1].name))
            setUpNextStop()
            stopNumber = stopNumber + 1
        end
    end
end

function handleUnloading(stopCoords)
    Bus.DisplayMessageAndWaitUntilBusStopped(determineWaitForPassengersMessage())
    Bus.OpenDoorsAndActivateHazards(activeRoute.Doors)

    local departingPeds = {}
    for i = 1, numberDepartingPedsNextStop do
        local ped = table.remove(pedsOnBus)
        table.insert(departingPeds, ped)
        table.insert(pedsToDelete, ped)
        Peds.LeaveVehicle(ped, Bus.bus)
    end

    waitUntilPedsOffBus(departingPeds)

    Peds.WalkPedsToLocation(departingPeds, stopCoords)
end

function determineWaitForPassengersMessage()
    if numberDepartingPedsNextStop == 0 and #pedsAtNextStop == 0 then
        return _U('no_passengers_loading_or_unloading')
    elseif numberDepartingPedsNextStop == 0 then
        return _U('no_passengers_unloading')
    elseif #pedsAtNextStop == 0 then
        return _U('no_passengers_loading')
    end

    return _U('wait_for_passengers')
end

function waitUntilPedsOffBus(departingPeds)
    local stop = activeRouteStops[stopNumber]

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
        return Bus.CloseDoorsAndDeactivateHazards()
    end

    local freeSeats = Bus.FindFreeSeats(activeRoute.FirstSeat, activeRoute.Capacity)

    for i = 1, #pedsAtNextStop do
        Peds.EnterVehicle(pedsAtNextStop[i], Bus.bus, freeSeats[i])
        table.insert(pedsOnBus, pedsAtNextStop[i])
    end

    waitUntilPedsOnBus()
    Bus.CloseDoorsAndDeactivateHazards()
end

function waitUntilPedsOnBus()
    local stop = activeRouteStops[stopNumber]

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

function payForEachPedLoaded(numberOfPeds)
    if numberOfPeds > 0 then
        local amountToPay = numberOfPeds * activeRoute.PaymentPerPassenger
        TriggerServerEvent('blarglebus:passengersLoaded', amountToPay)
        ESX.ShowNotification(_U('passengers_loaded', numberOfPeds, amountToPay))
    end
end

function setUpNextStop()
    local nextStop = activeRouteStops[stopNumber + 1]
    local numberOfPedsToSpawn = 0
    local freeSeats = activeRoute.Capacity - #pedsOnBus
    
    pedsAtNextStop = {}

    if isLastStop(stopNumber + 1) then
        numberOfPedsToSpawn, numberDepartingPedsNextStop = setUpLastStop()
    elseif nextStop.unloadType == Config.UnloadType.All then
        numberOfPedsToSpawn, numberDepartingPedsNextStop = setUpAllStop()
    elseif nextStop.unloadType == Config.UnloadType.Some then
        numberOfPedsToSpawn, numberDepartingPedsNextStop = setUpSomeStop(freeSeats)
    elseif nextStop.unloadType == Config.UnloadType.None and freeSeats > 0 then
        numberOfPedsToSpawn, numberDepartingPedsNextStop = setUpNoneStop(freeSeats)
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

function isLastStop(stopNumber)
    return stopNumber == #activeRouteStops
end

function setUpLastStop()
    print ('next stop is last, all peds should depart')
    return 0, #pedsOnBus
end

function setUpAllStop()
    print ('next stop is All, all peds should unload, should spawn peds equal to capacity')
    return activeRoute.Capacity, #pedsOnBus
end

function setUpSomeStop(freeSeats)
    local numberOfPedsToSpawn = math.random(1, activeRoute.Capacity)
    local minimumDepartingPeds = 1

    if numberOfPedsToSpawn > freeSeats then
        minimumDepartingPeds = numberOfPedsToSpawn - freeSeats
    end

    local numberDeparting = math.random(minimumDepartingPeds, #pedsOnBus)

    print ('next stop is Some, randomly decided to spawn ' .. numberOfPedsToSpawn .. ' peds and depart ' .. numberDeparting)
    return numberOfPedsToSpawn, numberDeparting
end

function setUpNoneStop(freeSeats)
    local numberOfPedsToSpawn = math.random(1, freeSeats)

    print ('next stop is None, randomly deciding to spawn ' .. numberOfPedsToSpawn .. 'peds')
    return numberOfPedsToSpawn, 0
end


function playerDistanceFromCoords(coords)
    return GetDistanceBetweenCoords(playerPosition, coords.x, coords.y, coords.z, true)
end
