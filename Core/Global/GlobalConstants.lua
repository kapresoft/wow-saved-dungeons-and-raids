if type(SDNR_DB) ~= "table" then SDNR_DB = {} end
if type(SDNR_LOG_LEVEL) ~= "number" then SDNR_LOG_LEVEL = 1 end
if type(SDNR_DEBUG_MODE) ~= "boolean" then SDNR_DEBUG_MODE = false end

--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GetAddOnMetadata = GetAddOnMetadata
local date = date

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type string
local addon
--- @type Namespace
local ns
addon, ns = ...

local addonShortName = 'SavedDNR'
local consoleCommand = "sdnr"
local useShortName = true

local LibStub = LibStub

local ADDON_INFO_FMT = '%s|cfdeab676: %s|r'
local TOSTRING_ADDON_FMT = '|cfdfefefe{{|r|cfdeab676%s|r|cfdfefefe}}|r'
local TOSTRING_SUBMODULE_FMT = '|cfdfefefe{{|r|cfdeab676%s|r|cfdfefefe::|r|cfdfbeb2d%s|r|cfdfefefe}}|r'

local function formatColor(color, text) return sformat('|cfd%s%s|r', color, text) end

local RED_COLOR = 'FF0000'
local ErrorText = 'ERROR'
local errorTextWithColor = formatColor(RED_COLOR, ErrorText)

--- @param moduleName string
--- @param optionalMajorVersion number|string
local function LibName(moduleName, optionalMajorVersion)
    assert(moduleName, "Module name is required for LibName(moduleName)")
    local majorVersion = optionalMajorVersion or '1.0'
    local v = sformat("%s-%s-%s", addon, moduleName, majorVersion)
    return v
end
--- @param moduleName string
local function ToStringFunction(moduleName)
    local name = addon
    if useShortName then name = addonShortName end
    if moduleName then return function() return string.format(TOSTRING_SUBMODULE_FMT, name, moduleName) end end
    return function() return string.format(TOSTRING_ADDON_FMT, name) end
end

--[[-----------------------------------------------------------------------------
GlobalConstants
-------------------------------------------------------------------------------]]
--- @class GlobalConstants
local L = LibStub:NewLibrary(LibName('GlobalConstants'), 1)

--- @param o GlobalConstants
local function GlobalConstantProperties(o)

    local consoleCommandTextFormat = '|cfd2db9fb%s|r'
    local consoleKeyValueTextFormat = '|cfdfbeb2d%s|r: %s'
    local command = sformat("/%s", consoleCommand)

    --- @class GlobalAttributes
    local C = {
        DB_NAME = 'SDNR_DB',
        CHECK_VAR_SYNTAX_FORMAT = '|cfdeab676%s ::|r %s',
        CONSOLE_HEADER_FORMAT = '|cfdeab676### %s ###|r',
        CONSOLE_OPTIONS_FORMAT = '  - %-8s|cfdeab676:: %s|r',

        CONSOLE_COMMAND_TEXT_FORMAT = consoleCommandTextFormat,
        CONSOLE_KEY_VALUE_TEXT_FORMAT = consoleKeyValueTextFormat,

        CONSOLE_PLAIN = command,
        COMMAND      = sformat(consoleCommandTextFormat, command),
        HELP_COMMAND = sformat(consoleCommandTextFormat, command .. ' help'),

        --- @see https://wowpedia.fandom.com/wiki/API_GetDifficultyInfo
        --- @see https://wowpedia.fandom.com/wiki/DifficultyID

        --- @table<string, InstanceDifficulty>
        INSTANCE_DIFFICULTY = {
            --- @type InstanceDifficulty
            Normal = { id = 1, name = 'Normal' },
            --- @type InstanceDifficulty
            Heroic = { id = 2, name = 'Heroic' },
            --- @type InstanceDifficulty
            Normal_10Player = { id = 3, name = '10 Player' },
            --- @type InstanceDifficulty
            Normal_25Player = { id = 4, name = '25 Player' },
            --- @type InstanceDifficulty
            Heroic_10Player = { id = 5, name = '10 Player (Heroic)' },
            --- @type InstanceDifficulty
            Heroic_25Player = { id = 6, name = '25 Player (Heroic)' },
        },
        DEBUG_LFG_PRE_RETAIL_DEBUG_HOOK_ENABLED = false,
    }

    local DAILY_DUNGEON_QUESTS = {
        --- @type table<QuestID, LFGActivities> Beta, Alpha, Heroic
        HEROIC_ACTIVITIES = {
            [13248] = { 1210, 1204, 1125 }, -- UP / Ymiron
            [13245] = { 1211, 1207, 1122 }, -- UK / Ingvar
            [13247] = { 1212, 1205, 1124 }, -- Oculus / Ley Line
            [13256] = { 1212, 1205, 1124 }, -- Oculus / Cyanigosa
            [13246] = { 1213, 1197, 1132 }, -- Nexus / Keristrasza
            [13251] = { 1214, 1203, 1126 }, -- CoS / Mal'Ganis
            [13252] = { 1215, 1201, 1128 }, -- HoS / Sjonnir
            [13253] = { 1216, 1202, 1127 }, -- HoL / Loken
            [13250] = { 1217, 1199, 1130 }, -- Gun / Gal'darah
            [13249] = { 1218, 1200, 1129 }, -- DTK / Prophet
            [13254] = { 1219, 1219, 1121 }, -- AN / Anub'arak
            [13255] = { 1220, 1220, 1131 }, -- OK / Volazj
            [14199] = { 1238, -1, 1133 },   -- ToC / Black Night
        },

        --- only 1 normal instance
        --- @type table<QuestID, LFGActivityID>
        NORMAL_ACTIVITIES = {
            [13240] = 1067, -- Oc
            [13241] = 1075, -- UP
            [13243] = 1065, -- CoS
            [13244] = 1068, -- HoL
        },
    }

    --- @class EventNames
    local E = {
        OnClick = 'OnClick',
        OnDragStart = 'OnDragStart',
        OnDragStop = 'OnDragStop',
        OnEnter = 'OnEnter',
        OnEvent = 'OnEvent',
        OnLeave = 'OnLeave',
        OnModifierStateChanged = 'OnModifierStateChanged',
        OnMouseDown = 'OnMouseDown',
        OnMouseUp = 'OnMouseUp',
        OnReceiveDrag = 'OnReceiveDrag',
        OnShow = 'OnShow',

        -- Blizzard Events
        PLAYER_ENTERING_WORLD = 'PLAYER_ENTERING_WORLD',
        UPDATE_INSTANCE_INFO = 'UPDATE_INSTANCE_INFO',
    }
    local function newMessage(name) return sformat('%s::' .. name, addonShortName)  end
    --- @class MessageNames
    local M = {
        OnAfterInitialize = newMessage('OnAfterInitialize'),
        OnAddonReady = newMessage('OnAddonReady'),
    }

    o.C = C
    o.E = E
    o.M = M
    o.DAILY_DUNGEON_QUESTS = DAILY_DUNGEON_QUESTS

end

--- @param o GlobalConstants
local function Methods(o)

    function o:GetAceLocale() return LibStub("AceLocale-3.0"):GetLocale(addon, true) end

    --- ### Usage
    --- ```
    --- GC:safecall(function(arg1) print('arg1:', arg1); print(arg1x()) --- end, "myarg1")
    --- .OnError(function(errorMsg) print('Error msg:', errorMsg) end)
    --- .Exec()
    ---
    --- - OR Use the built-in error function handler -
    ---
    --- GC:safecall(function(arg1) print('arg1:', arg1); print(arg1x()) --- end, "myarg1")
    --- .Exec()
    --- ```
    --- @param func SafeCallFn
    --- @vararg any The target function arguments
    --- @return FluentSafeCall
    function o:Safecall(func, ...)
        local args = { ... }
        --- @type FluentSafeCall
        local h = {
            func = func,
            --- @type FluentSafeCallExecute
            Exec = function() xpcall( func,
                    function(errorMsg) ns.O.Logger:NewLogger(errorTextWithColor):log(errorMsg) end,
                    unpack(args) )
            end,
            --- @param errorFn FluentErrorHandlerFn
            OnError = function(errorFn)
                return { Exec = function() xpcall(func, errorFn, unpack(args)) end }
            end
        }

        return h
    end

    function o:GetLogName()
        local logName = addon
        if useShortName then logName = addonShortName end
        return logName
    end

    ---#### Example
    ---```
    ---local version, curseForge, issues, repo, lastUpdate, wowInterfaceVersion = GC:GetAddonInfo()
    ---```
    --- @return string, string, string, string, string, string
    function o:GetAddonInfo()
        local versionText, lastUpdate
        --@non-debug@
        versionText = GetAddOnMetadata(ns.name, 'Version')
        lastUpdate = GetAddOnMetadata(ns.name, 'X-Github-Project-Last-Changed-Date')
        --@end-non-debug@
        --@debug@
        versionText = '1.0.x.dev'
        lastUpdate = date("%m/%d/%y %H:%M:%S")
        --@end-debug@
        local wowInterfaceVersion = select(4, GetBuildInfo())

        return versionText, GetAddOnMetadata(ns.name, 'X-CurseForge'),
            GetAddOnMetadata(ns.name, 'X-Github-Issues'),
            GetAddOnMetadata(ns.name, 'X-Github-Repo'),
            lastUpdate, wowInterfaceVersion
    end

    function o:GetAddonInfoFormatted()
        local C = self:GetAceLocale()
        local version, curseForge, issues, repo, lastUpdate, wowInterfaceVersion = self:GetAddonInfo()
        return sformat(C['Addon Info'] .. ":\n%s\n%s\n%s\n%s\n%s\n%s\n%s",
                sformat(ADDON_INFO_FMT, C['Version'], version),
                sformat(ADDON_INFO_FMT, C['Curse-Forge'], curseForge),
                sformat(ADDON_INFO_FMT, C['Bugs'], issues),
                sformat(ADDON_INFO_FMT, C['Repo'], repo),
                sformat(ADDON_INFO_FMT, C['Last-Update'], lastUpdate),
                sformat(ADDON_INFO_FMT, C['Interface-Version'], wowInterfaceVersion),
                sformat(ADDON_INFO_FMT, C['Locale'], GetLocale())
        )
    end

end

GlobalConstantProperties(L)
Methods(L)

ns.LibName = LibName
ns.ToStringFunction = ToStringFunction
