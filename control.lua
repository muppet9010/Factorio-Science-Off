local ScienceUsage = require("scripts/science_usage")
local EventScheduler = require("utility/event-scheduler")
local Gui = require("scripts/gui")

local function CreateGlobals()
    ScienceUsage.CreateGlobals()
    Gui.CreateGlobals()
end

local function OnLoad()
    --Any Remote Interface registration calls can go in here or in root of control.lua
    ScienceUsage.OnLoad()
    Gui.OnLoad()
end

local function OnSettingChanged(event)
    --if event == nil or event.setting == "xxxxx" then
    --	local x = tonumber(settings.global["xxxxx"].value)
    --end
end

local function OnStartup()
    CreateGlobals()
    OnLoad()
    OnSettingChanged(nil)

    ScienceUsage.OnStartup()
    Gui.OnStartup()
end

script.on_init(OnStartup)
script.on_configuration_changed(OnStartup)
script.on_event(defines.events.on_runtime_mod_setting_changed, OnSettingChanged)
script.on_load(OnLoad)

EventScheduler.RegisterScheduler()
