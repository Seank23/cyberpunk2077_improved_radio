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
            for key, val in string.gmatch(line, "(%w+)=(%w+)") do

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

function tobool(v)
    return v and ( (type(v)=="number") and (v==1) or ( (type(v)=="string") and (v=="true") ) )
end

return IO