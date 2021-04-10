UI = {
    radioData = require("radioData.lua"),
    parent = nil,
    songsEnabled = {}
}

function table_invert(t)
    local s={}
    for k,v in pairs(t) do
      s[v]=k
    end
    return s
end

function UI.init(ImprovedRadio)

    UI.parent = ImprovedRadio

    ImGui.SetNextWindowPos(100, 500, ImGuiCond.FirstUseEver)
    ImGui.SetNextWindowSize(500, 600, ImGuiCond.Appearing)

    for key, _ in pairs(radioData.songHashToInfo) do
        UI.songsEnabled[key] = true
    end
end

function UI.draw()

    ImGui.Begin("Improved Radio")

    ImGui.BeginChild("trackInfo", 480, 65, true)
    songInfo = {}
    if(UI.parent.curSongInfoString) then
        for val in string.gmatch(UI.parent.curSongInfoString, "[^%|]+") do
            table.insert(songInfo, val)
        end
    end
    ImGui.Text("Track: " .. tostring(songInfo[3]))
    ImGui.Text("Artist: " .. tostring(songInfo[2]))
    ImGui.Text("Station: " .. tostring(UI.radioData.radioStationNames[UI.parent.curStation]))
    ImGui.EndChild()

    ImGui.Spacing()

    if(ImGui.Button("Skip Track")) then
        UI.parent.skipSong()
    end

    ImGui.Spacing()

    if(ImGui.CollapsingHeader("Track Remover")) then

        ImGui.BeginChild("trackRemover", 480, 300, true)

        local dropdownSelected = radioData.radioStationNames[UI.parent.curStation]

        if ImGui.BeginCombo("Station", tostring(dropdownSelected)) then

            for i, option in pairs(radioData.radioStationNames) do
                if ImGui.Selectable(option, (option == dropdownSelected)) then
                    dropdownSelected = option
                    ImGui.SetItemDefaultFocus()
                end
            end
            ImGui.EndCombo()
        end
        ImGui.Spacing()
        ImGui.Separator()

        local stationId = table_invert(radioData.radioStationNames)
        local songList = radioData.radioStationSongs[stationId[dropdownSelected]]

        if(songList) then

            local songCodes = {}
            for val in string.gmatch(songList, "(%w+),") do
                table.insert(songCodes, val)
            end

            for key, val in ipairs(songCodes) do

                local songInfoString = radioData.songHashToInfo[val]
                local songInfo = {}
                for info in string.gmatch(songInfoString, "[^%|]+") do
                    table.insert(songInfo, info)
                end

                local songLabel = tostring(songInfo[3]) .. " - " .. tostring(songInfo[2])
                if(songInfo[2] == nil) then
                    songLabel = tostring(songInfo[1])
                end

                local prevEnabled = UI.songsEnabled[val]
                UI.songsEnabled[val] = ImGui.Selectable(songLabel, UI.songsEnabled[val], ImGuiSelectableFlags.AllowDoubleClick)

                if(UI.songsEnabled[val] ~= prevEnabled) then
                UI.parent.setSongsToRemove(UI.songsEnabled)
                end
            end
        end
        ImGui.EndChild()
    end
    ImGui.Spacing()
    if(ImGui.CollapsingHeader("Custom Radio Station")) then

    end

    ImGui.End()
end

return UI