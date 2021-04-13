local IO = require("io.lua")

UI = {
    radioData = require("radioData.lua"),
    parent = nil,
    removerSelectedStation = nil,
    songsEnabled = {},
    shufflePlaylist = false,
    playlistUIStations = {},
    playlistButtonName = "Play",
    curSlot = 1
}

function table_invert(t)
    local s={}
    for k,v in pairs(t) do
      s[v]=k
    end
    return s
end

function getSongCodes(radioName)

    local stationId = table_invert(radioData.radioStationNames)
    local songList = radioData.radioStationSongs[stationId[radioName]]

    if(songList) then
        local songCodes = {}
        for val in string.gmatch(songList, "(%w+),") do
            table.insert(songCodes, val)
        end
        return songCodes
    end
    return nil
end

function UI.songCodeToLabel(code)

    if(code == "Select Track") then
        return code
    end
    
    local songInfo = UI.parent.songCodeToInfo(code)

    local songLabel = tostring(songInfo[3]) .. " - " .. tostring(songInfo[2])
    if(songInfo[2] == nil) then
        songLabel = tostring(songInfo[1])
    end
    return songLabel
end

function UI.init(ImprovedRadio)

    UI.parent = ImprovedRadio

    ImGui.SetNextWindowPos(100, 500, ImGuiCond.FirstUseEver)
    ImGui.SetNextWindowSize(500, 800, ImGuiCond.Appearing)

    UI.songsEnabled = IO.readFile("songsEnabled.ini")
    
    if(UI.songsEnabled == nil) then
        UI.songsEnabled = {}
        for key, _ in pairs(radioData.songHashToInfo) do
            UI.songsEnabled[key] = true
        end
    end
    UI.parent.setSongsToRemove(UI.songsEnabled)

    local playlistCount = 0
    UI.parent.playlistSongs, playlistCount = IO.readFile("slot_" .. UI.curSlot .. ".ini")
    for i = 1, playlistCount do
        UI.parent.loadTrack(UI.parent.playlistSongs[i])
    end
end

function UI.draw()

    ImGui.Begin("Improved Radio")

    ImGui.BeginChild("trackInfo", 480, 92, true)
    songInfo = {}
    if(UI.parent.curSongInfoString) then
        for val in string.gmatch(UI.parent.curSongInfoString, "[^%|]+") do
            table.insert(songInfo, val)
        end
    end
    local trackName = songInfo[3]
    if(trackName == nil) then trackName = songInfo[1] end
    ImGui.SetWindowFontScale(1.2)
    ImGui.Text("Playing...")
    ImGui.SetWindowFontScale(1)
    ImGui.Spacing()
    ImGui.Separator()
    ImGui.Text("Track: " .. tostring(trackName))
    ImGui.Text("Artist: " .. tostring(songInfo[2]))
    ImGui.Text("Station: " .. tostring(UI.radioData.radioStationNames[UI.parent.curStation]))
    ImGui.EndChild()

    ImGui.Spacing()

    if(ImGui.Button("Skip Track", 150, 20)) then
        if(UI.parent.playlistPlaying) then
            UI.parent.prevSong = UI.parent.playlistNextSong()
        else
            UI.parent.skipSong()
        end
    end

    ImGui.Spacing()

    if(ImGui.CollapsingHeader("Track Remover")) then

        ImGui.BeginChild("trackRemover", 480, 250, true)

        if(UI.removerSelectedStation == nil) then
            UI.removerSelectedStation = radioData.radioStationNames[UI.parent.curStation]
        end

        if ImGui.BeginCombo("Station", UI.removerSelectedStation) then

            for _, option in pairs(radioData.radioStationNames) do
                if ImGui.Selectable(option, (option == UI.removerSelectedStation)) then
                    UI.removerSelectedStation = option
                    ImGui.SetItemDefaultFocus()
                end
            end
            ImGui.EndCombo()
        end
        ImGui.Spacing()
        ImGui.Separator()

        local songCodes = getSongCodes(UI.removerSelectedStation)

        if(songCodes) then
            for _, val in ipairs(songCodes) do

                local songState = "(enabled) "
                if(UI.songsEnabled[val] == false) then
                    songState = "(disabled) "
                end

                local songLabel = UI.songCodeToLabel(val)
                local prevEnabled = UI.songsEnabled[val]
                UI.songsEnabled[val] = ImGui.Selectable(songState .. songLabel, UI.songsEnabled[val], ImGuiSelectableFlags.AllowDoubleClick)

                if(UI.songsEnabled[val] ~= prevEnabled) then
                    UI.parent.setSongsToRemove(UI.songsEnabled)
                    IO.writeFile("songsEnabled.ini", UI.songsEnabled)
                end
            end
        end
        
        ImGui.EndChild()
    end
    ImGui.Spacing()

    if(ImGui.CollapsingHeader("Custom Radio Playlist")) then

        ImGui.BeginChild("customRadio", 480, 250, true)
        if(ImGui.Button(UI.playlistButtonName, 150, 20)) then

            if(UI.parent.playlistPlaying) then
                UI.parent.playlistPlaying = false
                UI.playlistButtonName = "Play"
            else
                UI.parent.prevSong = nil
                UI.parent.playlistPlaying = true
                UI.playlistButtonName = "Stop"
            end
        end
        ImGui.SameLine()
        UI.parent.playlistShuffle = ImGui.Checkbox("Shuffle", UI.parent.playlistShuffle)
        ImGui.SameLine()
        if(ImGui.Button("Clear")) then
            UI.parent.playlistSongs = {}
            UI.parent.playlistCount = 0
            UI.parent.playlistPlaying = false
        end

        if(ImGui.Button("Add Track", 150, 20)) then
            UI.parent.playlistCount = UI.parent.playlistCount + 1
            UI.playlistUIStations[UI.parent.playlistCount] = "Select Station"
            UI.parent.playlistSongs[UI.parent.playlistCount] = "Select Track"
        end

        for i = 1, 5 do
            ImGui.SameLine()
            if(ImGui.Button("Slot " .. i)) then

                IO.writeFile("slot_" .. UI.curSlot .. ".ini", UI.parent.playlistSongs) -- Save current playlist to slot
                UI.curSlot = i
                UI.parent.playlistCount = 0
                local playlistCount = 0
                UI.parent.playlistSongs, playlistCount = IO.readFile("slot_" .. i .. ".ini") -- Load selected slot
                for i = 1, playlistCount do
                    UI.parent.loadTrack(UI.parent.playlistSongs[i])
                end
                if(UI.parent.playlistPlaying) then
                    UI.parent.playlistNextSong()
                end
            end
        end
        ImGui.Spacing()
        ImGui.Separator()
        for i = 1, UI.parent.playlistCount do

            ImGui.PushItemWidth(200)
            if ImGui.BeginCombo("##CustomStation" .. i, UI.playlistUIStations[i]) then

                for _, option in pairs(radioData.radioStationNames) do
                    if ImGui.Selectable(option, (option == UI.playlistUIStations[i])) then
                        UI.playlistUIStations[i] = option
                        ImGui.SetItemDefaultFocus()
                    end
                end
                ImGui.EndCombo()
            end
            ImGui.SameLine(220)
            if ImGui.BeginCombo("##CustomSong" .. i, UI.songCodeToLabel(UI.parent.playlistSongs[i])) then
                
                if(UI.playlistUIStations[i] ~= "Select Station") then

                    local songNames = {}
                    local songCodes = getSongCodes(UI.playlistUIStations[i])
                    if(songCodes) then
                        for _, option in pairs(songCodes) do

                            if ImGui.Selectable(UI.songCodeToLabel(option), (option == UI.parent.playlistSongs[i])) then
                                UI.parent.playlistSongs[i] = option
                                ImGui.SetItemDefaultFocus()
                            end
                        end
                    end
                end
                ImGui.EndCombo()
            end
            ImGui.PopItemWidth()
            ImGui.SameLine(430)
            if(ImGui.Button("X (" .. i .. ")")) then
                UI.parent.removePlaylistSong(i)
            end
        end
        ImGui.EndChild()
    end

    ImGui.End()
end

return UI