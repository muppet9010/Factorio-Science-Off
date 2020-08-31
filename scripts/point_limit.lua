local PointLimit = {}
local Events = require("utility/events")
local Interfaces = require("utility/interfaces")

PointLimit.CreateGlobals = function()
    global.pointLimit = global.pointLimit or {}
    global.pointLimit.maxPoints = global.pointLimit.maxPoints or 0
end

PointLimit.OnLoad = function()
    Interfaces.RegisterInterface("PointLimit.GetPointLimit", PointLimit.GetPointLimit)
    Events.RegisterHandler("CheckNow", "PointLimit.CheckPointLimit", PointLimit.CheckPointLimit)
end

PointLimit.OnStartUp = function()
    global.pointLimit.maxPoints = settings.startup["science_off-points_target"].value
    Events.RegisterHandler("CheckNow", "PointLimit.CheckPointLimit", PointLimit.CheckPointLimit)
end

PointLimit.CheckPointLimit = function()
    if global.pointLimit.maxPoints == 0 or Interfaces.Call("State.IsGameFinished") then
        return
    end
    for _, pointTotal in pairs(Interfaces.Call("ScienceUsage.GetAllForcesPointTotals")) do
        if pointTotal >= global.pointLimit.maxPoints then
            Events.RaiseEvent({name = "GameFinished"})
            return
        end
    end
end

PointLimit.GetPointLimit = function()
    return global.pointLimit.maxPoints
end

return PointLimit
