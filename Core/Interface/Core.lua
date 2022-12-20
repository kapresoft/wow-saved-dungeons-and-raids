---@class BaseLibraryObject
local BaseLibrary = {
    ---@type table
    mt = { __tostring = function() end },
    ---@type LoggerInterface
    logger = {}
}

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
