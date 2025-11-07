
local entity = data.raw["reactor"]["heat-assembling-machine-muluna-vacuum-heating-tower-reactor"]
if entity then
    if entity.energy_source.emissions_per_minute then
        entity.energy_source.emissions_per_minute["electromagnetic_waves"] = nil
    end
end