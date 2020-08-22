local ScienceUsage = {}
local EventScheduler = require("utility/event-scheduler")
local Logging = require("utility/logging")
local Interfaces = require("utility/interfaces")

ScienceUsage.CreateGlobals = function()
    global.scienceUsage = global.scienceUsage or {}
    global.scienceUsage.forces = global.scienceUsage.forces or {} -- Has an array of forces with thier data within them. See ScienceUsage.CreateForceUsedTable() for structure.
    ScienceUsage.CreateForceUsedTable(game.forces.player)
    global.scienceUsage.pointValues =
        global.scienceUsage.pointValues or
        {
            ["automation-science-pack"] = 10,
            ["logistic-science-pack"] = 30,
            ["military-science-pack"] = 60,
            ["chemical-science-pack"] = 100,
            ["production-science-pack"] = 340,
            ["utility-science-pack"] = 380,
            ["space-science-pack"] = 800
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
    EventScheduler.RegisterScheduledEventType("PollAllProductionStatistics", ScienceUsage.PollAllProductionStatistics)
    Interfaces.RegisterInterface("ScienceUsage.GetPlayerForceTable", ScienceUsage.GetPlayerForceTable)
    Interfaces.RegisterInterface("ScienceUsage.GetPackPointValue", ScienceUsage.GetPackPointValue)
end

ScienceUsage.OnStartup = function()
    if not EventScheduler.IsEventScheduled("PollAllProductionStatistics") then
        EventScheduler.ScheduleEvent(game.tick + 60, "PollAllProductionStatistics")
    end
end

ScienceUsage.PollAllProductionStatistics = function(event)
    EventScheduler.ScheduleEvent(event.tick + 60, "PollAllProductionStatistics")
    for _, forceTable in pairs(global.scienceUsage.forces) do
        ScienceUsage.PollForceProducitonStatistics(forceTable, event.tick)
    end
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
            force.item_production_statistics.on_flow("coin", -pointsGained)
            scienceUsed = true
        --Logging.Log(serpent.block(forceTable))
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
        error("No force science data for players force index: " .. player.force.index)
    end
end

ScienceUsage.GetPackPointValue = function(packPrototype)
    if global.scienceUsage.pointValues[packPrototype] ~= nil then
        return global.scienceUsage.pointValues[packPrototype]
    else
        error("No science pack point value for pack type: " .. packPrototype)
    end
end

return ScienceUsage
