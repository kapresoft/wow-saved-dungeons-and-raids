--[[-----------------------------------------------------------------------------
Namespace
-------------------------------------------------------------------------------]]
--- @class Namespace : LibPackMixin
local Namespace = {
    ---Usage:
    ---```
    ---local GC = LibStub(LibName('GlobalConstants'), 1)
    ---```
    --- @type fun(moduleName:string, optionalMajorVersion:string)
    --- @return string The full LibStub library name. Example:  'SavedDungeonsAndRaids-GlobalConstants-1.0.1'
    LibName = {},

    --- @type LocalLibStub
    LibStub = {},
    --- @type LibStub
    LibStubAce = {},
    ---Usage:
    ---```
    ---local L = {}
    ---local mt = { __tostring = ns.ToStringFunction() }
    ---setmetatable(mt, L)
    ---```
    --- @type fun(moduleName:string)
    ToStringFunction = {},

}
--[[-----------------------------------------------------------------------------
Others
-------------------------------------------------------------------------------]]
--- @class BaseLibraryObject
local BaseLibrary = {
    --- @type table
    mt = { __tostring = function() end },
    --- @type LoggerInterface
    logger = {}
}
--- @class BaseLibraryObject_WithAceEvent : AceEvent
local BaseLibraryWithAceEvent = {
    --- @type table
    mt = { __tostring = function() end },
    --- @type LoggerInterface
    logger = {}
}

--- @class MainEventHandlerFrame : _Frame
local MainEventHandlerFrame = {
    --- @type MainEventContext
    ctx = {}
}

--- @class MainEventContext
local EventFrameWidgetInterface = {
    --- @type MainEventHandlerFrame
    frame = {},
    --- @type SavedDungeonsAndRaid
    addon = {},
}
