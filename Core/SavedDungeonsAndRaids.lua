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
local GC, SavedInstances, ACE = O.GlobalConstants, O.SavedInstances, O.AceLibrary
local AceConfig, AceConfigDialog = ACE.AceConfig, ACE.AceConfigDialog

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

---@type AceDB
A.db = nil


--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]

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

        O.AceDbInitializerMixin:New(self):InitDb()
        O.OptionsMixin:New(self):InitOptions()
    end

    ---@param level number
    function o:LogLevel(level) SDNR_LOG_LEVEL = level or 0 end

    function o:BINDING_SDNR_OPTIONS_DLG() self:OpenConfig() end

    function o:RegisterHooks()
        SavedInstances:RegisterConsoleHooks()
    end

    function o:RegisterSlashCommands()
        self:RegisterChatCommand("sdnr", "SlashCommands")
    end
    ---@param spaceSeparatedArgs string
    function o:SlashCommands(spaceSeparatedArgs)
        local args = Table.parseSpaceSeparatedVar(spaceSeparatedArgs)
        if IsEmptyTable(args) then
            self:SlashCommand_Help_Handler(); return
        end
        --if IsAnyOf('config', unpack(args)) or IsAnyOf('conf', unpack(args)) then
        --    self:SlashCommand_OpenConfig(); return
        --end
        if IsAnyOf('info', unpack(args)) then
            self:SlashCommand_InfoHandler(); return
        end
        if IsAnyOf('list', unpack(args)) then
            self:SlashCommand_ListSavedInstances(); return
        end
        -- Otherwise, show help
        self:SlashCommand_Help_Handler()
    end

    function o:SlashCommand_OpenConfig() o:OpenConfig() end

    function o:SlashCommand_ListSavedInstances()
        SavedInstances:ReportSavedInstances()
    end

    function o:SlashCommand_InfoHandler() p:log(GC:GetAddonInfoFormatted()) p:log(GC:GetAddonInfoFormatted()) end

    function o:SlashCommand_Help_Handler()
        p:log('')
        --p:log(GC.C.CONSOLE_HEADER_FORMAT, AVAILABLE_CONSOLE_COMMANDS_TEXT)
        --p:log(USAGE_LABEL)
        --p:log(OPTIONS_LABEL)
        --TODO next localize
        local COMMAND_INFO_TEXT = ":: Prints additional addon info"
        local COMMAND_LIST_TEXT = ":: Prints the saved dungeons and raids on the console"
        local COMMAND_CONFIG_TEXT = ":: Shows the config UI"
        local COMMAND_HELP_TEXT = ":: Shows this help"
        local OPTIONS_LABEL = "options"
        local USAGE_LABEL = sformat("usage: %s [%s]", GC.C.CONSOLE_PLAIN, OPTIONS_LABEL)
        p:log(USAGE_LABEL)
        p:log(OPTIONS_LABEL .. ":")
        p:log(GC.C.CONSOLE_OPTIONS_FORMAT, 'list', COMMAND_LIST_TEXT)
        --p:log(GC.C.CONSOLE_OPTIONS_FORMAT, 'config', COMMAND_CONFIG_TEXT)
        p:log(GC.C.CONSOLE_OPTIONS_FORMAT, 'info', COMMAND_INFO_TEXT)
        p:log(GC.C.CONSOLE_OPTIONS_FORMAT, 'help', COMMAND_HELP_TEXT)
    end

    function o:OpenConfig()
        AceConfigDialog:Open(ns.name)
        self.onHideHooked = self.onHideHooked or false
        self.configDialogWidget = AceConfigDialog.OpenFrames[ns.name]

        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
        if not self.onHideHooked then
            --self:HookScript(self.configDialogWidget.frame, 'OnHide', 'OnHide_Config_WithSound')
            --self.onHideHooked = true
        end
    end
end

local function Constructor()
    Methods(A)
    SDNR = A
    _G[ns.name] = A
end

Constructor()
