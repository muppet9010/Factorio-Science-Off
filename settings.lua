data:extend(
    {
        {
            name = "science_off-time_limit",
            type = "int-setting",
            default_value = 120,
            minimum_value = 0,
            setting_type = "startup",
            order = "1001"
        },
        {
            name = "science_off-points_target",
            type = "int-setting",
            default_value = 0,
            minimum_value = 0,
            setting_type = "startup",
            order = "1002"
        },
        {
            name = "science_off-target_run_data",
            type = "string-setting",
            default_value = "",
            allow_blank = true,
            setting_type = "startup",
            order = "1003"
        }
    }
)
data:extend(
    {
        {
            name = "science_off-game_end_state",
            type = "string-setting",
            default_value = "editor",
            allowed_values = {"editor", "god"},
            setting_type = "runtime-global",
            order = "1004"
        }
    }
)
