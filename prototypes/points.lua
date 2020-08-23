local Utils = require("utility/utils")
local CommonFunctions = require("scripts/common_functions")

local points = {
    type = "item",
    name = "science_off-points",
    icon = "__base__/graphics/icons/coin.png",
    icon_size = 64,
    icon_mipmaps = 4,
    flags = {"hidden"},
    subgroup = "science-pack",
    order = "y",
    stack_size = 1
}

local targetPoints = Utils.DeepCopy(points)
targetPoints.name = targetPoints.name .. "-target"
CommonFunctions.UpdateTargetGraphicFromItsIcon(targetPoints)

data:extend({points, targetPoints})
