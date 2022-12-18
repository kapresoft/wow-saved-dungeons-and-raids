if type(SDNR_DB) ~= "table" then SDNR_DB = {} end
if type(SDNR_LOG_LEVEL) ~= "number" then SDNR_LOG_LEVEL = 1 end
if type(SDNR_DEBUG_MODE) ~= "boolean" then SDNR_DEBUG_MODE = false end


--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
---@type string
local addon
---@type Namespace
local ns
addon, ns = ...

local pformat = Kapresoft_LibUtil.PrettyPrint.pformat
local addonShortName = 'SavedDNR'
local consoleCommand = "sdnr"
local useShortName = true

local LibStub = LibStub

local TOSTRING_ADDON_FMT = '|cfdfefefe{{|r|cfdeab676%s|r|cfdfefefe}}|r'
local TOSTRING_SUBMODULE_FMT = '|cfdfefefe{{|r|cfdeab676%s|r|cfdfefefe::|r|cfdfbeb2d%s|r|cfdfefefe}}|r'

---@param moduleName string
---@param optionalMajorVersion number|string
local function LibName(moduleName, optionalMajorVersion)
    assert(moduleName, "Module name is required for LibName(moduleName)")
    local majorVersion = optionalMajorVersion or '1.0'
    local v = sformat("%s-%s-%s", addon, moduleName, majorVersion)
    return v
end
---@param moduleName string
local function ToStringFunction(moduleName)
    local name = addon
    if useShortName then name = addonShortName end
    if moduleName then return function() return string.format(TOSTRING_SUBMODULE_FMT, name, moduleName) end end
    return function() return string.format(TOSTRING_ADDON_FMT, name) end
end

---@class LocalLibStub
local S = {}

---@param moduleName string
---@param optionalMinorVersion number
function S:NewLibrary(moduleName, optionalMinorVersion)
    ---use Ace3 LibStub here
    ---@type BaseLibraryObject
    local o = LibStub:NewLibrary(LibName(moduleName), optionalMinorVersion or 1)
    assert(o, sformat("Module not found: %s", tostring(moduleName)))
    o.mt = getmetatable(o) or {}
    o.mt.__tostring = ns.ToStringFunction(moduleName)
    setmetatable(o, o.mt)
    ns:Register(moduleName, o)
    ---@type Logger
    local loggerLib = LibStub(LibName(ns.M.Logger), 1)
    o.logger = loggerLib:NewLogger(moduleName)
    return o
end

---@param moduleName string
---@param optionalMinorVersion number
function S:GetLibrary(moduleName, optionalMinorVersion) return LibStub(LibName(moduleName), optionalMinorVersion or 1) end

S.mt = { __call = function (_, ...) return S:GetLibrary(...) end }
setmetatable(S, S.mt)

--[[-----------------------------------------------------------------------------
GlobalConstants
-------------------------------------------------------------------------------]]
---@class GlobalConstants
local L = LibStub:NewLibrary(LibName('GlobalConstants'), 1)

---@param o GlobalConstants
local function GlobalConstantProperties(o)

    local consoleCommandTextFormat = '|cfd2db9fb%s|r'
    local consoleKeyValueTextFormat = '|cfdfbeb2d%s|r: %s'
    local command = sformat("/%s", consoleCommand)

    ---@class GlobalAttributes
    local C = {
        CHECK_VAR_SYNTAX_FORMAT = '|cfdeab676%s ::|r %s',
        CONSOLE_HEADER_FORMAT = '|cfdeab676### %s ###|r',
        CONSOLE_OPTIONS_FORMAT = '  - %-8s|cfdeab676:: %s|r',

        CONSOLE_COMMAND_TEXT_FORMAT = consoleCommandTextFormat,
        CONSOLE_KEY_VALUE_TEXT_FORMAT = consoleKeyValueTextFormat,

        CONSOLE_PLAIN = command,
        COMMAND      = sformat(consoleCommandTextFormat, command),
        HELP_COMMAND = sformat(consoleCommandTextFormat, command .. ' help'),
    }

    ---@class EventNames
    local E = {
        OnEnter = 'OnEnter',
        OnEvent = 'OnEvent',
        OnLeave = 'OnLeave',
        OnModifierStateChanged = 'OnModifierStateChanged',
        OnDragStart = 'OnDragStart',
        OnDragStop = 'OnDragStop',
        OnMouseUp = 'OnMouseUp',
        OnMouseDown = 'OnMouseDown',
        OnReceiveDrag = 'OnReceiveDrag',

        PLAYER_ENTERING_WORLD = 'PLAYER_ENTERING_WORLD',
    }
    local function newMessage(name) return sformat('%s::' .. name, addonShortName)  end
    ---@class MessageNames
    local M = {
        OnAfterInitialize = newMessage('OnAfterInitialize'),
        OnAddonReady = newMessage('OnAddonReady'),
    }

    o.C = C
    o.E = E
    o.M = M
end

---@param o GlobalConstants
local function Methods(o)
    --  TODO
end

GlobalConstantProperties(L)
Methods(L)

ns.LibName = LibName
ns.ToStringFunction = ToStringFunction
ns.LibStub = S