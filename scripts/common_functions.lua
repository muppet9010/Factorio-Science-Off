local CommonFunctions = {}

CommonFunctions.GetTargetSciencePackName = function(name)
    return "science_off-" .. name .. "-target"
end

CommonFunctions.UpdateTargetGraphicFromItsIcon = function(prototype)
    prototype.icons = {
        {
            icon = "__core__/graphics/covered-chunk.png",
            icon_size = 10,
            icon_mipmaps = 0
        },
        {
            icon = prototype.icon,
            icon_size = prototype.icon_size,
            icon_mipmaps = prototype.icon_mipmaps
        }
    }
    prototype.icon = nil
    prototype.icon_size = nil
    prototype.icon_mipmaps = nil
end

return CommonFunctions
