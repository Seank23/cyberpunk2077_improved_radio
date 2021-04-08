ImprovedRadio = {
    radioData = require("radioData")
    player = nil
    car = nil
    ws = nil
}

function ImprovedRadio
:new()

    registerForEvent("onInit", function() 
        ImprovedRadio.player = Game.GetPlayer()
        ImprovedRadio.ws = Game.GetWorkspotSystem()  
    end)

    registerForEvent("onUpdate", function() 
        
        if(player and ws and ws:IsActorInWorkspot(player)) then
            local car = Game['GetMountedVehicle;GameObject'](player)
			if (car and car:IsRadioReceiverActive()) then
                
            end
        end
    end)
end

return ImprovedRadio:new()