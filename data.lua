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

if_recipe_exists("insulation-science-pack", allow_prod)
if_recipe_exists("aerospace-science-pack", allow_prod)

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