# mpv-osc-framework

a mpv osc framework to help building your custom osc

changelog:

ver 0.5

first release

## Introduction

mpv-osc-framewokr, or oscf, is a simple framework to help building your own osc, as well as sharing codes between different oscs.

The file ''oscf.lua'' provides a core set of functions to run this framework, and another file ''expansion.lua'' provides more functions and elements templates to help building a osc.

A ''mpv-osc-modern'' like osc is realized with this framework, which is coded in ''main.lua''

To try it, you need to make a new folder in ''~~/mpv/scripts'', and download all 3 files there. Remenber to remove other osc scripts. And you will need [material-design-iconic-font](https://zavoloklom.github.io/material-design-iconic-font/) as well.

This oscf provides modularized and event-driven methods to help building your osc. Everything that runs within oscf can be an element, and each element runs individually as a module. This oscf provides an internal timer to schedual periodical tasks, as well as a event dispatcher for event driven tasks. 

## Elements

Elements are basic units of the osc. An element can be a button, a shape, or even an invisible updater. The default element is already defined in the code. The most important part is the tick() function and the responder table.

Function tick() periodically updates the render codes to the framework, which is controlled by the system timer. The render codes are stored in ''pack'' table. pack[1] stores position codes, pack[2] style codes, and pack[3] and after are drawing/text content codes. There are setPos(), setStyle(), and render() functions to update them respectively. The result codes are in ASS format. MPV provides mp.assdraw package to generate drawing codes. 

responder is a table of functions related to different events. Events are dispatch by dispatchEvent() function. Each event is named by a string, and the responder function of the event is called.

## Layouts

An element is added to a layout to take effect. There are two sets of layout, idle and play. As they are named, the idle layout is used when player in idle status, and play for playing status(file loaded, or none idle)

## Events

Two events are built in to support this framework, ''resize'' and ''idle''. ''resize'' happens when the osc dimesions are changed, and ''idle'' happens when mpv goes into/out of idle status. ''resize'' is very useful to reset the geometry of an element. An element respond to an event with its responder, like
```
element.responder['event_name'] = function(self, args) ... return true/end end
```
if an event is dispatched like
```
dispatchEvent('event_name', args)
```
, the responder will be called. The responder should always return true/false/nil. If the return is true, it terminates this event for other responders. This could be useful for overlaped elements that a mouse button actions only active the top one.

This framework provides basic mouse action support, including mouse_move, mouse_leave, mbtn_left/right/mid_down/up, wheel_up/down actions. They are all triggered as events.

## Timer

This framework use a timer to update elements render codes periodically. The period is no shorter than 0.03 seconds by default.

## Active Area

Active Area is the area that activates the osc and mouse button actions. Use setActiveArea() functions to set an active area.

## Usage

This framework is a libray or package to support further osc codes. As the [manual](https://mpv.io/manual/master/#script-location) says, make a folder in ''scripts'', like ''scripts/osc''. Then put oscf.lua in this folder, and maker another ''main.lua'' as the entry script. In ''main.lua'', use
```
require 'oscf'
```
to enable the framework.

NOTICE: This work is still under development. You may suffer from unkown bugs, and the script may subject to further changes.

## Public Function List

More details can be found in the script.

```
function setOsd(text)       -- set osd display

function getVisibility()    -- get osc visibility

function setVisibility(mode)-- set osc visibility

function showOsc()          -- show osc if it's faded out

function newElement(name, source)   -- create a new element, either from 'default', or from an existing source

function getElement(name)   -- get the table of an element

function addToIdleLayout(name)      -- add an element to idle layout

function addToPlayLayout(name)      -- add an element to play layout

function addToLayout(layout, name)  -- add an element to a layout

function dispatchEvent(event, arg)  -- dispatch an event

function setIdleActiveArea(name, x1, y1, x2, y2)    -- set active area for idle layout

function setIdleActiveArea(name, x1, y1, x2, y2)    -- set active area for play layout

function setActiveArea(layout, name, x1, y1, x2, y2)-- set active area for a layout

function getMousePos()      -- get mouse position

function enableMouseButtonEvents() -- temporarily enable mouse button events

function disableMouseButtonEvents()-- temporarily disable mouse button events
```
