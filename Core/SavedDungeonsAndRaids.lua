--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local LibStub = LibStub
local Table = Kapresoft_LibUtil.Table
local toStringSorted = Table.toStringSorted
local addon, ns = ...
---@class SavedDungeonsAndRaid
local A = LibStub("AceAddon-3.0"):NewAddon(addon, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
local mt = getmetatable(A)
if mt then
    mt.__tostring = function() return sformat('{{%s}}', addon) end
end
--setmetatable(A, mt)
ns['addon'] = A

local function s_replace(str, match, replacement)
    if type(str) ~= 'string' then return nil end
    return str:gsub("%" .. match, replacement)
end
local function ShouldLog(level)
    assert(type(level) == 'number', 'Level should be a number between 1 and 100')
    local function GetLogLevel() return SDNR_LOG_LEVEL or 0 end
    if GetLogLevel() >= level then return true end
    return false
end
local function ArgToString(any, optionalStringFormatSafe)
    local text
    if type(any) == 'table' then text = self:format(any) else text = tostring(any) end
    if optionalStringFormatSafe == true then
        return s_replace(text, '%', '$')
    end
    return text
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param o SavedDungeonsAndRaid
local function Methods(o)

end

---@param o SavedDungeonsAndRaid
local function RegisterEvents(o)

end

local function Constructor()

    Methods(A)
    RegisterEvents(A)

    A:Print('loaded:', addon)
    A:Printf('Namespace keys: %s', pformat(Table.getSortedKeys(ns)))

    SDNR = A
end

Constructor()



