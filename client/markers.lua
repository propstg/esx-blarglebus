Markers = {}
Markers.markerPositions = {}
Markers.abortMarkerPosition = nil

function Markers.StartMarkers()
    Markers.InitNotOnDutyMarkers()

    Citizen.CreateThread(function ()
        while true do
            Citizen.Wait(10)
    
            for _, markerPosition in pairs(Markers.markerPositions) do
                Markers.DrawMarker(markerPosition, Config.Markers.StartColor)
            end

            if Markers.abortMarkerPosition ~= nil then
                Markers.DrawMarker(Markers.abortMarkerPosition, Config.Markers.AbortColor)
            end
        end
    end)
end

function Markers.ResetMarkers()
    Markers.StopMarkers()
    Markers.InitNotOnDutyMarkers()
end

function Markers.StopMarkers()
    Markers.markerPositions = {}
    Markers.StopAbortMarker()
end

function Markers.SetMarkers(markersTable)
    Markers.markerPositions = markersTable
end

function Markers.InitNotOnDutyMarkers()
    for _, markerPosition in pairs(Config.Routes) do
        table.insert(Markers.markerPositions, markerPosition.SpawnPoint)
    end
end

function Markers.StartAbortMarker(abortMarkerPosition)
    Markers.abortMarkerPosition = abortMarkerPosition
end

function Markers.StopAbortMarker()
    Markers.abortMarkerPosition = nil
end

function Markers.DrawMarker(coords, markerColor)
    local markerSize = Config.Markers.Size
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
        markerColor.r,      -- red
        markerColor.g,      -- green
        markerColor.b,      -- blue
        markerColor.a,      -- alpha
        true,               -- bobUpAndDown
        true,               -- faceCamera
        2,                  -- p19 "Typically set to 2. Does not seem to matter directly."
        1,                  -- rotate
        0,                  -- textureDict
        0,                  -- textureName
        0                   -- drawOnEnts
    )
end
