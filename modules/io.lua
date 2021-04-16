IO = {}

function IO.writeFile(filepath, data)

    local file, err = io.open(filepath,' w')
    if file then
        for key, val in pairs(data) do
            local line = tostring(key) .. '=' .. tostring(val)
            file:write(line .. '\n')
        end
        file:close()
    else
        print("error:", err)
    end
end

function IO.readFile(filepath)

    local file, err = io.open(filepath, 'rb')
    if file then
        local data = {}
        local count = 0
        for line in io.lines(filepath) do
            for key, val in string.gmatch(line, "(.*)=(.*)") do

                if(tonumber(key) ~= nil and string.match(key, "0x") == nil) then
                    if(val == "true" or val == "false") then
                        data[tonumber(key)] = tobool(val)
                    else
                        data[tonumber(key)] = val
                    end
                else
                    if(val == "true" or val == "false") then
                        data[key] = tobool(val)
                    else
                        data[key] = val
                    end
                end
            end
            count = count + 1
        end
        file:close()
        return data, count
    else
        print("error:", err)
    end
end

function IO.readReplacements()

    local file = io.open("replacements/replacements.ini", "rb")
    if(file == nil) then
        return nil
    end
    local replacementFiles = {}
    for line in io.lines("replacements/replacements.ini") do
        table.insert(replacementFiles, line)
    end
    local replacementTable = {}
    for _, val in ipairs(replacementFiles) do
        local curFile = IO.readFile("replacements/" .. val)
        table.insert(replacementTable, curFile)
    end
    return replacementTable
end

function tobool(v)
    return v and ( (type(v)=="number") and (v==1) or ( (type(v)=="string") and (v=="true") ) )
end

return IO