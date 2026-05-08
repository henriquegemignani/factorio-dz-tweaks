
local entity = data.raw["reactor"]["heat-assembling-machine-muluna-vacuum-heating-tower-reactor"]
if entity then
    if entity.energy_source.emissions_per_minute then
        entity.energy_source.emissions_per_minute["electromagnetic_waves"] = nil
    end
end

if mods["nullius"] then
    data.raw["recipe"]["wooden-chest"].localised_name = {"entity-name.nullius-small-chest-1"}
    data.raw["recipe"]["wooden-chest"].ingredients = {
      {type = "item", name = "nullius-iron-sheet", amount = 2},
      {type = "item", name = "nullius-iron-rod", amount = 1}
    }
end