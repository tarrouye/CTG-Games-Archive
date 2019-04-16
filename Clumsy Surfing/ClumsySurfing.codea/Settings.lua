Settings = class()

function Settings:init()
    local function toggleText()
        local txt = "Toggle Music ("
        if music.muted then
            txt = txt .. "off)"
        else
            txt = txt .. "on)"
        end

        return txt
    end

    local function toggleText2()
        local txt = "Toggle Sounds ("
        if sound_muted then
            txt = txt .. "off)"
        else
            txt = txt .. "on)"
        end

        return txt
    end

    self.buttons = {
        TextButton(toggleText(), WIDTH / 2, HEIGHT * 3/4, function(slef) toggleMusic() slef.txt = toggleText() end, MIN_DIMENSION / 16),

        TextButton(toggleText2(), WIDTH / 2, HEIGHT * 5/8, function(slef) toggleSounds() slef.txt = toggleText2() end, MIN_DIMENSION / 16),

        TextButton("Show Air Time Leaderboard", WIDTH / 2, HEIGHT / 2, function() gamecenter.showLeaderboards("clumsysurfing_airtime") end, MIN_DIMENSION / 16),


        TextButton("Show Flips Leaderboard", WIDTH / 2, HEIGHT * 3/8, function() gamecenter.showLeaderboards("clumsysurfing_flips") end, MIN_DIMENSION / 16),
    
        TextButton("Water physics by @Luatee", WIDTH / 2, MIN_DIMENSION / 32, function() openURL("https://codea.io/talk/profile/2547/Luatee", true) end, MIN_DIMENSION / 32),
    
        --TextButton("More Theodore games", WIDTH / 2, MIN_DIMENSION / 8, function() openURL("http://ctgstuff.host56.com/games", true) end, MIN_DIMENSION / 32)
    }
end

function Settings:draw()
    for i, b in ipairs(self.buttons) do 
        b:draw()
    end
end

function Settings:touched(t)
    local tb = false
    for i, b in ipairs(self.buttons) do 
        if b:touched(t) then
            tb = true
        end
    end
    
    return tb
end
