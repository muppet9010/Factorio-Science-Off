local State = {}
local Events = require("utility/events")
local Interfaces = require("utility/interfaces")

State.CreateGlobals = function()
    global.state = global.state or {}
    global.state.finished = global.state.finished or false
end

State.OnLoad = function()
    Interfaces.RegisterInterface("State.IsGameFinished", State.IsGameFinished)
    Events.RegisterEvent("GameFinished")
    Events.RegisterHandler("GameFinished", "State.GameFinished", State.GameFinished)
end

State.GameFinished = function()
    global.state.finished = true
    for _, surface in pairs(game.surfaces) do
        for _, entity in pairs(surface.find_entities()) do
            entity.active = false
        end
        surface.always_day = true
    end
    for _, player in pairs(game.connected_players) do
        player.set_controller {type = defines.controllers.god}
        player.spectator = true
    end
end

State.IsGameFinished = function()
    return global.state.finished
end

return State
