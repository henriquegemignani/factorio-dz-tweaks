local asteroid_util = require("__space-age__.prototypes.planet.asteroid-spawn-definitions")

local function table_find(t, n)
    for _, v in pairs(t) do
        if v == n then
            return true
        end
    end
    return false
end

---@param name string
---@param call function(proto: data.RecipePrototype): nil
local function if_recipe_exists(name, call)
    local it = data.raw["recipe"][name]
    if it then
        call(it)
    end
end

---@param item data.ItemPrototype?
---@param location data.SpaceLocationID
local function default_import_fix(item, location)
    if item then
        item.default_import_location = location
    end
end

---@param proto data.RecipePrototype
local function allow_prod(proto)
    proto.allow_productivity = true
end

---@param proto data.RecipePrototype
---@param mapping table<string, int>
local function ignore_productivity_fix(proto, mapping)
    for _, result in pairs(proto.results) do
        local n = mapping[result.name]
        if n then
            result.ignored_by_productivity = n
        end
    end
end

-- Make Thorium Extraction not produce barrels out of thin air
if_recipe_exists(
    "thorium-extraction", 
    ---@param proto data.RecipePrototype
    function(proto)
        ignore_productivity_fix(proto, {
            ["barrel"] = 20,
        })
    end
)

-- Make Frontrider enrichment process not positive for thorium
if_recipe_exists(
    "frontrider-enrichment-process",
    ---@param proto data.RecipePrototype
    function(proto)
        ignore_productivity_fix(proto, {
            ["thorium"] = 30,
            ["uranium-235"] = 1,
        })
    end
)

-- Make the superheated iron/copper melting accept prod and not produce lubricant
for _, name in pairs {"superheated-molten-iron", "superheated-molten-copper"} do
    if_recipe_exists(
        name,
        ---@param proto data.RecipePrototype
        function(proto)
            proto.allow_productivity = true
            ignore_productivity_fix(proto, {
                ["lubricant"] = 200,
            })
        end
    ) 
end

if_recipe_exists(
    "hardened-steel",
    ---@param proto data.RecipePrototype
    function(proto)
        proto.allow_productivity = true
        ignore_productivity_fix(proto, {
            ["hot-lubricant"] = 200,
        })
    end
) 

-- Allow prod in a bunch of recipes
if_recipe_exists("insulation-science-pack", allow_prod)
if_recipe_exists("aerospace-science-pack", allow_prod)
if_recipe_exists("atmospheric-thruster", allow_prod)
if_recipe_exists("rhenium-alloy-plate", allow_prod)
if_recipe_exists("navicomputer", allow_prod)
if_recipe_exists("atmospheric-fuel", allow_prod)
if_recipe_exists("battery-from-lithium", allow_prod)

-- Fix default import for certain items
default_import_fix(data.raw["tool"]["insulation-science-pack"], "prosephina")
default_import_fix(data.raw["tool"]["thermodynamic-science-pack"], "lemures")
default_import_fix(data.raw["tool"]["aerospace-science-pack"], "planet-dea-dia")

-- Fixes for Thermodynamic Science
if_recipe_exists(
    "thermodynamic-science-pack",
    ---@param proto data.RecipePrototype
    function(proto)
        proto.allow_productivity = true

        for _, ingredient in pairs(proto.ingredients) do
            if ingredient.name == "water" then
                ingredient.amount = 100
            end
        end

        ignore_productivity_fix(proto, {
            ["hot-lubricant"] = 100,
            ["steam"] = 1000,
        })
    end
)

-- Fixes

-- Ensure Maraxsis makes the vessel for all sciences
---@param name string
local function ensure_pressurized(name)
    if data.raw["tool"][name] then
        local inputs = data.raw["lab"]["biolab"].inputs
        if not table_find(inputs, name) then
            table.insert(inputs, name)
        end
    end
end
ensure_pressurized "insulation-science-pack"
ensure_pressurized "thermodynamic-science-pack"
ensure_pressurized "aerospace-science-pack"
ensure_pressurized "battlefield-science-pack"

-- Add a route from castra to corrundum
if data.raw["planet"]["castra"] and data.raw["planet"]["corrundum"] then
    data:extend {
        {
            type = "space-connection",
            name = "castra-corrundum",
            subgroup = "planet-connections",
            from = "castra",
            to = "corrundum",
            order = "f1",
            length = 20000,
            asteroid_spawn_definitions = asteroid_util.spawn_definitions(asteroid_util.vulcanus_gleba)
        },
    }
end

if data.raw["technology"]["asteroid-productivity"] then
    if data.raw["recipe"]["auric-asteroid-crushing"] then
        table.insert(data.raw["technology"]["asteroid-productivity"].effects, {
            type = "change-recipe-productivity",
            recipe = "auric-asteroid-crushing",
            change = 0.1,
            hidden = false
        })
    end

    if data.raw["recipe"]["promethium-gravel"] then
        table.insert(data.raw["technology"]["asteroid-productivity"].effects, {
            type = "change-recipe-productivity",
            recipe = "promethium-gravel",
            change = 0.1,
            hidden = false
        })
    end
end

-- Make bioflux recycle into itself
if_recipe_exists(
    "bioflux-from-gel",
    ---@param proto data.RecipePrototype
    function(proto)
        proto.auto_recycle = false
    end
)