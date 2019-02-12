Blips = {}
Blips.routeBlips = {}
Blips.abortBlip = nil

function Blips.ResetBlips()
    Blips.StopBlips()
    Blips.StartBlips()
end

function Blips.StartBlips()
    for _, route in pairs(Config.Routes) do
        Blips.routeBlips[route.Name] = Blips.CreateAndInitBlip(route.SpawnPoint, _U(route.Name))
    end
end

function Blips.SetBlipAndWaypoint(routeName, x, y, z)
    SetBlipCoords(Blips.routeBlips[routeName], x, y, z)
    SetNewWaypoint(x, y)
end

function Blips.StopBlips()
    for _, blip in pairs(Blips.routeBlips) do
        RemoveBlip(blip)
    end
    
    Blips.StopAbortBlip()
end

function Blips.StartAbortBlip(routeName, spawnPoint)
    Blips.abortBlip = Blips.CreateAndInitBlip(spawnPoint, _U('abort_route', _U(routeName)))
end

function Blips.StopAbortBlip()
    RemoveBlip(Blips.abortBlip)
    Blips.abortBlip = nil
end

function Blips.CreateAndInitBlip(coords, blipLabel)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 513)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(blipLabel)
    EndTextCommandSetBlipName(blip)
    return blip
end