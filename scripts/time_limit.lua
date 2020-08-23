local TimeLimit = {}
local EventScheduler = require("utility/event-scheduler")
local Events = require("utility/events")
local Interfaces = require("utility/interfaces")

TimeLimit.CreateGlobals = function()
    global.timeLimit = global.timeLimit or {}
    global.timeLimit.maxTicks = global.timeLimit.maxTicks or 0
    global.timeLimit.currentTick = global.timeLimit.currentTick or 0
end

TimeLimit.OnLoad = function()
    EventScheduler.RegisterScheduledEventType("TimeLimit.CheckTimeLimit", TimeLimit.CheckTimeLimit)
    Interfaces.RegisterInterface("TimeLimit.GetTicksRemaining", TimeLimit.GetTicksRemaining)
end

TimeLimit.OnStartUp = function()
    global.timeLimit.maxTicks = settings.startup["science_off-time_limit"].value * 3600 -- minutes to ticks
    if global.timeLimit.maxTicks > 0 and not EventScheduler.IsEventScheduled("TimeLimit.CheckTimeLimit") then
        EventScheduler.ScheduleEvent(game.tick + 60, "TimeLimit.CheckTimeLimit")
    end
end

TimeLimit.CheckTimeLimit = function()
    if Interfaces.Call("State.IsGameFinished") then
        return
    end
    global.timeLimit.currentTick = game.tick
    local ticksRemaining = TimeLimit.GetTicksRemaining()
    if ticksRemaining == nil then
        return
    elseif ticksRemaining <= 0 then
        Events.RaiseEvent({name = "GameFinished"})
        return
    end
    EventScheduler.ScheduleEvent(game.tick + 60, "TimeLimit.CheckTimeLimit")

    Interfaces.Call("Gui.UpdateTimeRemainingAllPlayers", ticksRemaining)
end

TimeLimit.GetTicksRemaining = function()
    if global.timeLimit.maxTicks == 0 then
        return nil
    end
    return global.timeLimit.maxTicks - global.timeLimit.currentTick
end

return TimeLimit
