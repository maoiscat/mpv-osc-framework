# mpv-osc-framework

a mpv osc framework to help build your custom osc

changelog:

ver 0.5

first release

## Introduction

mpv-osc-framewokr, or oscf, is a simple framework to help building your own osc, as well as sharing codes between different oscs.

The file ''oscf.lua'' provides a core set of functions to run this framework, and another file ''expansion.lua'' provides more functions and elements templates to help building a osc.

A ''mpv-osc-modern'' like osc is realized with this framework, which is coded in ''main.lua''

To try it, you need to make a new folder in ''~~/mpv/scripts'', and download all 3 files there. Remenber to remove other osc scripts. And you will need [material-design-iconic-font](https://zavoloklom.github.io/material-design-iconic-font/) as well.

This oscf provides modularized and event-driven methods to help building your osc. Everything that runs within oscf can be an element, and each element runs individually as a module. This oscf provides an internal timer to schedual periodical tasks, as well as a event dispatcher for event driven tasks. 

