local TimeLimit = {}
local Events = require("utility/events")
local Interfaces = require("utility/interfaces")

TimeLimit.CreateGlobals = function()
    global.timeLimit = global.timeLimit or {}
    global.timeLimit.maxTicks = global.timeLimit.maxTicks or 0
end

TimeLimit.OnLoad = function()
    Interfaces.RegisterInterface("TimeLimit.GetTicksRemaining", TimeLimit.GetTicksRemaining)
    Events.RegisterHandler("CheckNow", "TimeLimit.CheckTimeLimit", TimeLimit.CheckTimeLimit)
end

TimeLimit.OnStartUp = function()
    global.timeLimit.maxTicks = settings.startup["science_off-time_limit"].value * 3600 -- minutes to ticks
end

TimeLimit.CheckTimeLimit = function()
    if global.timeLimit.maxTicks == 0 or Interfaces.Call("State.IsGameFinished") then
        return
    end
    local ticksRemaining = TimeLimit.GetTicksRemaining()
    if ticksRemaining == nil then
        return
    elseif ticksRemaining <= 0 then
        Events.RaiseEvent({name = "GameFinished"})
        return
    end
    Interfaces.Call("Gui.UpdateTimeRemainingAllPlayers", ticksRemaining)
end

TimeLimit.GetTicksRemaining = function()
    if global.timeLimit.maxTicks == 0 then
        return nil
    end
    return math.max(global.timeLimit.maxTicks - Interfaces.Call("ScienceUsage.GetCurrentTick"), 0) -- don't go negative as messes up time displays.
end

return TimeLimit
