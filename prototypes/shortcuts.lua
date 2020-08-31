local Constants = require("constants")

data:extend(
    {
        {
            type = "shortcut",
            name = "science_off-score_toggle",
            action = "lua",
            toggleable = true,
            icon = {
                filename = Constants.AssetModName .. "/graphics/shortcut/score_toggle.png",
                width = 36,
                height = 36
            },
            small_icon = {
                filename = Constants.AssetModName .. "/graphics/shortcut/score_toggle.png",
                width = 36,
                height = 36
            },
            disabled_small_icon = {
                filename = Constants.AssetModName .. "/graphics/shortcut/score_toggle-disabled.png",
                width = 36,
                height = 36
            }
        },
        {
            type = "shortcut",
            name = "science_off-score_value_toggle",
            action = "lua",
            toggleable = true,
            icon = {
                filename = Constants.AssetModName .. "/graphics/shortcut/score_value_toggle.png",
                width = 36,
                height = 36
            },
            small_icon = {
                filename = Constants.AssetModName .. "/graphics/shortcut/score_value_toggle.png",
                width = 36,
                height = 36
            },
            disabled_small_icon = {
                filename = Constants.AssetModName .. "/graphics/shortcut/score_value_toggle-disabled.png",
                width = 36,
                height = 36
            }
        }
    }
)
