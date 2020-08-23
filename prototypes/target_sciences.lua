local Utils = require("utility/utils")
local CommonFunctions = require("scripts/common_functions")

local targetSciences = {}
for _, tool in pairs(data.raw["tool"]) do
    if tool.subgroup == "science-pack" then
        local targetScience = Utils.DeepCopy(tool)
        local origName = targetScience.name
        targetScience.name = CommonFunctions.GetTargetSciencePackName(targetScience.name)
        targetScience.localised_name = {"item-name.science_off-target_item", {"item-name." .. origName}}
        targetScience.localised_description = {"item-description.science_off-target_item", {"item-name." .. origName}}
        targetScience.flags = {"hidden"}
        CommonFunctions.UpdateTargetGraphicFromItsIcon(targetScience)
        table.insert(targetSciences, targetScience)
    end
end

data:extend(targetSciences)
