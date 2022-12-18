--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat, unpack = string.format, unpack

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GetBuildInfo, GetAddOnMetadata = GetBuildInfo, GetAddOnMetadata

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local ns = SDNR_Namespace(...)
local O, LibStubLocal, M = ns:LibPack()
local LibStub = O.AceLibStub

local GC = O.GlobalConstants
local Table, String = O.LU.Table, O.LU.String
local toStringSorted, pformat = Table.toStringSorted, O.pformat
local IsBlank, IsAnyOf, IsEmptyTable = String.IsBlank, String.IsAnyOf, Table.isEmpty

---@class SavedDungeonsAndRaid
local A = LibStub("AceAddon-3.0"):NewAddon(ns.name, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
local mt = getmetatable(A) or {}
mt.__tostring = ns.ToStringFunction()
local p = O.Logger:NewLogger()
A.logger = p

--setmetatable(A, mt)
ns['addon'] = A


--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param o SavedDungeonsAndRaid
local function Methods(o)

    O.MainEventHandler:Init(o)

    function o:OnInitialize()
        p:log(10, "Initialized called..")

        self:RegisterSlashCommands()
        self:SendMessage(GC.M.OnAfterInitialize, self)
    end

    function o:RegisterSlashCommands()
        self:RegisterChatCommand("sdnr", "SlashCommands")
    end
    ---@param spaceSeparatedArgs string
    function o:SlashCommands(spaceSeparatedArgs)
        local args = Table.parseSpaceSeparatedVar(spaceSeparatedArgs)
        if IsEmptyTable(args) then
            self:SlashCommand_Help_Handler()
            return
        end

        if IsAnyOf('config', unpack(args)) then
            p:log('TODO: Open Configuration')
            -- self:OpenConfig()
            return
        end
        if IsAnyOf('info', unpack(args)) then
            self:SlashCommand_InfoHandler()
            return
        end
        -- Otherwise, show help
        self:SlashCommand_Help_Handler()
    end

    function o:SlashCommand_InfoHandler() p:log(GC:GetAddonInfoFormatted())
    end

    function o:SlashCommand_Help_Handler()
        p:log('')
        --p:log(GC.C.CONSOLE_HEADER_FORMAT, AVAILABLE_CONSOLE_COMMANDS_TEXT)
        --p:log(USAGE_LABEL)
        --p:log(OPTIONS_LABEL)
        --TODO next localize
        local COMMAND_NONE_TEXT = ":: Shows the config UI (default)"
        local COMMAND_INFO_TEXT = ":: Prints additional addon info"
        local COMMAND_HELP_TEXT = ":: Shows this help"
        local OPTIONS_LABEL = "options"
        local USAGE_LABEL = sformat("usage: %s [%s]", GC.C.CONSOLE_PLAIN, OPTIONS_LABEL)
        p:log(USAGE_LABEL)
        p:log(OPTIONS_LABEL .. ":")
        p:log(GC.C.CONSOLE_OPTIONS_FORMAT, 'config', COMMAND_NONE_TEXT)
        p:log(GC.C.CONSOLE_OPTIONS_FORMAT, 'info', COMMAND_INFO_TEXT)
        p:log(GC.C.CONSOLE_OPTIONS_FORMAT, 'help', COMMAND_HELP_TEXT)
    end
end

local function Constructor()
    Methods(A)
    SDNR = A
end

Constructor()



