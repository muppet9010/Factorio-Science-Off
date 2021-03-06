local ScienceUsage = require("scripts/science_usage")
local EventScheduler = require("utility/event-scheduler")
local Gui = require("scripts/gui")
local TimeLimit = require("scripts/time_limit")
local PointLimit = require("scripts/point_limit")
local State = require("scripts/state")
local TargetRunData = require("scripts/target_run_data")
local PrintScores = require("scripts/print_scores")

local function CreateGlobals()
    State.CreateGlobals()
    ScienceUsage.CreateGlobals()
    TimeLimit.CreateGlobals()
    PointLimit.CreateGlobals()
    Gui.CreateGlobals()
    TargetRunData.CreateGlobals()
    PrintScores.CreateGlobals()
end

local function OnLoad()
    --Any Remote Interface registration calls can go in here or in root of control.lua
    State.OnLoad()
    ScienceUsage.OnLoad()
    TimeLimit.OnLoad()
    PointLimit.OnLoad()
    Gui.OnLoad()
    TargetRunData.OnLoad()
    PrintScores.OnLoad()
end

local function OnSettingChanged(event)
    PrintScores.OnSettingChanged(event)
end

local function OnStartup()
    CreateGlobals()
    OnLoad()
    OnSettingChanged(nil)

    ScienceUsage.OnStartup()
    TimeLimit.OnStartUp()
    PointLimit.OnStartUp()
    Gui.OnStartup()
    TargetRunData.OnStartup()
end

script.on_init(OnStartup)
script.on_configuration_changed(OnStartup)
script.on_event(defines.events.on_runtime_mod_setting_changed, OnSettingChanged)
script.on_load(OnLoad)

EventScheduler.RegisterScheduler()
