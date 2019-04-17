Overlay = {}
Overlay.isVisible = false
Overlay.wasPaused = false

if not Config.ShowOverlay then
    function Overlay.Init() end
    function Overlay.Stop() end
    function Overlay.Start() end
    function Overlay.Update() end
    return
end

function Overlay.Init()
    Overlay.SendMessage({
        type = 'init',
        translatedLabels = Locales[Config.Locale]
    })
end

function Overlay.Stop()
    Overlay.isVisible = false
    Overlay.SendChangeVisibilityMessage(false)
end

function Overlay.Start()
    Overlay.Init()

    Overlay.isVisible = true
    Overlay.SendChangeVisibilityMessage(true)

    Citizen.CreateThread(function()
        while Overlay.isVisible do
            Citizen.Wait(250)

            local isPaused = IsPauseMenuActive()

            if isPaused ~= Overlay.wasPaused then
                Overlay.SendChangeVisibilityMessage(not isPaused)
                Overlay.wasPaused = isPaused
            end
        end
    end)
end

function Overlay.Update(routeName, nextStop, stopsRemaining, moneyEarned)
    local data = {
        type = 'update',
        routeName = routeName,
        nextStop = nextStop,
        stopsRemaining = stopsRemaining,
        moneyEarned = moneyEarned
    }

    Overlay.SendMessage(data)
end

function Overlay.SendChangeVisibilityMessage(visible)
    Overlay.SendMessage({
        type = 'changeVisibility',
        visible = visible
    })
end

function Overlay.SendMessage(message)
    SendNuiMessage(json.encode(message))
end
