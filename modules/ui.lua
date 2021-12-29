UI = {
    parent = nil,
    stationNameToId = nil,
    removerSelectedStation = nil,
    songsEnabled = {},
    shufflePlaylist = false,
    playlistUIStations = {},
    playlistButtonName = "Play",
    curSlot = 1,
    replacementsSelected = {}
}

function UI.songCodeToLabel(code)

    if(code == "Select Track") then
        return code
    end
    
    local songInfo = songCodeToInfo(code)
    local songLabel = tostring(songInfo[3]) .. " - " .. tostring(songInfo[2])
    if(songInfo[2] == nil) then
        songLabel = tostring(songInfo[1])
    end
    return songLabel
end

function UI.switchPlaylistSlot(slotIndex)

    IO.writeFile("user/slot_" .. UI.curSlot .. ".ini", UI.parent.playlistSongs) -- Save current playlist to slot
    UI.curSlot = slotIndex
    UI.parent.playlistCount = 0
    UI.parent.playlistSongs = IO.readFile("user/slot_" .. slotIndex .. ".ini") -- Load playlist in selected slot
    for _, val in ipairs(UI.parent.playlistSongs) do
        UI.parent.loadPlaylistTrack(val)
    end
    if(UI.parent.playlistPlaying) then
        UI.parent.playlistNextSong()
    end
end

function UI.init(ImprovedRadio)

    UI.parent = ImprovedRadio
    UI.stationNameToId = table_invert(radioData.radioStationNames)

    ImGui.SetNextWindowPos(100, 500, ImGuiCond.FirstUseEver)
    ImGui.SetNextWindowSize(500, 820, ImGuiCond.Appearing)

    UI.songsEnabled = IO.readFile("user/songsEnabled.ini") -- Load enabled songs data
    
    if(UI.songsEnabled == nil) then -- Could not load songsEnabled.ini, creating songsEnabled table
        UI.songsEnabled = {}
        for key, _ in pairs(radioData.songHashToInfo) do
            UI.songsEnabled[key] = true
        end
    end
    UI.parent.setSongsToRemove(UI.songsEnabled)

    UI.parent.playlistSongs = IO.readFile("user/slot_" .. UI.curSlot .. ".ini") -- Load playlist in initial slot
    for _, val in ipairs(UI.parent.playlistSongs) do
        UI.parent.loadPlaylistTrack(val)
    end

    for key, _ in pairs(UI.parent.replacementTracks) do
        UI.replacementsSelected[key] = false
    end
end

function UI.draw()

    -- Main Window
    ImGui.Begin("Improved Radio")
    if(UI.parent.active == false) then
        ImGui.Text("Please enter a vehicle and turn on the radio.")
    else
        ImGui.PushItemWidth(480)
        if ImGui.BeginCombo("##Replacements", "Replacements") then

            for key, _ in pairs(UI.parent.replacementTracks) do
                local prevVal = UI.replacementsSelected[key]
                UI.replacementsSelected[key] = ImGui.Checkbox(key, UI.replacementsSelected[key])
                if(UI.replacementsSelected[key] ~= prevVal) then
                    if(UI.replacementsSelected[key]) then
                        UI.parent.enableReplacement(key)
                    else
                        UI.parent.disableReplacement(key) 
                    end
                    UI.stationNameToId = table_invert(radioData.radioStationNames)
                    UI.removerSelectedStation = radioData.radioStationNames[UI.parent.curStation]
                end
            end
            ImGui.EndCombo()
        end
        ImGui.PopItemWidth()

        -- Current Track Info Panel
        ImGui.BeginChild("trackInfo", 480, 92, true)
        songInfo = songCodeToInfo(UI.parent.curSong)
        local trackName = songInfo[3]
        if(trackName == nil) then trackName = songInfo[1] end
        ImGui.SetWindowFontScale(1.2)
        ImGui.Text("Playing...")
        ImGui.SetWindowFontScale(1)
        ImGui.Spacing()
        ImGui.Separator()
        ImGui.Text("Track: " .. tostring(trackName))
        ImGui.Text("Artist: " .. tostring(songInfo[2]))
        ImGui.Text("Station: " .. tostring(radioData.radioStationNames[UI.parent.curStation]))
        ImGui.EndChild()

        ImGui.Spacing()

        -- Skip Track Button
        if(ImGui.Button("Skip Track", 150, 20)) then
            if(UI.parent.playlistPlaying) then
                UI.parent.prevSong = UI.parent.playlistNextSong()
            else
                UI.parent.skipSong()
            end
        end

        ImGui.Spacing()

        -- Track Remover Menu
        if(ImGui.CollapsingHeader("Track Remover")) then

            -- Track Remover Panel
            ImGui.BeginChild("trackRemover", 480, 250, true)

            if(UI.removerSelectedStation == nil) then
                if(UI.parent.curStation) then
                    UI.removerSelectedStation = radioData.radioStationNames[UI.parent.curStation]
                else
                    UI.removerSelectedStation = radioData.radioStationNames["radio_station_01_att_rock"]
                end
            end

            -- Station Dropdown
            if ImGui.BeginCombo("##Station", UI.removerSelectedStation) then

                for _, option in pairs(radioData.radioStationNames) do
                    if ImGui.Selectable(option, (option == UI.removerSelectedStation)) then
                        UI.removerSelectedStation = option
                        ImGui.SetItemDefaultFocus()
                    end
                end
                ImGui.EndCombo()
            end

            ImGui.SameLine()

            if(ImGui.Button("Tune Station", 132, 20)) then
                UI.parent.tuneStation(UI.stationNameToId[UI.removerSelectedStation])
            end

            ImGui.Spacing()
            ImGui.Separator()
            
            local songCodes = getStationSongs(UI.stationNameToId[UI.removerSelectedStation])

            if(songCodes) then
                -- Station Song List
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
                        IO.writeFile("user/songsEnabled.ini", UI.songsEnabled)
                    end
                end
            end
            ImGui.EndChild()
        end

        ImGui.Spacing()

        -- Custom Radio Playlist Menu
        if(ImGui.CollapsingHeader("Custom Radio Playlist")) then

            -- Custom Radio Playlist Panel
            ImGui.BeginChild("customRadio", 480, 250, true)

            -- Play/Stop Playlist Button
            if(ImGui.Button(UI.playlistButtonName, 150, 20)) then

                if(UI.parent.playlistPlaying) then
                    UI.parent.stopPlaylist()
                else
                    UI.parent.playPlaylist()
                end
            end

            ImGui.SameLine()

            -- Clear Playlist Button
            if(ImGui.Button("Clear", 150, 20)) then
                UI.parent.clearPlaylist()
            end

            ImGui.SameLine()

            -- Shuffle Playlist Checkbox
            UI.parent.playlistShuffle = ImGui.Checkbox("Shuffle", UI.parent.playlistShuffle)

            -- Add Track Button
            if(ImGui.Button("Add Track", 150, 20)) then
                UI.parent.playlistCount = UI.parent.playlistCount + 1
                UI.playlistUIStations[UI.parent.playlistCount] = "Select Station"
                UI.parent.playlistSongs[UI.parent.playlistCount] = "Select Track"
            end

            -- Slot Buttons
            for i = 1, 5 do
                ImGui.SameLine()
                if(ImGui.Button("Slot " .. i)) then
                    UI.switchPlaylistSlot(i)
                end
            end

            ImGui.Spacing()
            ImGui.Separator()

            -- Playlist Tracklist
            for i = 1, UI.parent.playlistCount do

                -- Playlist Entry Station Dropdown
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

                -- Playlist Entry Track Dropdown
                ImGui.SameLine(220)
                if ImGui.BeginCombo("##CustomSong" .. i, UI.songCodeToLabel(UI.parent.playlistSongs[i])) then
                    
                    if(UI.playlistUIStations[i] ~= "Select Station") then

                        local songNames = {}
                        local songCodes = getStationSongs(UI.stationNameToId[UI.playlistUIStations[i]])
                        if(songCodes) then
                            for _, option in pairs(songCodes) do

                                if ImGui.Selectable(UI.songCodeToLabel(option), (option == UI.parent.playlistSongs[i])) then
                                    UI.parent.playlistSongs[i] = option
                                    ImGui.SetItemDefaultFocus()
                                    IO.writeFile("user/slot_" .. UI.curSlot .. ".ini", UI.parent.playlistSongs) -- Save current playlist to slot
                                end
                            end
                        end
                    end
                    ImGui.EndCombo()
                end
                ImGui.PopItemWidth()

                -- Playlist Entry Remove Button
                ImGui.SameLine(430)
                if(ImGui.Button("X (" .. i .. ")")) then
                    UI.parent.removePlaylistSong(i)
                end
            end
            ImGui.EndChild()
        end
    end
    ImGui.End()
end

return UI