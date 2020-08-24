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
    global.targetRunData.productionTargetItemCount = global.targetRunData.productionTargetItemCount or 0
end

TargetRunData.OnLoad = function()
    EventScheduler.RegisterScheduledEventType("TargetRunData.AddProductionTargetItem", TargetRunData.AddProductionTargetItem)
    Events.RegisterHandler("GameFinished", "TargetRunData.GameFinished", TargetRunData.GameFinished)
end

TargetRunData.OnStartup = function()
    if global.targetRunData.productionTargetItemCount == 0 then -- protect against second run of ONStartup. We don't support modifying values mid map.
        TargetRunData.RegisterDataEvents(game.json_to_table(settings.startup["science_off-target_run_data"].value))
    end
end

TargetRunData.RegisterDataEvents = function(data)
    if data == nil or data.scienceUsedHistory == nil or Utils.GetTableNonNilLength(data.scienceUsedHistory) == 0 then
        return
    end
    for tick, sciencePacksUsed in pairs(data.scienceUsedHistory) do
        tick = tonumber(tick)
        for packPrototypeName, count in pairs(sciencePacksUsed) do
            EventScheduler.ScheduleEvent(tick, "TargetRunData.AddProductionTargetItem", global.targetRunData.productionTargetItemCount, {itemName = packPrototypeName, count = count})
            global.targetRunData.productionTargetItemCount = global.targetRunData.productionTargetItemCount + 1
        end
    end
end

TargetRunData.AddProductionTargetItem = function(event)
    local itemName, count = event.data.itemName, event.data.count
    local pointsName = CommonFunctions.GetTargetSciencePackName("points")
    local pointsCount = Interfaces.Call("ScienceUsage.GetPackPointValue", itemName) * count
    local ghostPrototypeName = CommonFunctions.GetTargetSciencePackName(itemName)
    for _, force in pairs(Interfaces.Call("ScienceUsage.GetAllForceTableForces")) do
        force.item_production_statistics.on_flow(ghostPrototypeName, -count)
        force.item_production_statistics.on_flow(pointsName, -pointsCount)
    end
end

TargetRunData.GameFinished = function()
    for i = 0, global.targetRunData.productionTargetItemCount do
        EventScheduler.RemoveScheduledEvents("TargetRunData.AddProductionTargetItem", i)
    end
end

return TargetRunData
