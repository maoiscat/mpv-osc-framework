-- osc framework expansions
-- by maoiscat
-- github.com/maoiscat/

local assdraw = require 'mp.assdraw'
require 'oscf'

-- # some useful functions
-- print table, for debug
function ptb(tab, prefix)
    local fmt, str
    if prefix == nil then prefix = tostring(tab) end
    if type(tab) ~= 'table' then
        str = tostring(tab)
        string.gsub(str, '\n', '[nl]')
        print(string.format('%s = %s', prefix, str))
    else
        for k, v in pairs(tab) do
            str = prefix .. '.' .. tostring(k)
            ptb(v, str)
        end
    end
end

-- a simple clone function to help copying style table
function clone(sth)
    if type(sth) ~= 'table' then return sth end
    local copy = {}
    for k, v in pairs(sth) do
        copy[k] = clone(v)
    end
    return copy
end

-- get the outline box coordinates of an element.
-- geo: same format as element.geo
-- return: left, top, right, bottom position
function getBoxPos(geo)
    local box = {
    [1] = function(geo) return geo.x, geo.y-geo.h, geo.x+geo.w, geo.y end,
    [2] = function(geo) return geo.x-geo.w/2, geo.y-geo.h, geo.x+geo.w/2, geo.y end,
    [3] = function(geo) return geo.x-geo.w, geo.y-geo.h, geo.x, geo.y end,
    [4] = function(geo) return geo.x, geo.y-geo.h/2, geo.x+geo.w, geo.y+geo.h/2 end,
    [5] = function(geo) return geo.x-geo.w/2, geo.y-geo.h/2, geo.x+geo.w/2, geo.y+geo.h/2 end,
    [6] = function(geo) return geo.x-geo.w, geo.y-geo.h/2, geo.x, geo.y+geo.h/2 end,
    [7] = function(geo) return geo.x, geo.y, geo.x+geo.w, geo.y+geo.h end,
    [8] = function(geo) return geo.x-geo.w/2, geo.y, geo.x+geo.w/2, geo.y+geo.h end,
    [9] = function(geo) return geo.x-geo.w, geo.y, geo.x, geo.y+geo.h end,
    }
    local x1, y1, x2, y2
    if box[geo.an] then
        x1, y1, x2, y2 = box[geo.an](geo)
    end
    return x1, y1, x2, y2
end
-- get the list of tracks
-- return: tracks categorize as video, audio and sub
function getTrackList()
    local trackList = mp.get_property_native('track-list')
    local tracks = {video = {}, audio = {}, sub = {}}
    for i, v in ipairs(trackList) do
        if v.type ~= 'unknown' then
            table.insert(tracks[v.type], v)
        end
    end
    return tracks
end
-- get playlist
function getPlaylist()
    local playlist = mp.get_property_native('playlist')
    return playlist
end
-- get position on playlist
-- return: pos number start from 1
function getPlaylistPos()
    local pos = mp.get_property_number('playlist-pos-1')
    return pos
end
-- get chapter list
function getChapterList()
    local chapters = mp.get_property_native('chapter-list')
    return chapters
end
-- get current track
-- name: 'video', 'audio' or 'sub'
-- return: track index, 0 for none
function getTrack(name)
    local prop = string.format('current-tracks/%s/id', name)
    local index = mp.get_property_number(prop)
    if index then return index
        else return 0 end
end

-- cycle through tracks
-- name: 'video', 'audio' or 'sub'
-- direction: optional 'next' or 'prev', default is 'next'
function cycleTrack(name, direction)
    local current = getTrack(name)
    local index
    local tracks = getTrackList()
    tracks = tracks[name]
    if not tracks then return end
    if direction == 'prev' then
        index = current - 1
    else
        index = current + 1
    end
    if index > #tracks then index = 0
        elseif index < 0 then index = #tracks
            end
    local newTrack
    
    if index == 0 then
        newTrack = 'no'
    else
        newTrack = tracks[index].id
    end
    mp.commandv('set', name, newTrack)
end

-- build ass fomrat style code, almost a copy from oscf.lua
-- trans is a global tansparency modifier
-- return foramted style text
function buildStyle(style, trans)
    if not style then return '' end
    if not trans then trans = 0 end
    local fmt = {'{'}
    if style.color then
        table.insert(fmt, 
            string.format('\\1c&H%s&\\2c&H%s&\\3c&H%s&\\4c&H%s&',
                style.color[1], style.color[2], style.color[3], style.color[4]))
                    end
    local alpha = {}
    if style.alpha then
        for i = 1, 4 do
            alpha[i] = 255 - (((1-(style.alpha[i]/255)) * (1-trans)) * 255)
        end
    else
        alpha = {trans*255, trans*255, trans*255, trans*255}
    end
    table.insert(fmt, string.format('\\1a&H%x&\\2a&H%x&\\3a&H%x&\\4a&H%x&',
        alpha[1], alpha[2], alpha[3], alpha[4]))
    if style.border then
        table.insert(fmt, string.format('\\bord%.2f', style.border)) end
    if style.blur then
        table.insert(fmt, string.format('\\blur%.2f', style.blur)) end
    if style.shadow then
        table.insert(fmt, string.format('\\shad%.2f', style.shadow)) end
    if style.font then
        table.insert(fmt, string.format('\\fn%s', style.font)) end
    if style.fontsize then
        table.insert(fmt, string.format('\\fs%d', style.fontsize)) end
    if style.wrap then
        table.insert(fmt, string.format('\\q%d', style.wrap)) end
    table.insert(fmt, '}')
    return table.concat(fmt)
end

-- check if a position{x, y} is inside the hitbox of an object
-- the object must contain a .hitBox = {x1, y1, x2, y2} table
-- return: true if inside
function isInside(obj, pos)
    local x, y = pos[1], pos[2]
    if obj.hitBox.x1 <= x and x <= obj.hitBox.x2
        and obj.hitBox.y1 <= y and y <= obj.hitBox.y2 then
        return true
    else
        return false
    end
end


-- ass draw alias
-- draw a circle in clockwise direction
function assDrawCirCW(ass, x, y, r)
    ass:round_rect_cw(x-r, y-r, x+r, y+r, r)
end
-- draw a circle in counter-clockwise direction
function assDrawCirCCW(ass, x, y, r)
    ass:round_rect_ccw(x-r, y-r, x+r, y+r, r)
end
-- draw rectangle
-- r2 is optional
function assDrawRectCW(ass, x1, y1, x2, y2, r1, r2)
    ass:round_rect_cw(x1, y1, x2, y2, r1, r2)
end

function assDrawRectCCW(ass, x1, y1, x2, y2, r1, r2)
    ass:round_rect_ccw(x1, y1, x2, y2, r1, r2)
end
-- draw hexagon
-- r2 is optional
function assDrawHexaCW(ass, x1, y1, x2, y2, r1, r2)
    ass:hexagon_cw(x1, y1, x2, y2, r1, r2)
end

function assDrawHexaCCW(ass, x1, y1, x2, y2, r1, r2)
    ass:hexagon_ccw(x1, y1, x2, y2, r1, r2)
end
-- draw lines
function assDrawLine(ass, x1, y1, x2, y2)
    ass:move_to(x1, y1)
    ass:line_to(x2, y2)
end

function assDrawLineTo(ass, x, y)
    ass:line_to(x, y)
end


-- # element templates
-- logo
-- shows a logo in the center
local ne = newElement('logo')
ne.init = function(self)
        self.geo.x = player.geo.width / 2
        self.geo.y = player.geo.height / 2
        local ass = assdraw.ass_new()    
        ass:new_event()
        ass:pos(self.geo.x, self.geo.y)
        ass:append('{\\1c&H8E348D&\\3c&H0&\\3a&H60&\\blur1\\bord0.5\\4a&HFF&}')
        ass:draw_start()
        assDrawCirCW(ass, 0, 0, 100)
        ass:draw_stop()

        ass:new_event()
        ass:pos(self.geo.x, self.geo.y)
        ass:append('{\\1c&H632462&\\bord0\\4a&HFF&}')
        ass:draw_start()
        assDrawCirCW(ass, 6, -6, 75)
        ass:draw_stop()

        ass:new_event()
        ass:pos(self.geo.x, self.geo.y)
        ass:append('{\\1c&HFFFFFF&\\bord0\\4a&HFF&}')
        ass:draw_start()
        assDrawCirCW(ass, -4, 4, 50)
        ass:draw_stop()

        ass:new_event()
        ass:pos(self.geo.x, self.geo.y)
        ass:append('{\\1c&H632462&\\bord0&\\4a&HFF&}')
        ass:draw_start()
        ass:move_to(-20, -20)
        ass:line_to(23.3, 5)
        ass:line_to(-20, 35)
        ass:draw_stop()
        
        ass:new_event()
        ass:pos(self.geo.x, player.geo.height - 20)
        ass:an(2)
        ass:append('{\\fs30\\1c&H0&\\3c&HFFFFFF&\\q2\\4a&HFF&}DROP FILES HERE TO PLAY')
        
        self.pack[4] = ass.text
    end
ne.responder['resize'] = function(self)
        self:init()
    end

-- msg
-- display a message in the screen
ne = newElement('message')
ne.geo.x = 40
ne.geo.y = 20
ne.geo.an = 7
ne.layer = 1000
ne.visible = false
ne.text = ''
ne.startTime = 0
ne.duration = 0
ne.style.color = {'ffffff', '0', '0', '333333'}
ne.style.border = 1
ne.style.shadow = 1
ne.render = function(self)    
        self.pack[4] = self.text
    end
ne.tick = function(self)
        if not self.visible then return '' end
        if player.now-self.startTime >= self.duration then
            self.visible = false
        end
        return table.concat(self.pack)
    end
ne.display = function(self, text, duration)
        if not duration then duration = 1 end
        self.duration = duration
        -- text too long may be slow
        text = string.sub(text, 0, 2000)
        text = string.gsub(text, '\\', '\\\\')
        self.text = text
        self:render()
        self.startTime = player.now
        self.visible = true
    end

-- box
-- draw a simple box, usually used as backgrounds
ne = newElement('box')
ne.geo.r = 0    -- corner radius
ne.init = function(self)
        self:setPos()
        self:setStyle()
        self:render()
    end
ne.render = function(self)
        local ass = assdraw.ass_new()
        ass:new_event()
        ass:draw_start()
        assDrawRectCW(ass, 0, 0, self.geo.w, self.geo.h, self.geo.r)
        ass:draw_stop()
        self.pack[4] = ass.text
    end

-- button
-- display some content, also respond to mouse button
ne = newElement('button')
ne.enabled = true
ne.text = ''
ne.style.color1 = {'0', '0', '0', '0'}
ne.style.color2 = {'ffffff', 'ffffff', 'ffffff', 'ffffff'}
-- responder active area, left top right bottom
ne.hitBox = {x1 = 0, y1 = 0, x2 = 0, y2 = 0}
ne.init = function(self)
        self:setPos()
        self:enable()
        self:render()
        self:setHitBox()
    end
ne.render = function(self)
        self.pack[4] = self.text
    end
ne.enable = function(self)
        self.enabled = true
        self.style.color = self.style.color1
        self:setStyle()
    end
ne.disable = function(self)
        self.enabled = false
        self.style.color = self.style.color2
        self:setStyle()
    end
ne.setHitBox = function(self)
        local x1, y1, x2, y2 = getBoxPos(self.geo)
        self.hitBox = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
    end
-- check if mouse event happens inside hitbox
ne.isInside = isInside

-- tooltip
ne = newElement('tooltip')
ne.visible = false
-- key is optional
-- pos is in '{x, y}' format
ne.show = function(self, text, pos, key)
        self.geo.x = pos[1]
        self.geo.y = pos[2]
        self.pack[4] = text
        self.key = key
        if self.geo.x < player.geo.width*0.1 then
            self.geo.an = 1
            self.geo.x = self.geo.x - 15
        elseif self.geo.x > player.geo.width*0.9 then
            self.geo.an = 3
            self.geo.x = self.geo.x + 15
        else
            self.geo.an = 2
        end
        self:setPos()
        self.visible = true
    end
-- update tooltip content regardless of visible status if key matches
ne.update = function(self, text, key)
        if self.key == key then
            self.pack[4] = text
            return true
        end
        return false
    end
-- only hides when key matches, maybe useful for shared tooltip
-- return true if key match
ne.hide = function(self, key)
        if self.key == key then
            self.visible = false
            return true
        end
        return false
    end
ne.responder['mouse_leave'] = function(self)
        self.visible = false
    end
    
-- slider
ne = newElement('slider')
ne.barHeight = 0
ne.barRadius = 0
ne.nobRadius = 0
ne.geo.gap = 0
ne.geo.bar = {x1 = 0, y1 = 0, x2 = 0, y2 = 0, r = 0} -- relative pos
ne.geo.nob = {x = 0, y = 0, r = 0}  -- will be flushed by setParam
ne.value = 0        -- 0~100
ne.xMin = 0
ne.xMax = 0         -- min/max x pos
ne.xLength = 0      -- xMax - xMin
ne.xValue = 0       -- value/100 * xLength
ne.style.color1 = {}   -- color1 for enabled
ne.style.color2 = {}   -- color2 for disabled
ne.enabled = true
ne.hitBox = {}
ne.markers = {}
-- get corresponding slider value at a position
ne.getValueAt = function(self, pos)
        local x = pos[1]
        local val = (x - self.xMin)*100 / self.xLength
        if val < 0 then val = 0
            elseif val > 100 then val = 100 end
        return val
    end
ne.setParam = function(self)
        local x1, y1, x2, y2 = getBoxPos(self.geo)
        local bar, nob = self.geo.bar, self.geo.nob
        self.hitBox = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
        
        self.geo.x = x1
        self.geo.y = y1
        self.geo.an = 7       -- help drawing
        
        local gap = math.max(self.barRadius, self.nobRadius)
        self.xMin = x1 + gap
        self.xMax = x2 - gap
        self.xLength = self.xMax - self.xMin
        self.xValue = self.value/100 * self.xLength
        
        bar.r = self.barRadius
        bar.x1 = gap - bar.r
        bar.y1 = (self.geo.h - self.barHeight) / 2
        bar.x2 = bar.x1 + self.xValue + 2*bar.r
        bar.y2 = bar.y1 + self.barHeight
        
        nob.x = gap + self.xValue
        nob.y = self.geo.h / 2
        nob.r = self.nobRadius
        
        self.geo.gap = gap
    end
ne.init = function(self)
        self:setParam()
        self:setPos()
        self:enable()
        self:render()
    end
ne.render = function(self)
        local bar, nob = self.geo.bar, self.geo.nob
        bar.x2 = bar.x1 + self.xValue + 2*self.barRadius
        nob.x = self.geo.gap + self.xValue
        local ass = assdraw.ass_new()
        ass:new_event()
        ass:draw_start()
        -- bar
        assDrawRectCW(ass, bar.x1, bar.y1, bar.x2, bar.y2, bar.r)
        -- nob
        assDrawCirCW(ass, nob.x, nob.y, nob.r)
        -- markers
        for i, v in ipairs(self.markers) do
            local x = v/100 * self.xLength + self.geo.gap
            local y1, y2 = self.geo.bar.y1-3, self.geo.bar.y2+3
            assDrawRectCW(ass, x-1, y1, x+1, y2, 0)
        end
        ass:draw_stop()
        self.pack[4] = ass.text
    end
ne.enable = function(self)
        self.enabled = true
        self.style.color = self.style.color1
        self:setStyle()
    end
ne.disable = function(self)
        self.enabled = false
        self.style.color = self.style.color2
        self:setStyle()
    end
ne.isInside = isInside