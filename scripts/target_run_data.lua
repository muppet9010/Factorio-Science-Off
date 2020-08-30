local TargetRunData = {}
local EventScheduler = require("utility/event-scheduler")
local Logging = require("utility/logging")
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
    if global.targetRunData.productionTargetItemCount == 1 then -- protect against second run of OnStartup. We don't need to support modifying values mid map.
        TargetRunData.HandleRawTargetRunData(settings.startup["science_off-target_run_data"].value)
    end
end

TargetRunData.HandleRawTargetRunData = function(settingString)
    if settingString == nil or settingString == "" then
        return
    end

    local data = global.targetRunData.data
    local validSciencePackPrototypes = game.get_filtered_item_prototypes({{filter = "subgroup", subgroup = "science-pack"}})

    local rawData = game.json_to_table(settingString)
    if rawData == nil or type(rawData) ~= "table" then
        return TargetRunData.ValidationFailed("invalid data structure")
    end

    if rawData.scienceUsedTotal == nil or type(rawData.scienceUsedTotal) ~= "table" then
        return TargetRunData.ValidationFailed("scienceUsedTotal is invalid data structure")
    end
    if Utils.GetTableNonNilLength(rawData.scienceUsedTotal) == 0 then
        return TargetRunData.ValidationFailed("scienceUsedTotal is empty list")
    end
    data.scienceUsedTotal = {}
    for sciencePackName, rawCount in pairs(rawData.scienceUsedTotal) do
        local count = tonumber(rawCount)
        if count == nil or count < 0 then
            return TargetRunData.ValidationFailed("scienceUsedTotal count not a non-negative number:'" .. tostring(rawCount) .. "'")
        end
        if validSciencePackPrototypes[sciencePackName] == nil then
            return TargetRunData.ValidationFailed("scienceUsedTotal science pack type not valid:'" .. tostring(sciencePackName) .. "'")
        end
        data.scienceUsedTotal[sciencePackName] = count
    end

    data.pointsTotal = tonumber(rawData.pointsTotal)
    if rawData.pointsTotal == nil or rawData.pointsTotal < 0 then
        return TargetRunData.ValidationFailed("pointsTotal not a non-negative number: '" .. tostring(rawData.pointsTotal) .. "'")
    end

    data.endTimeTick = tonumber(rawData.endTimeTick)
    if rawData.endTimeTick == nil or rawData.endTimeTick < 0 then
        return TargetRunData.ValidationFailed("endTimeTick not a non-negative number: '" .. tostring(rawData.endTimeTick) .. "'")
    end

    if rawData.scienceUsedHistory == nil or type(rawData.scienceUsedHistory) ~= "table" then
        return TargetRunData.ValidationFailed("scienceUsedHistory is invalid data structure")
    end
    if Utils.GetTableNonNilLength(rawData.scienceUsedHistory) == 0 then
        return TargetRunData.ValidationFailed("scienceUsedHistory is empty list")
    end
    data.scienceUsedHistoryEntries = {}
    local currentTargetItemEntry = 1
    for rawTick, rawSciencePacksUsed in pairs(rawData.scienceUsedHistory) do
        local tick = tonumber(rawTick)
        if tick == nil or tick <= 0 then
            return TargetRunData.ValidationFailed("scienceUsedHistory entry tick not a positive number:'" .. tostring(rawTick) .. "'")
        end
        local sciencePacksUsed = {}
        for sciencePackName, rawCount in pairs(rawSciencePacksUsed) do
            local count = tonumber(rawCount)
            if count == nil or count < 0 then
                return TargetRunData.ValidationFailed("scienceUsedHistory count not a non-negative number:'" .. tostring(rawCount) .. "' for tick " .. tick)
            end
            if validSciencePackPrototypes[sciencePackName] == nil then
                return TargetRunData.ValidationFailed("scienceUsedHistory science pack type not valid:'" .. tostring(sciencePackName) .. "' for tick " .. tick)
            end
            sciencePacksUsed[sciencePackName] = count
        end
        data.scienceUsedHistoryEntries[currentTargetItemEntry] = {tick = tick, sciencePacksUsed = sciencePacksUsed}
        currentTargetItemEntry = currentTargetItemEntry + 1
    end

    TargetRunData.RegisterDataEvent()
end

TargetRunData.ValidationFailed = function(specificMessage)
    local errorMessage = "ERROR: bad Target Run Data setting provided: " .. specificMessage
    Logging.Log(errorMessage)
    EventScheduler.ScheduleEvent(0, "EventScheduler.GamePrint", "TargetRunData.HandleRawTargetRunData", {message = errorMessage})
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
