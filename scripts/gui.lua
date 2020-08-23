local Interfaces = require("utility/interfaces")
local Events = require("utility/events")
local GuiUtil = require("utility/gui-util")
--local Logging = require("utility/logging")
local Colors = require("utility/colors")
local GuiActionsClick = require("utility/gui-actions-click")
local Utils = require("utility/utils")
local Gui = {}

Gui.CreateGlobals = function()
    global.gui = global.gui or {}
    global.gui.playerScoreOpen = global.gui.playerScoreOpen or {}
end

Gui.OnLoad = function()
    Interfaces.RegisterInterface("Gui.UpdateScoreForForcesPlayers", Gui.UpdateScoreForForcesPlayers)
    Events.RegisterEvent(defines.events.on_player_joined_game)
    Events.RegisterHandler(defines.events.on_player_joined_game, "Gui.OnPlayerJoined", Gui.OnPlayerJoined)
    Events.RegisterEvent(defines.events.on_lua_shortcut)
    Events.RegisterHandler(defines.events.on_lua_shortcut, "Gui.OnLuaShortcut", Gui.OnLuaShortcut)
    Interfaces.RegisterInterface("Gui.ShowFinalScoreAllPlayers", Gui.ShowFinalScoreAllPlayers)
end

Gui.OnStartup = function()
    Gui.RecreateAllPlayers()
end

Gui.OnPlayerJoined = function(event)
    local playerIndex, player = event.player_index, game.get_player(event.player_index)
    global.gui.playerScoreOpen[playerIndex] = global.gui.playerScoreOpen[playerIndex] or true
    Gui.RecreatePlayer(player)
end

Gui.RecreatePlayer = function(player)
    GuiUtil.DestroyPlayersReferenceStorage(player.index, "score")
    if not global.gui.playerScoreOpen[player.index] then
        return
    end
    Gui.OpenScoreForPlayer(player)
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
                    children = {
                        {
                            type = "label",
                            caption = {"gui-caption.science_off-score_title-label"},
                            style = "muppet_label_heading_large_bold"
                        },
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
                            style = "muppet_frame_content",
                            storeName = "score",
                            styling = {horizontally_stretchable = true},
                            attributes = {
                                visible = false
                            }
                        }
                    }
                }
            }
        }
    )
    Gui.UpdateScoreForPlayer(player)
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
        --local packValue = Interfaces.Call("ScienceUsage.GetPackPointValue", packPrototypeName)
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
        -- removed as made GUI very messy and would have needed headings on table
        --[[table.insert(
            sciencePackGuiElements,
            {
                type = "label",
                caption = packValue,
                style = "muppet_label_text_medium"
            }
        )--]]
        table.insert(
            sciencePackGuiElements,
            {
                type = "label",
                caption = "x " .. Utils.DisplayNumberPretty(packCount),
                style = "muppet_label_text_medium"
            }
        )
        -- removed as made GUI very messy and would have needed headings on table
        --[[table.insert(
            sciencePackGuiElements,
            {
                type = "label",
                caption = (packCount * packValue),
                style = "muppet_label_text_medium"
            }
        )--]]
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

Gui.OnLuaShortcut = function(event)
    local shortcutName = event.prototype_name
    if shortcutName == "science_off-score_toggle" then
        local player = game.get_player(event.player_index)
        Gui.ToggleScoreForPlayer(player)
    end
end

Gui.ShowFinalScoreAllPlayers = function(event)
    --TODO: do the final full screen score for all connected players at the end.
end

return Gui
