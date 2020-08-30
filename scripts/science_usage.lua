local ScienceUsage = {}
local EventScheduler = require("utility/event-scheduler")
--local Logging = require("utility/logging")
local Interfaces = require("utility/interfaces")
local Events = require("utility/events")

ScienceUsage.CreateGlobals = function()
    global.scienceUsage = global.scienceUsage or {}
    global.scienceUsage.forces = global.scienceUsage.forces or {} -- Has an array of forces with thier data within them. See ScienceUsage.CreateForceUsedTable() for structure.
    ScienceUsage.CreateForceUsedTable(game.forces.player)
    global.scienceUsage.currentTick = global.scienceUsage.currentTick or 0
    global.scienceUsage.pointValues =
        global.scienceUsage.pointValues or
        {
            ["automation-science-pack"] = 1,
            ["logistic-science-pack"] = 3,
            ["military-science-pack"] = 6,
            ["chemical-science-pack"] = 10,
            ["production-science-pack"] = 34,
            ["utility-science-pack"] = 38,
            ["space-science-pack"] = 80
        }
end

ScienceUsage.CreateForceUsedTable = function(force)
    global.scienceUsage.forces[force.index] = global.scienceUsage.forces[force.index] or {}
    local forceTable = global.scienceUsage.forces[force.index]
    forceTable.name = force.name
    forceTable.id = force.index
    forceTable.force = force
    forceTable.scienceUsedHistory = forceTable.scienceUsedHistory or {} -- table of ticks containing a table of science types used each second.
    forceTable.pointsHistory = forceTable.pointsHistory or {} -- table of ticks containing the points gained each second.
    forceTable.scienceUsedTotal = forceTable.scienceUsedTotal or {} -- table of each science types used in total.
    forceTable.scienceUsedTotalLastSecond = forceTable.scienceUsedTotalLastSecond or {} -- table of each science types used in total last second.
    forceTable.pointsTotal = forceTable.pointsTotal or 0
end

ScienceUsage.OnLoad = function()
    EventScheduler.RegisterScheduledEventType("ScienceUsage.PollAllProductionStatistics", ScienceUsage.PollAllProductionStatistics)
    Interfaces.RegisterInterface("ScienceUsage.GetPlayerForceTable", ScienceUsage.GetPlayerForceTable)
    Interfaces.RegisterInterface("ScienceUsage.GetPackPointValue", ScienceUsage.GetPackPointValue)
    Interfaces.RegisterInterface("ScienceUsage.GetAllForcesPointTotals", ScienceUsage.GetAllForcesPointTotals)
    Interfaces.RegisterInterface("ScienceUsage.GetUsageDataJsonForForceTable", ScienceUsage.GetUsageDataJsonForForceTable)
    Interfaces.RegisterInterface("ScienceUsage.GetCurrentTick", ScienceUsage.GetCurrentTick)
    Events.RegisterEvent("CheckNow")
    Interfaces.RegisterInterface("ScienceUsage.GetAllForceTableForces", ScienceUsage.GetAllForceTableForces)
end

ScienceUsage.OnStartup = function()
    if not EventScheduler.IsEventScheduled("ScienceUsage.PollAllProductionStatistics") then
        EventScheduler.ScheduleEvent(game.tick + 60, "ScienceUsage.PollAllProductionStatistics")
    end
end

ScienceUsage.PollAllProductionStatistics = function(event)
    if Interfaces.Call("State.IsGameFinished") then
        return
    end
    global.scienceUsage.currentTick = event.tick
    Interfaces.Call("Gui.UpdateScoreCurrentTimeAllPlayers")
    EventScheduler.ScheduleEvent(global.scienceUsage.currentTick + 60, "ScienceUsage.PollAllProductionStatistics")
    for _, forceTable in pairs(global.scienceUsage.forces) do
        ScienceUsage.PollForceProducitonStatistics(forceTable, global.scienceUsage.currentTick)
    end
    Events.RaiseEvent({name = "CheckNow"})
end

ScienceUsage.PollForceProducitonStatistics = function(forceTable, tick)
    local force = forceTable.force
    local scienceUsed = false
    for packName, pointsValue in pairs(global.scienceUsage.pointValues) do
        local currentValue = force.item_production_statistics.get_output_count(packName)
        local countInSecond = currentValue - (forceTable.scienceUsedTotalLastSecond[packName] or 0)
        if countInSecond > 0 then
            forceTable.scienceUsedHistory[tick] = forceTable.scienceUsedHistory[tick] or {}
            forceTable.scienceUsedHistory[tick][packName] = countInSecond
            forceTable.scienceUsedTotal[packName] = (forceTable.scienceUsedTotal[packName] or 0) + countInSecond
            local pointsGained = pointsValue * countInSecond
            forceTable.pointsHistory[tick] = forceTable.pointsHistory[tick] or {}
            forceTable.pointsHistory[tick][packName] = pointsGained
            forceTable.pointsTotal = forceTable.pointsTotal + pointsGained
            force.item_production_statistics.on_flow("science_off-points", -pointsGained)
            scienceUsed = true
        end
        forceTable.scienceUsedTotalLastSecond[packName] = currentValue
    end
    if scienceUsed then
        Interfaces.Call("Gui.UpdateScoreForForcesPlayers", force)
    end
end

ScienceUsage.GetPlayerForceTable = function(player)
    if global.scienceUsage.forces[player.force.index] ~= nil then
        return global.scienceUsage.forces[player.force.index]
    else
        error("No force science usage data for player and force: " .. player.name .. " - " .. player.force.name)
    end
end

ScienceUsage.GetPackPointValue = function(packPrototype)
    if global.scienceUsage.pointValues[packPrototype] ~= nil then
        return global.scienceUsage.pointValues[packPrototype]
    else
        error("No science pack point value for pack type: " .. packPrototype)
    end
end

ScienceUsage.GetAllForcesPointTotals = function()
    local forcesPoints = {}
    for _, forceTable in pairs(global.scienceUsage.forces) do
        forcesPoints[forceTable.force] = forceTable.pointsTotal
    end
    return forcesPoints
end

ScienceUsage.GetUsageDataJsonForForceTable = function(forceTable)
    local object = {
        scienceUsedHistory = forceTable.scienceUsedHistory,
        scienceUsedTotal = forceTable.scienceUsedTotal,
        pointsTotal = forceTable.pointsTotal,
        endTimeTick = global.scienceUsage.currentTick
    }
    return game.table_to_json(object)
end

ScienceUsage.GetCurrentTick = function()
    return global.scienceUsage.currentTick
end

ScienceUsage.GetAllForceTableForces = function()
    local forces = {}
    for _, forceTable in pairs(global.scienceUsage.forces) do
        forces[forceTable.id] = forceTable.force
    end
    return forces
end

return ScienceUsage
