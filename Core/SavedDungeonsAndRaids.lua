--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local ns = SDNR_Namespace(...)
local O = ns:LibPack()
local LibStub = LibStub
local Table = O.Table
local toStringSorted = Table.toStringSorted
local pformat = O.pformat

---@class SavedDungeonsAndRaid
local A = LibStub("AceAddon-3.0"):NewAddon(ns.name, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
local mt = getmetatable(A) or {}
mt.__tostring = ns.ToStringFunction()

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

    A:Print('loaded:', ns.name)
    A:Printf('Namespace keys: %s', ns:ToStringNamespaceKeys())
    A:Printf('Namespace Object keys: %s', ns:ToStringObjectKeys())

    SDNR = A
end

Constructor()



