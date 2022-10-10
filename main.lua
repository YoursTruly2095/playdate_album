
--[[

(c) YoursTruly2095 2022

 * ------------------------------------------------------------------------------
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 *
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 *
 * 3. This notice may not be removed or altered from any source distribution.
 * -----------------------------------------------------------------------------
 * (This is the zlib License)

--]]

--[[

Gondomania font from https://idleberg.github.io/playdate-arcade-fonts/
(with minor updates... I added some punctuation marks :-) )

--]]

import("CoreLibs/timer")

local gr <const> = playdate.graphics
local snd <const> = playdate.sound

local cover
local player
local x,y
local font

local show_lyrics = false

local line_spacing = 7
local height = 1
local audio_buffer_size = 2     -- 1 second isn;t enough for the biggest art transitions

local songs, art 
songs, art = import("album_data.lua")

local current_song
local current_art

local function scan_lyrics(lyrics)
    
    local data_table = {}
    
    _, height = gr.getTextSize("Polygondwanaland")
    
    local y = 0
    
    for k,line in ipairs(lyrics) do
        local width, _ = gr.getTextSize(line)
        
        data_table[k] = 
        {
            x = (400-width)/2,
            y = y,
            w = width,
            text = string.upper(line)
        }
        
        local middle
        if width > 400 then
            local length = string.len(line)
            middle = math.ceil(length / 2)
            
        
            while line:byte(middle) ~= 0x20 and middle < length do
                middle = middle + 1
            end
            
            print("middle",k,line, middle, length)
            data_table[k].middle = middle
            
            data_table[k].text = string.upper(string.sub(line,1,middle))
            data_table[k].text2 = string.upper(string.sub(line,middle))
            
            width,_ = gr.getTextSize(data_table[k].text)
            data_table[k].w = width
            width,_ = gr.getTextSize(data_table[k].text2)
            data_table[k].w2 = width
            
        end
        
        
        y = y + height + line_spacing
        if middle then y = y + height + 2 end
        
        print(line)
    end
    
    return data_table, y+(100*(height+line_spacing))
end

-- a function that loads the graphics for the menu
function load_game()
    
    -- no sleeping
    playdate.setAutoLockDisabled(true)
    
    current_song = 1
    current_art = 1

    -- load the font before we process the lyrics
    font = gr.font.new("Gondomania.pft")
    gr.setFont(font)
    
    for k,v in pairs(songs) do
        v.lyrics, v.loop_location = scan_lyrics(v.lyrics)
    end
    
    -- load art
    cover = gr.image.new(art[current_art].file)
    
    local next_art = current_art + 1
    if next_art > #art then next_art = 1 end
    next_cover = gr.image.new(art[next_art].file)
    
    
    -- load audio
    player = snd.fileplayer.new(songs[current_song].audio, audio_buffer_size)
    player:setStopOnUnderrun(false)
    player:play()
    
end

-- actually call the load function
load_game()


local crank_angle = nil
local top_lyric_position = 0
--local display_playback_adjustment_timer = nil
--local adjust_speed = false
local mode = 'view'

local function move_art(button_state)
    local x = art[current_art].x
    local y = art[current_art].y
    
    if button_state == playdate.kButtonUp then y = y + 3 
    elseif button_state == playdate.kButtonDown then y = y - 3 
    elseif button_state == playdate.kButtonLeft then x = x + 3 
    elseif button_state == playdate.kButtonRight then x = x - 3 
    elseif button_state == playdate.kButtonUp|playdate.kButtonLeft then y = y + 2 x = x + 2 
    elseif button_state == playdate.kButtonUp|playdate.kButtonRight then y = y + 2 x = x - 2 
    elseif button_state == playdate.kButtonDown|playdate.kButtonLeft then y = y - 2 x = x + 2 
    elseif button_state == playdate.kButtonDown|playdate.kButtonRight then y = y - 2 x = x - 2 end
    
    art[current_art].x = x
    art[current_art].y = y
    
    if art[current_art].x > 0 then art[current_art].x = 0 end
    if art[current_art].y > 0 then art[current_art].y = 0 end
    if art[current_art].x < -art[current_art].w+400 then art[current_art].x = -art[current_art].w+400 end
    if art[current_art].y < -art[current_art].h+240 then art[current_art].y = -art[current_art].h+240 end
end    

local function move_lyrics(angle_delta)
    top_lyric_position = top_lyric_position + (angle_delta / 10)

    if top_lyric_position < -songs[current_song].loop_location then
        top_lyric_position = 100
    elseif top_lyric_position > 150 then
        top_lyric_position = 50 - songs[current_song].loop_location
    end
end

local function adjust_volume(angle_delta)
    -- adjusting volume
    local vol,_ = player:getVolume()
    vol = vol - (angle_delta / 1800)
    if vol > 1.0 then vol = 1.0 end
    if vol < 0.0 then vol = 0.0 end
    player:setVolume(vol,vol)
end    

local function adjust_track(button_state, angle_delta)
    if angle_delta ~= 0 then
    
        local offset = player:getOffset()
        local length = player:getLength()
        --print("Setting offset", offset, length, angle_delta, angle_delta/100)
        offset = offset - (angle_delta / 25)
        --print("after adjust", offset)
        if offset < 0 then offset = 0 end
        if offset > length then offset = length end
        --print("after limits", offset)
        
        player:setOffset(offset+audio_buffer_size)
        
        --offset = player:getOffset()
        --length = player:getLength()
        --print("Get after setting", offset, length)
    end
end

local function print_lyrics()

    gr.setColor(gr.kColorWhite)
    
    for _,line in ipairs(songs[current_song].lyrics) do
        local y = top_lyric_position + line.y
        if y > -(height*2) and y < 240 then
            if line.middle then
                
                gr.fillRect(0, y-2, line.w+4, height+4)
                gr.drawText(line.text, 2, y)
                gr.fillRect(400-line.w2-2, y+height, line.w2+2, height+4)
                gr.drawText(line.text2, 400-line.w2-2, y+height+2)
                
            else
                if line.text ~= "" then
                    gr.fillRect(line.x-2, y-2, line.w+4, height+4)
                    gr.drawText(line.text, line.x, y)
                end
            end
        end
    end
end

local function display_volume()
    local bar = 200 - (200 * player:getVolume())
    gr.setColor(gr.kColorWhite)
    gr.fillRect(360, 20, 10, 200)
    gr.setColor(gr.kColorBlack)
    gr.fillRect(360, 20+bar, 10, 200-bar)
    
    local width, height, title
    title = 'VOLUME'
    width, height = gr.getTextSize(title)
    gr.setColor(gr.kColorWhite)
    gr.fillRect(340-(width+4), 178, width+4, height+4)
    gr.drawText(title, 340-(width+2), 180)
end    

local function display_track()
    local length = player:getLength()
    local location = player:getOffset()
    
    gr.setColor(gr.kColorWhite)
    gr.fillRect(20, 200, 360, 10)
    gr.setColor(gr.kColorBlack)
    gr.fillRect(18+((location/length)*360), 195, 4, 20)
    
    local width, height, title
    title = string.upper(songs[current_song].title)
    width, height = gr.getTextSize(title)
    gr.setColor(gr.kColorWhite)
    gr.fillRect(380-(width+4), 20, width+4, height+4)
    gr.drawText(title, 380-(width+2), 22)
    
    title = 'TRACK'
    width, height = gr.getTextSize(title)
    gr.setColor(gr.kColorWhite)
    gr.fillRect(20, 138, width+4, height+4)
    gr.drawText(title, 22, 140)
    
end

local function next_song(direction)
    if direction == nil then direction = 1 end
    current_song = current_song + direction
    if current_song > #songs then current_song = 1 end
    if current_song < 1 then current_song = #songs end
    player:load(songs[current_song].audio)
    player:play()  
    top_lyric_position = 0
end    

function playdate.update()
    
    -- playdate update is locked to framerate
    local dt = 1/30
  
    local button_state = playdate.getButtonState()
    
    local last_crank_angle = crank_angle
    crank_angle = playdate.getCrankPosition()
    if last_crank_angle == nil then last_crank_angle = crank_angle end
    local angle_delta = (last_crank_angle - crank_angle)
    if math.abs(angle_delta) > 180 then
        -- assume overflow and the crank went the short way to this new angle
        if angle_delta > 0 then angle_delta = angle_delta - 360 else angle_delta = angle_delta + 360 end
    end
    
    
    if mode == 'view' or mode == 'lyrics' then
        move_art(button_state)
    end
    
    if mode == 'lyrics' then
        move_lyrics(angle_delta)
    elseif mode == 'volume' then
        adjust_volume(angle_delta)
    elseif mode == 'track' then
        adjust_track(button_state, angle_delta)
    end
    
    
    
    playdate.graphics.clear()
    cover:draw(art[current_art].x,art[current_art].y)
    
    if mode == 'lyrics' then 
        print_lyrics() 
    elseif mode == 'volume' then
        display_volume()
    elseif mode == 'track' then
        display_track()
    else
        -- debug x y print
        gr.setColor(gr.kColorWhite)    
        gr.fillRect(20-2, 200-2, 100, height+4)
        gr.drawText(-art[current_art].x..","..-art[current_art].y, 20, 200)
    end
    
    -- move on to the next song
    if not player:isPlaying() then 
        --print("Next song")
        next_song()
    end
    
    if cover == next_cover then
        -- display the new image before we tank the 
        -- framerate by loading the next image
        coroutine.yield()
        local next_art = current_art + 1
        if next_art > #art then next_art = 1 end
        next_cover = gr.image.new(art[next_art].file)
    end
        
    playdate.timer.updateTimers()
end






--[[

Handle Playdate UI

--]]

function playdate.AButtonUp()    
    if mode == 'view' or mode == 'lyrics' then
        current_art = current_art + 1
        if current_art > #art then current_art = 1 end
        cover = next_cover
    end
end

function playdate.rightButtonUp()
    if mode == 'track' then
        player:stop()
        next_song() 
    end
end

function playdate.leftButtonUp()
    if mode == 'track' then
        player:stop()
        next_song(-1) 
    end
end

local button_timer = nil
local button_count = 0
function playdate.BButtonUp()    
            
    button_count = button_count + 1
    
    if button_timer == nil then
        button_timer = playdate.timer.new(333, function() 
    
            if button_count == 1 then
                if mode ~= 'view' then
                    mode = 'view'
                else
                    mode = 'lyrics'
                end
            elseif button_count == 2 then
                mode = 'volume' 
            elseif button_count == 3 then
                mode = 'track'
                -- could consider switching player here to a 'scrub_player' 
                -- that has a shorter buffer, in order to have the scrub
                -- work better without shortening the buffer of the main
                -- player, which we need long for the art transitions
            else
                mode = 'view'
            end
            
            button_timer = nil 
            button_count = 0
        end)
    else
        button_timer:reset()
    end
    
end



