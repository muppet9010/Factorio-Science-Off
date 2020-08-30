local CommonFunctions = {}
local Constants = require("constants")

CommonFunctions.GetTargetSciencePackName = function(name)
    return "science_off-" .. name .. "-target"
end

CommonFunctions.UpdateTargetGraphicFromItsIcon = function(prototype)
    prototype.icons = {
        {
            icon = prototype.icon,
            icon_size = prototype.icon_size,
            icon_mipmaps = prototype.icon_mipmaps
        },
        {
            icon = Constants.AssetModName .. "/graphics/icons/line-chart-64.png",
            icon_size = 64
        }
    }
    prototype.icon = nil
    prototype.icon_size = nil
    prototype.icon_mipmaps = nil
end

return CommonFunctions
