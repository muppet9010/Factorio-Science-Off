local Constants = require("constants")

data:extend(
    {
        {
            type = "item-group",
            name = "science_off",
            icon = Constants.AssetModName .. "/thumbnail.png",
            icon_size = 64,
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
