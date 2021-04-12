ImprovedRadio = {
    radioData = require("radioData.lua"),
    ui = require("ui.lua"),
    updateSeconds = 2,
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
    prevSong = nil
}

function ImprovedRadio.dump(o)
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

function ImprovedRadio.hasValue(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

function ImprovedRadio.songCodeToInfo(code)

    local songInfoString = radioData.songHashToInfo[code]
    local songInfo = {}
    for info in string.gmatch(songInfoString, "[^%|]+") do
        table.insert(songInfo, info)
    end
    return songInfo
end

function ImprovedRadio.getStation(song)

    for key, songList in pairs(ImprovedRadio.radioData.radioStationSongs) do
        if(songList:find(song)) then
            return key
        end
    end
    return nil
end

function ImprovedRadio.skipSong()

    if(ImprovedRadio.curStation) then

        local stationSongList = ImprovedRadio.radioData.radioStationSongs[ImprovedRadio.curStation]
        local songs = {}
        for val in string.gmatch(stationSongList, "(%w+),") do
            table.insert(songs, val)
        end

        validSongs = {}
        local count = 1
        for k, v in ipairs(songs) do
            if(ImprovedRadio.hasValue(ImprovedRadio.songsToRemove, v) == false) then
                validSongs[count] = v
                count = count + 1
            end
        end

        nextSongIndex = math.random(1, count - 1)
        nextSongInfoString = ImprovedRadio.radioData.songHashToInfo[validSongs[nextSongIndex]]
        nextSongInfo = {}
        for val in string.gmatch(nextSongInfoString, "[^%|]+") do
            table.insert(nextSongInfo, val)
        end

        ImprovedRadio.audio:RequestSongOnRadioStation(ImprovedRadio.curStation, nextSongInfo[1])
    end
end

function ImprovedRadio.playlistNextSong()

    local nextIndex = 1
    if(ImprovedRadio.playlistShuffle) then
        nextIndex = math.random(1, ImprovedRadio.playlistCount)
    else
        nextIndex = ImprovedRadio.playlistIndex
    end
    if(nextIndex > ImprovedRadio.playlistCount) then
        nextIndex = nextIndex - ImprovedRadio.playlistCount
    end

    local nextSongCode = ImprovedRadio.playlistSongs[nextIndex]
    local nextStation = ImprovedRadio.getStation(nextSongCode)
    local nextSongInfo = ImprovedRadio.songCodeToInfo(nextSongCode)
    print(nextSongInfo[1])

    ImprovedRadio.car:SetRadioReceiverStation(ImprovedRadio.radioData.radioStationIndex[nextStation])
    ImprovedRadio.audio:RequestSongOnRadioStation(nextStation, nextSongInfo[1])
    ImprovedRadio.playlistIndex = ImprovedRadio.playlistIndex + 1
end

function ImprovedRadio.setSongsToRemove(songStates)
    ImprovedRadio.songsToRemove = {}
    local i = 1
    for key, val in pairs(songStates) do
        if(val == false) then
            ImprovedRadio.songsToRemove[i] = key
            i = i + 1
        end
    end
end

function ImprovedRadio:new()

    registerForEvent("onInit", function() 

        ImprovedRadio.player = Game.GetPlayer() 
        ImprovedRadio.workSpot = Game.GetWorkspotSystem()
        ImprovedRadio.audio = Game.GetAudioSystem()
        ImprovedRadio.ui.init(ImprovedRadio)
        timer = 0
    end)

    registerForEvent("onUpdate", function(deltaTime)

        ImprovedRadio.timer = ImprovedRadio.timer + deltaTime
        if(ImprovedRadio.timer > ImprovedRadio.updateSeconds) then
            ImprovedRadio.timer = ImprovedRadio.timer - ImprovedRadio.updateSeconds

            if(ImprovedRadio.player and ImprovedRadio.workSpot and ImprovedRadio.workSpot:IsActorInWorkspot(ImprovedRadio.player)) then

                ImprovedRadio.car = Game['GetMountedVehicle;GameObject'](ImprovedRadio.player)
                if (ImprovedRadio.car and ImprovedRadio.car:IsRadioReceiverActive()) then
                    
                    local curSong = tostring(ImprovedRadio.car:GetRadioReceiverTrackName()):sub(20, 29)
                    ImprovedRadio.curSongInfoString = ImprovedRadio.radioData.songHashToInfo[curSong]

                    if(ImprovedRadio.playlistPlaying and ImprovedRadio.prevSong ~= curSong) then
                        ImprovedRadio.playlistNextSong()
                        ImprovedRadio.prevSong = curSong
                    end

                    if(ImprovedRadio.curStation == nil) then
                        ImprovedRadio.curStation = ImprovedRadio.getStation(curSong)
                    end

                    if(ImprovedRadio.hasValue(ImprovedRadio.songsToRemove, curSong)) then
                        ImprovedRadio.skipSong() 
                    end
                end
            end
        end
    end)

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
end

return ImprovedRadio:new()