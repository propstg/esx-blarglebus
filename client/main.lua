local E_KEY = 38

local playerPosition = nil
local playerPed = nil

local isBusDriver = false
local isOnDuty = false
local isRouteFinished = false
local isRouteJustStarted = false
local isRouteJustAborted = false

local activeRoute = nil
local activeRouteLine = nil
local stopNumber = 1
local lastStopCoords = {}
local totalMoneyPaidThisRoute = 0

local pedsOnBus = {}
local pedsAtNextStop = {}
local pedsToDelete = {}
local numberDepartingPedsNextStop = 0

Citizen.CreateThread(function()
    waitForEsxInitialization()
    waitForPlayerJobInitialization()
    registerJobChangeListener()

    Overlay.Init()
    startAbortRouteThread()
    startPedCleanupThread()
    startMainLoop()
end)

function waitForEsxInitialization()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end

function waitForPlayerJobInitialization()
    while true do
        local playerData = ESX.GetPlayerData()
        if playerData.job ~= nil then
            handleJobChange(playerData.job)
            break
        end
        Citizen.Wait(10)
    end
end

function registerJobChangeListener()
    RegisterNetEvent('esx:setJob')
    AddEventHandler('esx:setJob', handleJobChange)
end

function startAbortRouteThread()
    Citizen.CreateThread(function()
        while true do
            if isOnDuty and not isRouteFinished and not isRouteJustStarted and not isRouteJustAborted then
                handleAbortRoute()
                Citizen.Wait(15)
            else
                Citizen.Wait(1000)
            end
        end
    end)
end

function startMainLoop()
    while true do
        if isBusDriver and not isRouteJustAborted then
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
end

function startPedCleanupThread()
    Citizen.CreateThread(function()
        while true do
            if #pedsToDelete > 0 and (not isOnDuty or playerDistanceFromCoords(lastStopCoords) > Config.DeleteDistance) then
                Peds.DeletePeds(pedsToDelete)
            end

            Citizen.Wait(5000)
        end
    end)
end

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
    immediatelyEndRoute()
    Markers.StopMarkers()
    Blips.StopBlips()
end

function handleSpawnPoint(locationIndex)
    local route = Config.Routes[locationIndex]
    local coords = route.SpawnPoint;
    
    if playerDistanceFromCoords(coords) < Config.Markers.Size then
        ESX.ShowHelpNotification(_U('start_route', _(route.Name)))

        if IsControlJustPressed(1, E_KEY) then
            startRoute(locationIndex)
        end
    end
end

function startRoute(route)
    handleSettingRouteJustStartedAsync()
    isOnDuty = true
    isRouteFinished = false
    activeRoute = Config.Routes[route]
    activeRouteLine = activeRoute.Lines[math.random(1, #activeRoute.Lines)]
    totalMoneyPaidThisRoute = 0
    ESX.ShowNotification(_U('route_assigned', _U(activeRouteLine.Name)))
    Bus.CreateBus(activeRoute.SpawnPoint, activeRoute.BusModel, activeRouteLine.BusColor)
    Blips.StartAbortBlip(activeRoute.Name, activeRoute.SpawnPoint)
    Markers.StartAbortMarker(activeRoute.SpawnPoint)
    Overlay.Start()

    stopNumber = 0
    setUpNextStop()
    stopNumber = 1

    local firstStopName = _U(activeRouteLine.Stops[1].name)
    ESX.ShowNotification(_U('drive_to_first_marker', firstStopName))
    updateOverlay(firstStopName)
end

function handleSettingRouteJustStartedAsync()
    isRouteJustStarted = true
    Citizen.CreateThread(function()
        Citizen.Wait(5000)
        isRouteJustStarted = false
    end)
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

    if playerDistanceFromCoords(coords) < Config.Markers.Size then
        Bus.DisplayMessageAndWaitUntilBusStopped(_U('stop_bus'))

        TriggerServerEvent('blarglebus:finishRoute', activeRoute.Payment)
        immediatelyEndRoute()

        Markers.ResetMarkers()
        Blips.ResetBlips()
    end
end

function handleNormalStop()
    local currentStop = activeRouteLine.Stops[stopNumber]

    if playerDistanceFromCoords(currentStop) < Config.Markers.Size then
        lastStopCoords = currentStop
        handleUnloading(currentStop)
        handleLoading()
        payForEachPedLoaded(#pedsAtNextStop)

        local nextStopName = ''
        if (isLastStop(stopNumber)) then
            local coords = activeRoute.SpawnPoint
            isRouteFinished = true
            Markers.StopAbortMarker()
            Markers.SetMarkers({coords})
            Blips.SetBlipAndWaypoint(activeRoute.Name, coords.x, coords.y, coords.z)
            Blips.StopAbortBlip()
            ESX.ShowNotification(_U('return_to_terminal'))
            nextStopName = _U('terminal')
        else
            nextStopName = _U(activeRouteLine.Stops[stopNumber + 1].name)
            ESX.ShowNotification(_U('drive_to_next_marker', nextStopName))
            setUpNextStop()
            stopNumber = stopNumber + 1
        end

        updateOverlay(nextStopName)
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
    local stop = activeRouteLine.Stops[stopNumber]

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
    local stop = activeRouteLine.Stops[stopNumber]

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
        totalMoneyPaidThisRoute = totalMoneyPaidThisRoute + amountToPay
    end
end

function setUpNextStop()
    local nextStop = activeRouteLine.Stops[stopNumber + 1]
    local numberOfPedsToSpawn = 0
    local freeSeats = activeRoute.Capacity - #pedsOnBus
    
    pedsAtNextStop = {}

    if isLastStop(stopNumber + 1) then
        numberOfPedsToSpawn, numberDepartingPedsNextStop = setUpLastStop()
    elseif nextStop.unloadType == UnloadType.All then
        numberOfPedsToSpawn, numberDepartingPedsNextStop = setUpAllStop()
    elseif nextStop.unloadType == UnloadType.Some then
        numberOfPedsToSpawn, numberDepartingPedsNextStop = setUpSomeStop(freeSeats)
    elseif nextStop.unloadType == UnloadType.None and freeSeats > 0 then
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
    return stopNumber == #activeRouteLine.Stops
end

function setUpLastStop()
    Log.debug('next stop is last, all peds should depart')
    return 0, #pedsOnBus
end

function setUpAllStop()
    Log.debug('next stop is All, all peds should unload, should spawn peds equal to capacity')
    return activeRoute.Capacity, #pedsOnBus
end

function setUpSomeStop(freeSeats)
    local numberOfPedsToSpawn = math.random(1, activeRoute.Capacity)
    local minimumDepartingPeds = 1

    if numberOfPedsToSpawn > freeSeats then
        minimumDepartingPeds = numberOfPedsToSpawn - freeSeats
    end

    local numberDeparting = math.random(minimumDepartingPeds, #pedsOnBus)

    Log.debug('next stop is Some, randomly decided to spawn ' .. numberOfPedsToSpawn .. ' peds and depart ' .. numberDeparting)
    return numberOfPedsToSpawn, numberDeparting
end

function setUpNoneStop(freeSeats)
    local numberOfPedsToSpawn = math.random(1, freeSeats)

    Log.debug('next stop is None, randomly deciding to spawn ' .. numberOfPedsToSpawn .. 'peds')
    return numberOfPedsToSpawn, 0
end

function handleAbortRoute()
    if playerDistanceFromCoords(activeRoute.SpawnPoint) < Config.Markers.Size then
        ESX.ShowHelpNotification(_U('abort_route_help', totalMoneyPaidThisRoute))

        if IsControlJustPressed(1, E_KEY) then
            handleSettingRouteJustAbortedAsync()
            TriggerServerEvent('blarglebus:abortRoute', totalMoneyPaidThisRoute)

            immediatelyEndRoute()
            Blips.ResetBlips()
            Markers.ResetMarkers()
        end
    end
end

function handleSettingRouteJustAbortedAsync()
    isRouteJustAborted = true
    Citizen.CreateThread(function()
        Citizen.Wait(5000)
        isRouteJustAborted = false
    end)
end

function immediatelyEndRoute()
    isOnDuty = false
    activeRoute = nil
    activeRouteLine = nil
    Peds.DeletePeds(pedsToDelete)
    Peds.DeletePeds(pedsAtNextStop)
    Peds.DeletePeds(pedsOnBus)
    Bus.DeleteBus()
    Overlay.Stop()
end

function playerDistanceFromCoords(coords)
    return GetDistanceBetweenCoords(playerPosition, coords.x, coords.y, coords.z, true)
end

function updateOverlay(nextStopName)
    Overlay.Update(_U(activeRouteLine.Name), nextStopName, #activeRouteLine.Stops - stopNumber, totalMoneyPaidThisRoute)
end
