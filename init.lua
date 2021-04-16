local radioData = require("modules/radioData.lua")
local IO = require("modules/io.lua")

ImprovedRadio = {
    ui = require("modules/ui.lua"),
    updateSeconds = 1,
    player = nil,
    workSpot = nil,
    car = nil,
    audio = nil,
    timer = 0,
    isUIVisible = false,
    curStation = nil,
    curSongInfoString = nil,
    songsToRemove = {},
    playlistSongs = {},
    playlistCount = 0,
    playlistIndex = 1,
    playlistPlaying = false,
    playlistShuffle = false,
    curSong = nil,
    prevSong = nil,

    radioDataStationsBak = nil,
    radioDataTracksBak = nil,
    replacementStations = {},
    replacementTracks = {} 
}

function ImprovedRadio:new()

    -- Init function
    registerForEvent("onInit", function() 

        ImprovedRadio.player = Game.GetPlayer() 
        ImprovedRadio.workSpot = Game.GetWorkspotSystem()
        ImprovedRadio.audio = Game.GetAudioSystem()
        ImprovedRadio.loadReplacements()
        ImprovedRadio.ui.init(ImprovedRadio)
        timer = 0
    end)

    -- Update function
    registerForEvent("onUpdate", function(deltaTime)
        
        if(ImprovedRadio.timer > ImprovedRadio.updateSeconds or ImprovedRadio.timer == 0) then
            if(ImprovedRadio.timer == 0) then
                ImprovedRadio.timer = 2
            end
            ImprovedRadio.timer = ImprovedRadio.timer - ImprovedRadio.updateSeconds

            if(ImprovedRadio.player and ImprovedRadio.workSpot and ImprovedRadio.workSpot:IsActorInWorkspot(ImprovedRadio.player)) then

                ImprovedRadio.car = Game['GetMountedVehicle;GameObject'](ImprovedRadio.player)
                if (ImprovedRadio.car and ImprovedRadio.car:IsRadioReceiverActive()) then
                    
                    ImprovedRadio.curSong = tostring(ImprovedRadio.car:GetRadioReceiverTrackName()):sub(20, 29)
                    ImprovedRadio.curSongInfoString = radioData.songHashToInfo[ImprovedRadio.curSong]

                    if(ImprovedRadio.curStation == nil) then
                        ImprovedRadio.curStation = getStation(ImprovedRadio.curSong)
                    end

                    if(ImprovedRadio.curSong ~= "0x00000000") then -- News   

                        if(ImprovedRadio.playlistPlaying and ImprovedRadio.prevSong ~= ImprovedRadio.curSong) then
                            ImprovedRadio.prevSong = ImprovedRadio.playlistNextSong()
                        elseif(hasValue(ImprovedRadio.songsToRemove, ImprovedRadio.curSong)) then
                            ImprovedRadio.skipSong() 
                        end
                    end
                end
            end
        end

        ImprovedRadio.timer = ImprovedRadio.timer + deltaTime
    end)

    -- UI event functions
    registerForEvent("onDraw", function()
        if ImprovedRadio.isUIVisible then	
            ImprovedRadio.ui.draw()
        end
    end) 
    
    registerForEvent("onOverlayOpen", function()
        ImprovedRadio.isUIVisible = true
    end)
    
    registerForEvent("onOverlayClose", function()
        ImprovedRadio.isUIVisible = false
    end)

    -- Hotkey functions
    registerHotkey("showUI", "Toggle Improved Radio Window", function()
        if(ImprovedRadio.isUIVisible) then
            ImprovedRadio.isUIVisible = false
        else
            ImprovedRadio.isUIVisible = true
        end
    end)

    registerHotkey("skipSong", "Skip Song", function()
        if(ImprovedRadio.playlistPlaying) then
            ImprovedRadio.prevSong = ImprovedRadio.playlistNextSong()
        else
            ImprovedRadio.skipSong()
        end
    end)

    registerHotkey("playPlaylist", "Play/Stop Playlist", function()
        if(ImprovedRadio.playlistPlaying) then
            ImprovedRadio.stopPlaylist()
        else
            ImprovedRadio.playPlaylist()
        end
    end)

    registerHotkey("playlistSlot1", "Play Playlist Slot 1", function()
        ImprovedRadio.ui.switchPlaylistSlot(1)
    end)

    registerHotkey("playlistSlot2", "Play Playlist Slot 2", function()
        ImprovedRadio.ui.switchPlaylistSlot(2)
    end)

    registerHotkey("playlistSlot3", "Play Playlist Slot 3", function()
        ImprovedRadio.ui.switchPlaylistSlot(3)
    end)

    registerHotkey("playlistSlot4", "Play Playlist Slot 4", function()
        ImprovedRadio.ui.switchPlaylistSlot(4)
    end)

    registerHotkey("playlistSlot5", "Play Playlist Slot 5", function()
        ImprovedRadio.ui.switchPlaylistSlot(5)
    end)
end

function ImprovedRadio.loadReplacements()

    ImprovedRadio.radioDataStationsBak = table.shallow_copy(radioData.radioStationNames)
    ImprovedRadio.radioDataTracksBak = table.shallow_copy(radioData.songHashToInfo)

    local replacementTable = IO.readReplacements()
    for _, replacement in ipairs(replacementTable) do

        local name = replacement["name"]
        local stations = {}
        local tracks = {}

        for key, val in pairs(replacement) do
            if(string.find(key, "radio_station")) then
                stations[key] = val
            elseif(string.find(key, "0x")) then
                tracks[key] = val
            end
        end
        ImprovedRadio.replacementStations[name] = stations
        ImprovedRadio.replacementTracks[name] = tracks
    end
end

function ImprovedRadio.enableReplacement(name)

    for key, val in pairs(ImprovedRadio.replacementStations[name]) do
        radioData.radioStationNames[key] = val
    end

    for key, val in pairs(ImprovedRadio.replacementTracks[name]) do
        radioData.songHashToInfo[key] = val
    end
end

function ImprovedRadio.disableReplacement(name)

    for key, val in pairs(ImprovedRadio.radioDataStationsBak) do
        radioData.radioStationNames[key] = val
    end

    for key, val in pairs(ImprovedRadio.radioDataTracksBak) do
        radioData.songHashToInfo[key] = val
    end

    for key, val in pairs(ImprovedRadio.ui.replacementsSelected) do
        if(val) then
            ImprovedRadio.enableReplacement(key)
        end
    end
end

-- Track Remover/Skip Track functions

function ImprovedRadio.setSongsToRemove(songStates)

    ImprovedRadio.songsToRemove = {}
    for key, val in pairs(songStates) do
        if(val == false) then
            table.insert(ImprovedRadio.songsToRemove, key)
        end
    end
end

function ImprovedRadio.skipSong()

    if(ImprovedRadio.curStation) then

        local songs = getStationSongs(ImprovedRadio.curStation)

        validSongs = {}
        local count = 1
        for k, v in ipairs(songs) do
            if(hasValue(ImprovedRadio.songsToRemove, v) == false) then
                validSongs[count] = v
                count = count + 1
            end
        end

        local nextSongIndex = math.random(1, count - 1) -- Chooses random entry from valid songs
        local nextSongInfo = songCodeToInfo(validSongs[nextSongIndex])

        ImprovedRadio.audio:RequestSongOnRadioStation(ImprovedRadio.curStation, nextSongInfo[1])
    end
end

function ImprovedRadio.tuneStation(station)

    local stationIndex = radioData.radioStationIndex[station]
    ImprovedRadio.car:SetRadioReceiverStation(stationIndex)
    ImprovedRadio.curStation = station
end

-- Custom Playlist functions

function ImprovedRadio.loadPlaylistTrack(songCode)

    UI.parent.playlistCount = UI.parent.playlistCount + 1

    if(songCode == "Select") then
        UI.playlistUIStations[UI.parent.playlistCount] = "Select Station"
        ImprovedRadio.playlistSongs[UI.parent.playlistCount] = "Select Track"
    else
        local stationName = radioData.radioStationNames[getStation(songCode)]
        UI.playlistUIStations[UI.parent.playlistCount] = stationName
    end
end

function ImprovedRadio.removePlaylistSong(index)

    table.remove(ImprovedRadio.playlistSongs, index)
    ImprovedRadio.playlistCount = ImprovedRadio.playlistCount - 1
end

function ImprovedRadio.playPlaylist()

    ImprovedRadio.prevSong = nil
    ImprovedRadio.playlistPlaying = true
    ImprovedRadio.ui.playlistButtonName = "Stop"
end

function ImprovedRadio.stopPlaylist()

    ImprovedRadio.playlistPlaying = false
    ImprovedRadio.ui.playlistButtonName = "Play"
end

function ImprovedRadio.clearPlaylist()

    ImprovedRadio.stopPlaylist()
    ImprovedRadio.playlistSongs = {}
    ImprovedRadio.playlistCount = 0
end

function ImprovedRadio.playlistNextSong()

    if(ImprovedRadio.playlistCount == 0) then -- Playlist empty, stop playlist
        ImprovedRadio.stopPlaylist()
        return
    end

    local nextIndex = 1
    local nextSongCode = "Select Track"

    if(hasValue(ImprovedRadio.playlistSongs, ImprovedRadio.curSong) == false) then -- Requested song it not playing, try again
        ImprovedRadio.playlistIndex = ImprovedRadio.playlistIndex - 1
    end
    
    if(ImprovedRadio.playlistShuffle) then -- Play randomly
        nextIndex = ImprovedRadio.playlistIndex
        while nextIndex == ImprovedRadio.playlistIndex do
            nextIndex = math.random(1, ImprovedRadio.playlistCount)
        end
    else                                        --  Play in order
        nextIndex = ImprovedRadio.playlistIndex
        if(nextIndex > ImprovedRadio.playlistCount) then
            nextIndex = nextIndex - ImprovedRadio.playlistCount
        end
        ImprovedRadio.playlistIndex = nextIndex + 1
    end

    local nextSongCode = ImprovedRadio.playlistSongs[nextIndex]

    if(nextSongCode == nil or nextSongCode == "Select Track") then -- Song is not valid

        for i = 1, ImprovedRadio.playlistCount do -- Iterate through playlist to find first valid song
            nextSongCode = ImprovedRadio.playlistSongs[i]
            if(nextSongCode ~= nil and nextSongCode ~= "Select Track") then
                ImprovedRadio.playlistIndex = i
                break
            end
        end
    end

    local nextStation = getStation(nextSongCode)
    local nextSongInfo = songCodeToInfo(nextSongCode)

    ImprovedRadio.car:SetRadioReceiverStation(radioData.radioStationIndex[nextStation])
    ImprovedRadio.audio:RequestSongOnRadioStation(nextStation, nextSongInfo[1])
    ImprovedRadio.curStation = nextStation
    return nextSongCode
end

-- Util functions

function getStation(song)

    for key, songList in pairs(radioData.radioStationSongs) do
        if(songList:find(song)) then
            return key
        end
    end
    return nil
end

function getStationSongs(stationID)

    local songList = radioData.radioStationSongs[stationID]

    if(songList) then
        local songCodes = {}
        for val in string.gmatch(songList, "(%w+),") do
            table.insert(songCodes, val)
        end
        return songCodes
    end
    return nil
end

function songCodeToInfo(code)

    local songInfoString = radioData.songHashToInfo[code]
    local songInfo = {}
    for info in string.gmatch(songInfoString, "[^%|]+") do
        table.insert(songInfo, info)
    end
    return songInfo
end

function hasValue(tab, val)

    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

function table_invert(t)

    local s={}
    for k,v in pairs(t) do
      s[v]=k
    end
    return s
end

function table.shallow_copy(t)
    local t2 = {}
    for k,v in pairs(t) do
      t2[k] = v
    end
    return t2
end

function dump(o)

    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end

return ImprovedRadio:new()