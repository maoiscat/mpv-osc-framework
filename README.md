# mpv-osc-framework

Oscf is an “osc framework” to help building your custom osc for mpv player.

changelog:

ver 1.2

	[change] some tweaks on event handle methods

ver 1.1

	[change] mouse leaving active areas will produce a 'mouse_leave' event

ver 1.0

	[change] change fixedSize to fixedHeight
	[fix] a bug fix in mouseMove()
	[change] some minor tweak in the framework

ver 0.6

	[add] realize the init function for element 'default'
	[add] add a seperate setAlpha function to set alpha codes, yet setStyle function set alpha codes as well
	[change] element.pack now has 4 elements, [2] = alpha codes, [4] = render codes
	[change] renderLayout function use setAlpha to mix global transparency
	[change] optimize setPos() and setStyle()
	[fix] bugfix for expansions and main

ver 0.5

	first release

## Introduction

Mpv-osc-framewokr, or oscf, is a simple tool to help building your own osc(on screen control), as well as sharing codes between different oscs.

The file “oscf.lua” provides a core set of functions to run this tool, and another file "expansion.lua" provides more functions and templates to make it works better.

The file "main.lua" has realized a ["mpv-osc-modern"](https://github.com/maoiscat/mpv-osc-modern) like osc with this tool, as a demo.

To try it, you need to make a new folder in "\~\~/mpv/scripts", and download all 3 files there. Remenber to remove other osc scripts. And you will need [material-design-iconic-font](https://zavoloklom.github.io/material-design-iconic-font/) as well.

## Getting Start

The oscf is coded in [lua](http://www.lua.org/) language, which is natively supported by mpv. The [manual](https://mpv.io/manual/master/#script-location) has told everything about the scripting work, so I just suggest a simple method:

	1. Make a new folder in "~~/mpv/scripts/", such as "~~/mpv/scripts/demo/".
	2. Copy oscf.lua to "demo".
	3. Make a new file "main.lua" in "demo".
	4. Use "require 'oscf'" in main.lua to import oscf. 

Now when mpv starts, it loads demo/main.lua automatically, and oscf starts as well.

## Elements

Elements are basic units of the osc. An element can be a button, a shape, or even an invisible updater. Elements are created like:

```
local el1 = newElement('element1')
local el2 = newElement('element2', 'element1')
```
Here 'element2' is the name of el2, and el2 is created using the element named as 'element1', which is el1, as a template. The template for el1 is an internal default element, whose name is 'default' as well.

The created element is completely the same as the template. It use a "deep copy" method to make the clone from each key and value of the template recursively.

The "default" element is defined as follows:

```
elements['default'] = {
    layer = 0,
    geo = {x = 0, y = 0, w = 0, h = 0, an = 7},
    trans = 0,
    style = {
        color = {'ffffff', 'ffffff', 'ffffff', 'ffffff'},
        alpha = {0, 0, 0, 0},
        border = nil,
        blur = nil,
        shadow = nil,
        font = nil,
        fontsize = nil,
        wrap = nil,
        },
    visible = true,
    pack = {'', '', '', ''},
    init = function(self) end,
    setPos = function(self) end,
    setAlpha = function(self, trans) end,
    setStyle = function(self) end,
    render = function(self) end,
    tick = function(self) end,
    responder = {},
    }
```

Here are details:

**layer** is the z order of an element. An element of higher layer place on top of an lower one when overlaped.

**geo** is the geometry parameters of an element. They are x - left, y - top, w - width, h - height, and an - alignment respectively. Definitions of alignments are the same as ASS/SSA styles, because elements are rendered as ASS subtitles. More details can be found [here](http://www.perlfu.co.uk/projects/asa/ass-specs.doc).

**trans** is a global transparency modifier for the visual effect realization. Users may not need to touch it. It's a decimal ranging from 0 to 1, and 1 means invisible.

**style** is the style params to render the element. They are all ASS styled params. 

	*color* - primary, secondary, outline and background color in **BGR** order.

	*alpha* - primary, secondary, outline and background transparency, 0~255, 255 is invisible.

	*border* - border size, decimal numbers.

	*blur* - blur size, decimal numbers.

	*shadow* - shadow size, decimal numbers.

	*font* - fontname, string.

	*fontsize* - font size, decimal numbers.

	*wrap* - wrap style, 0 - auto wrap, 1- end wrap, 2 - no wrap, 3 - another auto wrap.

**visible** is true when the element is visible. 

**pack** stores then render results. In the pack, [1] stores the position and alignment code, [2] stores the alpha code, [3] stores other style codes, and [4] stores text and drawing codes. They are all string in ASS format.

**init(self)** is the initialize method, which is realized to do the following work:

	setPos()
	setAlpha()
	render()

users can overwrite a new init if needed.

**setPos(self)** is a method to update position codes in pack[1]. Users may not need to overwrite it.

**setAlpha(self, trans)** is a method to update alpha codes in pack[2]. It's usually called by the framework, and users may not need to overwrite it.

**setStyle(self)** is a method to update other style codes in pack[3]. The default method hasn't realized all ASS style codes, users may overwrite this method in their own needs.

**render(self)** is a method to update text and drawing codes in pack[4]. This method does nothing by default. Users have to realize it.

**tick(self)** is a method called by a timer of the framework automatically. The framework updates the render results of each element in every tick, which is 0.03 second by default. If there are any periodical tasks, they can be done here. By default this method returns the concatenated string of pack if the element is visible. If an user overwrite this method, he must make sure it always return a string, or the framework may halt.

**responder** stores the event responder methods. An example of a responder is like this:

```
responder['event_name'] = function(self, arg)
		...
		return true/false
	end
```

A responder returning **true** will terminate this event for other elements. This may be useful in mouse action events when multiple elements are overlapped and only the top one is allowed to responde.

## Layouts

Having created a new element, you should add it to a layout to take effect.

There are two internal layouts: idle and play. Idle means the "idle-active" status that the player is just started and no file is loaded. Yet play means files are loaded and playing, which is opposite to idle.

Therefore, if an element is added to the idle layout, it only appears when player is idle, like the logo. On contrary, an element added to the play layout shows up when the player is playing.

The related funtions are:

```
function addToIdleLayout(name)      -- add an element to idle layout
function addToPlayLayout(name)      -- add an element to play layout
function addToLayout(layout, name)  -- add an element to a layout
```

Here "name" is the string of your element name, rather than the element table name.

## Events

In this tool, events are identified by name, which is a string, such as 'get_read', 'stop'.

There are two events built in to support this framework: 'resize' and 'idle'. 'resize' happens when the osc dimesions are changed, and 'idle' happens when mpv goes into/out of idle status. 'resize' is very useful to reset the geometry of an element.

Users can generate and dispatch other events using

```
dispatchEvent('event_name', args)
```

This function dispatch events for all layouts. Then the function in **element.responder\['event_name'\]** will be called if it exists for every single element in current layout, except that a responder returns **false** and terminates this event.

## Mouse Action Support

This tool provides basic mouse action support, they are:

	mouse_move/ mouse_leave
	mbtn_left_down/ mbtn_left_up
	mbtn_mid_down/ mbtn_mid_up
	mbtn_right_down/ mbnt_right_up
	mbtn_left_dbl/ mbtn_right_dbl
	wheel_up/ wheel_down

All mouse actions are treated as events. Normally the responder should be like:

```
element.responder['mouse_move'] = function(self, pos)
		local x, y = pos[1], pos[2]
		....
		return true
	end
```

It should be noticed that except for 'mouse_move' and 'mouse_leave', other mouse button events are generated only when the mouse pointer is inside of an 'active area'.

## Active Area

When mouse moves inside of an active area, the osc will be shown if it's faded out. The mouse button key bindings are enabled, and thus mouse button events can be generated.

The active areas for idle and play layouts are different, and both layouts support multiple active areas. The related functions are:

```
function setIdleActiveArea(name, x1, y1, x2, y2)    -- set active area for idle layout
function setIdleActiveArea(name, x1, y1, x2, y2)    -- set active area for play layout
function setActiveArea(layout, name, x1, y1, x2, y2)-- set active area for a layout
```

Here 'name' is the name string of an area, and x1, y1, x2, y2 are left, top right, bottom position of an area.

## Timer

As said, this framework use a periodical timer to call tick() method to update render results. The timing interval is 0.03 seconds by default, which limits the maximum fps to about 33.

This timer also updates a public variable *player.now*. Users may use it to realize some time related functions.

## Visual Effects

This tool uses a fading out effect to hide osc elements. Yet the osc can be "always on" or "hidden forever". The related funcion is:

```
getVisibility()    -- get osc visibility
setVisibility(mode)-- set osc visibility
```

Supported visibility modes are 'normal', 'always', 'hide'. And the fadding effect can be tuned with variables in *opts* table.

## Public Variables

This tool introduces two public tables: *player* and *opts*.

```
player = {
    now = 0,
    geo = {width = 0, height = 0, aspect = 0},
    idle = true,
    }

opts = {
    scale = 1,
    fixedHeight = false,
    hideTimeout = 1,
    fadeDuration = 0.5,
    }
```

*player* table reflects the player status for public access, which is normally generated by your program, and changing their values do not interfere the framework

**now** is the now time of the player in seconds. Users may use this value to do some time related tasks.

**geo** is the geometry of the video area. It is usually used to determine elements' placement.

**idle** is true when player is in idle status. This is used to check if it's using the idle layout.

*opts* table means  user options, and altering them may change osc behavior.

**scale** is the render scale of an element. scale = 2 will double the size of an element.

**fixedHeight** chooses wether to fix the y resolution to 480. On true, all elements will scale with the player window height. On false the window keeps its real y resolution.

**hideTimeout** is the time before the osc starts to hide after mouse leaves all active area. Measured in seconds. A negative value means never hide.

**fadeDuration** is the time length during the fading out effect. Measured in seconds. A negative value means never fade.

## Public Function List

More details can be found in the script.

```
getVisibility()    -- get osc visibility
setVisibility(mode)-- set osc visibility
showOsc()          -- show osc if it's faded out
newElement(name, source)   -- create a new element, either from 'default', or from an existing source
getElement(name)   -- get the table of an element
addToIdleLayout(name)      -- add an element to idle layout
addToPlayLayout(name)      -- add an element to play layout
addToLayout(layout, name)  -- add an element to a layout
dispatchEvent(event, arg)  -- dispatch an event
setIdleActiveArea(name, x1, y1, x2, y2)    -- set active area for idle layout
setPlayActiveArea(name, x1, y1, x2, y2)    -- set active area for play layout
setActiveArea(layout, name, x1, y1, x2, y2)-- set active area for a layout
getMousePos()      -- get mouse position
enableMouseButtonEvents() -- temporarily enable mouse button events
disableMouseButtonEvents()-- temporarily disable mouse button events
```
