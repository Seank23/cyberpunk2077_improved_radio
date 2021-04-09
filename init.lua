local radioData = require("radioData.lua")

ImprovedRadio = {
    player = nil,
    workSpot = nil,
    car = nil,
    audio = nil,
    timer = 0,
    songsToRemove = {
        [1] = "0x0000CE54",
        [2] = "0x0000CE95",
        [3] = "0x0000CE96",
        [4] = "0x0000CE97",
        [5] = "0x0000CE99",
        [6] = "0x0000CE9A",
        [7] = "0x0000CE9B",
        [8] = "0x0000CE9E",
        [9] = "0x0000CE9F",
        [10] = "0x0000D075",
        [11] = "0x0000D076",
        [12] = "0x00013150"
    }
}

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

function hasValue(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

function getStation(song)

    for key, songList in pairs(radioData.radioStationSongs) do
        if(songList:find(song)) then
            return key
        end
    end
    return nil
end

function skipSong(curSong)

    local curRadioStation = getStation(curSong)
    if(curRadioStation) then

        local stationSongList = radioData.radioStationSongs[curRadioStation]
        local songs = {}
        for val in string.gmatch(radioData.stationSongList, "(%w+),") do
            table.insert(songs, val)
        end

        validSongs = {}
        local count = 1
        for k, v in ipairs(songs) do
            if(hasValue(ImprovedRadio.songsToRemove, v) == false) then
                validSongs[count] = v
                count = count + 1
            end
        end

        nextSongIndex = math.random(1, count - 1)
        nextSongInfoString = radioData.songHashToInfo[validSongs[nextSongIndex]]
        nextSongInfo = {}
        for val in string.gmatch(nextSongInfoString, "[^%|]+") do
            table.insert(nextSongInfo, val)
        end

        ImprovedRadio.audio:RequestSongOnRadioStation(curRadioStation, nextSongInfo[1])
    end
end

function ImprovedRadio:new()

    registerForEvent("onInit", function() 

        ImprovedRadio.player = Game.GetPlayer() 
        ImprovedRadio.workSpot = Game.GetWorkspotSystem()
        ImprovedRadio.audio = Game.GetAudioSystem()
        timer = 0
    end)

    registerForEvent("onUpdate", function(deltaTime)

        timer = timer + deltaTime
        if(timer > 2) then
            timer = timer - 2

            if(ImprovedRadio.player and ImprovedRadio.workSpot and ImprovedRadio.workSpot:IsActorInWorkspot(ImprovedRadio.player)) then

                local car = Game['GetMountedVehicle;GameObject'](ImprovedRadio.player)
                if (car and car:IsRadioReceiverActive()) then

                    local curRadioSong = tostring(car:GetRadioReceiverTrackName()):sub(20, 29)
                    if(hasValue(ImprovedRadio.songsToRemove, curRadioSong)) then
                        
                        skipSong(curRadioSong) 
                    end
                end
            end
        end
    end)
end

return ImprovedRadio:new()