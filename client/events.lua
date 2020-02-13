-- These are stubs that get called on certain events.
-- You can use them to run custom code, like triggering events in other resources.
-- Don't delete the function, if you don't need it. Just leave it empty.

Events = {}

function Events.RouteStarted(routeNameKey)
end

function Events.ArrivedAtStop(currentStopNameKey, nextStopNameKey)
end

function Events.DepartingStop(currentStopNameKey, nextStopNameKey)
end

function Events.RouteEnded()
end
