
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