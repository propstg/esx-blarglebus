markerPositions = {}

function startMarkers()
    initNotOnDutyMarkers()

    Citizen.CreateThread(function ()
        while true do
            Citizen.Wait(10)
    
            for i = 1, #markerPositions do
                drawCircle(markerPositions[i])
            end
        end
    end)
end

function setMarkers(markersTable)
    markerPositions = markersTable
end

function initNotOnDutyMarkers()
    for i = 1, #Config.Routes do
        table.insert(markerPositions, Config.Routes[i].SpawnPoint)
    end
end

function drawCircle(coords)
    local markerSize = Config.Marker.Size
    DrawMarker(1, coords.x, coords.y, coords.z, 0, 0, 0, 0, 0, 0, markerSize, markerSize, markerSize, 20, 200, 20, 100, 0, 0, 2, 0, 0, 0, 0)
end

Markers = {
    StartMarkers = startMarkers,
    SetMarkers = setMarkers,
    ResetMarkers = initNotOnDutyMarkers
}
