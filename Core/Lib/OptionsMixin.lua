--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local O, LibStub, M = SDNR_LibPack(...)
local GC, AceConfig = O.GlobalConstants, O.AceConfig
local IsEmptyTable = O.LU.Table.isEmpty


--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class OptionsMixin : BaseLibraryObject
local L = LibStub:NewLibrary(M.OptionsMixin)
local p = L.logger;
p:log("Loaded: %s", M.OptionsMixin)

---@param addon SavedDungeonsAndRaid
function L:Init(addon)
    self.addon = addon
end

local function Methods(o)

    function o:CreateOptions()


        AceConfig:RegisterOptionsTable(ADDON_NAME, options, { "abp_options" })
        AceConfigDialog:AddToBlizOptions(ADDON_NAME, ADDON_NAME)
    end

end

Methods(L)