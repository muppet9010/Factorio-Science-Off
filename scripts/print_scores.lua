local PrintScores = {}
local Interfaces = require("utility/interfaces")
local Events = require("utility/events")
local Utils = require("utility/utils")

PrintScores.CreateGlobals = function()
    global.printScores = global.printScores or {}
    global.printScores.intervalTick = global.printScores.intervalTick or 0
    global.printScores.nextIntervalTick = global.printScores.nextIntervalTick or 0
end

PrintScores.OnLoad = function()
    Events.RegisterHandler("CheckNow", "PrintScores.CheckPrintInterval", PrintScores.CheckPrintInterval)
end

PrintScores.OnSettingChanged = function(event)
    local currentTick = game.tick
    if event == nil or (event.setting_type == "runtime-global" and event.setting == "science_off-print_timestamped_score_interval") then
        global.printScores.intervalTick = tonumber(settings.global["science_off-print_timestamped_score_interval"].value) * 3600
        PrintScores.SetNextIntervalTick(currentTick)
    end
end

PrintScores.SetNextIntervalTick = function(currentTick)
    global.printScores.nextIntervalTick = ((math.floor(currentTick / global.printScores.intervalTick) + 1) * global.printScores.intervalTick)
end

PrintScores.CheckPrintInterval = function(event)
    local scienceUsageCurrentTick = event.scienceUsageCurrentTick
    if scienceUsageCurrentTick ~= global.printScores.nextIntervalTick then
        return
    end
    PrintScores.SetNextIntervalTick(scienceUsageCurrentTick)
    PrintScores.PrintTimestampedScore(scienceUsageCurrentTick)
end

PrintScores.PrintTimestampedScore = function(scienceUsageCurrentTick)
    for force, pointsTotal in pairs(Interfaces.Call("ScienceUsage.GetAllForcesPointTotals")) do
        force.print({"message.science_off-timestamped_points", Utils.DisplayTimeOfTicks(scienceUsageCurrentTick, "hour", "second"), pointsTotal})
    end
end

return PrintScores
