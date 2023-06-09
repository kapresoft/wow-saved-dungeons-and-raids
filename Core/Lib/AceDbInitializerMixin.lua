--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...
local O, LibStub, M, GC = ns.O, ns.LibStub, ns.M, ns.O.GlobalConstants
local LibUtil = ns.Kapresoft_LibUtil
local AceDB = O.AceLibrary.AceDB
local IsEmptyTable = O.LU.Table.isEmpty
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class AceDbInitializerMixin : BaseLibraryObject
local L = LibStub:NewLibrary(M.AceDbInitializerMixin)
local p = L.logger;

--- Called by Mixin Automatically
--- @param addon SavedDungeonsAndRaid
function L:Init(addon)
    self.addon = addon
    local newAceDB = AceDB:New(GC.C.DB_NAME)
    self.db = function() return newAceDB end
    self.addon.db = self.db
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param a SavedDungeonsAndRaid
local function AddonCallbackMethods(a)
    function a:OnProfileChanged()
        p:log('OnProfileChanged called...')
    end
    function a:OnProfileChanged()
        p:log('OnProfileReset called...')
    end
    function a:OnProfileChanged()
        p:log('OnProfileCopied called...')
    end
end

---@param o AceDbInitializerMixin
local function Methods(o)

    --- Usage:  local instance = AceDbInitializerMixin:New(addon)
    --- @param addon SavedDungeonsAndRaid
    --- @return AceDbInitializerMixin
    function o:New(addon) return LibUtil:CreateAndInitFromMixin(o, addon) end

    ---@return AceDB
    function o:GetDB() return self.addon.db() end

    function o:InitDb()
        p:log(100, 'Initialize called...')
        AddonCallbackMethods(self.addon)
        self.db().RegisterCallback(self.addon, "OnProfileChanged", "OnProfileChanged")
        self.db().RegisterCallback(self.addon, "OnProfileReset", "OnProfileChanged")
        self.db().RegisterCallback(self.addon, "OnProfileCopied", "OnProfileChanged")
        self:InitDbDefaults()
    end

    function o:InitDbDefaults()
        local profileName = self.addon.db():GetCurrentProfile()
        local defaultProfile = {}
        local defaults = { profile = defaultProfile }
        self.db():RegisterDefaults(defaults)
        local wowDB = _G[GC.C.DB_NAME]
        if IsEmptyTable(wowDB.profiles[profileName]) then wowDB.profiles[profileName] = defaultProfile end
        self.db().profile.enable = false
        p:log(5, 'Profile: %s', self.db():GetCurrentProfile())
    end
end

Methods(L)

