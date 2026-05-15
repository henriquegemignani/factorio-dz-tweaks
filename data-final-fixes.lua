
local entity = data.raw["reactor"]["heat-assembling-machine-muluna-vacuum-heating-tower-reactor"]
if entity then
    if entity.energy_source.emissions_per_minute then
        entity.energy_source.emissions_per_minute["electromagnetic_waves"] = nil
    end
end

if mods["nullius"] then
    if data.raw["recipe"]["nullius-closed-chest"] then
        data.raw["recipe"]["nullius-closed-chest"].allow_as_intermediate = false
        data.raw["recipe"]["nullius-closed-chest"].allow_intermediates = false
    end
end