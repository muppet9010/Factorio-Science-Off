local TargetRunData = {}
local EventScheduler = require("utility/event-scheduler")
--local Logging = require("utility/logging")
local Interfaces = require("utility/interfaces")
local Events = require("utility/events")
local CommonFunctions = require("scripts/common_functions")
local Utils = require("utility/utils")

TargetRunData.CreateGlobals = function()
    global.targetRunData = global.targetRunData or {}
    global.targetRunData.data = global.targetRunData.data or {}
    global.targetRunData.productionTargetItemCount = global.targetRunData.productionTargetItemCount or 1
end

TargetRunData.OnLoad = function()
    EventScheduler.RegisterScheduledEventType("TargetRunData.AddProductionTargetItem", TargetRunData.AddProductionTargetItem)
    Events.RegisterHandler("GameFinished", "TargetRunData.GameFinished", TargetRunData.GameFinished)
end

TargetRunData.OnStartup = function()
    if global.targetRunData.productionTargetItemCount == 1 then -- protect against second run of ONStartup. We don't support modifying values mid map.
        TargetRunData.HandleRawTargetRunData(game.json_to_table(settings.startup["science_off-target_run_data"].value))
    end
end

TargetRunData.HandleRawTargetRunData = function(rawData)
    local data = global.targetRunData.data
    data.scienceUsedTotal = rawData.scienceUsedTotal
    data.pointsTotal = rawData.pointsTotal
    data.endTimeTick = rawData.endTimeTick
    data.scienceUsedHistoryEntries = {}
    local currentTargetItemEntry = 1
    for tick, sciencePacksUsed in pairs(rawData.scienceUsedHistory) do
        tick = tonumber(tick)
        data.scienceUsedHistoryEntries[currentTargetItemEntry] = {tick = tick, sciencePacksUsed = sciencePacksUsed}
        currentTargetItemEntry = currentTargetItemEntry + 1
    end
    TargetRunData.RegisterDataEvent()
end

TargetRunData.RegisterDataEvent = function()
    local index = global.targetRunData.productionTargetItemCount
    local data = global.targetRunData.data.scienceUsedHistoryEntries[index]
    if data == nil then
        return
    end
    EventScheduler.ScheduleEvent(data.tick, "TargetRunData.AddProductionTargetItem", index, data.sciencePacksUsed)
    global.targetRunData.productionTargetItemCount = index + 1
end

TargetRunData.AddProductionTargetItem = function(event)
    for itemName, count in pairs(event.data) do
        local pointsName = CommonFunctions.GetTargetSciencePackName("points")
        local pointsCount = Interfaces.Call("ScienceUsage.GetPackPointValue", itemName) * count
        local ghostPrototypeName = CommonFunctions.GetTargetSciencePackName(itemName)
        for _, force in pairs(Interfaces.Call("ScienceUsage.GetAllForceTableForces")) do
            force.item_production_statistics.on_flow(ghostPrototypeName, -count)
            force.item_production_statistics.on_flow(pointsName, -pointsCount)
        end
    end
    TargetRunData.RegisterDataEvent()
end

TargetRunData.GameFinished = function()
    local index = global.targetRunData.productionTargetItemCount - 1
    if global.targetRunData.data.scienceUsedHistoryEntries ~= nil and global.targetRunData.data.scienceUsedHistoryEntries[index] ~= nil then
        EventScheduler.RemoveScheduledEvents("TargetRunData.AddProductionTargetItem", index, global.targetRunData.data.scienceUsedHistoryEntries[index].tick)
    end
end

return TargetRunData
