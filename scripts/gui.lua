local Interfaces = require("utility/interfaces")
local Events = require("utility/events")
local GuiUtil = require("utility/gui-util")
--local Logging = require("utility/logging")
--local Colors = require("utility/colors")
local Utils = require("utility/utils")
local GuiActionsClick = require("utility/gui-actions-click")
local Gui = {}

Gui.CreateGlobals = function()
    global.gui = global.gui or {}
    global.gui.playerScoreOpen = global.gui.playerScoreOpen or {}
    global.gui.playerPackValueOpen = global.gui.playerPackValueOpen or {}
end

Gui.OnLoad = function()
    Interfaces.RegisterInterface("Gui.UpdateScoreForForcesPlayers", Gui.UpdateScoreForForcesPlayers)
    Events.RegisterEvent(defines.events.on_player_joined_game)
    Events.RegisterHandler(defines.events.on_player_joined_game, "Gui.OnPlayerJoined", Gui.OnPlayerJoined)
    Events.RegisterEvent(defines.events.on_lua_shortcut)
    Events.RegisterHandler(defines.events.on_lua_shortcut, "Gui.OnLuaShortcut", Gui.OnLuaShortcut)
    Interfaces.RegisterInterface("Gui.UpdateTimeRemainingAllPlayers", Gui.UpdateTimeRemainingAllPlayers)
    Events.RegisterHandler("GameFinished", "Gui.ShowEndGameTextAllPlayers", Gui.ShowEndGameTextAllPlayers)
    GuiActionsClick.MonitorGuiClickActions()
    GuiActionsClick.LinkGuiClickActionNameToFunction("getPlayersForceUsageData", Gui.GetPlayersForceUsageDataButtonClicked)
    Interfaces.RegisterInterface("Gui.UpdateScoreCurrentTimeAllPlayers", Gui.UpdateScoreCurrentTimeAllPlayers)
end

Gui.OnStartup = function()
    Gui.RecreateAllPlayers()
end

Gui.OnPlayerJoined = function(event)
    local playerIndex, player = event.player_index, game.get_player(event.player_index)
    global.gui.playerScoreOpen[playerIndex] = global.gui.playerScoreOpen[playerIndex] or true
    global.gui.playerPackValueOpen[playerIndex] = global.gui.playerPackValueOpen[playerIndex] or false
    Gui.RecreatePlayer(player)
end

Gui.RecreatePlayer = function(player)
    GuiUtil.DestroyPlayersReferenceStorage(player.index, "score")
    if global.gui.playerScoreOpen[player.index] then
        Gui.OpenScoreForPlayer(player)
    end
    if global.gui.playerPackValueOpen[player.index] then
        Gui.OpenPackValueForPlayer(player)
    end
    if Interfaces.Call("State.IsGameFinished") then
        Gui.CreateEndGameTextForPlayer(player)
    end
end

Gui.RecreateAllPlayers = function()
    for _, player in pairs(game.connected_players) do
        Gui.RecreatePlayer(player)
    end
end

Gui.OpenScoreForPlayer = function(player)
    global.gui.playerScoreOpen[player.index] = true
    player.set_shortcut_toggled("science_off-score_toggle", true)
    Gui.CreateScoreForPlayer(player)
end

Gui.CloseScoreForPlayer = function(player)
    GuiUtil.DestroyPlayersReferenceStorage(player.index, "score")
    global.gui.playerScoreOpen[player.index] = false
    player.set_shortcut_toggled("science_off-score_toggle", false)
end

Gui.ToggleScoreForPlayer = function(player)
    if global.gui.playerScoreOpen[player.index] then
        Gui.CloseScoreForPlayer(player)
    else
        Gui.OpenScoreForPlayer(player)
    end
end

Gui.CreateScoreForPlayer = function(player)
    GuiUtil.AddElement(
        {
            parent = player.gui.left,
            name = "score",
            type = "frame",
            style = "muppet_frame_main_marginTL_paddingBR",
            storeName = "score",
            children = {
                {
                    type = "flow",
                    direction = "vertical",
                    style = "muppet_flow_vertical_marginTL",
                    styling = {horizontally_stretchable = false},
                    children = {
                        {
                            name = "score_title",
                            type = "label",
                            caption = "self",
                            style = "muppet_label_heading_large_bold"
                        },
                        {
                            name = "time_current",
                            type = "label",
                            caption = {"self", 0},
                            style = "muppet_label_text_large",
                            storeName = "score"
                        },
                        {
                            type = "frame",
                            direction = "vertical",
                            style = "muppet_frame_content_shadowSunken",
                            children = {
                                {
                                    type = "table",
                                    column_count = 2,
                                    style = "muppet_table_horizontalSpaced",
                                    children = {
                                        {
                                            name = "score_points",
                                            type = "label",
                                            caption = {"self", 0},
                                            style = "muppet_label_text_large",
                                            storeName = "score"
                                        },
                                        {
                                            type = "sprite",
                                            sprite = "item/coin",
                                            style = "muppet_sprite_32",
                                            styling = {
                                                width = 20,
                                                height = 20
                                            }
                                        }
                                    }
                                },
                                {
                                    name = "sciences",
                                    type = "frame",
                                    direction = "vertical",
                                    style = "muppet_frame_contentInnerDark_shadowSunken",
                                    storeName = "score",
                                    styling = {horizontally_stretchable = true},
                                    attributes = {
                                        visible = false
                                    }
                                }
                            }
                        },
                        {
                            type = "frame",
                            direction = "vertical",
                            style = "muppet_frame_content_shadowSunken",
                            styling = {
                                top_margin = 2,
                                horizontally_stretchable = true
                            },
                            exclude = Interfaces.Call("TimeLimit.GetTicksRemaining") == nil and Interfaces.Call("PointLimit.GetPointLimit") == 0,
                            children = {
                                {
                                    name = "time_remaining",
                                    type = "label",
                                    caption = {"self", ""},
                                    style = "muppet_label_text_large",
                                    storeName = "score",
                                    exclude = Interfaces.Call("TimeLimit.GetTicksRemaining") == nil
                                },
                                {
                                    name = "point_target",
                                    type = "label",
                                    caption = {"self", Utils.DisplayNumberPretty(Interfaces.Call("PointLimit.GetPointLimit"))},
                                    style = "muppet_label_text_large",
                                    exclude = Interfaces.Call("PointLimit.GetPointLimit") == 0
                                }
                            }
                        }
                    }
                }
            }
        }
    )
    Gui.UpdateScoreForPlayer(player)
    Gui.UpdateTimeRemainingPlayer(player, Interfaces.Call("TimeLimit.GetTicksRemaining"))
    Gui.UpdateScoreCurrentTimeForPlayer(player, Interfaces.Call("ScienceUsage.GetCurrentTick"))
end

Gui.UpdateScoreForForcesPlayers = function(force)
    for _, player in pairs(game.connected_players) do
        if player.force == force then
            Gui.UpdateScoreForPlayer(player)
        end
    end
end

Gui.UpdateScoreForPlayer = function(player)
    local playerIndex = player.index
    if not global.gui.playerScoreOpen[playerIndex] then
        return
    end
    local forceScienceUsage = Interfaces.Call("ScienceUsage.GetPlayerForceTable", player)
    GuiUtil.UpdateElementFromPlayersReferenceStorage(playerIndex, "score", "score_points", "label", {caption = {"self", Utils.DisplayNumberPretty(forceScienceUsage.pointsTotal)}}, false)

    GuiUtil.DestroyElementInPlayersReferenceStorage(playerIndex, "score", "sciences", "table")
    local sciencePackGuiElements = {}
    for packPrototypeName, packCount in pairs(forceScienceUsage.scienceUsedTotal) do
        table.insert(
            sciencePackGuiElements,
            {
                type = "sprite",
                sprite = "item/" .. packPrototypeName,
                style = "muppet_sprite_32",
                styling = {
                    width = 24,
                    height = 24
                }
            }
        )
        table.insert(
            sciencePackGuiElements,
            {
                type = "label",
                caption = "x " .. Utils.DisplayNumberPretty(packCount),
                style = "muppet_label_text_medium"
            }
        )
    end
    if #sciencePackGuiElements > 0 then
        GuiUtil.UpdateElementFromPlayersReferenceStorage(playerIndex, "score", "sciences", "frame", {visible = true}, false)
    else
        GuiUtil.UpdateElementFromPlayersReferenceStorage(playerIndex, "score", "sciences", "frame", {visible = false}, false)
    end
    GuiUtil.AddElement(
        {
            parent = GuiUtil.GetElementFromPlayersReferenceStorage(playerIndex, "score", "sciences", "frame"),
            name = "sciences",
            type = "table",
            column_count = 2,
            style = "muppet_table_verticalSpaced",
            storeName = "score",
            children = sciencePackGuiElements
        }
    )
end

Gui.UpdateScoreCurrentTimeAllPlayers = function()
    local currentTick = Interfaces.Call("ScienceUsage.GetCurrentTick")
    for _, player in pairs(game.connected_players) do
        Gui.UpdateScoreCurrentTimeForPlayer(player, currentTick)
    end
end

Gui.UpdateScoreCurrentTimeForPlayer = function(player, currentTick)
    local playerIndex = player.index
    if not global.gui.playerScoreOpen[playerIndex] then
        return
    end
    GuiUtil.UpdateElementFromPlayersReferenceStorage(playerIndex, "score", "time_current", "label", {caption = {"self", Utils.DisplayTimeOfTicks(currentTick, "hour", "second")}}, false)
end

Gui.OnLuaShortcut = function(event)
    local shortcutName = event.prototype_name
    if shortcutName == "science_off-score_toggle" then
        Gui.ToggleScoreForPlayer(game.get_player(event.player_index))
    elseif shortcutName == "science_off-score_value_toggle" then
        Gui.TogglePackValueForPlayer(game.get_player(event.player_index))
    end
end

Gui.UpdateTimeRemainingAllPlayers = function()
    local remainingTicks = Interfaces.Call("TimeLimit.GetTicksRemaining")
    for _, player in pairs(game.connected_players) do
        Gui.UpdateTimeRemainingPlayer(player, remainingTicks)
    end
end

Gui.UpdateTimeRemainingPlayer = function(player, remainingTicks)
    local playerIndex = player.index
    if not global.gui.playerScoreOpen[playerIndex] then
        return
    end
    if remainingTicks ~= nil then
        GuiUtil.UpdateElementFromPlayersReferenceStorage(playerIndex, "score", "time_remaining", "label", {caption = {"self", Utils.DisplayTimeOfTicks(remainingTicks, "hour", "second")}}, false)
    end
end

Gui.ShowEndGameTextAllPlayers = function()
    for _, player in pairs(game.connected_players) do
        Gui.ShowEndGameTextFoPlayer(player)
    end
end

Gui.ShowEndGameTextFoPlayer = function(player)
    Gui.CloseScoreForPlayer(player)
    Gui.OpenScoreForPlayer(player)
    Gui.CreateEndGameTextForPlayer(player)
end

Gui.CreateEndGameTextForPlayer = function(player)
    GuiUtil.AddElement(
        {
            parent = player.gui.left,
            type = "frame",
            style = "muppet_frame_main_marginTL_paddingBR",
            styling = {width = 400},
            children = {
                {
                    type = "flow",
                    direction = "vertical",
                    style = "muppet_flow_vertical_marginTL",
                    children = {
                        {
                            name = "end_game_title",
                            type = "label",
                            caption = "self",
                            style = "muppet_label_heading_large_bold"
                        },
                        {
                            name = "end_game_info_message1",
                            type = "label",
                            caption = "self",
                            style = "muppet_label_text_medium"
                        },
                        {
                            type = "line"
                        },
                        {
                            name = "end_game_info_message2",
                            type = "label",
                            caption = "self",
                            style = "muppet_label_text_medium"
                        },
                        {
                            name = "force_usage_data",
                            type = "frame",
                            direction = "vertical",
                            style = "muppet_frame_content_shadowSunken",
                            storeName = "end_game",
                            styling = {
                                horizontally_stretchable = true,
                                padding = 4,
                                top_margin = 4,
                                bottom_margin = 8
                            },
                            children = {
                                {
                                    name = "force_usage_data",
                                    type = "label",
                                    caption = "self",
                                    style = "muppet_label_text_small"
                                },
                                {
                                    name = "get_force_usage_data",
                                    type = "button",
                                    caption = "self",
                                    registerClick = {
                                        actionName = "getPlayersForceUsageData"
                                    },
                                    style = "muppet_button_text_medium",
                                    styling = {
                                        top_margin = 4
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    )
end

Gui.GetPlayersForceUsageDataButtonClicked = function(event)
    local player, playerIndex = game.get_player(event.playerIndex), event.playerIndex
    local forceTable = Interfaces.Call("ScienceUsage.GetPlayerForceTable", player)
    local jsonData = Interfaces.Call("ScienceUsage.GetUsageDataJsonForForceTable", forceTable)

    GuiUtil.DestroyElementInPlayersReferenceStorage(playerIndex, "end_game", "data_export", "text-box")
    GuiUtil.AddElement(
        {
            parent = GuiUtil.GetElementFromPlayersReferenceStorage(playerIndex, "end_game", "force_usage_data", "frame"),
            name = "data_export",
            type = "text-box",
            text = jsonData,
            style = "muppet_textbox",
            styling = {
                height = 88,
                width = 362,
                bottom_margin = 4,
                right_margin = -2
            },
            attributes = {
                word_wrap = true,
                read_only = true
            },
            storeName = "end_game"
        }
    )
end

Gui.OpenPackValueForPlayer = function(player)
    global.gui.playerPackValueOpen[player.index] = true
    player.set_shortcut_toggled("science_off-score_value_toggle", true)
    Gui.CreatePackValueForPlayer(player)
end

Gui.ClosePackValueForPlayer = function(player)
    GuiUtil.DestroyPlayersReferenceStorage(player.index, "pack_value")
    global.gui.playerPackValueOpen[player.index] = false
    player.set_shortcut_toggled("science_off-score_value_toggle", false)
end

Gui.TogglePackValueForPlayer = function(player)
    if global.gui.playerPackValueOpen[player.index] then
        Gui.ClosePackValueForPlayer(player)
    else
        Gui.OpenPackValueForPlayer(player)
    end
end

Gui.CreatePackValueForPlayer = function(player)
    local sciencePackValuesTableContents = {}
    for packPrototypeName, pointValue in pairs(Interfaces.Call("ScienceUsage.GetAllPackPoints")) do
        table.insert(
            sciencePackValuesTableContents,
            {
                type = "sprite",
                sprite = "item/" .. packPrototypeName,
                style = "muppet_sprite_32",
                styling = {
                    width = 24,
                    height = 24
                }
            }
        )
        table.insert(
            sciencePackValuesTableContents,
            {
                type = "label",
                style = "muppet_label_text_large",
                caption = {"gui-caption.science_off-pack_value_entry-label", pointValue}
            }
        )
    end
    GuiUtil.AddElement(
        {
            parent = player.gui.left,
            name = "packValue",
            type = "frame",
            style = "muppet_frame_main_marginTL_paddingBR",
            styling = {horizontally_stretchable = false},
            storeName = "pack_value",
            children = {
                {
                    type = "flow",
                    direction = "vertical",
                    style = "muppet_flow_vertical_marginTL",
                    children = {
                        {
                            name = "pack_value_title",
                            type = "label",
                            caption = "self",
                            style = "muppet_label_heading_large_bold"
                        },
                        {
                            type = "frame",
                            direction = "vertical",
                            style = "muppet_frame_content_shadowSunken",
                            styling = {horizontally_stretchable = true},
                            children = {
                                {
                                    type = "table",
                                    column_count = 2,
                                    style = "muppet_table_horizontalSpaced",
                                    children = sciencePackValuesTableContents
                                }
                            }
                        }
                    }
                }
            }
        }
    )
end

return Gui
