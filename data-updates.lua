
---@param recipe_name string
---@param technology_name string
local function remove_unlock(recipe_name, technology_name)
    local tech = data.raw["technology"][technology_name]
    if tech and tech.effects then
        for i = #tech.effects, 1, -1 do
            local effect = tech.effects[i]
            if effect.type == "unlock-recipe" and effect.recipe == recipe_name then
                table.remove(tech.effects, i)
            end
        end
    end
end


-- Remove the battlefield science pack entry from the biolab we added, as it breaks castra
if data.raw["tool"]["battlefield-science-pack"] then
    local inputs = data.raw["lab"]["biolab"].inputs

    for i = #inputs, 1, -1 do
        if inputs[i] == "battlefield-science-pack" then
            table.remove(inputs, i)
            break
        end
    end
end

if data.raw["assembling-machine"]["atan-atom-forge"] then
    local fluid_boxes = data.raw["assembling-machine"]["atan-atom-forge"].fluid_boxes
    if fluid_boxes then
        fluid_boxes[1].pipe_connections[1].position = { 0.25, -2.66 }
        fluid_boxes[2].pipe_connections[1].position = { 0.25, 2.66 }
    end
end

if mods["wooden_platform"] and mods["pelagos"] then
    remove_unlock("wooden-platform", "steel-axe")
    remove_unlock("pelagos-wooden-platform", "coconut-processing-technology")
    table.insert(
		data.raw["technology"]["coconut-processing-technology"].effects,
		{ type = "unlock-recipe", recipe = "wooden-platform" }
	)
    data.raw["recipe"]["pelagos-wooden-platform"] = nil
end