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
    DrawMarker(22,          -- type, MarkerTypeChevronUpx3
        coords.x,           -- posX
        coords.y,           -- posY
        coords.z + 6.0,     -- posZ
        0,                  -- dirX
        0,                  -- dirY
        0,                  -- dirZ
        0.0,                -- rotX
        180.0,              -- rotY
        0.0,                -- rotZ
        markerSize / 2.0,   -- scaleX
        2.0,                -- scaleY
        10.0,               -- scaleZ
        20,                 -- red
        200,                -- green
        20,                 -- blue
        100,                -- alpha
        true,               -- bobUpAndDown
        true,               -- faceCamera
        2,                  -- p19 "Typically set to 2. Does not seem to matter directly."
        1,                  -- rotate
        0,                  -- textureDict
        0,                  -- textureName
        0                   -- drawOnEnts
    )
end

Markers = {
    StartMarkers = startMarkers,
    SetMarkers = setMarkers,
    ResetMarkers = initNotOnDutyMarkers
}