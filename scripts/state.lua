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
    game.speed = 0.01
end

State.IsGameFinished = function()
    return global.state.finished
end

return State
