local asteroid_util
if mods["space-age"] then
    asteroid_util = require("__space-age__.prototypes.planet.asteroid-spawn-definitions")
end

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
local function remove_auto_recycle(proto)
    proto.auto_recycle = false
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

-- Clear auto_recycle from certain recipes
if_recipe_exists("bioflux-from-gel", remove_auto_recycle)
if_recipe_exists("planetaris-compression-rocket-fuel", remove_auto_recycle)

-- Make Wooden Platform only use pelagos recipe, for upcycling reasons
if mods["wooden_platform"] and mods["pelagos"] then
    data.raw["recipe"]["wooden-platform"].ingredients = {
        { type = "item", name = "wood", amount = 15 },
        { type = "item", name = "coconut-sealant", amount = 5 },
        { type = "item", name = "coconut-husk", amount = 10 },
    }
end

-- Add a route from Moshine to Maraxsis, since Arig removes the other routes
if mods["planetaris-arig"] and data.raw["planet"]["moshine"] and data.raw["planet"]["maraxsis"] then
    data:extend {{
        type = "space-connection",
        name = "moshine-maraxsis",
        subgroup = "planet-connections",
        from = "moshine",
        to = "maraxsis",
        order = "f",
        length = 20000,
        asteroid_spawn_definitions = asteroid_util.spawn_definitions(asteroid_util.gleba_aquilo)
    }}
end

-- Lock all tech that uses gold science behind the gold science pack
for _, tech in pairs(data.raw["technology"]) do
    if tech.prerequisites and tech.prerequisites[1] == "planet-discovery-secretas" and tech.name ~= "steam-recycler" then
        tech.prerequisites = {"golden-science-pack"}
    end
end
if data.raw["technology"]["golden-science-pack"] then
    data.raw["technology"]["golden-science-pack"].prerequisites = {"steam-recycler"}
end

-- Merge vesta's heavy-water with metal&stars
if data.raw["fluid"]["heavy-water"] and data.raw["fluid"]["ske_heavy_water"] then
    data.raw["recipe"]["heavy-water"] = data.raw["recipe"]["ske_heavy_water"]
    data.raw["recipe"]["heavy-water"].name = "heavy-water"
    data.raw["recipe"]["ske_heavy_water"] = nil
    data.raw["fluid"]["ske_heavy_water"] = nil

    for _, tech in pairs(data.raw["technology"]) do
        if tech.effects then
            for _, effect in pairs(tech.effects) do
                if effect.type == "unlock-recipe" and effect.recipe == "ske_heavy_water" then
                    effect.recipe = "heavy-water"
                end
            end
        end
        if tech.research_trigger then
            if tech.research_trigger.type == "craft-fluid" and tech.research_trigger.fluid == "ske_heavy_water" then
                tech.research_trigger.fluid = "heavy-water"
            end
        end
    end
    for _, recipe in pairs(data.raw["recipe"]) do
        if recipe.ingredients then
            for _, ingredient in pairs(recipe.ingredients) do
                if ingredient.name == "ske_heavy_water" then
                    ingredient.name = "heavy-water"
                end
            end
        end
        if recipe.results then
            for _, result in pairs(recipe.results) do
                if result.name == "ske_heavy_water" then
                    result.name = "heavy-water"
                end
            end
        end
    end
end