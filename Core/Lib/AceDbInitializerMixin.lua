--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local O, LibStub, M = SDNR_LibPack(...)
local GC, AceDB = O.GlobalConstants, O.AceDB
local IsEmptyTable = O.LU.Table.isEmpty
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class AceDbInitializerMixin : BaseLibraryObject
local L = LibStub:NewLibrary(M.AceDbInitializerMixin)
local p = L.logger;
p:log("Loaded: %s", M.AceDbInitializerMixin)

---@param addon SavedDungeonsAndRaid
function L:Init(addon)
    self.addon = addon
    self.addon.db = AceDB:New(GC.C.DB_NAME)
    self.addon.dbInit = self
    self.db = self.addon.db
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

    ---@return AceDB
    function o:GetDB() return self.addon.db end

    function o:Initialize()
        p:log('InitializeDb called...')
        AddonCallbackMethods(self.addon)

        self.db.RegisterCallback(self.addon, "OnProfileChanged", "OnProfileChanged")
        self.db.RegisterCallback(self.addon, "OnProfileReset", "OnProfileChanged")
        self.db.RegisterCallback(self.addon, "OnProfileCopied", "OnProfileChanged")
        self:InitDbDefaults()
    end

    function o:InitDbDefaults()
        local profileName = self.addon.db:GetCurrentProfile()
        local defaultProfile = {
            enable= true
        }
        local defaults = { profile = defaultProfile }
        self.db:RegisterDefaults(defaults)
        self.addon.profile = self.db.profile
        local wowDB = _G[GC.C.DB_NAME]
        if IsEmptyTable(wowDB.profiles[profileName]) then wowDB.profiles[profileName] = defaultProfile end
        self.addon.profile.enable = false
        p:log(1, 'Profile: %s', self.db:GetCurrentProfile())
    end
end

Methods(L)

