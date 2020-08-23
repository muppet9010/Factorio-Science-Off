local PointLimit = {}
local EventScheduler = require("utility/event-scheduler")
local Events = require("utility/events")
local Interfaces = require("utility/interfaces")

PointLimit.CreateGlobals = function()
    global.pointLimit = global.pointLimit or {}
    global.pointLimit.maxPoints = global.pointLimit.maxPoints or 0
end

PointLimit.OnLoad = function()
    EventScheduler.RegisterScheduledEventType("PointLimit.CheckPointLimit", PointLimit.CheckPointLimit)
    Interfaces.RegisterInterface("PointLimit.GetPointLimit", PointLimit.GetPointLimit)
end

PointLimit.OnStartUp = function()
    global.pointLimit.maxPoints = settings.startup["science_off-points_target"].value
    if global.pointLimit.maxPoints > 0 and not EventScheduler.IsEventScheduled("PointLimit.CheckPointLimit") then
        EventScheduler.ScheduleEvent(game.tick + 60, "PointLimit.CheckPointLimit")
    end
end

PointLimit.CheckPointLimit = function()
    if Interfaces.Call("State.IsGameFinished") or global.pointLimit.maxPoints == 0 then
        return
    end
    for _, pointTotal in pairs(Interfaces.Call("ScienceUsage.GetAllForcesPointTotals")) do
        if pointTotal >= global.pointLimit.maxPoints then
            Events.RaiseEvent({name = "GameFinished"})
            return
        end
    end
    EventScheduler.ScheduleEvent(game.tick + 60, "PointLimit.CheckPointLimit")
end

PointLimit.GetPointLimit = function()
    return global.pointLimit.maxPoints
end

return PointLimit
