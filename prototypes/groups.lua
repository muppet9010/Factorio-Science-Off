local Constants = require("constants")

data:extend(
    {
        {
            type = "item-group",
            name = "science_off",
            icon = Constants.AssetModName .. "/graphics/group/science_off.png",
            icon_size = 32,
            order = "zzz"
        },
        {
            type = "item-subgroup",
            name = "science_off-counters",
            group = "science_off"
        },
        {
            type = "item-subgroup",
            name = "science_off-target_counters",
            group = "science_off"
        }
    }
)
