--[[-----------------------------------------------------------------------------
Interface
-------------------------------------------------------------------------------]]

---@class LibStub
local _LibStub = {

    ---@param self LibStub
    ---@param major string
    ---@param minor number|string
    NewLibrary = function (self, major, minor) end,

    ---@param self LibStub
    ---@param major string
    ---@param minor number|string
    GetLibrary = function (self, major, minor) end,

}
setmetatable(_LibStub, { __call = _LibStub.GetLibrary })

---@class LoggerInterface
local LoggerInterface = {}
---@param format string The string format. Example: logger:log('hello: %s', 'world')
function LoggerInterface:log(format, ...)  end

---@class MainEventHandlerFrame : _Frame
local MainEventHandlerFrame = {
    ---@type MainEventContext
    ctx = {}
}

---@class MainEventContext
local EventFrameWidgetInterface = {
    ---@type MainEventHandlerFrame
    frame = {},
    ---@type SavedDungeonsAndRaid
    addon = {},
}
--[[-----------------------------------------------------------------------------
AceConsole
-------------------------------------------------------------------------------]]
---@class AceConsole
local AceConsole_Interface = {
    -- Embeds AceConsole into the target object making the functions from the mixins list available on target:..
    ---@param self AceConsole
    ---@param target any object to embed AceBucket in
    Embed = function(self, target)  end
}
--[[-----------------------------------------------------------------------------
AceEvent - https://www.wowace.com/projects/ace3/pages/api/ace-event-3-0
-------------------------------------------------------------------------------]]

---@class AceEvent
local AceEvent_Interface = {
    --AceEvent:RegisterMessage(message[, callback [, arg]])
    ---@param self AceEvent
    ---@param message string
    ---@param callback fun(event:string, ...) : void
    RegisterMessage = function(self, message, callback, ...)  end
}
