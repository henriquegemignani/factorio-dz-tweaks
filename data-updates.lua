
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